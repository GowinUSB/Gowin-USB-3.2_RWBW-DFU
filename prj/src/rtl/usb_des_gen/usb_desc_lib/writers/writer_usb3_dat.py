import ctypes
import os

def _get_size(obj):
    return len(obj) if isinstance(obj, bytes) else ctypes.sizeof(obj)

def _auto_patch_lengths(desc_data):
    """自动计算全局配置长度与 BOS 长度"""
    # 1. HS 配置修补
    hs_cfg = desc_data.get('hs_cfg')
    hs_payload = desc_data.get('hs_payload', [])
    if hs_cfg and hs_payload:
        hs_cfg.wTotalLength = ctypes.sizeof(hs_cfg) + sum(_get_size(x) for x in hs_payload)

        unique_interfaces = set()
        for i, item in enumerate(hs_payload):
            desc_type = getattr(item, 'bDescriptorType', -1)
            
            # 统计接口数量
            if desc_type == 0x04:
                unique_interfaces.add(getattr(item, 'bInterfaceNumber', -1))
                
            # 嗅探 IAD 接口关联
            elif desc_type == 0x0B:
                iad_intfs = set()
                for j in range(i + 1, len(hs_payload)):
                    sub_item = hs_payload[j]
                    sub_type = getattr(sub_item, 'bDescriptorType', -1)
                    if sub_type == 0x0B: break
                    if sub_type == 0x04: iad_intfs.add(getattr(sub_item, 'bInterfaceNumber', -1))
                if hasattr(item, 'bInterfaceCount'): item.bInterfaceCount = len(iad_intfs)
                if hasattr(item, 'bFirstInterface') and iad_intfs: item.bFirstInterface = min(iad_intfs)
                
            # 嗅探 UVC / UAC 局部头部，自动推导 Class-Specific 数据总长
            elif desc_type == 0x24 and hasattr(item, 'wTotalLength'):
                class_total_len = 0
                for j in range(i, len(hs_payload)):
                    sub_item = hs_payload[j]
                    sub_type = getattr(sub_item, 'bDescriptorType', -1)
                    # 遇到标准接口(0x04)、标准端点(0x05) 或 IAD(0x0B) 说明当前类特定块结束
                    if j > i and sub_type in (0x04, 0x05, 0x0B): 
                        break
                    class_total_len += _get_size(sub_item)
                item.wTotalLength = class_total_len
                
        if hasattr(hs_cfg, 'bNumInterfaces'):
            hs_cfg.bNumInterfaces = len(unique_interfaces)

    # 2. DFU 配置修补
    dfu_cfg = desc_data.get('dfu_cfg')
    dfu_payload = desc_data.get('dfu_payload', [])
    if dfu_cfg and dfu_payload:
        dfu_cfg.wTotalLength = ctypes.sizeof(dfu_cfg) + sum(_get_size(x) for x in dfu_payload)

    # 3. BOS 修补 (APP 模式)
    bos_head = desc_data.get('bos_head')
    bos_caps = desc_data.get('bos_caps', [])
    if bos_head:
        if hasattr(bos_head, 'wTotalLength'):
            bos_head.wTotalLength = _get_size(bos_head) + sum(_get_size(cap) for cap in bos_caps)
        if hasattr(bos_head, 'bNumDeviceCaps'):
            bos_head.bNumDeviceCaps = len(bos_caps)

    # 4. BOS 修补 (DFU 模式)
    dfu_bos_head = desc_data.get('dfu_bos_head')
    dfu_bos_caps = desc_data.get('dfu_bos_caps', [])
    if dfu_bos_head:
        if hasattr(dfu_bos_head, 'wTotalLength'):
            dfu_bos_head.wTotalLength = _get_size(dfu_bos_head) + sum(_get_size(cap) for cap in dfu_bos_caps)
        if hasattr(dfu_bos_head, 'bNumDeviceCaps'):
            dfu_bos_head.bNumDeviceCaps = len(dfu_bos_caps)


def _process_block_to_dat(block_bytes):
    """按 8 字节对齐补零，并进行 64-bit 逆序打包"""
    lines = []
    data = bytearray(block_bytes)
    remainder = len(data) % 8
    if remainder != 0:
        data.extend([0x00] * (8 - remainder))
        
    for i in range(0, len(data), 8):
        chunk = data[i:i+8]
        reversed_chunk = chunk[::-1]
        lines.append("".join([f"{b:02X}" for b in reversed_chunk]))
    return lines

def _concat_block(key, desc_data):
    """安全提取并拼接块数据"""
    block = desc_data.get(key, [])
    if not isinstance(block, list):
        block = [block]
    return b"".join([bytes(b) for b in block])


def generate_usb3_dat_files(desc_data, strings_config, prefix="USB3_2_desc", output_dir="output"):
    _auto_patch_lengths(desc_data)
    os.makedirs(output_dir, exist_ok=True)
    dat_path = os.path.join(output_dir, f"{prefix}.dat")
    vh_path = os.path.join(output_dir, f"{prefix}_params.vh")
    
    # === 1. 数据块提取与拼接 (严格遵循要求的物理顺序) ===
    blocks = {}
    blocks['device'] = bytes(desc_data['dev_desc'])
    blocks['config'] = bytes(desc_data['hs_cfg']) + b"".join([bytes(b) for b in desc_data.get('hs_payload', [])])
    blocks['bos'] = bytes(desc_data['bos_head']) + b"".join([bytes(b) for b in desc_data.get('bos_caps', [])])
    
    # 字符串提取
    blocks['str0'] = bytes(desc_data['lang_bytes'])
    str_lengths = {'STR0': len(blocks['str0'])}
    str_data_lines = []
    for i, (key, text) in enumerate(strings_config.items(), start=1):
        if key == "MSFT": continue
        utf16_bytes = text.encode('utf-16le')
        str_desc = bytes([len(utf16_bytes) + 2, 0x03]) + utf16_bytes
        blocks[f'str{i}'] = str_desc
        str_lengths[f'STR{i}'] = len(str_desc)
    
    blocks['msft'] = bytes(desc_data['msft_string'])
    
    # DFU 与 MS OS 解析
    blocks['dfu_device'] = bytes(desc_data.get('dfu_dev', b''))
    blocks['dfu_config'] = bytes(desc_data.get('dfu_cfg', b'')) + b"".join([bytes(b) for b in desc_data.get('dfu_payload', [])])
    
    blocks['msos10_app_compat'] = _concat_block('msos10_app_compat', desc_data)
    blocks['msos10_app_ext0'] = _concat_block('msos10_app_ext0', desc_data)
    blocks['msos10_app_ext1'] = _concat_block('msos10_app_ext1', desc_data)
    blocks['msos20_app_desc'] = _concat_block('msos20_app_desc', desc_data)
    
    blocks['dfu_bos'] = bytes(desc_data.get('dfu_bos_head', b'')) + b"".join([bytes(b) for b in desc_data.get('dfu_bos_caps', [])])
    blocks['msos10_dfu_compat'] = _concat_block('msos10_dfu_compat', desc_data)
    blocks['msos10_dfu_ext0'] = _concat_block('msos10_dfu_ext0', desc_data)
    blocks['msos20_dfu_desc'] = _concat_block('msos20_dfu_desc', desc_data)

    # === 2. 顺序生成 .dat 文件 ===
    dat_lines = []
    sequence_keys = [
        'device', 'config', 'bos', 
        * [f'str{i}' for i in range(len(str_lengths))],
        'msft', 'dfu_device', 'dfu_config',
        'msos10_app_compat', 'msos10_app_ext0', 'msos10_app_ext1', 'msos20_app_desc',
        'dfu_bos', 'msos10_dfu_compat', 'msos10_dfu_ext0', 'msos20_dfu_desc'
    ]
    
    for key in sequence_keys:
        if blocks.get(key):
            dat_lines.extend(_process_block_to_dat(blocks[key]))
            
    with open(dat_path, "w", encoding="utf-8") as f:
        for line in dat_lines:
            f.write(line + "\n")

    # === 3. 生成 64-bit 对齐的 .vh 参数文件 ===
    vh_lines = [
        "// Auto-generated by USB Core Builder",
        "// =========================================================================",
        f"// {prefix}_params.vh",
        "// =========================================================================",
        "",
        f"`define DESCR_USB3_DEVICE_LEN                       {len(blocks['device'])}",
        f"`define DESCR_USB3_CONFIG_LEN                       {len(blocks['config'])}",
        f"`define DESCR_USB3_BOS_LEN                          {len(blocks['bos'])}"
    ]
    
    for i in range(len(str_lengths)):
        vh_lines.append(f"`define DESCR_USB3_STR{i}_LEN                         {len(blocks[f'str{i}'])}")
        
    vh_lines.extend([
        f"`define DESCR_USB3_MSFT_LEN                         {len(blocks['msft'])}",
        "",
        f"`define DESCR_USB3_DFU_DEVICE_LEN                   {len(blocks['dfu_device'])}",
        f"`define DESCR_USB3_DFU_CONFIG_LEN                   {len(blocks['dfu_config'])}",
        "",
        f"`define DESCR_USB3_MSOS10_APP_compatibleID_LEN      {len(blocks['msos10_app_compat'])}",
        f"`define DESCR_USB3_MSOS10_APP_INT0_Extend_Pro_LEN   {len(blocks['msos10_app_ext0'])}",
        f"`define DESCR_USB3_MSOS10_APP_INT1_Extend_Pro_LEN   {len(blocks['msos10_app_ext1'])}",
        f"`define DESCR_USB3_MSOS20_APP_DES_LEN               {len(blocks['msos20_app_desc'])}",
        "",
        f"`define DESCR_USB3_DFU_BOS_LEN                      {len(blocks['dfu_bos'])}",
        f"`define DESCR_USB3_MSOS10_DFU_compatibleID_LEN      {len(blocks['msos10_dfu_compat'])}",
        f"`define DESCR_USB3_MSOS10_DFU_INT0_Extend_Pro_LEN   {len(blocks['msos10_dfu_ext0'])}",
        f"`define DESCR_USB3_MSOS20_DFU_DES_LEN               {len(blocks['msos20_dfu_desc'])}",
        "",
        "// 核心描述符地址与长度 (按 64-bit / 8 Bytes 对齐推导)",
        "localparam bit [13:0]    DEVICE_DESC_BASE                    =   10'd0;",
        "localparam bit [13:0]    CONFIG_DESC_BASE                    =   DEVICE_DESC_BASE                +   ((`DESCR_USB3_DEVICE_LEN                        + 7 ) / 8);",
        "localparam bit [13:0]    BOS_DESC_BASE                       =   CONFIG_DESC_BASE                +   ((`DESCR_USB3_CONFIG_LEN                        + 7 ) / 8);",
        "localparam bit [13:0]    STR0_DESC_BASE                      =   BOS_DESC_BASE                   +   ((`DESCR_USB3_BOS_LEN                           + 7 ) / 8);"
    ])
    
    prev_base = "STR0_DESC_BASE"
    for i in range(1, len(str_lengths)):
        current_base = f"STR{i}_DESC_BASE"
        prev_len = f"`DESCR_USB3_STR{i-1}_LEN"
        vh_lines.append(f"localparam bit [13:0]    {current_base:<35} =   {prev_base:<31} +   (({prev_len:<46} + 7 ) / 8);")
        prev_base = current_base
        
    last_str_len = f"`DESCR_USB3_STR{len(str_lengths)-1}_LEN"
    
    vh_lines.extend([
        f"localparam bit [13:0]    STRMSFT_DESC_BASE                   =   {prev_base:<31} +   (({last_str_len:<46} + 7 ) / 8);",
        f"localparam bit [13:0]    DFU_DEVICE_DESC_BASE                =   STRMSFT_DESC_BASE               +   ((`DESCR_USB3_MSFT_LEN                          + 7 ) / 8);",
        f"localparam bit [13:0]    DFU_CONFIG_DESC_BASE                =   DFU_DEVICE_DESC_BASE            +   ((`DESCR_USB3_DFU_DEVICE_LEN                    + 7 ) / 8);",
        f"localparam bit [13:0]    MSOS10_APP_COMPAT_ID_DESC_BASE      =   DFU_CONFIG_DESC_BASE            +   ((`DESCR_USB3_DFU_CONFIG_LEN                    + 7 ) / 8);",
        f"localparam bit [13:0]    MSOS10_APP_INT0_EXT_DESC_BASE       =   MSOS10_APP_COMPAT_ID_DESC_BASE  +   ((`DESCR_USB3_MSOS10_APP_compatibleID_LEN       + 7 ) / 8);",
        f"localparam bit [13:0]    MSOS10_APP_INT1_EXT_DESC_BASE       =   MSOS10_APP_INT0_EXT_DESC_BASE   +   ((`DESCR_USB3_MSOS10_APP_INT0_Extend_Pro_LEN    + 7 ) / 8);",
        f"localparam bit [13:0]    MSOS20_APP_DESC_BASE                =   MSOS10_APP_INT1_EXT_DESC_BASE   +   ((`DESCR_USB3_MSOS10_APP_INT1_Extend_Pro_LEN    + 7 ) / 8);",
        "",
        f"localparam bit [13:0]    DFU_BOS_DESC_BASE                   =   MSOS20_APP_DESC_BASE            +   ((`DESCR_USB3_MSOS20_APP_DES_LEN                + 7 ) / 8);",
        f"localparam bit [13:0]    MSOS10_DFU_COMPAT_ID_DESC_BASE      =   DFU_BOS_DESC_BASE               +   ((`DESCR_USB3_DFU_BOS_LEN                       + 7 ) / 8);",
        f"localparam bit [13:0]    MSOS10_DFU_INT0_EXT_DESC_BASE       =   MSOS10_DFU_COMPAT_ID_DESC_BASE  +   ((`DESCR_USB3_MSOS10_DFU_compatibleID_LEN       + 7 ) / 8);",
        f"localparam bit [13:0]    MSOS20_DFU_DESC_BASE                =   MSOS10_DFU_INT0_EXT_DESC_BASE   +   ((`DESCR_USB3_MSOS10_DFU_INT0_Extend_Pro_LEN    + 7 ) / 8);",
        "",
        f"localparam bit [13:0]    ROM_LEN                             =   MSOS20_DFU_DESC_BASE            +   ((`DESCR_USB3_MSOS20_DFU_DES_LEN                + 7 ) / 8);"
    ])

    with open(vh_path, "w", encoding="utf-8") as f:
        f.write("\n".join(vh_lines) + "\n")
        
    print(f"成功！生成路径:\n  -> {dat_path}\n  -> {vh_path}")
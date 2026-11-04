import ctypes
import os

def make_string_desc(text):
    utf16_bytes = text.encode('utf-16le')
    return bytes([len(utf16_bytes) + 2, 0x03]) + utf16_bytes

def _get_size(obj):
    return len(obj) if isinstance(obj, bytes) else ctypes.sizeof(obj)

def _auto_patch_lengths(desc_data):
    """【全维智能拓扑引擎】 接管全局长度、接口计数与 IAD 辖区管理"""
    hs_cfg = desc_data.get('hs_cfg')
    hs_payload = desc_data.get('hs_payload', [])
    fs_cfg = desc_data.get('fs_cfg')
    fs_payload = desc_data.get('fs_payload', [])
    
    # 1. 高速 (HS) 配置树全维智能解析
    if hs_cfg and hs_payload:
        hs_cfg.wTotalLength = ctypes.sizeof(hs_cfg) + sum(_get_size(x) for x in hs_payload)
        unique_interfaces = set()
        for item in hs_payload:
            if getattr(item, 'bDescriptorType', -1) == 0x04:
                unique_interfaces.add(getattr(item, 'bInterfaceNumber', -1))
        if hasattr(hs_cfg, 'bNumInterfaces'):
            hs_cfg.bNumInterfaces = len(unique_interfaces)

        for i, item in enumerate(hs_payload):
            desc_type = getattr(item, 'bDescriptorType', -1)
            if desc_type == 0x0B:
                iad_intfs = set()
                for j in range(i + 1, len(hs_payload)):
                    sub_item = hs_payload[j]
                    sub_type = getattr(sub_item, 'bDescriptorType', -1)
                    if sub_type == 0x0B: break
                    if sub_type == 0x04:
                        iad_intfs.add(getattr(sub_item, 'bInterfaceNumber', -1))
                if hasattr(item, 'bInterfaceCount'):
                    item.bInterfaceCount = len(iad_intfs)
                if hasattr(item, 'bFirstInterface') and iad_intfs:
                    item.bFirstInterface = min(iad_intfs)
            elif hasattr(item, 'wTotalLength') and desc_type != 0x02:
                class_total_len = 0
                for j in range(i, len(hs_payload)):
                    sub_item = hs_payload[j]
                    sub_type = getattr(sub_item, 'bDescriptorType', -1)
                    if j > i and sub_type in (0x04, 0x05, 0x0B): break
                    class_total_len += _get_size(sub_item)
                item.wTotalLength = class_total_len

    # 2. 全速 (FS) 配置树解析
    if fs_cfg and fs_payload:
        fs_cfg.wTotalLength = ctypes.sizeof(fs_cfg) + sum(_get_size(x) for x in fs_payload)

    # 3. DFU 配置树解析
    dfu_cfg = desc_data.get('dfu_cfg')
    dfu_payload = desc_data.get('dfu_payload', [])
    if dfu_cfg and dfu_payload:
        dfu_cfg.wTotalLength = ctypes.sizeof(dfu_cfg) + sum(_get_size(x) for x in dfu_payload)

    # 4. BOS 解析
    bos_head = desc_data.get('bos_head')
    if 'bos_caps' in desc_data: bos_caps = desc_data['bos_caps']
    elif 'bos_msos_desc' in desc_data: bos_caps = [desc_data['bos_msos_desc']]
    elif 'bos_msos_bytes' in desc_data: bos_caps = [desc_data['bos_msos_bytes']]
    else: bos_caps = []

    if bos_head:
        if hasattr(bos_head, 'wTotalLength'):
            bos_head.wTotalLength = _get_size(bos_head) + sum(_get_size(cap) for cap in bos_caps)
        if hasattr(bos_head, 'bNumDeviceCaps'):
            bos_head.bNumDeviceCaps = len(bos_caps)


def format_detailed_obj(obj, base_comment=""):
    """
    智能格式化核心：
    取代原本粗糙的单行 Hex 输出，提供类似 C 语言注释级别的精细拆分与语义解析
    """
    data = bytes(obj)
    size = len(data)
    
    def _build_lines(lines_data):
        out = []
        for chunk, cmt in lines_data:
            hex_str = " ".join([f"{b:02X}" for b in chunk])
            pad = max(0, 32 - len(hex_str))
            out.append(f"{hex_str}{' ' * pad}// {cmt}")
        return "\n".join(out)

    # 1. 纯 bytes 类型（如 HID Report, 字符串, Padding）
    if isinstance(obj, bytes):
        # 粗略判定为字符串描述符 (以长度和 0x03 开头)
        if size >= 2 and data[0] == size and data[1] == 0x03:
            hex_str = " ".join([f"{b:02X}" for b in data])
            return f"{hex_str} // {base_comment}"
            
        # 其他纯 bytes 数据 (如长达数十字节的 HID Report)，强制每行 16 字节截断
        lines = []
        for i in range(0, size, 16):
            chunk = data[i:i+16]
            hex_str = " ".join([f"{b:02X}" for b in chunk])
            if i == 0 and base_comment:
                padding = max(0, 48 - len(hex_str))
                lines.append(f"{hex_str}{' ' * padding}// {base_comment}")
            else:
                lines.append(hex_str)
        return "\n".join(lines)

    # 2. 针对特定 CTypes 结构体的智能展开解析
    desc_type = getattr(obj, 'bDescriptorType', -1)
    
    # --- Device Descriptor ---
    if desc_type == 0x01 and size >= 18:
        lines = [
            (data[0:2], f"bLength = {data[0]}, bDescriptorType = 0x{data[1]:02X} (Device)"),
            (data[2:4], f"bcdUSB = 0x{data[3]:02X}{data[2]:02X}"),
            (data[4:7], f"bDeviceClass = 0x{data[4]:02X}, bDeviceSubClass = 0x{data[5]:02X}, bDeviceProtocol = 0x{data[6]:02X}"),
            (data[7:8], f"bMaxPacketSize0 = {data[7]} bytes"),
            (data[8:10], f"idVendor = 0x{data[9]:02X}{data[8]:02X}"),
            (data[10:12], f"idProduct = 0x{data[11]:02X}{data[10]:02X}"),
            (data[12:14], f"bcdDevice = 0x{data[13]:02X}{data[12]:02X}"),
            (data[14:17], f"iManufacturer = {data[14]}, iProduct = {data[15]}, iSerialNumber = {data[16]}"),
            (data[17:18], f"bNumConfigurations = {data[17]}")
        ]
        return _build_lines(lines)

    # --- Device Qualifier ---
    if desc_type == 0x06 and size >= 10:
        lines = [
            (data[0:2], f"bLength = {data[0]}, bDescriptorType = 0x{data[1]:02X} (Qualifier)"),
            (data[2:4], f"bcdUSB = 0x{data[3]:02X}{data[2]:02X}"),
            (data[4:7], f"bDeviceClass = 0x{data[4]:02X}, bDeviceSubClass = 0x{data[5]:02X}, bDeviceProtocol = 0x{data[6]:02X}"),
            (data[7:8], f"bMaxPacketSize0 = {data[7]} bytes"),
            (data[8:9], f"bNumConfigurations = {data[8]}"),
            (data[9:10], f"bReserved = 0x{data[9]:02X}")
        ]
        return _build_lines(lines)

    # --- MS OS 2.0 Platform Capability ---
    if desc_type == 0x10 and size >= 28 and getattr(obj, 'bDevCapabilityType', 0) == 0x05:
        lines = [
            (data[0:4], f"bLength = {data[0]}, Type = 0x10, SubType = 0x05 (Platform Cap)"),
            (data[4:20], "PlatformCapabilityUUID (MS OS 2.0 UUID)"),
            (data[20:24], f"dwWindowsVersion = 0x{data[23]:02X}{data[22]:02X}{data[21]:02X}{data[20]:02X}"),
            (data[24:26], f"wTotalLength = {data[24] + (data[25]<<8)} bytes"),
            (data[26:27], f"bMS_VendorCode = 0x{data[26]:02X}"),
            (data[27:28], f"bAltEnumCode = 0x{data[27]:02X}")
        ]
        return _build_lines(lines)

    # 3. 其他类型的描述符（单行输出，并自动抓取对象属性生成智能注释）
    hex_str = " ".join([f"{b:02X}" for b in data])
    details = []
    
    if desc_type == 0x02:
        details.append(f"Config: wTotalLen={getattr(obj, 'wTotalLength', 0)}, {getattr(obj, 'bNumInterfaces', 0)} Interfaces, Val={getattr(obj, 'bConfigurationValue', 0)}")
    elif desc_type == 0x04:
        details.append(f"Interface: Num={getattr(obj, 'bInterfaceNumber', 0)}, Alt={getattr(obj, 'bAlternateSetting', 0)}, {getattr(obj, 'bNumEndpoints', 0)} EPs, Class=0x{getattr(obj, 'bInterfaceClass', 0):02X}")
    elif desc_type == 0x05:
        addr = getattr(obj, 'bEndpointAddress', 0)
        dir_str = "IN" if (addr & 0x80) else "OUT"
        details.append(f"Endpoint: {dir_str} (0x{addr:02X}), Attr=0x{getattr(obj, 'bmAttributes', 0):02X}, MaxPkt={getattr(obj, 'wMaxPacketSize', 0)}")
    elif desc_type == 0x24:
        details.append(f"CS_INTERFACE: Subtype=0x{getattr(obj, 'bDescriptorSubtype', 0):02X}")
    elif desc_type == 0x0B:
        details.append(f"IAD: FirstIntf={getattr(obj, 'bFirstInterface', 0)}, Count={getattr(obj, 'bInterfaceCount', 0)}")
    elif desc_type == 0x0F:
        details.append(f"BOS Header: wTotalLength={getattr(obj, 'wTotalLength', 0)}, {getattr(obj, 'bNumDeviceCaps', 0)} Caps")
        
    comment = base_comment
    if details:
        comment = f"{base_comment} [{', '.join(details)}]" if base_comment else ", ".join(details)
        
    padding = max(0, 32 - len(hex_str))
    return f"{hex_str}{' ' * padding}// {comment}"


def generate_files(desc_data, strings_config, prefix="usb", output_dir="output"):
    _auto_patch_lengths(desc_data)
    
    os.makedirs(output_dir, exist_ok=True)
    hex_path = os.path.join(output_dir, f"{prefix}_desc.hex")
    vh_path = os.path.join(output_dir, f"{prefix}_desc_params.vh")
    
    # === 1. 数据块提取 ===
    hs_blocks = desc_data.get('hs_payload', [])
    if not hs_blocks and 'endpoints' in desc_data:
        hs_blocks = [desc_data['hs_intf_bulk'], *desc_data['endpoints']]
    
    fs_blocks = desc_data.get('fs_payload', [])

    if 'bos_caps' in desc_data:
        bos_cap_blocks = desc_data['bos_caps']
    elif 'bos_msos_desc' in desc_data:
        bos_cap_blocks = [desc_data['bos_msos_desc']]
    else:
        bos_cap_blocks = [desc_data.get('bos_msos_bytes', b'')]
        
    if 'dfu_payload' in desc_data:
        dfu_blocks = desc_data['dfu_payload']
    else:
        dfu_blocks = [desc_data['dfu_intf'], desc_data['dfu_func']]

    len_hs_cfg = _get_size(desc_data['hs_cfg']) + sum(_get_size(item) for item in hs_blocks)
    len_fs_cfg = _get_size(desc_data.get('fs_cfg', b'')) + sum(_get_size(item) for item in fs_blocks) 
    len_bos = _get_size(desc_data['bos_head']) + sum(_get_size(cap) for cap in bos_cap_blocks)
    len_dfu_dev = _get_size(desc_data['dfu_dev'])
    len_dfu_cfg = _get_size(desc_data['dfu_cfg']) + sum(_get_size(item) for item in dfu_blocks)
    len_dev = _get_size(desc_data['dev_desc'])
    len_qual = _get_size(desc_data['qual_desc'])
    len_hid = _get_size(desc_data.get('hid_report_bytes', b''))
    len_oscfg = _get_size(desc_data.get('oscfg_bytes', b''))

    # === 2. 写入增强版、人类友好的 Hex 文件 ===
    with open(hex_path, "w", encoding="utf-8") as f:
        f.write("// =========================================================================\n")
        f.write(f"// {os.path.basename(hex_path)}\n")
        f.write("// =========================================================================\n\n")

        f.write("// ======================== 1. 设备描述符 (Device Descriptor) ========================\n")
        f.write(format_detailed_obj(desc_data['dev_desc']) + "\n")
        f.write(format_detailed_obj(bytes([0x00, 0x00]), "2 bytes padding (填充)") + "\n\n")

        f.write("// ======================== 2. 设备限定描述符 (Device Qualifier) ========================\n")
        f.write(format_detailed_obj(desc_data['qual_desc']) + "\n")
        f.write(format_detailed_obj(bytes([0x00, 0x00]), "2 bytes padding (填充)") + "\n\n")

        f.write("// ======================== 3. FS 配置描述符 ========================\n")
        if 'fs_cfg' in desc_data:
            f.write(format_detailed_obj(desc_data['fs_cfg'], "FS Header") + "\n")
            for block in fs_blocks:
                f.write(format_detailed_obj(block, "FS Payload") + "\n")
        f.write("\n")

        f.write("//==============================================================================\n")
        f.write(f"//======================== 4. HS 配置描述符 - {len_hs_cfg} Bytes ========================\n")
        f.write("//==============================================================================\n")
        
        f.write(format_detailed_obj(desc_data['hs_cfg']) + "\n")
        for block in hs_blocks:
             f.write(format_detailed_obj(block) + "\n")
        f.write("\n")

        f.write("// ======================== 5. 其他速率配置 ========================\n")
        if 'oscfg_bytes' in desc_data:
            f.write(format_detailed_obj(desc_data['oscfg_bytes'], "Other Speed Configuration Descriptor") + "\n\n")

        f.write("// ======================== 6. HID Report Descriptor ========================\n")
        if 'hid_report_bytes' in desc_data:
            f.write(format_detailed_obj(desc_data['hid_report_bytes'], f"HID Report Descriptor ({len_hid} Bytes)") + "\n\n")

        f.write("// ======================== 7. BOS Descriptor ========================\n")
        f.write(format_detailed_obj(desc_data['bos_head']) + "\n")
        for cap in bos_cap_blocks:
            f.write(format_detailed_obj(cap) + "\n")
        f.write("\n")

        f.write("// ======================== 8. 字符串描述符 (String Descriptors) ========================\n")
        f.write(format_detailed_obj(desc_data['lang_bytes'], "String 0: Supported Languages") + "\n")
        str_idx = 1
        for key, s_val in strings_config.items():
            str_desc_bytes = make_string_desc(s_val)
            f.write(format_detailed_obj(str_desc_bytes, f"String {str_idx} ({key}): \"{s_val}\"") + "\n")
            str_idx += 1
        f.write("\n")
        
        f.write("// ======================== 9. DFU Mode Device/Config ========================\n")
        f.write(format_detailed_obj(desc_data['dfu_dev'], "DFU Mode Device Descriptor") + "\n")
        f.write(format_detailed_obj(desc_data['dfu_cfg'], "DFU Mode Config Descriptor") + "\n")
        for block in dfu_blocks:
            f.write(format_detailed_obj(block, "DFU Mode Payload") + "\n")

    # === 3. 动态拼接 VH 模板 (保留原有逻辑，精准映射硬件地址) ===
    dynamic_str_params = ""
    dynamic_str_addrs = ""
    
    prev_addr = "DESC_STRSERIAL_ADDR"
    prev_len = "DESC_STRSERIAL_LEN"
    
    for key, val in strings_config.items():
        if key in ["VENDOR", "PRODUCT", "SERIAL"]: continue
            
        dynamic_str_params += f'parameter {key}           = "{val}";\n'
        dynamic_str_params += f'parameter {key}_LEN       = {len(val)};\n'
        
        dynamic_str_addrs += f"localparam logic [15:0] DESC_{key}_ADDR        = {prev_addr} + {prev_len};\n"
        dynamic_str_addrs += f"localparam logic [15:0] DESC_{key}_LEN         = 16'd2 + 2*{key}_LEN;\n\n"
        
        prev_addr = f"DESC_{key}_ADDR"
        prev_len = f"DESC_{key}_LEN"

    vh_template = f"""// =========================================================================
// {prefix}_params.vh
// =========================================================================

parameter VENDORSTR = "{strings_config.get('VENDOR', '')}";
parameter VENDORSTR_LEN = {len(strings_config.get('VENDOR', ''))};
parameter PRODUCTSTR = "{strings_config.get('PRODUCT', '')}";
parameter PRODUCTSTR_LEN = {len(strings_config.get('PRODUCT', ''))};
parameter SERIALSTR = "{strings_config.get('SERIAL', '')}";
parameter SERIALSTR_LEN = {len(strings_config.get('SERIAL', ''))};

//STRING
{dynamic_str_params.strip()}

localparam logic [15:0] DESC_DEV_ADDR  = 16'd0;
localparam logic [15:0] DESC_DEV_LEN   = 16'd{len_dev};

localparam logic [15:0] DESC_QUAL_ADDR = 16'd20;
localparam logic [15:0] DESC_QUAL_LEN  = 16'd{len_qual};

localparam logic [15:0] DESC_FSCFG_ADDR = 16'd32;
localparam logic [15:0] DESC_FSCFG_LEN  = 16'd{len_fs_cfg};

localparam logic [15:0] DESC_HSCFG_ADDR = DESC_FSCFG_ADDR + DESC_FSCFG_LEN;
localparam logic [15:0] DESC_HSCFG_LEN  = 16'd{len_hs_cfg};

localparam logic [15:0] DESC_OSCFG_ADDR = DESC_HSCFG_ADDR + DESC_HSCFG_LEN;
localparam logic [15:0] DESC_OSCFG_LEN  = 16'd{len_oscfg};

localparam logic [15:0] DESC_HIDRPT_ADDR = DESC_OSCFG_ADDR + DESC_OSCFG_LEN;
localparam logic [15:0] DESC_HIDRPT_LEN  = 16'd{len_hid};

localparam logic [15:0] DESC_BOS_ADDR = DESC_HIDRPT_ADDR + DESC_HIDRPT_LEN;
localparam logic [15:0] DESC_BOS_LEN  = 16'd{len_bos};

localparam logic [15:0] DESC_STRLANG_ADDR     = DESC_BOS_ADDR + DESC_BOS_LEN;

localparam logic [15:0] DESC_STRVENDOR_ADDR   = DESC_STRLANG_ADDR + 4;
localparam logic [15:0] DESC_STRVENDOR_LEN    = 16'd2 + 2*VENDORSTR_LEN;

localparam logic [15:0] DESC_STRPRODUCT_ADDR  = DESC_STRVENDOR_ADDR + DESC_STRVENDOR_LEN;
localparam logic [15:0] DESC_STRPRODUCT_LEN   = 16'd2 + 2*PRODUCTSTR_LEN;

localparam logic [15:0] DESC_STRSERIAL_ADDR   = DESC_STRPRODUCT_ADDR + DESC_STRPRODUCT_LEN;
localparam logic [15:0] DESC_STRSERIAL_LEN    = 16'd2 + 2*SERIALSTR_LEN;

{dynamic_str_addrs.strip()}

localparam logic [15:0] DESC_DFUMODE_DEV_ADDR = {prev_addr} + {prev_len};
localparam logic [15:0] DESC_DFUMODE_DEV_LEN  = 16'd{len_dfu_dev};

localparam logic [15:0] DESC_DFUMODE_CFG_ADDR = DESC_DFUMODE_DEV_ADDR + DESC_DFUMODE_DEV_LEN;
localparam logic [15:0] DESC_DFUMODE_CFG_LEN  = 16'd{len_dfu_cfg};

localparam logic [15:0] DESC_END_ADDR         = DESC_DFUMODE_CFG_ADDR + DESC_DFUMODE_CFG_LEN;
localparam logic        HAVE_STRINGS          = (VENDORSTR_LEN > 0 || PRODUCTSTR_LEN > 0 || SERIALSTR_LEN > 0);
localparam logic [15:0] ROM_LEN               = (HAVE_STRINGS)? DESC_END_ADDR : DESC_STRLANG_ADDR ;
"""

    with open(vh_path, "w", encoding="utf-8") as f:
        f.write(vh_template.strip() + "\n")

    print(f"成功生成！生成路径:\n  -> {hex_path}\n  -> {vh_path}")
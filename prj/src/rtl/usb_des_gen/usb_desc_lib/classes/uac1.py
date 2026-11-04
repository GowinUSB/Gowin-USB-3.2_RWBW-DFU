import ctypes

# =========================================================================
# UAC 1.0 (USB Audio Class 1.0) 专属描述符结构体库
# =========================================================================

class desc_UAC1_AC_Header_t(ctypes.LittleEndianStructure):
    """UAC 1.0 音频控制接口头 (AC Header)"""
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),   # 0x24 (CS_INTERFACE)
        ("bDescriptorSubtype",  ctypes.c_uint8),   # 0x01 (HEADER)
        ("bcdADC",              ctypes.c_uint16),  # 0x0100 (UAC 1.0)
        ("wTotalLength",        ctypes.c_uint16),
        ("bInCollection",       ctypes.c_uint8),   # 关联的音频流接口数
        ("baInterfaceNr_1",     ctypes.c_uint8),   # 第一个流接口编号
    ]

class desc_UAC1_Input_Terminal_t(ctypes.LittleEndianStructure):
    """UAC 1.0 输入端子 (Input Terminal)"""
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),   # 0x24
        ("bDescriptorSubtype",  ctypes.c_uint8),   # 0x02 (INPUT_TERMINAL)
        ("bTerminalID",         ctypes.c_uint8),
        ("wTerminalType",       ctypes.c_uint16),
        ("bAssocTerminal",      ctypes.c_uint8),
        ("bNrChannels",         ctypes.c_uint8),
        ("bmChannelConfig",     ctypes.c_uint16),  # UAC1 中是 16-bit
        ("iChannelNames",       ctypes.c_uint8),
        ("iTerminal",           ctypes.c_uint8),
    ]

class desc_UAC1_Output_Terminal_t(ctypes.LittleEndianStructure):
    """UAC 1.0 输出端子 (Output Terminal)"""
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),   # 0x24
        ("bDescriptorSubtype",  ctypes.c_uint8),   # 0x03 (OUTPUT_TERMINAL)
        ("bTerminalID",         ctypes.c_uint8),
        ("wTerminalType",       ctypes.c_uint16),
        ("bAssocTerminal",      ctypes.c_uint8),
        ("bSourceID",           ctypes.c_uint8),
        ("iTerminal",           ctypes.c_uint8),
    ]

def make_UAC1_Feature_Unit_Class(num_channels):
    """
    [动态类工厂] 生成变长的 UAC 1.0 Feature Unit 结构体。
    UAC1 的 bmaControls 是每个通道 1 个字节（或 2 字节视具体定义，通常标准复合控为 1 字节 bmControls）。
    """
    class desc_UAC1_Feature_Unit_t(ctypes.LittleEndianStructure):
        _pack_ = 1
        _fields_ = [
            ("bLength",             ctypes.c_uint8),
            ("bDescriptorType",     ctypes.c_uint8),
            ("bDescriptorSubtype",  ctypes.c_uint8),   # 0x06 (FEATURE_UNIT)
            ("bUnitID",             ctypes.c_uint8),
            ("bSourceID",           ctypes.c_uint8),
            ("bControlSize",        ctypes.c_uint8),   # 每个通道控制字段的字节数（通常为 1）
            # 变长数组：Master (1) + Channels (N)
            ("bmaControls",         ctypes.c_uint8 * (num_channels + 1)), 
            ("iFeature",            ctypes.c_uint8),
        ]
    return desc_UAC1_Feature_Unit_t

class desc_UAC1_AS_General_t(ctypes.LittleEndianStructure):
    """UAC 1.0 音频流接口常规 (AS General)"""
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),
        ("bDescriptorSubtype",  ctypes.c_uint8),   # 0x01 (AS_GENERAL)
        ("bTerminalLink",       ctypes.c_uint8),
        ("bDelay",              ctypes.c_uint8),
        ("wFormatTag",          ctypes.c_uint16),  # 例如 0x0001 (PCM)
    ]

class desc_UAC1_Format_Type_I_t(ctypes.LittleEndianStructure):
    """UAC 1.0 格式类型 I (Format Type I)"""
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),
        ("bDescriptorSubtype",  ctypes.c_uint8),   # 0x02 (FORMAT_TYPE)
        ("bFormatType",         ctypes.c_uint8),   # 0x01 (FORMAT_TYPE_I)
        ("bNrChannels",         ctypes.c_uint8),
        ("bSubFrameSize",       ctypes.c_uint8),   # 每个子帧字节数（如 2 或 3）
        ("bBitResolution",      ctypes.c_uint8),   # 有效位数（如 16 或 24）
        ("bSamFreqType",        ctypes.c_uint8),   # 采样率类型（0表示连续，或者具体离散采样率个数）
        # 后续如果是离散采样率，通常用 3 字节表示一个频率（如 48000Hz = 0x00BB80）
    ]

def make_UAC1_Format_Type_I_Class(sam_freq_type):
    """
    [动态类工厂] 生成变长的 UAC 1.0 Format Type I 描述符结构体。
    - 若 sam_freq_type == 0: 后面跟 6 字节（连续频率：3字节下限 + 3字节上限）。
    - 若 sam_freq_type > 0:  后面跟 sam_freq_type * 3 字节（N个离散的 3字节采样率）。
    """
    # 确定尾部采样率数据的总字节数
    tail_bytes_count = 6 if sam_freq_type == 0 else (sam_freq_type * 3)

    class desc_UAC1_Format_Type_I_t(ctypes.LittleEndianStructure):
        _pack_ = 1
        _fields_ = [
            ("bLength",             ctypes.c_uint8),
            ("bDescriptorType",     ctypes.c_uint8),
            ("bDescriptorSubtype",  ctypes.c_uint8),   # 0x02 (FORMAT_TYPE)
            ("bFormatType",         ctypes.c_uint8),   # 0x01 (FORMAT_TYPE_I)
            ("bNrChannels",         ctypes.c_uint8),
            ("bSubFrameSize",       ctypes.c_uint8),
            ("bBitResolution",      ctypes.c_uint8),
            ("bSamFreqType",        ctypes.c_uint8),   # 采样率类型数
            # 变长尾部字节数组 (通过 ctypes 的字节数阵列完美映射)
            ("tSamFreq",            ctypes.c_uint8 * tail_bytes_count),
        ]
    return desc_UAC1_Format_Type_I_t


class desc_UAC1_Iso_Endpoint_t(ctypes.LittleEndianStructure):
    """UAC 1.0 音频特定端点描述符 (Audio Specific Endpoint)"""
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),   # 0x25 (CS_ENDPOINT)
        ("bDescriptorSubtype",  ctypes.c_uint8),   # 0x01 (EP_GENERAL)
        ("bmAttributes",        ctypes.c_uint8),
        ("bLockDelayUnits",     ctypes.c_uint8),
        ("wLockDelay",          ctypes.c_uint16),
    ]
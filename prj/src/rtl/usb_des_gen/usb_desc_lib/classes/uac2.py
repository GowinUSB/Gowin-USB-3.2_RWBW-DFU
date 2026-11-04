import ctypes

# =========================================================================
# UAC 2.0 (USB Audio Class 2.0) 标准描述符结构体库
# =========================================================================

class desc_UAC2_AC_Header_t(ctypes.LittleEndianStructure):
    """UAC 2.0 音频控制接口头 (AC Header)"""
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),   # 0x24 (CS_INTERFACE)
        ("bDescriptorSubtype",  ctypes.c_uint8),   # 0x01 (HEADER)
        ("bcdADC",              ctypes.c_uint16),
        ("bCategory",           ctypes.c_uint8),
        ("wTotalLength",        ctypes.c_uint16),
        ("bmControls",          ctypes.c_uint8),
    ]

class desc_UAC2_Clock_Source_t(ctypes.LittleEndianStructure):
    """UAC 2.0 时钟源 (Clock Source)"""
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),
        ("bDescriptorSubtype",  ctypes.c_uint8),   # 0x0A (CLOCK_SOURCE)
        ("bClockID",            ctypes.c_uint8),
        ("bmAttributes",        ctypes.c_uint8),
        ("bmControls",          ctypes.c_uint8),
        ("bAssocTerminal",      ctypes.c_uint8),
        ("iClockSource",        ctypes.c_uint8),
    ]

class desc_UAC2_Input_Terminal_t(ctypes.LittleEndianStructure):
    """UAC 2.0 输入端子 (Input Terminal)"""
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),
        ("bDescriptorSubtype",  ctypes.c_uint8),   # 0x02 (INPUT_TERMINAL)
        ("bTerminalID",         ctypes.c_uint8),
        ("wTerminalType",       ctypes.c_uint16),
        ("bAssocTerminal",      ctypes.c_uint8),
        ("bCSourceID",          ctypes.c_uint8),
        ("bNrChannels",         ctypes.c_uint8),
        ("bmChannelConfig",     ctypes.c_uint32),
        ("iChannelNames",       ctypes.c_uint8),
        ("bmControls",          ctypes.c_uint16),
        ("iTerminal",           ctypes.c_uint8),
    ]

class desc_UAC2_Output_Terminal_t(ctypes.LittleEndianStructure):
    """UAC 2.0 输出端子 (Output Terminal)"""
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),
        ("bDescriptorSubtype",  ctypes.c_uint8),   # 0x03 (OUTPUT_TERMINAL)
        ("bTerminalID",         ctypes.c_uint8),
        ("wTerminalType",       ctypes.c_uint16),
        ("bAssocTerminal",      ctypes.c_uint8),
        ("bSourceID",           ctypes.c_uint8),
        ("bCSourceID",          ctypes.c_uint8),
        ("bmControls",          ctypes.c_uint16),
        ("iTerminal",           ctypes.c_uint8),
    ]

def make_UAC2_Feature_Unit_Class(num_channels):
    """
    [动态类工厂] 生成变长的 UAC 2.0 Feature Unit 结构体。
    由于 bmaControls 数组的长度 = (通道数 + 1) * 4 Bytes，只能动态推导。
    """
    class desc_UAC2_Feature_Unit_t(ctypes.LittleEndianStructure):
        _pack_ = 1
        _fields_ = [
            ("bLength",             ctypes.c_uint8),
            ("bDescriptorType",     ctypes.c_uint8),
            ("bDescriptorSubtype",  ctypes.c_uint8),   # 0x06 (FEATURE_UNIT)
            ("bUnitID",             ctypes.c_uint8),
            ("bSourceID",           ctypes.c_uint8),
            # 变长数组：Master (1) + Channels (N)
            ("bmaControls",         ctypes.c_uint32 * (num_channels + 1)), 
            ("iFeature",            ctypes.c_uint8),
        ]
    return desc_UAC2_Feature_Unit_t

class desc_UAC2_AS_General_t(ctypes.LittleEndianStructure):
    """UAC 2.0 音频流接口常规 (AS General)"""
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),
        ("bDescriptorSubtype",  ctypes.c_uint8),   # 0x01 (AS_GENERAL)
        ("bTerminalLink",       ctypes.c_uint8),
        ("bmControls",          ctypes.c_uint8),
        ("bFormatType",         ctypes.c_uint8),
        ("bmFormats",           ctypes.c_uint32),
        ("bNrChannels",         ctypes.c_uint8),
        ("bmChannelConfig",     ctypes.c_uint32),
        ("iChannelNames",       ctypes.c_uint8),
    ]

class desc_UAC2_Format_Type_I_t(ctypes.LittleEndianStructure):
    """UAC 2.0 音频格式类型 I (Format Type I)"""
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),
        ("bDescriptorSubtype",  ctypes.c_uint8),   # 0x02 (FORMAT_TYPE)
        ("bFormatType",         ctypes.c_uint8),
        ("bSubslotSize",        ctypes.c_uint8),
        ("bBitResolution",      ctypes.c_uint8),
    ]

class desc_UAC2_Iso_Endpoint_t(ctypes.LittleEndianStructure):
    """UAC 2.0 音频数据端点扩展属性 (Audio Data Endpoint)"""
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),   # 0x25 (CS_ENDPOINT)
        ("bDescriptorSubtype",  ctypes.c_uint8),   # 0x01 (EP_GENERAL)
        ("bmAttributes",        ctypes.c_uint8),
        ("bmControls",          ctypes.c_uint8),
        ("bLockDelayUnits",     ctypes.c_uint8),
        ("wLockDelay",          ctypes.c_uint16),
    ]
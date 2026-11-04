"""
=========================================================================
USB Video Class (UVC) 描述符核心库
基于 UVC 1.1 / 1.5 规范构建，支持未压缩格式 (Uncompressed)
=========================================================================
"""

import ctypes

# =========================================================================
# 常量定义 (UVC 1.11 / 1.5)
# =========================================================================
CS_INTERFACE             = 0x24
CS_ENDPOINT              = 0x25

# VC (Video Control) Subtypes
VC_HEADER                = 0x01
VC_INPUT_TERMINAL        = 0x02
VC_OUTPUT_TERMINAL       = 0x03

# VS (Video Streaming) Subtypes
VS_INPUT_HEADER          = 0x01
VS_FORMAT_UNCOMPRESSED   = 0x04
VS_FRAME_UNCOMPRESSED    = 0x05
VS_COLORFORMAT           = 0x0D

# =========================================================================
# 1. VC (Video Control) 类描述符
# =========================================================================

def make_UVC_VC_Header_Class(num_interfaces=1):
    """
    动态生成 VC Header 描述符类
    :param num_interfaces: 关联的 VideoStreaming 接口数量 (baInterfaceNr 数组长度)
    """
    class _desc_UVC_VC_Header_t(ctypes.LittleEndianStructure):
        _pack_ = 1
        _fields_ = [
            ("bLength", ctypes.c_uint8),
            ("bDescriptorType", ctypes.c_uint8),
            ("bDescriptorSubtype", ctypes.c_uint8),
            ("bcdUVC", ctypes.c_uint16),
            ("wTotalLength", ctypes.c_uint16),
            ("dwClockFrequency", ctypes.c_uint32),
            ("bInCollection", ctypes.c_uint8),
            ("baInterfaceNr", ctypes.c_uint8 * num_interfaces)
        ]
    return _desc_UVC_VC_Header_t

def make_UVC_VC_Input_Terminal_Class(control_size=3):
    """
    动态生成 VC Input Terminal 描述符类 (例如 Camera 终端)
    :param control_size: bmControls 的字节大小 (通常为 3)
    """
    class _desc_UVC_VC_Input_Terminal_t(ctypes.LittleEndianStructure):
        _pack_ = 1
        _fields_ = [
            ("bLength", ctypes.c_uint8),
            ("bDescriptorType", ctypes.c_uint8),
            ("bDescriptorSubtype", ctypes.c_uint8),
            ("bTerminalID", ctypes.c_uint8),
            ("wTerminalType", ctypes.c_uint16),
            ("bAssocTerminal", ctypes.c_uint8),
            ("iTerminal", ctypes.c_uint8),
            ("wObjectiveFocalLengthMin", ctypes.c_uint16),
            ("wObjectiveFocalLengthMax", ctypes.c_uint16),
            ("wOcularFocalLength", ctypes.c_uint16),
            ("bControlSize", ctypes.c_uint8),
            ("bmControls", ctypes.c_uint8 * control_size)
        ]
    return _desc_UVC_VC_Input_Terminal_t

class desc_UVC_VC_Output_Terminal_t(ctypes.LittleEndianStructure):
    """
    VC Output Terminal 描述符 (USB 视频输出)
    该结构体长度固定，无需使用工厂函数
    """
    _pack_ = 1
    _fields_ = [
        ("bLength", ctypes.c_uint8),
        ("bDescriptorType", ctypes.c_uint8),
        ("bDescriptorSubtype", ctypes.c_uint8),
        ("bTerminalID", ctypes.c_uint8),
        ("wTerminalType", ctypes.c_uint16),
        ("bAssocTerminal", ctypes.c_uint8),
        ("bSourceID", ctypes.c_uint8),
        ("iTerminal", ctypes.c_uint8)
    ]

# =========================================================================
# 2. VS (Video Streaming) 类描述符
# =========================================================================

def make_UVC_VS_Input_Header_Class(num_formats=1, control_size=1):
    """
    动态生成 VS Input Header 描述符类
    :param num_formats: 该接口支持的视频格式数量
    :param control_size: 每个格式占据的 Control 字节数 (通常为 1)
    """
    class _desc_UVC_VS_Input_Header_t(ctypes.LittleEndianStructure):
        _pack_ = 1
        _fields_ = [
            ("bLength", ctypes.c_uint8),
            ("bDescriptorType", ctypes.c_uint8),
            ("bDescriptorSubtype", ctypes.c_uint8),
            ("bNumFormats", ctypes.c_uint8),
            ("wTotalLength", ctypes.c_uint16),
            ("bEndpointAddress", ctypes.c_uint8),
            ("bmInfo", ctypes.c_uint8),
            ("bTerminalLink", ctypes.c_uint8),
            ("bStillCaptureMethod", ctypes.c_uint8),
            ("bTriggerSupport", ctypes.c_uint8),
            ("bTriggerUsage", ctypes.c_uint8),
            ("bControlSize", ctypes.c_uint8),
            # 这里的数组长度取决于 格式数 * 单个控制尺寸
            ("bmaControls", ctypes.c_uint8 * (control_size * num_formats))
        ]
    return _desc_UVC_VS_Input_Header_t

class desc_UVC_VS_Format_Uncompressed_t(ctypes.LittleEndianStructure):
    """
    未压缩格式描述符 (例如 YUY2)
    固定长度 27 字节
    """
    _pack_ = 1
    _fields_ = [
        ("bLength", ctypes.c_uint8),
        ("bDescriptorType", ctypes.c_uint8),
        ("bDescriptorSubtype", ctypes.c_uint8),
        ("bFormatIndex", ctypes.c_uint8),
        ("bNumFrameDescriptors", ctypes.c_uint8),
        ("guidFormat", ctypes.c_uint8 * 16),
        ("bBitsPerPixel", ctypes.c_uint8),
        ("bDefaultFrameIndex", ctypes.c_uint8),
        ("bAspectRatioX", ctypes.c_uint8),
        ("bAspectRatioY", ctypes.c_uint8),
        ("bmInterlaceFlags", ctypes.c_uint8),
        ("bCopyProtect", ctypes.c_uint8)
    ]

def make_UVC_VS_Frame_Uncompressed_Class(num_intervals=1):
    """
    动态生成 未压缩帧分辨率描述符 (配置分辨率与帧率)
    :param num_intervals: 该分辨率下支持的帧率档位数量 (离散模式)
    """
    class _desc_UVC_VS_Frame_Uncompressed_t(ctypes.LittleEndianStructure):
        _pack_ = 1
        _fields_ = [
            ("bLength", ctypes.c_uint8),
            ("bDescriptorType", ctypes.c_uint8),
            ("bDescriptorSubtype", ctypes.c_uint8),
            ("bFrameIndex", ctypes.c_uint8),
            ("bmCapabilities", ctypes.c_uint8),
            ("wWidth", ctypes.c_uint16),
            ("wHeight", ctypes.c_uint16),
            ("dwMinBitRate", ctypes.c_uint32),
            ("dwMaxBitRate", ctypes.c_uint32),
            ("dwMaxVideoFrameBufferSize", ctypes.c_uint32),
            ("dwDefaultFrameInterval", ctypes.c_uint32),
            ("bFrameIntervalType", ctypes.c_uint8),
            # 数组存储离散的帧间隔时间，如果是连续模式此处结构需另写
            ("dwFrameInterval", ctypes.c_uint32 * num_intervals)
        ]
    return _desc_UVC_VS_Frame_Uncompressed_t

class desc_UVC_VS_Color_Matching_t(ctypes.LittleEndianStructure):
    """
    颜色匹配描述符
    声明色彩空间，用于精准还原本设备输出的 YUV 数据
    """
    _pack_ = 1
    _fields_ = [
        ("bLength", ctypes.c_uint8),
        ("bDescriptorType", ctypes.c_uint8),
        ("bDescriptorSubtype", ctypes.c_uint8),
        ("bColorPrimaries", ctypes.c_uint8),
        ("bTransferCharacteristics", ctypes.c_uint8),
        ("bMatrixCoefficients", ctypes.c_uint8)
    ]
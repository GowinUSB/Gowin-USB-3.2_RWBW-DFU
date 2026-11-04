"""
=========================================================================
USB Communication Device Class (CDC) 描述符库
=========================================================================
"""

import ctypes

# CDC 类特定描述符类型
CS_INTERFACE = 0x24
CS_ENDPOINT  = 0x25

# CDC 类特定接口描述符子类型 (Subtypes)
CDC_SUBTYPE_HEADER          = 0x00
CDC_SUBTYPE_CALL_MANAGEMENT = 0x01
CDC_SUBTYPE_ACM             = 0x02
CDC_SUBTYPE_UNION           = 0x06

class desc_CDC_Header_t(ctypes.LittleEndianStructure):
    """ CDC Header 描述符 """
    _pack_ = 1
    _fields_ = [
        ("bLength", ctypes.c_uint8),
        ("bDescriptorType", ctypes.c_uint8),
        ("bDescriptorSubtype", ctypes.c_uint8),
        ("bcdCDC", ctypes.c_uint16)
    ]

class desc_CDC_CallManagement_t(ctypes.LittleEndianStructure):
    """ CDC Call Management 描述符 """
    _pack_ = 1
    _fields_ = [
        ("bLength", ctypes.c_uint8),
        ("bDescriptorType", ctypes.c_uint8),
        ("bDescriptorSubtype", ctypes.c_uint8),
        ("bmCapabilities", ctypes.c_uint8),
        ("bDataInterface", ctypes.c_uint8)
    ]

class desc_CDC_ACM_t(ctypes.LittleEndianStructure):
    """ CDC Abstract Control Management 描述符 """
    _pack_ = 1
    _fields_ = [
        ("bLength", ctypes.c_uint8),
        ("bDescriptorType", ctypes.c_uint8),
        ("bDescriptorSubtype", ctypes.c_uint8),
        ("bmCapabilities", ctypes.c_uint8)
    ]

def make_CDC_Union_Class(num_slaves=1):
    """
    动态生成 CDC Union 描述符类
    :param num_slaves: 从接口 (Slave Interface) 的数量
    """
    class _desc_CDC_Union_t(ctypes.LittleEndianStructure):
        _pack_ = 1
        _fields_ = [
            ("bLength", ctypes.c_uint8),
            ("bDescriptorType", ctypes.c_uint8),
            ("bDescriptorSubtype", ctypes.c_uint8),
            ("bMasterInterface", ctypes.c_uint8),
            ("bSlaveInterfaces", ctypes.c_uint8 * num_slaves)
        ]
    return _desc_CDC_Union_t
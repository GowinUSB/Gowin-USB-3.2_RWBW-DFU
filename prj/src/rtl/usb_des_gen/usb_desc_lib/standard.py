import ctypes

# =========================================================================
# 1. 结构体定义 (控制内存对齐)
# =========================================================================
class desc_Device_t(ctypes.LittleEndianStructure):
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),
        ("bcdUSB",              ctypes.c_uint16),
        ("bDeviceClass",        ctypes.c_uint8),
        ("bDeviceSubClass",     ctypes.c_uint8),
        ("bDeviceProtocol",     ctypes.c_uint8),
        ("bMaxPacketSize0",     ctypes.c_uint8),
        ("idVendor",            ctypes.c_uint16),
        ("idProduct",           ctypes.c_uint16),
        ("bcdDevice",           ctypes.c_uint16),
        ("iManufacturer",       ctypes.c_uint8),
        ("iProduct",            ctypes.c_uint8),
        ("iSerialNumber",       ctypes.c_uint8),
        ("bNumConfigurations",  ctypes.c_uint8),
    ]

class desc_Qualifier_t(ctypes.LittleEndianStructure):
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),
        ("bcdUSB",              ctypes.c_uint16),
        ("bDeviceClass",        ctypes.c_uint8),
        ("bDeviceSubClass",     ctypes.c_uint8),
        ("bDeviceProtocol",     ctypes.c_uint8),
        ("bMaxPacketSize0",     ctypes.c_uint8),
        ("bNumConfigurations",  ctypes.c_uint8),
        ("bReserved",           ctypes.c_uint8),
    ]

class desc_Config_t(ctypes.LittleEndianStructure):
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),
        ("wTotalLength",        ctypes.c_uint16),
        ("bNumInterfaces",      ctypes.c_uint8),
        ("bConfigurationValue", ctypes.c_uint8),
        ("iConfiguration",      ctypes.c_uint8),
        ("bmAttributes",        ctypes.c_uint8),
        ("bMaxPower",           ctypes.c_uint8),
    ]

class desc_IAD_t(ctypes.LittleEndianStructure):
    """标准接口关联描述符 (Interface Association Descriptor, Type 0x0B)"""
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),   # 0x0B
        ("bFirstInterface",     ctypes.c_uint8),
        ("bInterfaceCount",     ctypes.c_uint8),
        ("bFunctionClass",      ctypes.c_uint8),
        ("bFunctionSubClass",   ctypes.c_uint8),
        ("bFunctionProtocol",   ctypes.c_uint8),
        ("iFunction",           ctypes.c_uint8),
    ]

class desc_Interface_t(ctypes.LittleEndianStructure):
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),
        ("bInterfaceNumber",    ctypes.c_uint8),
        ("bAlternateSetting",   ctypes.c_uint8),
        ("bNumEndpoints",       ctypes.c_uint8),
        ("bInterfaceClass",     ctypes.c_uint8),
        ("bInterfaceSubclass",  ctypes.c_uint8),
        ("bInterfaceProtocol",  ctypes.c_uint8),
        ("iInterface",          ctypes.c_uint8),
    ]

class desc_Endpoint_t(ctypes.LittleEndianStructure):
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),
        ("bEndpointAddress",    ctypes.c_uint8),
        ("bmAttributes",        ctypes.c_uint8),
        ("wMaxPacketSize",      ctypes.c_uint16),
        ("bInterval",           ctypes.c_uint8),
    ]


class desc_HID_t(ctypes.LittleEndianStructure):
    """标准的 HID 类描述符 (Type 0x21)"""
    _pack_ = 1
    _fields_ = [
        ("bLength",                 ctypes.c_uint8),
        ("bDescriptorType",         ctypes.c_uint8),
        ("bcdHID",                  ctypes.c_uint16),
        ("bCountryCode",            ctypes.c_uint8),
        ("bNumDescriptors",         ctypes.c_uint8),
        ("bReportDescriptorType",   ctypes.c_uint8),
        ("wReportDescriptorLength", ctypes.c_uint16),
    ]

class desc_BOS_Header_t(ctypes.LittleEndianStructure):
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),
        ("wTotalLength",        ctypes.c_uint16),
        ("bNumDeviceCaps",      ctypes.c_uint8),
    ]

class desc_BOS_MSOS20_Capability_t(ctypes.LittleEndianStructure):
    """微软 MS OS 2.0 平台能力描述符 (Platform Capability Descriptor)"""
    _pack_ = 1
    _fields_ = [
        ("bLength",                       ctypes.c_uint8),
        ("bDescriptorType",               ctypes.c_uint8),
        ("bDevCapabilityType",            ctypes.c_uint8),
        ("bReserved",                     ctypes.c_uint8),
        ("PlatformCapabilityUUID",        ctypes.c_uint8 * 16), # 16字节 UUID
        ("dwWindowsVersion",              ctypes.c_uint32),
        ("wMSOSDescriptorSetTotalLength", ctypes.c_uint16),
        ("bMS_VendorCode",                ctypes.c_uint8),
        ("bAltEnumCode",                  ctypes.c_uint8),
    ]

class desc_DFU_Functional_t(ctypes.LittleEndianStructure):
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),
        ("bmAttributes",        ctypes.c_uint8),
        ("wDetachTimeOut",      ctypes.c_uint16),
        ("wTransferSize",       ctypes.c_uint16),
        ("bcdDFUVersion",       ctypes.c_uint16),
    ]








##  3.2  专属库

class desc_SS_Endpoint_Companion_t(ctypes.LittleEndianStructure):
    """USB 3.0/3.2 超高速端点伴随描述符 (SuperSpeed Endpoint Companion, Type 0x30)"""
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),   # 0x30 (SS_ENDPOINT_COMPANION)
        ("bMaxBurst",           ctypes.c_uint8),   # 每个突发传输的最大包数 (0 to 15)
        ("bmAttributes",        ctypes.c_uint8),   # 属性（对于Bulk为MaxStreams，对于Isoch为Mult）
        ("wBytesPerInterval",   ctypes.c_uint16),  # 每间隔传输的总字节数（高带宽Isoch使用）
    ]


class desc_BOS_SS_Device_Capability_t(ctypes.LittleEndianStructure):
    """USB 3.0 超高速设备能力描述符 (SuperSpeed Device Capability)"""
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),   # 0x10 (DEVICE CAPABILITY)
        ("bDevCapabilityType",  ctypes.c_uint8),   # 0x03 (SUPERSPEED_USB)
        ("bmAttributes",        ctypes.c_uint8),
        ("wSpeedsSupported",    ctypes.c_uint16),
        ("bFunctionalitySupport", ctypes.c_uint8),
        ("bU1DevExitLat",       ctypes.c_uint8),
        ("wU2DevExitLat",       ctypes.c_uint16),
    ]

class desc_BOS_SSP_Device_Capability_t(ctypes.LittleEndianStructure):
    """USB 3.1+ 超高速增强设备能力描述符 (SuperSpeedPlus Device Capability)"""
    _pack_ = 1
    _fields_ = [
        ("bLength",             ctypes.c_uint8),
        ("bDescriptorType",     ctypes.c_uint8),   # 0x10
        ("bDevCapabilityType",  ctypes.c_uint8),   # 0x0A (SUPERSPEED_PLUS)
        ("bReserved",           ctypes.c_uint8),
        ("bmAttributes",        ctypes.c_uint32),
        ("wFunctionalitySupport", ctypes.c_uint16),
        ("wReserved",           ctypes.c_uint16),
        ("bmSublinkSpeedAttr0", ctypes.c_uint32),
        ("bmSublinkSpeedAttr1", ctypes.c_uint32),
    ]

class desc_MS_OS_Compat_ID_Header_t(ctypes.LittleEndianStructure):
    """Microsoft OS Compatible ID Descriptor Header (WinUSB 免驱绑定)"""
    _pack_ = 1
    _fields_ = [
        ("dwLength",            ctypes.c_uint32),
        ("bcdVersion",          ctypes.c_uint16),
        ("wIndex",              ctypes.c_uint16),  # 0x0004
        ("bCount",              ctypes.c_uint8),   # Function 个数
        ("bReserved1",          ctypes.c_uint8 * 7),
    ]

class desc_MS_OS_Compat_ID_Function_t(ctypes.LittleEndianStructure):
    """Microsoft OS Compatible ID Function Entry"""
    _pack_ = 1
    _fields_ = [
        ("bFirstInterfaceNumber", ctypes.c_uint8),
        ("bReserved",             ctypes.c_uint8),
        ("compatibleID",          ctypes.c_uint8 * 8), # 例如 "WINUSB\0\0"
        ("subCompatibleID",       ctypes.c_uint8 * 8),
        ("bReserved2",            ctypes.c_uint8 * 6),
    ]


# =========================================================================
# MS OS 1.0 Extended Properties
# =========================================================================
class desc_MS_OS_Ext_Prop_Header_t(ctypes.LittleEndianStructure):
    _pack_ = 1
    _fields_ = [
        ("dwLength", ctypes.c_uint32),
        ("bcdVersion", ctypes.c_uint16),
        ("wIndex", ctypes.c_uint16),
        ("wCount", ctypes.c_uint16)
    ]

# 注意：由于 Property Data (如 GUID 字符串) 长度可变，
# 在主脚本中直接用 bytes 拼接 Extended Properties 的属性段，
# 以保持灵活性，而非强制约束在一个固定 ctypes 中。

# =========================================================================
# MS OS 2.0 Descriptor Set
# =========================================================================
class desc_MS_OS_20_Set_Header_t(ctypes.LittleEndianStructure):
    _pack_ = 1
    _fields_ = [
        ("wLength", ctypes.c_uint16),
        ("wDescriptorType", ctypes.c_uint16),
        ("dwWindowsVersion", ctypes.c_uint32),
        ("wTotalLength", ctypes.c_uint16)
    ]

class desc_MS_OS_20_Subset_Header_Configuration_t(ctypes.LittleEndianStructure):
    _pack_ = 1
    _fields_ = [
        ("wLength", ctypes.c_uint16),
        ("wDescriptorType", ctypes.c_uint16),
        ("bConfigurationValue", ctypes.c_uint8),
        ("bReserved", ctypes.c_uint8),
        ("wTotalLength", ctypes.c_uint16)
    ]

class desc_MS_OS_20_Subset_Header_Function_t(ctypes.LittleEndianStructure):
    _pack_ = 1
    _fields_ = [
        ("wLength", ctypes.c_uint16),
        ("wDescriptorType", ctypes.c_uint16),
        ("bFirstInterface", ctypes.c_uint8),
        ("bReserved", ctypes.c_uint8),
        ("wSubsetLength", ctypes.c_uint16)
    ]

class desc_MS_OS_20_Feature_Compat_ID_t(ctypes.LittleEndianStructure):
    _pack_ = 1
    _fields_ = [
        ("wLength", ctypes.c_uint16),
        ("wDescriptorType", ctypes.c_uint16),
        ("CompatibleID", ctypes.c_uint8 * 8),
        ("SubCompatibleID", ctypes.c_uint8 * 8)
    ]

class desc_BOS_USB2_Ext_Capability_t(ctypes.LittleEndianStructure):
    _pack_ = 1
    _fields_ = [
        ("bLength", ctypes.c_uint8),
        ("bDescriptorType", ctypes.c_uint8),
        ("bDevCapabilityType", ctypes.c_uint8),
        ("bmAttributes", ctypes.c_uint32)
    ]
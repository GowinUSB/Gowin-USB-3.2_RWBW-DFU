"""
=========================================================================
USB 3.2 BULK + DFU Composite Device 配置总表
支持 MS OS 1.0 & 2.0 (多接口/多 GUID 配置)
=========================================================================
"""

import ctypes
import os

from usb_desc_lib.standard import (
    desc_Device_t, desc_Config_t, desc_Interface_t, desc_Endpoint_t,
    desc_SS_Endpoint_Companion_t, 
# BOS
    desc_BOS_Header_t,
    desc_BOS_USB2_Ext_Capability_t,
    desc_BOS_SS_Device_Capability_t, desc_BOS_SSP_Device_Capability_t,
    desc_BOS_MSOS20_Capability_t,
# MSOS1.0
    desc_MS_OS_Compat_ID_Header_t, desc_MS_OS_Compat_ID_Function_t,desc_MS_OS_Ext_Prop_Header_t,
# MSOS2.0
    desc_MS_OS_20_Set_Header_t, desc_MS_OS_20_Subset_Header_Configuration_t,
    desc_MS_OS_20_Subset_Header_Function_t, desc_MS_OS_20_Feature_Compat_ID_t,
#DFU
    desc_DFU_Functional_t
)
from usb_desc_lib.writers.writer_usb3_dat import generate_usb3_dat_files

# =========================================================================
# 辅助函数：快速生成 MS OS 字符串与属性
# =========================================================================
def build_msos10_ext_prop(guid_str):
    """构建 MS OS 1.0 Extended Properties Payload (REG_MULTI_SZ)"""
    prop_name = "DeviceInterfaceGUIDs\0".encode('utf-16le')
    prop_data = (guid_str + "\0\0").encode('utf-16le')
    
    dwSize = 14 + len(prop_name) + len(prop_data)
    dwPropertyDataType = 7 # REG_MULTI_SZ
    wPropertyNameLength = len(prop_name)
    dwPropertyDataLength = len(prop_data)
    
    payload = struct.pack('<IIH', dwSize, dwPropertyDataType, wPropertyNameLength)
    payload += prop_name
    payload += struct.pack('<I', dwPropertyDataLength)
    payload += prop_data
    return payload

def build_msos20_registry_prop(guid_str):
    """构建 MS OS 2.0 Registry Property (REG_MULTI_SZ)"""
    prop_name = "DeviceInterfaceGUIDs\0".encode('utf-16le')
    prop_data = (guid_str + "\0\0").encode('utf-16le')
    
    wLength = 10 + len(prop_name) + len(prop_data)
    wDescriptorType = 0x0004 # MS_OS_20_FEATURE_REG_PROPERTY
    wPropertyDataType = 0x0007 # REG_MULTI_SZ
    wPropertyNameLength = len(prop_name)
    wPropertyDataLength = len(prop_data)
    
    payload = struct.pack('<HHH', wLength, wDescriptorType, wPropertyDataType)
    payload += struct.pack('<H', wPropertyNameLength)
    payload += prop_name
    payload += struct.pack('<H', wPropertyDataLength)
    payload += prop_data
    return payload

import struct # 用于上面的辅助打包

# =========================================================================
# 【核心设备参数】
# =========================================================================
USB_VID         = 0x33AA
USB_PID         = 0x7607
DEVICE_BCD      = 0x0100
USB_BCD_VERSION = 0x0320 

dev_desc = desc_Device_t(
    bLength            = ctypes.sizeof(desc_Device_t),
    bDescriptorType    = 0x01,       
    bcdUSB             = USB_BCD_VERSION,       
    bDeviceClass       = 0xEF,                  # Misc
    bDeviceSubClass    = 0x02,                  # Common
    bDeviceProtocol    = 0x01,                  # IAD
    bMaxPacketSize0    = 0x09,                  # 512
    idVendor           = USB_VID,               
    idProduct          = USB_PID,               
    bcdDevice          = DEVICE_BCD,            
    iManufacturer      = 1,
    iProduct           = 2,
    iSerialNumber      = 3,                     
    bNumConfigurations = 1
)

desc_config_ps = {
    "config": desc_Config_t(
        bLength             = ctypes.sizeof(desc_Config_t),
        bDescriptorType     = 0x02,       
        wTotalLength        = 0,                    
        bNumInterfaces      = 2,
        bConfigurationValue = 1,
        iConfiguration      = 0,
        bmAttributes        = 0x80,                 
        bMaxPower           = 0x32                  
    ),
    "interface_bulk": {
        "interface": desc_Interface_t(
            bLength            = ctypes.sizeof(desc_Interface_t),
            bDescriptorType    = 0x04,
            bInterfaceNumber   = 0,
            bAlternateSetting  = 0,
            bNumEndpoints      = 4,                 
            bInterfaceClass    = 0xFF,              
            bInterfaceSubclass = 0x00,   
            bInterfaceProtocol = 0x00,          
            iInterface         = 4
        ),
        "ep1_out": desc_Endpoint_t(
            bLength            = ctypes.sizeof(desc_Endpoint_t),
            bDescriptorType    = 0x05,       
            bEndpointAddress   = 0x01, 
            bmAttributes       = 0x02,              
            wMaxPacketSize     = 1024,
            bInterval          = 0
        ),
        "ep1_out_ss": desc_SS_Endpoint_Companion_t(
            bLength            = ctypes.sizeof(desc_SS_Endpoint_Companion_t),
            bDescriptorType    = 0x30,       
            bMaxBurst          = 15,                
            bmAttributes       = 0,
            wBytesPerInterval  = 0
        ),
        "ep1_in": desc_Endpoint_t(
            bLength            = ctypes.sizeof(desc_Endpoint_t),
            bDescriptorType    = 0x05,       
            bEndpointAddress   = 0x81, 
            bmAttributes       = 0x02,              
            wMaxPacketSize     = 1024,
            bInterval          = 0
        ),
        "ep1_in_ss": desc_SS_Endpoint_Companion_t(
            bLength            = ctypes.sizeof(desc_SS_Endpoint_Companion_t),
            bDescriptorType    = 0x30,       
            bMaxBurst          = 15,                
            bmAttributes       = 0,
            wBytesPerInterval  = 0
        ),
        "ep2_out": desc_Endpoint_t(
            bLength            = ctypes.sizeof(desc_Endpoint_t),
            bDescriptorType    = 0x05,       
            bEndpointAddress   = 0x02, 
            bmAttributes       = 0x02,              
            wMaxPacketSize     = 1024,
            bInterval          = 0
        ),
        "ep2_out_ss": desc_SS_Endpoint_Companion_t(
            bLength            = ctypes.sizeof(desc_SS_Endpoint_Companion_t),
            bDescriptorType    = 0x30,       
            bMaxBurst          = 15,               
            bmAttributes       = 0,
            wBytesPerInterval  = 0
        ),
        "ep2_in": desc_Endpoint_t(
            bLength            = ctypes.sizeof(desc_Endpoint_t),
            bDescriptorType    = 0x05,       
            bEndpointAddress   = 0x82, 
            bmAttributes       = 0x02,              
            wMaxPacketSize     = 1024,
            bInterval          = 0
        ),
        "ep2_in_ss": desc_SS_Endpoint_Companion_t(
            bLength            = ctypes.sizeof(desc_SS_Endpoint_Companion_t),
            bDescriptorType    = 0x30,       
            bMaxBurst          = 15,                
            bmAttributes       = 0,
            wBytesPerInterval  = 0
        )
    },
    "interface_dfu": {
        "interface": desc_Interface_t(
            bLength            = ctypes.sizeof(desc_Interface_t),
            bDescriptorType    = 0x04,
            bInterfaceNumber   = 1,                 
            bAlternateSetting  = 0,
            bNumEndpoints      = 0,                 
            bInterfaceClass    = 0xFE,              
            bInterfaceSubclass = 0x01,              
            bInterfaceProtocol = 0x01,              
            iInterface         = 6                  
        ),
        "dfu_func": desc_DFU_Functional_t(
            bLength            = ctypes.sizeof(desc_DFU_Functional_t),
            bDescriptorType    = 0x21,              
            bmAttributes       = 0x0B,              
            wDetachTimeOut     = 0x00FF,            
            wTransferSize      = 0x0100,            
            bcdDFUVersion      = 0x0110             
        )
    }
}

# =========================================================================
# 3. BOS 与 MS OS 兼容性描述符
# =========================================================================
bos_head = desc_BOS_Header_t(
    bLength         = ctypes.sizeof(desc_BOS_Header_t),
    bDescriptorType = 0x0F,
    wTotalLength    = 70,    
    bNumDeviceCaps  = 4     
)

bos_usb2_ext = desc_BOS_USB2_Ext_Capability_t(
    bLength            = ctypes.sizeof(desc_BOS_USB2_Ext_Capability_t),
    bDescriptorType    = 0x10,
    bDevCapabilityType = 0x02,
    bmAttributes       = 0x00000002
)

bos_ss_cap = desc_BOS_SS_Device_Capability_t(
    bLength               = ctypes.sizeof(desc_BOS_SS_Device_Capability_t),
    bDescriptorType       = 0x10,
    bDevCapabilityType    = 0x03,    
    bmAttributes          = 0x00,
    wSpeedsSupported      = 0x000E,  
    bFunctionalitySupport = 0x03,    
    bU1DevExitLat         = 0x00,
    wU2DevExitLat         = 0x0000
)

bos_ssp_cap = desc_BOS_SSP_Device_Capability_t(
    bLength               = ctypes.sizeof(desc_BOS_SSP_Device_Capability_t),
    bDescriptorType       = 0x10,
    bDevCapabilityType    = 0x0A,    
    bReserved             = 0x00,
    bmAttributes          = 0x00000001, 
    wFunctionalitySupport = 0x1100,
    wReserved             = 0x0000,
    bmSublinkSpeedAttr0   = 0x000A4030, 
    bmSublinkSpeedAttr1   = 0x000A40B0  
)

msos20_bos = desc_BOS_MSOS20_Capability_t(
    bLength                       = ctypes.sizeof(desc_BOS_MSOS20_Capability_t),
    bDescriptorType               = 0x10,
    bDevCapabilityType            = 0x05,
    bReserved                     = 0x00,
    PlatformCapabilityUUID        = (ctypes.c_uint8 * 16)(
        0xDF, 0x60, 0xDD, 0xD8, 0x89, 0x45, 0xC7, 0x4C, 
        0x9C, 0xD2, 0x65, 0x9D, 0x9E, 0x64, 0x8A, 0x9F
    ),
    dwWindowsVersion              = 0x06030000, 
    wMSOSDescriptorSetTotalLength = 338,        
    bMS_VendorCode                = 0x02,
    bAltEnumCode                  = 0x00
)

# ----------------- MS OS 1.0 (APP) -----------------
compat_id_header_app = desc_MS_OS_Compat_ID_Header_t(
    dwLength   = 64,             
    bcdVersion = 0x0100,
    wIndex     = 0x0004,
    bCount     = 2,             
    bReserved1 = (ctypes.c_uint8 * 7)(0)
)
compat_id_func0_app = desc_MS_OS_Compat_ID_Function_t(
    bFirstInterfaceNumber = 0,                            
    bReserved             = 1,                           
    compatibleID          = (ctypes.c_uint8 * 8)(*b"WINUSB\0\0"), 
    subCompatibleID       = (ctypes.c_uint8 * 8)(0),
    bReserved2            = (ctypes.c_uint8 * 6)(0)
)
compat_id_func1_app = desc_MS_OS_Compat_ID_Function_t(
    bFirstInterfaceNumber = 1,                            
    bReserved             = 1,                           
    compatibleID          = (ctypes.c_uint8 * 8)(*b"WINUSB\0\0"), 
    subCompatibleID       = (ctypes.c_uint8 * 8)(0),
    bReserved2            = (ctypes.c_uint8 * 6)(0)
)

msos10_ext_prop_hdr0 = desc_MS_OS_Ext_Prop_Header_t(146, 0x0100, 0x0005, 1)
msos10_ext_prop_data0 = build_msos10_ext_prop("{1EAA7FAA-00A2-1A33-651E-484F21BD4126}")

msos10_ext_prop_hdr1 = desc_MS_OS_Ext_Prop_Header_t(146, 0x0100, 0x0005, 1)
msos10_ext_prop_data1 = build_msos10_ext_prop("{877F602E-1760-D303-49EA-D92D4F4DFE2D}")

# ----------------- MS OS 2.0 (APP) -----------------
msos20_set_hdr_app = desc_MS_OS_20_Set_Header_t(10, 0x0000, 0x06030000, 338)
msos20_cfg_subset_app = desc_MS_OS_20_Subset_Header_Configuration_t(8, 0x0001, 0, 0, 328)

msos20_func0_app = desc_MS_OS_20_Subset_Header_Function_t(8, 0x0002, 0, 0, 160)
msos20_compat0_app = desc_MS_OS_20_Feature_Compat_ID_t(20, 0x0003, (ctypes.c_uint8 * 8)(*b"WINUSB\0\0"), (ctypes.c_uint8 * 8)(0))
msos20_reg0_app = build_msos20_registry_prop("{1EAA7FAA-00A2-1A33-651E-484F21BD4126}")

msos20_func1_app = desc_MS_OS_20_Subset_Header_Function_t(8, 0x0002, 1, 0, 160)
msos20_compat1_app = desc_MS_OS_20_Feature_Compat_ID_t(20, 0x0003, (ctypes.c_uint8 * 8)(*b"WINUSB\0\0"), (ctypes.c_uint8 * 8)(0))
msos20_reg1_app = build_msos20_registry_prop("{877F602E-1760-D303-49EA-D92D4F4DFE2D}")

# ----------------- DFU 模式设备描述符 -----------------
dfu_dev_desc = desc_Device_t(
    bLength            = 18, bDescriptorType    = 0x01, bcdUSB = 0x0320, bDeviceClass = 0x00,
    bDeviceSubClass    = 0x00, bDeviceProtocol    = 0x00, bMaxPacketSize0    = 0x09,
    idVendor           = USB_VID, idProduct          = 0xFE01, bcdDevice          = 0x0100,
    iManufacturer      = 1, iProduct           = 2, iSerialNumber      = 3, bNumConfigurations = 1
)
dfu_cfg_desc = desc_Config_t(
    bLength = 9, bDescriptorType = 0x02, wTotalLength = 27, bNumInterfaces = 1,
    bConfigurationValue = 1, iConfiguration = 0, bmAttributes = 0x80, bMaxPower = 0x32
)
dfu_intf_desc = desc_Interface_t(
    bLength = 9, bDescriptorType = 0x04, bInterfaceNumber = 0, bAlternateSetting = 0,
    bNumEndpoints = 0, bInterfaceClass = 0xFE, bInterfaceSubclass = 0x01,
    bInterfaceProtocol = 0x02, iInterface = 6
)
dfu_func_desc = desc_DFU_Functional_t(
    bLength = 9, 
    bDescriptorType = 0x21, 
    bmAttributes = 0x0B, 
    wDetachTimeOut = 0x00FF,
    wTransferSize = 0x0200,                         
    bcdDFUVersion = 0x0110
)

# ----------------- DFU BOS (MSOS 1.0 & 2.0) -----------------
dfu_bos_head = desc_BOS_Header_t(5, 0x0F, 70, 4)

msos20_bos_dfu = desc_BOS_MSOS20_Capability_t(
    bLength                       = ctypes.sizeof(desc_BOS_MSOS20_Capability_t),
    bDescriptorType               = 0x10,
    bDevCapabilityType            = 0x05,
    bReserved                     = 0x00,
    PlatformCapabilityUUID        = (ctypes.c_uint8 * 16)(
        0xDF, 0x60, 0xDD, 0xD8, 0x89, 0x45, 0xC7, 0x4C, 
        0x9C, 0xD2, 0x65, 0x9D, 0x9E, 0x64, 0x8A, 0x9F
    ),
    dwWindowsVersion              = 0x06030000, 
    wMSOSDescriptorSetTotalLength = 162,        
    bMS_VendorCode                = 0x02,
    bAltEnumCode                  = 0x00
)

dfu_compat_id_header = desc_MS_OS_Compat_ID_Header_t(40, 0x0100, 0x0004, 1, (ctypes.c_uint8 * 7)(0))
dfu_compat_id_func0 = desc_MS_OS_Compat_ID_Function_t(0, 1, (ctypes.c_uint8 * 8)(*b"WINUSB\0\0"), (ctypes.c_uint8 * 8)(0), (ctypes.c_uint8 * 6)(0))

dfu_msos10_ext_prop_hdr0 = desc_MS_OS_Ext_Prop_Header_t(146, 0x0100, 0x0005, 1)
dfu_msos10_ext_prop_data0 = build_msos10_ext_prop("{F5436908-F3FD-36FC-8730-89531CBFEA14}")

dfu_msos20_set_hdr = desc_MS_OS_20_Set_Header_t(10, 0x0000, 0x06030000, 162)
dfu_msos20_compat = desc_MS_OS_20_Feature_Compat_ID_t(20, 0x0003, (ctypes.c_uint8 * 8)(*b"WINUSB\0\0"), (ctypes.c_uint8 * 8)(0))
dfu_msos20_reg = build_msos20_registry_prop("{F5436908-F3FD-36FC-8730-89531CBFEA14}")

msft_string = bytes([18, 3]) + "MSFT100".encode("utf-16le") + bytes([0x01, 0x00])
lang_bytes = bytes([0x04, 0x03, 0x09, 0x04])

strings_config = {
    "VENDOR":  "Gowinsemi",
    "PRODUCT": "USB Composite Device",
    "SERIAL":  "TEST",
    "STR4":    "WinUSB Bulk",
    "STR5":    "HID Interface",
    "STR6":    "DFU Runtime"
}

# =========================================================================
# 4. 生成执行 
# =========================================================================
if __name__ == "__main__":
    def _flatten_config(config_dict):
        payload_list = []
        for key, value in config_dict.items():
            if key == "config":  continue
            if isinstance(value, dict): payload_list.extend(_flatten_config(value))
            else: payload_list.append(value)
        return payload_list

    desc_data = {
        'dev_desc': dev_desc,
        'hs_cfg': desc_config_ps["config"],                
        'hs_payload': _flatten_config(desc_config_ps), 
        
        'bos_head': bos_head,
        'bos_caps': [bos_usb2_ext, bos_ss_cap, bos_ssp_cap, msos20_bos],
        'lang_bytes': lang_bytes,
        'msft_string': msft_string,
        
        'msos10_app_compat': [compat_id_header_app, compat_id_func0_app, compat_id_func1_app],
        'msos10_app_ext0': [msos10_ext_prop_hdr0, msos10_ext_prop_data0],
        'msos10_app_ext1': [msos10_ext_prop_hdr1, msos10_ext_prop_data1],
        'msos20_app_desc': [
            msos20_set_hdr_app, msos20_cfg_subset_app, 
            msos20_func0_app, msos20_compat0_app, msos20_reg0_app,
            msos20_func1_app, msos20_compat1_app, msos20_reg1_app
        ],
        
        'dfu_dev': dfu_dev_desc,
        'dfu_cfg': dfu_cfg_desc,
        'dfu_payload': [dfu_intf_desc, dfu_func_desc],
        'dfu_bos_head': dfu_bos_head,
        'dfu_bos_caps': [bos_usb2_ext, bos_ss_cap, bos_ssp_cap, msos20_bos_dfu],
        
        'msos10_dfu_compat': [dfu_compat_id_header, dfu_compat_id_func0],
        'msos10_dfu_ext0': [dfu_msos10_ext_prop_hdr0, dfu_msos10_ext_prop_data0],
        'msos20_dfu_desc': [dfu_msos20_set_hdr, dfu_msos20_compat, dfu_msos20_reg]
    }

    script_dir = os.path.dirname(os.path.abspath(__file__))
    target_output_dir = os.path.normpath(os.path.join(script_dir, "..","usb3_2_user_layer", "descriptors"))

    generate_usb3_dat_files(desc_data, strings_config, prefix="usb_desc_RWBW+DFU", output_dir=target_output_dir)
    print(f"成功生成！路径: {target_output_dir}")
# =========================================================================
# usb_desc_lib/constants.py
# =========================================================================

# --- 1. 标准描述符类型 (Standard Descriptor Types) ---
DESC_TYPE_DEVICE                        = 0x01
DESC_TYPE_CONFIG                        = 0x02
DESC_TYPE_STRING                        = 0x03
DESC_TYPE_INTERFACE                     = 0x04
DESC_TYPE_ENDPOINT                      = 0x05
DESC_TYPE_DEVICE_QUALIFIER              = 0x06
DESC_TYPE_OTHER_SPEED_CONFIG            = 0x07
DESC_TYPE_INTERFACE_POWER               = 0x08
DESC_TYPE_IAD                           = 0x0B
DESC_TYPE_BOS                           = 0x0F
DESC_TYPE_DEVICE_CAPABILITY             = 0x10
DESC_TYPE_SS_ENDPOINT_COMPANION         = 0x30

# --- 2. UAC 描述符类型 (Audio Specific Descriptor Types) ---
CS_INTERFACE                            = 0x24
CS_ENDPOINT                             = 0x25

# --- 3. UAC 音频控制接口子类型 (Audio Control Interface Subtypes) ---
AC_SUBTYPE_HEADER                       = 0x01
AC_SUBTYPE_INPUT_TERMINAL               = 0x02
AC_SUBTYPE_OUTPUT_TERMINAL              = 0x03
AC_SUBTYPE_MIXER_UNIT                   = 0x04
AC_SUBTYPE_SELECTOR_UNIT                = 0x05
AC_SUBTYPE_FEATURE_UNIT                 = 0x06
AC_SUBTYPE_EFFECT_UNIT                  = 0x07
AC_SUBTYPE_PROCESSING_UNIT              = 0x08
AC_SUBTYPE_EXTENSION_UNIT               = 0x09
AC_SUBTYPE_CLOCK_SOURCE                 = 0x0A
AC_SUBTYPE_CLOCK_SELECTOR               = 0x0B
AC_SUBTYPE_CLOCK_MULTIPLIER             = 0x0C
AC_SUBTYPE_SAMPLE_RATE_CONVERTER        = 0x0D

# --- 4. UAC 音频流接口子类型 (Audio Streaming Interface Subtypes) ---
AS_SUBTYPE_AS_GENERAL                   = 0x01
AS_SUBTYPE_FORMAT_TYPE                  = 0x02
AS_SUBTYPE_ENCODER                      = 0x03
AS_SUBTYPE_DECODER                      = 0x04

# --- 5. UAC 端点子类型 (Audio Endpoint Subtypes) ---
EP_SUBTYPE_EP_GENERAL                   = 0x01

# --- 6. 常用终端类型 (Terminal Types) ---
TERM_TYPE_USB_UNDEFINED                 = 0x0100
TERM_TYPE_USB_STREAMING                 = 0x0101
TERM_TYPE_USB_VENDOR_SPEC               = 0x01FF
TERM_TYPE_IN_MICROPHONE                 = 0x0201
TERM_TYPE_IN_DESKTOP_MIC                = 0x0202
TERM_TYPE_OUT_SPEAKER                   = 0x0301
TERM_TYPE_OUT_HEADPHONES                = 0x0302
TERM_TYPE_EXT_LINE_CONNECTOR            = 0x0603
TERM_TYPE_EXT_DIGITAL_AUDIO_INTF        = 0x0605

# --- 7. UAC 2.0 音频功能类别 (Audio Function Category Codes) ---
UAC2_FUNCTION_UNDEF                     = 0x00
UAC2_FUNCTION_DESKTOP_SPEAKER           = 0x01
UAC2_FUNCTION_HOME_THEATER              = 0x02
UAC2_FUNCTION_MICROPHONE                = 0x03
UAC2_FUNCTION_HEADSET                   = 0x04
UAC2_FUNCTION_TELEPHONE                 = 0x05
UAC2_FUNCTION_CONVERTER                 = 0x06
UAC2_FUNCTION_SOUND_RECORDER            = 0x07
UAC2_FUNCTION_IO_BOX                    = 0x08
UAC2_FUNCTION_MUSICAL_INSTRUMENT        = 0x09
UAC2_FUNCTION_PRO_AUDIO                 = 0x0A
UAC2_FUNCTION_AUDIO_VIDEO               = 0x0B
UAC2_FUNCTION_CONTROL_PANEL             = 0x0C
UAC2_FUNCTION_OTHER                     = 0x0D

# --- 8. USB 标准设备/接口类代码 (Class/SubClass/Protocol) ---

# Misc / IAD 设备级代码 (Device Descriptor)
CLASS_MISC                              = 0xEF
SUBCLASS_COMMON                         = 0x02
PROTOCOL_IAD                            = 0x01

# Audio 功能级/接口级代码 (Function / Interface Descriptor)
CLASS_AUDIO                             = 0x01

# Audio 子类 (SubClass)
SUBCLASS_AUDIO_UNDEFINED                = 0x00  # 通常用于 IAD 的 Function SubClass
SUBCLASS_AUDIOCONTROL                   = 0x01  # Audio Control 接口
SUBCLASS_AUDIOSTREAMING                 = 0x02  # Audio Streaming 接口
SUBCLASS_MIDISTREAMING                  = 0x03  # MIDI Streaming 接口

# Audio 协议版本 (Protocol)
PROTOCOL_AUDIO_UAC1                     = 0x00  # UAC 1.0
PROTOCOL_AUDIO_UAC2                     = 0x20  # UAC 2.0

# --- 9. 端点方向掩码 (Endpoint Direction Masks) ---
EP_DIR_OUT                              = 0x00
EP_DIR_IN                               = 0x80
// Copyright (c) 2026 GOWIN SEMICONDUCTOR CORPORATION.
// SPDX-License-Identifier: MIT


package usb_std_pkg;
//==================================== bmRequestType =========================================    
localparam DIR_HOST_TO_DEVICE       = 1'b0 ;
localparam DIR_DEVICE_TO_HOST       = 1'b1 ;
    
localparam TYPE_STANDARD            = 2'h0 ;
localparam TYPE_CLASS               = 2'h1 ;
localparam TYPE_VENDOR              = 2'h2 ;
    
localparam RECIPIENT_DEVICE 	    = 5'h00 ;
localparam RECIPIENT_INTF	 	    = 5'h01 ;
localparam RECIPIENT_ENDPT	        = 5'h02 ;
localparam RECIPIENT_OTHER	        = 5'h02 ;

localparam GET_CLASS_INF 	        = 8'hA1 ;
localparam SET_CLASS_INF 	        = 8'h21 ;
//==================================== bRequest =========================================    
localparam GET_STATUS               = 8'h00  ;
localparam CLEAR_FEATURE            = 8'h01  ;
localparam SET_FEATURE              = 8'h03  ;
localparam SET_ADDRESS              = 8'h05 ; 
localparam GET_DESCRIPTOR           = 8'h06  ;
localparam SET_DESCRIPTOR           = 8'h07  ;
localparam GET_CONFIGURATION        = 8'h08  ;
localparam SET_CONFIGURATION        = 8'h09  ;
localparam GET_INTERFACE            = 8'h0A ;
localparam SET_INTERFACE            = 8'h0B ;
localparam SYNCH_FRAME              = 8'h0C ;
localparam SET_ENCRYPTION           = 8'h0D ;
localparam GET_ENCRYPTION           = 8'h0E ;
localparam SET_HANDSHAKE            = 8'h0F ;
localparam GET_HANDSHAKE            = 8'h10 ;
localparam SET_CONNECTION           = 8'h11 ;
localparam SET_SECURITY_DATA        = 8'h12 ;
localparam GET_SECURITY_DATA        = 8'h13 ;
localparam SET_WUSB_DATA            = 8'h14 ;
localparam LOOPBACK_DATA_WRITE      = 8'h15 ;
localparam LOOPBACK_DATA_READ       = 8'h16 ;
localparam SET_INTERFACE_DS         = 8'h17 ;
localparam SET_SEL                  = 8'h30 ;
localparam SET_ISOCH_DELAY          = 8'h31 ;

//==================================== wValue =========================================    
//GET_STATUS
localparam STANDARD_STATUS       = 8'h00 ;
localparam PTM_STATUS            = 8'h01 ;

//GET_DESCRIPTOR (High byte 15:8 )
localparam DEVICE_DESCRIPTOR_TYPE                                          = 8'h01   ;
localparam CONFIGURATION_DESCRIPTOR_TYPE                                   = 8'h02   ;
localparam STRING_DESCRIPTOR_TYPE                                          = 8'h03   ;
localparam INTERFACE_DESCRIPTOR_TYPE                                       = 8'h04   ;
localparam ENDPOINT_DESCRIPTOR_TYPE                                        = 8'h05   ;
localparam DEVICE_QUALIFIER_DESCRIPTOR_TYPE                                = 8'h06  ;// 未支持
localparam OTHER_SPEED_CONFIGURATION_DESCRIPTOR_TYPE                       = 8'h07  ;// 未支持
localparam INTERFACE_POWER_DESCRIPTOR_TYPE                                 = 8'h08   ;
localparam OTG_DESCRIPTOR_TYPE                                             = 8'h09   ;
localparam DEBUG_DESCRIPTOR_TYPE                                           = 8'h0A  ;
localparam INTERFACE_ASSOCIATION_DESCRIPTOR_TYPE                           = 8'h0B  ;
localparam BOS_DESCRIPTOR_TYPE                                             = 8'h0F  ;
localparam DEVICE_CAPABILITY_DESCRIPTOR_TYPE                               = 8'h10  ;
localparam SUPERSPEED_USB_ENDPOINT_COMPANION_DESCRIPTOR_TYPE               = 8'h30  ;
localparam SUPERSPEEDPLUS_ISOCHRONOUS_ENDPOINT_COMPANION_DESCRIPTOR_TYPE   = 8'h31  ;

//SET_FEATURE / CLEAR_FEATURE 
localparam ENDPOINT_HALT_FS         = 16'h0000;     // RECIPIENT_ENDPT
localparam FUNCTION_SUSPEND_FS      = 16'h0000;     // RECIPIENT_INTF
localparam DEVICE_REMOTE_WAKEUP_FS  = 16'h0001;
localparam TEST_MODE_FS             = 16'h0002;
localparam B_HNP_ENABLE_FS          = 16'h0003; 
localparam A_HNP_SUPPORT_FS         = 16'h0004; 
localparam A_ALT_HNP_SUPPORT_FS     = 16'h0005; 
localparam WUSB_DEVICE_FS           = 16'h0006; 
localparam U1_ENABLE_FS             = 16'h0030; 
localparam U2_ENABLE_FS             = 16'h0031; 
localparam LTM_ENABLE_FS            = 16'h0032; 
localparam B3_NTF_HOST_REL_FS       = 16'h0033; 
localparam B3_RSP_ENABLE_FS         = 16'h0034; 
localparam LDM_ENABLE_FS            = 16'h0035;
//==================================== wIndex =========================================    



endpackage
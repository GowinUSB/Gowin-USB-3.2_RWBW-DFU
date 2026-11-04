// Copyright (c) 2026 GOWIN SEMICONDUCTOR CORPORATION.
// SPDX-License-Identifier: MIT
package msos_pkg;

// bmRequestType
localparam GET_VENDOR_DEV           = 8'hC0;
localparam GET_VENDOR_INT           = 8'hC1;


// bRequest 
localparam VENDOR_CODE_10           = 8'h01;   //MSOS1.0 vendor
localparam VENDOR_CODE_20           = 8'h02;   //MSOS2.0 Vendor

//wValue    

//wIndex    
localparam GET_EXT_COMPAT_ID_SET    = 8'h04;
localparam GET_EXT_PROPERTIES_SET   = 8'h05;
localparam GET_DESCRIPTOR_SET       = 8'h07;

endpackage



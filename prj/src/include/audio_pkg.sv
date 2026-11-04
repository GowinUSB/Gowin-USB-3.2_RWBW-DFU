// Copyright (c) 2026 GOWIN SEMICONDUCTOR CORPORATION.
// SPDX-License-Identifier: MIT
package audio_pkg;
    localparam bit [31:0] SAMPLE_RATE_32    = 32'h00007D00;
    localparam bit [31:0] SAMPLE_RATE_44_1  = 32'h0000AC44;
    localparam bit [31:0] SAMPLE_RATE_48    = 32'h0000BB80;
    localparam bit [31:0] SAMPLE_RATE_64    = 32'h0000FA00;
    localparam bit [31:0] SAMPLE_RATE_88_2  = 32'h00015888;
    localparam bit [31:0] SAMPLE_RATE_96    = 32'h00017700;
    localparam bit [31:0] SAMPLE_RATE_128   = 32'h0001F400;
    localparam bit [31:0] SAMPLE_RATE_176_4 = 32'h0002B110;
    localparam bit [31:0] SAMPLE_RATE_192   = 32'h0002EE00;
    localparam bit [31:0] SAMPLE_RATE_352_8 = 32'h00056220;
    localparam bit [31:0] SAMPLE_RATE_384   = 32'h0005DC00;
    localparam bit [31:0] SAMPLE_RATE_705_6 = 32'h000AC440;
    localparam bit [31:0] SAMPLE_RATE_768   = 32'h000BB800;

    localparam bit [7:0]  DOP_PACKET_CODE0      = 8'h05 ;
    localparam bit [7:0]  DOP_PACKET_CODE1      = 8'hFA ;


//===============================================================================
// ============================================================================
// UAC Local Params
// ============================================================================
//==========================bmRequestType============================
localparam  GET_STAND_INTF         = 8'h81;
localparam  SET_STAND_INTF         = 8'h01;
localparam  GET_CLASS_INTF         = 8'hA1;
localparam  SET_CLASS_INTF         = 8'h21;
localparam  GET_CLASS_EP           = 8'hA2;
localparam  SET_CLASS_EP           = 8'h22;

localparam  SET_CUR                = 8'h01;
localparam  GET_CUR                = 8'h81;

//============================bRequest==================================
    //UAC1.1
localparam  SET_MIN                = 8'h02;
localparam  GET_MIN                = 8'h82;
localparam  SET_MAX                = 8'h03;
localparam  GET_MAX                = 8'h83;
localparam  SET_RES                = 8'h04;
localparam  GET_RES                = 8'h84;
    //UAC2.0
localparam  CUR                    = 8'h01;
localparam  RANGE                  = 8'h02;


//============================wValue====================================
localparam  CS_SAM_FREQ_CONTROL         = 8'h01;
localparam  CS_CLOCK_VALID_CONTROL      = 8'h02;
localparam  FU_MUTE_CONTROL             = 8'h01;
localparam  FU_VOLUME_CONTROL           = 8'h02;
localparam  CX_CLOCK_SELECTOR_CONTROL   = 8'h01;
localparam  AS_VAL_ALT_SETTINGS_CONTROL = 8'h02;

localparam  CN0                      = 8'h00;
localparam  CN1                      = 8'h01;
localparam  CN2                      = 8'h02;



// UAC 2.0 采样率配置
localparam int NUM_FREQS = 12;
localparam int LEN_FREQS = 12 * NUM_FREQS + 2 ;
localparam logic [31:0] SUPPORTED_FREQS [NUM_FREQS] = '{
    SAMPLE_RATE_44_1,  SAMPLE_RATE_48, 
    SAMPLE_RATE_64,    SAMPLE_RATE_88_2,  SAMPLE_RATE_96, 
    SAMPLE_RATE_128,   SAMPLE_RATE_176_4, SAMPLE_RATE_192, 
    SAMPLE_RATE_352_8, SAMPLE_RATE_384,   SAMPLE_RATE_705_6, 
    SAMPLE_RATE_768
};


localparam  VOLUME_NUM               = 16'h0001;
localparam  VOLUME_FS_MIN            = 16'hD200;
localparam  VOLUME_FS_MAX            = 16'h0000;
localparam  VOLUME_FS_RES            = 16'h0300;

localparam  VOLUME_HS_MAX            = 16'h0000;
localparam  VOLUME_HS_MIN            = 16'hC080;
localparam  VOLUME_HS_RES            = 16'h0080;



// ============================================================================
// UAC 2.0 采样率 ROM 自动生成逻辑 (USB3.2 专用)
// ============================================================================
// 64bit 下所需长度
localparam int UAC_FREQ_ROM_DEPTH = (LEN_FREQS + 7) / 8; 

typedef logic [63:0] freq_rom_t [0:UAC_FREQ_ROM_DEPTH-1];
function automatic freq_rom_t build_freq_rom();
    freq_rom_t rom; //64BIT
    logic [UAC_FREQ_ROM_DEPTH*64-1:0] flat_data; 
    
    flat_data = '0; 

// 2 + NUM_FREQS*（4 MIN + 4MAX + 4 RES ） 
    flat_data[15:0] = NUM_FREQS[15:0]; 
    for (int i = 0; i < NUM_FREQS; i++) begin
        flat_data[ (2 + i*12)*8 +: 32 ] = SUPPORTED_FREQS[i]; // MIN 
        flat_data[ (6 + i*12)*8 +: 32 ] = SUPPORTED_FREQS[i]; // MAX 
        // flat_data[ (10 + i*12)*8 +: 32 ] = 0; // RES
    end
    

    for (int j = 0; j < UAC_FREQ_ROM_DEPTH; j++) begin
        rom[j] = flat_data[j*64 +: 64];
    end
    
    return rom;
endfunction

localparam freq_rom_t UAC_FREQ_RANGE_ROM = build_freq_rom();

// ============================================================================

// ------------------------------------------------------------------------
// 新增：用于内部模块传递的简化采样率/位宽
// ------------------------------------------------------------------------
//采样率枚举
typedef enum logic [3:0] {
     FREQ_32K        =   4'd0
    ,FREQ_44_1K      =   4'd1
    ,FREQ_48K        =   4'd2
    ,FREQ_64K        =   4'd3
    ,FREQ_88_2K      =   4'd4
    ,FREQ_96K        =   4'd5
    ,FREQ_128K       =   4'd6
    ,FREQ_176_4K     =   4'd7
    ,FREQ_192K       =   4'd8
    ,FREQ_352_8K     =   4'd9
    ,FREQ_384K       =   4'd10
    ,FREQ_705_6K     =   4'd11
    ,FREQ_768K       =   4'd12
    ,FREQ_RSVD       =   4'd15 
} sample_freq_e;

//位深枚举
typedef enum logic [1:0] {
     DEPTH_16B = 2'd0
    ,DEPTH_24B = 2'd1
    ,DEPTH_32B = 2'd2
    ,DEPTH_RSVD= 2'd3
} data_depth_e;

//配置结构体
typedef struct packed {
    sample_freq_e  freq;   // [5:2] 4bit
    data_depth_e   depth;  // [1:0] 2bit
} uac_audio_cfg_t;

endpackage
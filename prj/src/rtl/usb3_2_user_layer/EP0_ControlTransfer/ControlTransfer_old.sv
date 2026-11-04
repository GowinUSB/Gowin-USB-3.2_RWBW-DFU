// Copyright (c) 2026 GOWIN SEMICONDUCTOR CORPORATION.
// SPDX-License-Identifier: MIT

import usb_std_pkg::*;
import dfu_pkg::*;
import cdc_pkg::*;
import msos_pkg::*;
`include "descriptors/usb_desc_BULK+DFU.vh"

`include "../../include/USB_EP0_config.vh"

//===========================================
module ControlTransfer #(
    parameter bit ENABLE_MSOS = 1'b1
   ,parameter bit ENABLE_DFU  = 1'b1
)(
	 input   logic 	      clk 
	,input   logic          rst_n

	// requests
	,input   logic			   request_active 	
	,input   logic	[7:0]	   bmRequestType	
	,input   logic	[7:0]	   bRequest		
	,input   logic	[15:0]	wValue			
	,input   logic	[15:0]	wIndex			
	,input   logic	[15:0]	wLength	
	,input   logic				wait_user_commit_request
	,output  logic          request_commit  

	// ep0 IN  
   ,output  logic          transfer_in_mem_wr              
   ,output  logic [7:0]    transfer_in_mem_wr_mask       
   ,output  logic [13:0]   transfer_in_mem_wr_addr       	
   ,output  logic [63:0]   transfer_in_mem_wr_data       		 	
   ,output  logic          transfer_in_mem_commit        		
   ,output  logic [16:0]   transfer_in_mem_commit_len    	
   ,input   logic          transfer_in_mem_ready         
   ,input   logic          transfer_in_done            
   
	// ep0 OUT	
   ,input   logic          transfer_out_mem_has_data    
   ,input   logic [16:0]   transfer_out_mem_len        
   ,output  logic [13:0]   transfer_out_mem_rd_addr    
   ,input   logic [63:0]   transfer_out_mem_rd_data    
   ,output  logic          transfer_out_mem_clr        
 
	,output logic  [7:0]    current_config_value
	,output logic  		   set_interface
	,output logic  [15:0]   set_interface_num 
	,output logic  [15:0]   set_interface_alt_setting

// DFU Control  
`ifdef ENABLE_DFU
   ,input  logic           i_dfu_mode          // 重枚举后 进入 1：DFU_mode 0：APP_mode
   ,output logic           o_dfu_detach_flag   // 接收DFU_DETACH指令
    // EP0 DFU DATA     
    ,output logic           o_dfu_spi_wr_req    // 写请求
    ,input  logic           i_dfu_spi_wr_ack    // 写应答
    ,output logic           o_dfu_spi_wr_flush  // 强制刷写Flash 
    ,output logic [31:0]    o_dfu_spi_lba       // 逻辑块地址 (512B为单位)
    ,input  logic [8:0]     i_dfu_spi_buf_addr  // Flash控制器给出的读地址
    ,output logic [7:0]     o_dfu_spi_buf_rdata // 输出给Flash控制器的数据
`endif

)/*synthesis syn_ramstyle="block_ram"*/;


localparam ST_W                     =  4     ;
localparam ST_IDLE                  =  4'd0  ;
localparam ST_SETUP_STAGE           =  4'd1  ;
localparam ST_DATA_IN_STAGE         =  4'd2  ;
localparam ST_DATA_IN_STAGE_PREP    =  4'd3  ;
localparam ST_DATA_IN_STAGE_LEN_CAL =  4'd4  ;
localparam ST_DATA_IN_STAGE_COMMIT  =  4'd5  ;
localparam ST_DATA_OUT_STAGE        =  4'd6  ;
localparam ST_DATA_OUT_STAGE_PREP   =  4'd7  ;
localparam ST_DATA_OUT_STAGE_COMMIT =  4'd8  ;
localparam ST_CMT_REQ               =  4'd9  ;

logic [ST_W-1:0] state ;

//STD
// usb_std_pkg.sv
//CDC
// cdc_pkg.sv
//DFU
// MSOS_PKG.sv

localparam BYTE = 8'b0 ;

typedef struct packed {
    logic [ 7:0] bmRequestType;
    logic [ 7:0] bRequest;
    logic [15:0] wValue;
    logic [15:0] wIndex;
    logic [15:0] wLength;
} usb_setup_pkt_t;

usb_setup_pkt_t setup_pkt_latch;

logic [47:0] route_word;
// 拼接顺序：[RequestType 8] + [Request 8]  + [wValue 16] + [wIndex 16]
assign route_word = {setup_pkt_latch.bmRequestType, setup_pkt_latch.bRequest, setup_pkt_latch.wValue , setup_pkt_latch.wIndex};

//DFU相关参数
logic [7:0]    dfu_state ; 
logic          flash_trigger = 0;
logic [27:0]   detach_delay_cnt = 0;
// 适配 USB3 的 64-bit 宽 BRAM，深度 64 (即 512 Bytes)
logic [63:0]   dfu_ram [0:63] /*synthesis syn_ramstyle="block_ram"*/;
logic          detach_trigger;
logic [27:0]   disconnect_timer;   // 500ms 断开总线延时计数器

typedef enum logic [7:0] {
    CMD_IDLE
//=================== 标准类 =======================
   ,CMD_STD_GET_STATUS              // bRequest = 0x00  
   ,CMD_STD_CLEAR_FEATURE           // bRequest = 0x01
   ,CMD_STD_SET_FEATURE             // bRequest = 0x03
   ,CMD_STD_GET_DESC                // bRequest = 0x06
   ,CMD_STD_GET_CFG                 // bRequest = 0x08
   ,CMD_STD_SET_CFG                 // bRequest = 0x09
   ,CMD_STD_GET_INTF                // bRequest = 0x0A
   ,CMD_STD_SET_INTF                // bRequest = 0x0B
//usb3.0
   ,CMD_STD_SET_SEL                 // bRequest = 0x30
   ,CMD_STD_SET_ISOCH_DELAY         // bRequest = 0x31
//=================== 特定类 ======================
// Vendor Class
   ,CMD_GET_MS_OS10_COMPAT_ID       //11
   ,CMD_GET_MS_OS10_EXT_PROPERTIES
   ,CMD_GET_MS_OS20_DES
//UAC
`ifdef ENABLE_UAC
   ,CMD_SET_SAM_FREQ
   ,CMD_GET_SAM_FREQ
   ,CMD_GET_SAM_FREQ_RANGE
   ,CMD_SET_MUTE
   ,CMD_GET_MUTE
   ,CMD_SET_VOL
   ,CMD_GET_VOL_CUR
   ,CMD_GET_VOL_MAX
   ,CMD_GET_VOL_MIN
   ,CMD_GET_VOL_RES
   ,CMD_GET_VOL_RANGE 
   ,CMD_GET_CLK_VALID
   ,CMD_GET_VAL_ALT_SET
`endif
// UMS
`ifdef ENABLE_UMS
   ,CMD_UMS_GET_MAX_LUN          
`endif
// CDC
`ifdef ENABLE_CDC
   ,CMD_CDC_GET_LINE_CODING
   ,CMD_CDC_SET_LINE_CODING
`endif
// DFU
`ifdef ENABLE_DFU
   ,CMD_DFU_DETACH               
   ,CMD_DFU_DNLOAD
   ,CMD_DFU_GETSTATUS 
   ,CMD_DFU_CLRSTATUS 
`endif
} active_cmd_e;

active_cmd_e active_cmd;

//========================================================================================================================================================================================================================================================================
// Overall Structure Description
//1) SETUP解析  
//2) 数据状态机
//3) 内部寄存 （标准+特定）
//4) 外部通信 （标准+特定）


logic [15:0] transfer_len ;
logic        transfer_out_mem_rd ;
logic [15:0] transfer_len_mux_out ; //本次传输实际长度
logic [15:0] ep0_bytes_left; // 当前指令数据阶段剩余数据长度 （OUT/IN）


logic [15:0] transfer_out_mem_len_latch ;



logic            transfer_out_data_val ;
logic [63:0]     transfer_out_data ;
logic [15-2:0]   transfer_out_data_pt ;

logic [7:0]  U1SEL ;
logic [7:0]  U1PEL ;
logic [15:0] U2SEL ;
logic [15:0] U2PEL ;

logic [15:0] Delay ;

logic u1_enable ;
logic u2_enable ;
logic remoke_wakeup ;
logic LTM_enable ;

logic self_powered = 1 ; 
logic function_remote_wakeup = 0 ; 
logic function_remote_wakeup_capable = 0 ;
logic [15:0] LDM_Link_Delay = 0 ;
logic LDM_enable = 0 ;
logic LDM_valid = 0 ;

logic [63:0] device_standard_status       ;
logic [63:0] interface_standard_status    ;
logic [63:0] endpoint_standard_status     ;
logic [63:0] endpoint_PTM_status          ; 
logic [7:0] configuration_value ;


logic [63:0] transfer_in_data_mux ;
logic [13:0] transfer_in_data_mux_rd_addr ;

logic Halt = 0 ;

integer i ;

//===================================================================================================================================================================================
// 1) SETUP解析   
//    解析外部IO输入，输出长度 + CMD
//====================================================================================================================================================================================
logic [15:0] route_req_len;   // 查表得出的传输长度
// SETUP 命令解析
always_comb begin
   active_cmd           =    CMD_IDLE ;  
      unique casez (route_word)
//====================================== [标准请求] =============================================//
            //Get Descriptor  80 06 XX
            //备注：modelsim 似乎不支持 16'b?的写法
            {8'b1000_00??, GET_DESCRIPTOR, 16'h????, 16'h????} :                             active_cmd      = CMD_STD_GET_DESC;
            // Get Status (支持 Device, Interface, Endpoint)
            {8'b1000_00??, GET_STATUS, {8'h00, STANDARD_STATUS}, 16'h????} :                 active_cmd    = CMD_STD_GET_STATUS; 
            {8'b1000_00??, GET_STATUS, {8'h00, PTM_STATUS},      16'h????} :                 active_cmd    = CMD_STD_GET_STATUS; 

            //Set / Clear Feature (U1, U2, Wakeup, LTM)
            // Set Feature (device)
            {8'b0000_0000, SET_FEATURE, U1_ENABLE_FS,            16'h????},
            {8'b0000_0000, SET_FEATURE, U2_ENABLE_FS,            16'h????},
            {8'b0000_0000, SET_FEATURE, DEVICE_REMOTE_WAKEUP_FS, 16'h????},
            {8'b0000_0000, SET_FEATURE, LTM_ENABLE_FS,           16'h????} :                 active_cmd = CMD_STD_SET_FEATURE; 
            // Clear Feature (device)
            {8'b0000_0000, CLEAR_FEATURE, U1_ENABLE_FS,            16'h????},
            {8'b0000_0000, CLEAR_FEATURE, U2_ENABLE_FS,            16'h????},
            {8'b0000_0000, CLEAR_FEATURE, DEVICE_REMOTE_WAKEUP_FS, 16'h????},
            {8'b0000_0000, CLEAR_FEATURE, LTM_ENABLE_FS,           16'h????} :              active_cmd = CMD_STD_CLEAR_FEATURE; 
            //后续可以考虑加入 endpoint 以及 interface 的 SET/CLEAR FEATURE? 

            // Configuration (Get / Set)
            {8'b1000_0000, GET_CONFIGURATION, 16'h????, 16'h????} :                          active_cmd      = CMD_STD_GET_CFG;
            {8'b0000_0000, SET_CONFIGURATION, 16'h????, 16'h????} :                          active_cmd      = CMD_STD_SET_CFG;

            // Interface (Get / Set)
            {8'b1000_0001, GET_INTERFACE, 16'h????, 16'h????} :                              active_cmd      = CMD_STD_GET_INTF;

            {8'b0000_0001, SET_INTERFACE, 16'h????, 16'h????} :                              active_cmd      = CMD_STD_SET_INTF;

            // Set SEL
            {8'b0000_0000, SET_SEL, 16'h????, 16'h????} :                                    active_cmd      = CMD_STD_SET_SEL;

            // Set Isochronous Delay
            {8'b0000_0000, SET_ISOCH_DELAY, 16'h????, 16'h????} :                            active_cmd      = CMD_STD_SET_ISOCH_DELAY;


//====================================== [特定类请求] =============================================//
   // 处理 Windows 的获取 Compat ID 厂商请求
            {GET_VENDOR_DEV  , VENDOR_CODE_10, 16'h0000 , {8'h00, GET_EXT_COMPAT_ID_SET}    }              : active_cmd <= CMD_GET_MS_OS10_COMPAT_ID;
            {GET_VENDOR_INT  , VENDOR_CODE_10, 16'h???? , {8'h00, GET_EXT_PROPERTIES_SET}   }              : active_cmd <= CMD_GET_MS_OS10_EXT_PROPERTIES;
            {GET_VENDOR_DEV  , VENDOR_CODE_20, 16'h?    , {8'h00, GET_DESCRIPTOR_SET}       }              : active_cmd <= CMD_GET_MS_OS20_DES;

   // ----------------------------------------------------------------
   // CDC 请求
   // ----------------------------------------------------------------
   `ifdef ENABLE_CDC
            // Get / Set Line Coding
            {GET_CLASS_INF, GET_LINE_CODING, 16'h????, 16'h????} :                        active_cmd      = CMD_CDC_GET_LINE_CODING;
            {SET_CLASS_INF, SET_LINE_CODING, 16'h????, 16'h????} :                        active_cmd      = CMD_CDC_SET_LINE_CODING;
   `endif
   // ----------------------------------------------------------------
   // DFU 请求
   // ----------------------------------------------------------------
   `ifdef ENABLE_DFU
            {SET_CLASS_INF, DFU_DETACH,      16'h????, 16'h????} :                        active_cmd = CMD_DFU_DETACH;      // DFU_DETACH
            {SET_CLASS_INF, DFU_DNLOAD,      16'h????, 16'h????} :                        active_cmd = CMD_DFU_DNLOAD;      // DFU_DNLOAD
            {GET_CLASS_INF, DFU_GETSTATUS,   16'h????, 16'h????} :                        active_cmd = CMD_DFU_GETSTATUS;   // DFU_GETSTATUS
            {SET_CLASS_INF, DFU_CLRSTATUS,   16'h????, 16'h????} :                        active_cmd = CMD_DFU_CLRSTATUS;   // DFU_CLRSTATUS
   `endif

            default: begin
                active_cmd      = CMD_IDLE;
            end
      endcase
   // end
end

//拆分上下两者，目的是将 长度判断 与 48bit拼接字 隔离 ，优化时序
always_comb begin
   // 传输长度大部分时候都等效于 wLength
   // 除了 一堆描述符/UAC/UVC/DFU均存在特殊短包机制
   route_req_len = setup_pkt_latch.wLength;  
//====================================== [标准请求] =============================================//
   unique case (active_cmd)
      CMD_STD_GET_STATUS:      route_req_len = (setup_pkt_latch.wValue[7:0] == STANDARD_STATUS) ? 16'd2 : 16'd4;
      CMD_STD_GET_DESC: begin
         case (setup_pkt_latch.wValue[15:8])
            DEVICE_DESCRIPTOR_TYPE:        route_req_len = i_dfu_mode ? `DESCR_USB3_DFU_DEVICE_LEN : `DESCR_USB3_DEVICE_LEN;
            CONFIGURATION_DESCRIPTOR_TYPE: route_req_len = i_dfu_mode ? `DESCR_USB3_DFU_CONFIG_LEN : `DESCR_USB3_CONFIG_LEN;
            BOS_DESCRIPTOR_TYPE:           route_req_len = i_dfu_mode ? `DESCR_USB3_DFU_BOS_LEN : `DESCR_USB3_BOS_LEN;
            STRING_DESCRIPTOR_TYPE: begin
               case (setup_pkt_latch.wValue[7:0])
                  0: route_req_len        =  `DESCR_USB3_STR0_LEN;
                  1: route_req_len        =  `DESCR_USB3_STR1_LEN;
                  2: route_req_len        =  `DESCR_USB3_STR2_LEN;
                  3: route_req_len        =  `DESCR_USB3_STR3_LEN;
                  4: route_req_len        =  `DESCR_USB3_STR4_LEN;
                  5: route_req_len        =  `DESCR_USB3_STR5_LEN;
                  6: route_req_len        =  `DESCR_USB3_STR6_LEN;
                  238: route_req_len      =  `DESCR_USB3_MSFT_LEN;  
                  default: route_req_len  =  `DESCR_USB3_STR0_LEN; 
               endcase
            end
            default: ; 
         endcase
      end
      CMD_STD_GET_CFG:                 route_req_len = 16'd1;
      CMD_STD_GET_INTF:                route_req_len = 16'd1;
//====================================== [特定类请求] =============================================//
   // Vendor Class 厂商自定义
      CMD_GET_MS_OS10_COMPAT_ID      :    route_req_len = i_dfu_mode ? `DESCR_USB3_MSOS10_DFU_compatibleID_LEN 
                                                                     : `DESCR_USB3_MSOS10_APP_compatibleID_LEN;
                                                                     
      CMD_GET_MS_OS10_EXT_PROPERTIES :    route_req_len = i_dfu_mode ? `DESCR_USB3_MSOS10_DFU_INT0_Extend_Pro_LEN 
                                                                     : ((setup_pkt_latch.wValue[7:0] == 8'h0) ? `DESCR_USB3_MSOS10_APP_INT0_Extend_Pro_LEN :
                                                                                                                `DESCR_USB3_MSOS10_APP_INT1_Extend_Pro_LEN);
                                                                     
      CMD_GET_MS_OS20_DES            :    route_req_len = i_dfu_mode ? `DESCR_USB3_MSOS20_DFU_DES_LEN 
                                                                     : `DESCR_USB3_MSOS20_APP_DES_LEN;

   // ----------------------------------------------------------------
   // CDC 请求
   // ----------------------------------------------------------------
      CMD_CDC_GET_LINE_CODING       : route_req_len = 16'd7;


      CMD_DFU_GETSTATUS             : route_req_len = 16'd6;
      default: ; 
   endcase
end



//===================================================================================================================================================================================
// 2) 数据状态机
// SETUP指令 → 数据阶段（0/OUT/IN）→ 状态阶段
// ST_IDLE   ==>  ST_SETUP_STAGE ==> ST_CMT_REQ (0长度 结束)
//                               ==> ST_DATA_IN_STAGE_PREP (BRAM延迟)   ==> ST_DATA_IN_STAGE ==> ST_DATA_IN_STAGE_COMMIT
//                               ==> ST_DATA_OUT_STAGE_PREP (等hasdata) ==> ST_DATA_OUT_STAGE ++> ST_DATA_OUT_STAGE_COMMIT
//====================================================================================================================================================================================
logic st_setup_done;    // SETUP   阶段解析完毕   （CMD/length已就绪）
logic st_data_out_done; // 数据OUT 阶段接收完毕   （主机发给设备的数据已存入 RAM）
logic st_data_in_done;  // 数据in  阶段发送完毕   （设备发给主机的数据已完成）
logic st_status_done;   // 状态应答阶段完毕       (未使用)


always_ff @ ( posedge clk or negedge rst_n ) begin
   if ( !rst_n ) begin
      state                         <= ST_IDLE ;
      
      setup_pkt_latch.bmRequestType	<=  0 ; 
      setup_pkt_latch.bRequest		<=  0 ;
      setup_pkt_latch.wValue			<=  0 ;
      setup_pkt_latch.wIndex			<=  0 ;
      setup_pkt_latch.wLength	      <=  0 ;
               
      transfer_len                  <= 0 ;
         
      transfer_in_mem_wr            <= 0 ;
      transfer_in_mem_wr_mask       <= 0 ;
      transfer_in_mem_wr_addr       <= 0 ;
      transfer_in_mem_wr_data       <= 0 ;
      transfer_in_mem_commit        <= 0 ;
      transfer_in_mem_commit_len    <= 0 ;
      
      transfer_out_mem_rd           <= 0 ;
      transfer_out_mem_rd_addr      <= 0 ;
      transfer_out_mem_clr          <= 0 ;   

      request_commit                <= 0 ;     
      st_setup_done                <= 0 ;
      st_data_out_done             <= 0 ;
      st_data_in_done              <= 0 ;
   end
   else begin
      st_setup_done                <= 0 ;
      st_data_out_done             <= 0 ;
      st_data_in_done              <= 0 ;


      case ( state ) 
      ST_IDLE:begin
         if (request_active) begin
            state                         <= ST_SETUP_STAGE;
            setup_pkt_latch.bmRequestType <= bmRequestType;
            setup_pkt_latch.bRequest      <= bRequest;
            setup_pkt_latch.wValue        <= wValue;
            setup_pkt_latch.wIndex        <= wIndex;
            setup_pkt_latch.wLength       <= wLength;
         end

         transfer_len                  <= 0 ;
            
         transfer_in_mem_wr            <= 0 ;
         transfer_in_mem_wr_mask       <= 0 ;
         transfer_in_mem_wr_addr       <= 0 ;
         transfer_in_mem_wr_data       <= 0 ;
         transfer_in_mem_commit        <= 0 ;
         transfer_in_mem_commit_len    <= 0 ;
         
         transfer_out_mem_rd           <= 0 ;
         transfer_out_mem_rd_addr      <= 0 ;
         transfer_out_mem_clr          <= 0 ;   

         request_commit <= 0 ;  
      end            

      // ---------------- [解析阶段] ----------------
      ST_SETUP_STAGE: begin
         if ( active_cmd != CMD_IDLE ) begin
            st_setup_done <= 1;
            request_commit <= 1;

            //确定数据阶段 实际长度
            transfer_len_mux_out <= (route_req_len < setup_pkt_latch.wLength) ? route_req_len : setup_pkt_latch.wLength;
            ep0_bytes_left       <= (route_req_len < setup_pkt_latch.wLength) ? route_req_len : setup_pkt_latch.wLength;

            transfer_len   <= route_req_len; 
            state          <= ST_CMT_REQ;
         end 
         else begin
            // 遇到不支持的请求 (丢弃或 STALL？ )
            request_commit <= 0;
            transfer_len   <= 0;
            state          <= ST_IDLE; 
         end
      end
      ST_CMT_REQ :begin
         request_commit <= 0 ;
         if ( !request_commit ) begin  
            state <= ST_IDLE ;      // 避免异常进入该状态
         end
         else begin       
            // state <= ( setup_pkt_latch.wLength != 0 && setup_pkt_latch.bmRequestType[7] == DIR_HOST_TO_DEVICE ) ? ST_DATA_OUT_STAGE_PREP    : 
            //          ( setup_pkt_latch.wLength != 0 && setup_pkt_latch.bmRequestType[7] == DIR_DEVICE_TO_HOST ) ? ST_DATA_IN_STAGE_LEN_CAL  : 
            //          ST_IDLE ;
            if (setup_pkt_latch.wLength == 0) begin
                state <= ST_IDLE;                  // 无数据阶段，直接等待下一包或底层自动发状态阶段 0长包
            end 
            else if (setup_pkt_latch.bmRequestType[7] == DIR_HOST_TO_DEVICE) begin
                state <= ST_DATA_OUT_STAGE_PREP;   // 等待接收 OUT 数据
            end 
            else begin //(setup_pkt_latch.bmRequestType[7] == DIR_DEVICE_TO_HOST)
                state <= ST_DATA_IN_STAGE_PREP;    // 准备发送 IN 数据 (给RAM寻址留1拍)
            end
         end
      end

   // ---------------- [IN 数据阶段] ----------------
     ST_DATA_IN_STAGE_PREP: begin
         state <= ST_DATA_IN_STAGE;
     end

     ST_DATA_IN_STAGE: begin
         transfer_in_mem_wr            <= 1;
         transfer_in_mem_wr_mask       <= 0 ;
         transfer_in_mem_wr_addr <= transfer_in_mem_wr ? transfer_in_mem_wr_addr + 1 : transfer_in_mem_wr_addr;
         transfer_in_mem_wr_data <= transfer_in_data_mux;
         transfer_in_mem_commit        <= 0 ;
         transfer_in_mem_commit_len    <= 0 ;   
         
         if (ep0_bytes_left <= 16'd8) begin //等效于 data_in_stage_end
             state <= ST_DATA_IN_STAGE_COMMIT;
         end 
         else begin
             ep0_bytes_left <= ep0_bytes_left - 16'd8;
         end

     end

      ST_DATA_IN_STAGE_COMMIT: begin
         st_data_in_done              <= 1; // IN 数据发送完成

         transfer_in_mem_wr            <= 0;
         transfer_in_mem_wr_mask       <= 0 ;
         transfer_in_mem_wr_addr       <= 0;
         transfer_in_mem_wr_data       <= 0 ;
         transfer_in_mem_commit        <= 1;
         transfer_in_mem_commit_len    <= transfer_len_mux_out;
         state                         <= ST_IDLE;
      end

   // ---------------- [OUT 数据阶段] ----------------
      ST_DATA_OUT_STAGE_PREP: begin
          if (transfer_out_mem_has_data) begin
              state <= ST_DATA_OUT_STAGE;         
          end
      end

      ST_DATA_OUT_STAGE: begin
         transfer_out_mem_rd      <= (transfer_out_mem_has_data ) ? 1 : 0;
         transfer_out_mem_rd_addr <= (transfer_out_mem_has_data ) ? transfer_out_mem_rd_addr + 1 : transfer_out_mem_rd_addr;
         transfer_out_mem_clr          <= 0 ; 

         if (transfer_out_mem_has_data) begin
             if (ep0_bytes_left <= 16'd8) begin //等效于data_out_stage_end
                 state <= ST_DATA_OUT_STAGE_COMMIT;
             end 
             else begin
                 ep0_bytes_left <= ep0_bytes_left - 16'd8;
             end
         end
      end

      ST_DATA_OUT_STAGE_COMMIT: begin
         st_data_out_done          <= 1; // OUT 数据接收完成，通知业务层可提取 RAM


         transfer_out_mem_rd        <= 0;
         transfer_out_mem_rd_addr   <= 0;
         transfer_out_mem_clr       <= 1;       
         state                      <= ST_IDLE;
      end

      default:;
      endcase 
   end
end

// passing through data and its index of data_stage of OUT transfer 
always_ff @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      transfer_out_data_val <= 0 ;
      transfer_out_data     <= 0 ;
   end
   else if ( transfer_out_mem_rd ) begin
      transfer_out_data_val <= 1 ;
      transfer_out_data     <= transfer_out_mem_rd_data ;
   end
   else begin
      transfer_out_data_val <= 0 ;
      transfer_out_data     <= 0 ; 
   end
end

always_ff @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      transfer_out_data_pt <= 0 ;
   end
   else if ( transfer_out_data_val ) begin
      transfer_out_data_pt <= transfer_out_data_pt + 1 ;
   end
   else begin
      transfer_out_data_pt <= 0 ;
   end
end



//===================================================================================================================================================================================
// 数据处理部分
// 主机 OUT 数据 →   active_cmd == XXX && state == ST_SETUP_STAGE 
// 主机 IN  数据 →   active_cmd == XXX && transfer_out_data_val  
//===================================================================================================================================================================================
//===================================================================================================================================================================================
// 3) 内部寄存 (标准+特定) 
//    用于寄存 标准协议下 特性标志，
//            特定协议下 配置数据。
//====================================================================================================================================================================================


//====================================== [标准请求] =============================================//
// 0x01 GET_STATUS request response
assign device_standard_status    = { {7{BYTE}}, 3'b0, LTM_enable, u2_enable, u1_enable, remoke_wakeup, self_powered };              // Get Status request response
assign interface_standard_status = { {7{BYTE}}, 6'b0, function_remote_wakeup, function_remote_wakeup_capable };                     
assign endpoint_standard_status  = { {7{BYTE}}, 7'b0, Halt };                                                                       
assign endpoint_PTM_status       = { {4{BYTE}}, LDM_Link_Delay[15:8], LDM_Link_Delay[7:0], BYTE, 6'b0, LDM_valid, LDM_enable };     

// 0x01 Clear Feature request 
// 0x03 Set Feature request 
always_ff @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      u1_enable      <= 0 ;
      u2_enable      <= 0 ;
      remoke_wakeup  <= 0 ;
      LTM_enable     <= 0 ;
   end
   else if (state == ST_SETUP_STAGE ) begin
      if (active_cmd == CMD_STD_CLEAR_FEATURE) begin
         u1_enable       <= (setup_pkt_latch.wValue == U1_ENABLE_FS)              ? 0 : u1_enable;
         u2_enable       <= (setup_pkt_latch.wValue == U2_ENABLE_FS)              ? 0 : u2_enable;
         remoke_wakeup   <= (setup_pkt_latch.wValue == DEVICE_REMOTE_WAKEUP_FS)   ? 0 : remoke_wakeup;
         LTM_enable      <= (setup_pkt_latch.wValue == LTM_ENABLE_FS)             ? 0 : LTM_enable;      
      end
      else if (active_cmd == CMD_STD_SET_FEATURE) begin
         u1_enable       <= (setup_pkt_latch.wValue == U1_ENABLE_FS)              ? 1 : u1_enable;
         u2_enable       <= (setup_pkt_latch.wValue == U2_ENABLE_FS)              ? 1 : u2_enable;
         remoke_wakeup   <= (setup_pkt_latch.wValue == DEVICE_REMOTE_WAKEUP_FS)   ? 1 : remoke_wakeup;
         LTM_enable      <= (setup_pkt_latch.wValue == LTM_ENABLE_FS)             ? 1 : LTM_enable;      
      end
   end
end   

// 0x06 Get Descriptor request response
(* syn_ramstyle = "block_ram" *) logic [63:0] desc_rom [0:ROM_LEN-1]; // 根据实际总长度调整深度，改这个的时候留意下面rom_flat_addr的位数
initial begin
    $readmemh("./descriptors/usb_desc_BULK+DFU.dat", desc_rom);
end
logic [13:0] desc_base_addr;
always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        desc_base_addr <= 0;
    end 
    else if (state == ST_SETUP_STAGE) begin
        if ( active_cmd == CMD_STD_GET_DESC ) begin
            case (setup_pkt_latch.wValue[15:8])
                DEVICE_DESCRIPTOR_TYPE:        desc_base_addr <= i_dfu_mode ? DFU_DEVICE_DESC_BASE : DEVICE_DESC_BASE;
                CONFIGURATION_DESCRIPTOR_TYPE: desc_base_addr <= i_dfu_mode ? DFU_CONFIG_DESC_BASE : CONFIG_DESC_BASE;
                BOS_DESCRIPTOR_TYPE:           desc_base_addr <= i_dfu_mode ? DFU_BOS_DESC_BASE : BOS_DESC_BASE;
                STRING_DESCRIPTOR_TYPE: begin
                    case (setup_pkt_latch.wValue[7:0])
                        0: desc_base_addr <= STR0_DESC_BASE;
                        1: desc_base_addr <= STR1_DESC_BASE;
                        2: desc_base_addr <= STR2_DESC_BASE;     
                        3: desc_base_addr <= STR3_DESC_BASE;          
                        4: desc_base_addr <= STR4_DESC_BASE;          
                        5: desc_base_addr <= STR5_DESC_BASE;          
                        6: desc_base_addr <= STR6_DESC_BASE;   
                        238: desc_base_addr <= STRMSFT_DESC_BASE;   
                        default: desc_base_addr <= STR0_DESC_BASE;     
                    endcase
                end
            endcase
        end
         else if (active_cmd == CMD_GET_MS_OS10_COMPAT_ID) begin
            desc_base_addr <= i_dfu_mode ? MSOS10_DFU_COMPAT_ID_DESC_BASE 
                                         : MSOS10_APP_COMPAT_ID_DESC_BASE; 
        end
        else if (active_cmd == CMD_GET_MS_OS10_EXT_PROPERTIES) begin
            desc_base_addr <= i_dfu_mode ? MSOS10_DFU_INT0_EXT_DESC_BASE 
                                         : ((setup_pkt_latch.wValue[7:0] == 8'h0) ? MSOS10_APP_INT0_EXT_DESC_BASE : MSOS10_APP_INT1_EXT_DESC_BASE);
        end
        else if (active_cmd == CMD_GET_MS_OS20_DES) begin
            desc_base_addr <= i_dfu_mode ? MSOS20_DFU_DESC_BASE 
                                         : MSOS20_APP_DESC_BASE; 
        end

    end
end

// 0x08 Get Configuration request (直接赋值，可以改成assign)
// 0x09 Set Configuration request 
always_ff @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      configuration_value <= 0 ;
   end
   else if (  state == ST_SETUP_STAGE && active_cmd == CMD_STD_SET_CFG  ) begin
      configuration_value <= setup_pkt_latch.wValue[7:0] ;
   end   
end

// 0x0A Get Interface request 
// 0x0B Set Interface request
parameter   INTERFACE_NUM  =  3  ;
logic [7:0]  interface_alternate_setting     [0:INTERFACE_NUM-1];
always_ff @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      for (i = 0; i < INTERFACE_NUM; i = i + 1) begin
         interface_alternate_setting[i] <= 0 ;
      end
      set_interface                 <= 0 ;
      set_interface_num             <= 0 ;
      set_interface_alt_setting     <= 0 ;
   end
   else if (  state == ST_SETUP_STAGE && active_cmd == CMD_STD_SET_INTF ) begin
      if (setup_pkt_latch.wIndex < INTERFACE_NUM) begin
         interface_alternate_setting[setup_pkt_latch.wIndex] <= setup_pkt_latch.wValue[7:0] ;
      end
      set_interface                 <= 1 ;
      set_interface_num             <= setup_pkt_latch.wIndex ;
      set_interface_alt_setting     <= setup_pkt_latch.wValue  ;    
   end
   else begin
      set_interface                 <= 0 ;
   end
end

// 0x30 Set SEL request 
always_ff @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      U1SEL <= 0 ;
      U1PEL <= 0 ;
      U2SEL <= 0 ;
      U2PEL <= 0 ;
   end
   else if ( transfer_out_data_val && active_cmd == CMD_STD_SET_SEL) begin
      case ( transfer_out_data_pt ) 
      0: begin
         {U2PEL,U2SEL,U1PEL,U1SEL} <= transfer_out_data[(6*8-1)-:6*8] ;      
      end
      default:;
      endcase 
   end
end

// 0x31 Set Isochronous Delay request
always_ff @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      Delay <= 0 ;
   end
   else if ( state == ST_SETUP_STAGE && active_cmd == CMD_STD_SET_ISOCH_DELAY) begin
      Delay <= setup_pkt_latch.wValue ;
   end
end

//==================================== [特定类请求] ============================================//
   // ----------------------------------------------------------------
   // CDC 请求
   // ----------------------------------------------------------------
// Set Line Coding request 
logic [31:0] baud_rate;
logic [7:0] stop_bit;
logic [7:0] parity_type;
logic [7:0] data_bit;
always_ff @ ( posedge clk or negedge rst_n ) begin
   if ( !rst_n ) begin
      baud_rate   <= 32'd115200 ;
		stop_bit    <= 8'd0 ;
		parity_type <= 8'd0 ;
      data_bit    <= 8'd8 ;
   end
   else if ( transfer_out_data_val && active_cmd == CMD_CDC_SET_LINE_CODING ) begin
      case ( transfer_out_data_pt ) 
      0: begin
        {data_bit,parity_type,stop_bit,baud_rate}  <= transfer_out_data [(7*8-1)-:(7*8)]; 
      end
      default:;
      endcase       
   end
end


// BRAM 写入：直接捕获 USB3 的 64-bit 有效信号
always_ff @ (posedge clk) begin
   //  if (transfer_out_data_val && active_cmd == CMD_DFU_DNLOAD) begin
    if (transfer_out_data_val && active_cmd == CMD_DFU_DNLOAD && transfer_out_data_pt < 14'd64 ) begin //限定在512字节，防止溢出
        // transfer_out_data_pt 是以 64-bit (8 Bytes) 为单位的索引
        dfu_ram[transfer_out_data_pt[5:0]] <= transfer_out_data;
    end
end

// Flash 读出与虚拟 0xFF Padding 优化
logic [7:0] dfu_ram_byte_out;
// 根据 9-bit 地址计算 64-bit 所在的 Word (高 6 bit) 与 Byte 偏移 (低 3 bit)
assign dfu_ram_byte_out = dfu_ram[i_dfu_spi_buf_addr[8:3]][(i_dfu_spi_buf_addr[2:0] * 8) +: 8];



logic [15:0] dfu_actual_len;
always_ff @ (posedge clk or negedge rst_n) begin
   if (!rst_n) begin
      dfu_actual_len <= 16'd512;
   end
   else if (state == ST_SETUP_STAGE && active_cmd == CMD_DFU_DNLOAD) begin
      if (setup_pkt_latch.wLength != 0) begin
         dfu_actual_len <= setup_pkt_latch.wLength;
      end
   end
end
// 当读取地址超出 wLength 时，直接硬件输出 0xFF，免去内部补齐状态机的开销
// 此处不得直接使用wLength，因为会被复位为0
assign o_dfu_spi_buf_rdata = (i_dfu_spi_buf_addr < dfu_actual_len) ? dfu_ram_byte_out : 8'hFF;



//===================================================================================================================================================================================
// 4) 外部通信 / IN 数据反馈 (标准+特定)
//    ST_DATA_IN_STAGE 状态时，将内部寄存数据输出到外部，供主机读取
//    260908 修改框架，确保能被综合成BRAM结构
//====================================================================================================================================================================================
// Mux transfer in data 
always_ff @ ( posedge clk or negedge rst_n ) begin
   if ( !rst_n ) begin
      transfer_in_data_mux_rd_addr <= 0 ;
   end 
   else begin
      transfer_in_data_mux_rd_addr <= ( state == ST_DATA_IN_STAGE || state ==  ST_DATA_IN_STAGE_PREP ) ? transfer_in_data_mux_rd_addr + 1 : 0 ; 
   end
end


// =====================================================================
//固定.dat部分，使用BRAM结构优化时序
// =====================================================================
wire  [8:0]    rom_flat_addr = desc_base_addr[8:0] + transfer_in_data_mux_rd_addr[8:0];
logic [63:0]   desc_rom_data_q;

always_ff @(posedge clk) begin
    desc_rom_data_q <= desc_rom[rom_flat_addr];
end




// 非固定数组部分
logic [63:0] transfer_in_other_data_q;
always_ff @ ( posedge clk ) begin
   case ( active_cmd ) 
//====================================== [标准请求] =============================================//
      CMD_STD_GET_STATUS: begin
         if (setup_pkt_latch.bmRequestType[4:0] == RECIPIENT_DEVICE) 
            transfer_in_other_data_q <= device_standard_status;
         else if (setup_pkt_latch.bmRequestType[4:0] == RECIPIENT_INTF) 
            transfer_in_other_data_q <= interface_standard_status;
         else if (setup_pkt_latch.wValue[7:0] == PTM_STATUS) 
            transfer_in_other_data_q <= endpoint_PTM_status;
         else 
            transfer_in_other_data_q <= endpoint_standard_status;
      end

// 描述符与厂商自定义 (依赖读地址递增)
      CMD_STD_GET_DESC, 
      CMD_GET_MS_OS10_COMPAT_ID,      
      CMD_GET_MS_OS10_EXT_PROPERTIES, 
      CMD_GET_MS_OS20_DES            : begin
         transfer_in_other_data_q <= '0;
      end
      
      CMD_STD_GET_CFG: begin
         transfer_in_other_data_q <= { {7{BYTE}}, configuration_value };
      end

      CMD_STD_GET_INTF: begin
         if (setup_pkt_latch.wIndex < INTERFACE_NUM) 
            transfer_in_other_data_q <= { {7{BYTE}}, interface_alternate_setting[setup_pkt_latch.wIndex] };
         else 
            transfer_in_other_data_q <= 0;
      end

//260831  旧代码此处addr应改为wINdex，否则无论get interface N 都是指向 0
//transfer_in_other_data_q <= interface_alternate_setting_mem [setup_pkt_latch.wIndex] ;
//====================================== [特定类请求] =============================================//
   // ----------------------------------------------------------------
   // CDC 请求
   // ----------------------------------------------------------------
      CMD_CDC_GET_LINE_CODING: begin
         transfer_in_other_data_q <= {BYTE, data_bit, parity_type, stop_bit, baud_rate};
      end

//      CMD_GET_VAL_ALT_SET: begin
//         transfer_in_other_data_q <= { {7{BYTE}}, 8'h00 }; 
//      end
      CMD_DFU_GETSTATUS: begin
    // USB 是小端模式，按照 byte 顺序排列: { byte7, byte6, byte5(iString), byte4(bState), byte3~1(bwPoll), byte0(bStatus) }
    // bwPollTimeout 固定填入 0x000032
    transfer_in_other_data_q <= {
        16'h0000, 
        8'h00, 
        (i_dfu_mode ? dfu_state : APP_STATE_IDLE), 
        8'h00, 
        8'h00, 
        8'h32, 
        8'h00
    };
      end

      default : transfer_in_other_data_q <= 0 ;  
   endcase 
end

assign transfer_in_data_mux = (active_cmd == CMD_STD_GET_DESC || active_cmd == CMD_GET_MS_OS10_COMPAT_ID || active_cmd == CMD_GET_MS_OS10_EXT_PROPERTIES || active_cmd == CMD_GET_MS_OS20_DES)       
                              ? desc_rom_data_q 
                              : transfer_in_other_data_q;


//======================= OTHER ==============================================
assign current_config_value = configuration_value ;



//==============================================================
//======Interface Setting ( UAC )
reg  [7:0]  interface0_alter , interface1_alter , interface2_alter ;
always_ff @ ( posedge clk or negedge rst_n ) begin
    if (!rst_n) begin
        interface0_alter <= 'd0;
        interface1_alter <= 'd0;
        interface2_alter <= 'd0;
    end
    else begin
        if (set_interface) begin
            if (set_interface_num == 0) begin
                interface0_alter <= interface_alternate_setting[0];
            end
            else if (set_interface_num == 1) begin
                interface1_alter <= interface_alternate_setting[1];
            end
            else if (set_interface_num == 2) begin
                interface2_alter <= interface_alternate_setting[2];
            end
        end
    end
end


`ifdef ENABLE_DFU
    `include "dfu_fsm_handler.vh"
`endif


endmodule 




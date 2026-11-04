// Copyright (c) 2026 GOWIN SEMICONDUCTOR CORPORATION.
// SPDX-License-Identifier: MIT
import usb_std_pkg::*;
import msos_pkg::*; // 如果 MSOS 宏定义在这个包里

module usb_ep0_core (
     input  logic         clk
    ,input  logic         rst_n
    ,input  logic         i_dfu_mode

    // 1. 广播总线 (来自顶层 FSM)
    ,input  logic [47:0]  route_word
    ,input  logic         is_setup_stage
    ,input  logic [15:0]  wLength
    
    // 2. OUT 数据阶段总线
    ,input  logic         transfer_out_data_val 
    ,input  logic [63:0]  transfer_out_data     
    ,input  logic [13:0]  transfer_out_data_pt  

    // 3. IN 数据阶段总线
    ,input  logic [13:0]  IN_mux_rd_addr        // 顶层传入的递增读地址
    ,output logic         std_req_active        // 握手举手信号
    ,output logic [15:0]  std_req_len           // 向顶层汇报的发送长度
    ,output logic [63:0]  std_in_data           // 拼装好的 64-bit IN 数据

    // 4. 离散的核心业务 IO (输出给系统其他模块)
    ,output logic [7:0]   current_config_value
    ,output logic         set_interface
    ,output logic [15:0]  set_interface_num 
    ,output logic [15:0]  set_interface_alt_setting
);

    // =================================================================
    // 信号提取提取
    // =================================================================
    logic [7:0]  bmRequestType;
    logic [7:0]  bRequest;
    logic [15:0] wValue;
    logic [15:0] wIndex;

    assign bmRequestType = route_word[47:40];
    assign bRequest      = route_word[39:32];
    assign wValue        = route_word[31:16];
    assign wIndex        = route_word[15:0];

    // =================================================================
    // 1) SETUP 解码与长度路由 (SETUP Decode & Length)
    // =================================================================
    logic is_get_status , is_set_feature    , is_clr_feature;
    logic is_get_desc   , is_get_cfg        , is_set_cfg    ;
    logic is_get_intf   , is_set_intf;
    logic is_set_sel    , is_set_isoch_delay;

    // 微软 OS 描述符请求 
    logic is_get_msos10_compat_id, is_get_msos10_ext_prop, is_get_msos20_desc;

    always_comb begin
        is_get_status           = 0; is_set_feature       = 0; is_clr_feature       = 0;
        is_get_desc             = 0; is_get_cfg           = 0; is_set_cfg           = 0;
        is_get_intf             = 0; is_set_intf          = 0; is_set_sel           = 0;
        is_set_isoch_delay      = 0; 
        is_get_msos10_compat_id = 0; is_get_msos10_ext_prop = 0; is_get_msos20_desc   = 0;
        
        std_req_active          = 0;
        std_req_len             = 16'd0;

        unique casez (route_word)
//====================================== [标准请求] =============================================//
            //Get Descriptor  80 06 XX
            {8'b1000_00??, GET_DESCRIPTOR, 16'h????, 16'h????} : begin
                is_get_desc = 1; std_req_active = 1;
                case (wValue[15:8])
                    DEVICE_DESCRIPTOR_TYPE:        std_req_len = i_dfu_mode ? `DESCR_USB3_DFU_DEVICE_LEN : `DESCR_USB3_DEVICE_LEN;
                    CONFIGURATION_DESCRIPTOR_TYPE: std_req_len = i_dfu_mode ? `DESCR_USB3_DFU_CONFIG_LEN : `DESCR_USB3_CONFIG_LEN;
                    BOS_DESCRIPTOR_TYPE:           std_req_len = i_dfu_mode ? `DESCR_USB3_DFU_BOS_LEN : `DESCR_USB3_BOS_LEN;
                    STRING_DESCRIPTOR_TYPE: begin
                        case (wValue[7:0])
                            0: std_req_len = `DESCR_USB3_STR0_LEN;
                            1: std_req_len = `DESCR_USB3_STR1_LEN;
                            2: std_req_len = `DESCR_USB3_STR2_LEN;
                            3: std_req_len = `DESCR_USB3_STR3_LEN;
                            4: std_req_len = `DESCR_USB3_STR4_LEN;
                            5: std_req_len = `DESCR_USB3_STR5_LEN;
                            6: std_req_len = `DESCR_USB3_STR6_LEN;
                            238: std_req_len = `DESCR_USB3_MSFT_LEN;  
                            default: std_req_len = `DESCR_USB3_STR0_LEN; 
                        endcase
                    end
                endcase
            end
            // Get Status (支持 Device, Interface, Endpoint)
            {8'b1000_00??, GET_STATUS, {8'h00, STANDARD_STATUS}, 16'h????},
            {8'b1000_00??, GET_STATUS, {8'h00, PTM_STATUS},      16'h????} : begin
                is_get_status = 1; std_req_active = 1;
                std_req_len = (wValue[7:0] == STANDARD_STATUS) ? 16'd2 : 16'd4;
            end 

            //Set / Clear Feature (U1, U2, Wakeup, LTM)
            // Set Feature (device)
            {8'b0000_0000, SET_FEATURE,   16'h????, 16'h????} : begin is_set_feature = 1; std_req_active = 1; std_req_len = wLength; end
            {8'b0000_0000, CLEAR_FEATURE, 16'h????, 16'h????} : begin is_clr_feature = 1; std_req_active = 1; std_req_len = wLength; end
            //后续可以考虑加入 endpoint 以及 interface 的 SET/CLEAR FEATURE? 

            // Configuration (Get / Set)
            {8'b1000_0000, GET_CONFIGURATION, 16'h????, 16'h????} : begin is_get_cfg = 1; std_req_active = 1; std_req_len = 16'd1; end
            {8'b0000_0000, SET_CONFIGURATION, 16'h????, 16'h????} : begin is_set_cfg = 1; std_req_active = 1; std_req_len = wLength; end
            
            // Interface (Get / Set)
            {8'b1000_0001, GET_INTERFACE, 16'h????, 16'h????} : begin is_get_intf = 1; std_req_active = 1; std_req_len = 16'd1; end
            {8'b0000_0001, SET_INTERFACE, 16'h????, 16'h????} : begin is_set_intf = 1; std_req_active = 1; std_req_len = wLength; end
            // Set SEL
            {8'b0000_0000, SET_SEL, 16'h????, 16'h????} : begin is_set_sel = 1; std_req_active = 1; std_req_len = wLength; end
            // Set Isochronous Delay
            {8'b0000_0000, SET_ISOCH_DELAY, 16'h????, 16'h????} : begin is_set_isoch_delay = 1; std_req_active = 1; std_req_len = wLength; end


//====================================== [特定类请求] =============================================//
   // 处理 Windows 的获取 Compat ID 厂商请求
            {GET_VENDOR_DEV, VENDOR_CODE_10, 16'h0000, {8'h00, GET_EXT_COMPAT_ID_SET}} : begin
                is_get_msos10_compat_id = 1; std_req_active = 1;
                std_req_len = i_dfu_mode ? `DESCR_USB3_MSOS10_DFU_compatibleID_LEN : `DESCR_USB3_MSOS10_APP_compatibleID_LEN;
            end
            {GET_VENDOR_INT, VENDOR_CODE_10, 16'h????, {8'h00, GET_EXT_PROPERTIES_SET}} : begin
                is_get_msos10_ext_prop = 1; std_req_active = 1;
                std_req_len = i_dfu_mode ? `DESCR_USB3_MSOS10_DFU_INT0_Extend_Pro_LEN : 
                              ((wValue[7:0] == 8'h0) ? `DESCR_USB3_MSOS10_APP_INT0_Extend_Pro_LEN : `DESCR_USB3_MSOS10_APP_INT1_Extend_Pro_LEN);
            end
            {GET_VENDOR_DEV, VENDOR_CODE_20, 16'h????, {8'h00, GET_DESCRIPTOR_SET}} : begin
                is_get_msos20_desc = 1; std_req_active = 1;
                std_req_len = i_dfu_mode ? `DESCR_USB3_MSOS20_DFU_DES_LEN : `DESCR_USB3_MSOS20_APP_DES_LEN;
            end
            default: ;
        endcase
    end

// =================================================================
// 2) 内部寄存 (标准+特定) 
//    用于寄存 标准协议下 特性标志，
//            特定协议下 配置数据。
// =================================================================
logic self_powered = 1 ; 
logic function_remote_wakeup = 0 ; 
logic function_remote_wakeup_capable = 0 ;
logic [15:0] LDM_Link_Delay = 0 ;
logic LDM_enable = 0 ;
logic LDM_valid = 0 ;

// 0x00 GET_STATUS request response
logic [63:0] device_standard_status       ;
logic [63:0] interface_standard_status    ;
logic [63:0] endpoint_standard_status     ;
logic [63:0] endpoint_PTM_status          ; 
assign device_standard_status    = { {7{BYTE}}, 3'b0, LTM_enable, u2_enable, u1_enable, remote_wakeup, self_powered };              // Get Status request response
assign interface_standard_status = { {7{BYTE}}, 6'b0, function_remote_wakeup, function_remote_wakeup_capable };                     
assign endpoint_standard_status  = { {7{BYTE}}, 7'b0, Halt };                                                                       
assign endpoint_PTM_status       = { {4{BYTE}}, LDM_Link_Delay[15:8], LDM_Link_Delay[7:0], BYTE, 6'b0, LDM_valid, LDM_enable };     

// 0x01 Clear Feature request 
// 0x03 Set Feature request 
logic u1_enable, u2_enable, remote_wakeup, LTM_enable;
always_ff @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      u1_enable      <= 0 ;
      u2_enable      <= 0 ;
      remote_wakeup  <= 0 ;
      LTM_enable     <= 0 ;
   end
   else if (is_setup_stage ) begin
      if (is_clr_feature) begin
         u1_enable       <= (wValue == U1_ENABLE_FS)              ? 0 : u1_enable;
         u2_enable       <= (wValue == U2_ENABLE_FS)              ? 0 : u2_enable;
         remote_wakeup   <= (wValue == DEVICE_REMOTE_WAKEUP_FS)   ? 0 : remote_wakeup;
         LTM_enable      <= (wValue == LTM_ENABLE_FS)             ? 0 : LTM_enable;      
      end
      else if (is_set_feature) begin
         u1_enable       <= (wValue == U1_ENABLE_FS)              ? 1 : u1_enable;
         u2_enable       <= (wValue == U2_ENABLE_FS)              ? 1 : u2_enable;
         remote_wakeup   <= (wValue == DEVICE_REMOTE_WAKEUP_FS)   ? 1 : remote_wakeup;
         LTM_enable      <= (wValue == LTM_ENABLE_FS)             ? 1 : LTM_enable;      
      end
   end
end  

// 0x08 Get Configuration request
//
// 0x09 Set Configuration request 
logic [7:0]  configuration_value;
always_ff @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      configuration_value <= 0 ;
   end
   else if (  is_setup_stage && is_set_cfg  ) begin
      configuration_value <= wValue[7:0] ;
   end   
end

assign current_config_value = configuration_value;

// 0x0A Get Interface request 
//
// 0x0B Set Interface request
parameter   INTERFACE_NUM  =  3  ;
logic [7:0]  interface_alternate_setting     [0:INTERFACE_NUM-1];
always_ff @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      for (int i = 0; i < INTERFACE_NUM; i = i + 1) begin
         interface_alternate_setting[i] <= 0 ;
      end
      set_interface                 <= 0 ;
      set_interface_num             <= 0 ;
      set_interface_alt_setting     <= 0 ;
   end
   else if (  is_setup_stage && is_set_intf ) begin
      if (wIndex < INTERFACE_NUM) begin
         interface_alternate_setting[wIndex] <= wValue[7:0] ;
      end
      set_interface                 <= 1 ;
      set_interface_num             <= wIndex ;
      set_interface_alt_setting     <= wValue  ;    
   end
   else begin
      set_interface                 <= 0 ;
   end
end


// 0x30 Set SEL request 
logic [7:0]  U1SEL, U1PEL;
logic [15:0] U2SEL, U2PEL;
always_ff @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      U1SEL <= 0 ;
      U1PEL <= 0 ;
      U2SEL <= 0 ;
      U2PEL <= 0 ;
   end
   else if ( transfer_out_data_val && is_set_sel) begin
      case ( transfer_out_data_pt ) 
      0: begin
         {U2PEL,U2SEL,U1PEL,U1SEL} <= transfer_out_data[(6*8-1)-:6*8] ;      
      end
      default:;
      endcase 
   end
end

// 0x31 Set Isochronous Delay request
logic [15:0] Delay;
always_ff @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      Delay <= 0 ;
   end
   else if ( is_setup_stage && is_set_isoch_delay) begin
      Delay <= wValue ;
   end
end



// =================================================================
// 3) 描述符 ROM 读取 (Descriptor ROM)
// =================================================================
(* syn_ramstyle = "block_ram" *) logic [63:0] desc_rom [0:ROM_LEN-1]; // 根据实际总长度调整深度
initial begin
    $readmemh("./descriptors/usb_desc_RWBW+DFU.dat", desc_rom);
end

logic [13:0] desc_base_addr;
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        desc_base_addr <= 0;
    end 
    else if (is_setup_stage) begin
        if (is_get_desc) begin
            case (wValue[15:8])
                DEVICE_DESCRIPTOR_TYPE:        desc_base_addr <= i_dfu_mode ? DFU_DEVICE_DESC_BASE : DEVICE_DESC_BASE;
                CONFIGURATION_DESCRIPTOR_TYPE: desc_base_addr <= i_dfu_mode ? DFU_CONFIG_DESC_BASE : CONFIG_DESC_BASE;
                BOS_DESCRIPTOR_TYPE:           desc_base_addr <= i_dfu_mode ? DFU_BOS_DESC_BASE    : BOS_DESC_BASE;
                STRING_DESCRIPTOR_TYPE: begin
                    case (wValue[7:0])
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
        else if (is_get_msos10_compat_id) desc_base_addr <= i_dfu_mode ? MSOS10_DFU_COMPAT_ID_DESC_BASE : MSOS10_APP_COMPAT_ID_DESC_BASE;
        else if (is_get_msos10_ext_prop)  desc_base_addr <= i_dfu_mode ? MSOS10_DFU_INT0_EXT_DESC_BASE  : ((wValue[7:0] == 8'h0) ? MSOS10_APP_INT0_EXT_DESC_BASE : MSOS10_APP_INT1_EXT_DESC_BASE);
        else if (is_get_msos20_desc)      desc_base_addr <= i_dfu_mode ? MSOS20_DFU_DESC_BASE           : MSOS20_APP_DESC_BASE;
    end
end
wire [8:0] rom_flat_addr = desc_base_addr[8:0] + IN_mux_rd_addr[8:0];
logic [63:0] desc_rom_data_q;
always_ff @(posedge clk) 
    desc_rom_data_q <= desc_rom[rom_flat_addr];


// =================================================================
// 4) IN 数据拼装 (IN Data Assembly)
// =================================================================
localparam      BYTE = 8'b0;
logic           Halt = 0 ;


logic [63:0] transfer_in_other_data_q;
always_ff @(posedge clk) begin
    if (is_get_status) begin
        if (bmRequestType[4:0] == RECIPIENT_DEVICE) 
           transfer_in_other_data_q <= device_standard_status;
        else if (bmRequestType[4:0] == RECIPIENT_INTF) 
           transfer_in_other_data_q <= interface_standard_status;
        else if (wValue[7:0] == PTM_STATUS) 
           transfer_in_other_data_q <= endpoint_PTM_status;
        else 
           transfer_in_other_data_q <= endpoint_standard_status;
    end
    else if (is_get_cfg) begin
        transfer_in_other_data_q <= { {7{BYTE}}, configuration_value };
    end
    else if (is_get_intf) begin
        if (wIndex < INTERFACE_NUM)     transfer_in_other_data_q <= { {7{BYTE}}, interface_alternate_setting[wIndex] };
        else                            transfer_in_other_data_q <= '0;
    end
    else begin
        transfer_in_other_data_q <= '0;
    end
end
// 最终 MUX 出去给顶层
assign std_in_data = (is_get_desc || is_get_msos10_compat_id || is_get_msos10_ext_prop || is_get_msos20_desc) 
                     ? desc_rom_data_q              //ROM
                     : transfer_in_other_data_q;    //LUT







endmodule
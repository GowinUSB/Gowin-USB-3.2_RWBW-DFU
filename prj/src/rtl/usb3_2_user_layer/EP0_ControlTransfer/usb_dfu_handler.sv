// Copyright (c) 2026 GOWIN SEMICONDUCTOR CORPORATION.
// SPDX-License-Identifier: MIT

import usb_std_pkg::*;
import dfu_pkg::*;

module usb_dfu_handler (
     input  logic         clk
    ,input  logic         rst_n

// 广播 SETUP 指令
    ,input  logic [47:0]  route_word
    ,input  logic         is_setup_stage
    ,input  logic [15:0]  wLength
    ,input  logic         st_setup_done
// OUT数据相关
    ,input  logic         data_out_done
    ,input  logic         transfer_out_data_val // EP0 OUT 数据 有效
    ,input  logic [63:0]  transfer_out_data     // EP0 OUT 数据
    ,input  logic [13:0]  transfer_out_data_pt  // EP0 OUT 数据 计数器

// IN数据相关
    ,output logic         dfu_req_active        // 握手反馈
    ,output logic [15:0]  dfu_req_len           // EP0 IN 数据 长度
    ,output logic [63:0]  dfu_in_data           // EP0 IN 数据
 
// 链接至外部 IO
    ,input  logic         i_dfu_mode                   // 重枚举后 进入 1：DFU_mode 0：APP_mode
    ,output logic         o_dfu_detach_flag            // 接收DFU_DETACH指令
    // EP0 DFU DATA  
    ,output logic         o_dfu_spi_wr_req             // 写请求
    ,input  logic         i_dfu_spi_wr_ack             // 写应答
    ,output logic         o_dfu_spi_wr_flush           // 强制刷写Flash 
    ,output logic [31:0]  o_dfu_spi_lba                // 逻辑块地址 (512B为单位)
    ,input  logic [8:0]   i_dfu_spi_buf_addr           // Flash控制器给出的读地址
    ,output logic [7:0]   o_dfu_spi_buf_rdata          // 输出给Flash控制器的数据
);

    // ----------------------------------------------------------------
    // 1. SETUP 指令
    // ----------------------------------------------------------------
    logic is_dfu_detach;
    logic is_dfu_dnload;
    logic is_dfu_getstatus;
    logic is_dfu_clrstatus;
    logic [15:0] wValue;

    assign wValue = route_word[31:16];

    always_comb begin
        is_dfu_detach    = 0;
        is_dfu_dnload    = 0;
        is_dfu_getstatus = 0;
        is_dfu_clrstatus = 0;
        dfu_req_active   = 0;
        dfu_req_len      = 16'd0;

        casez (route_word)
            {SET_CLASS_INF  ,   DFU_DETACH, 16'h????, 16'h????}: begin
                is_dfu_detach  = 1;
                dfu_req_active = 1;
                dfu_req_len    = wLength;
            end
            {SET_CLASS_INF  ,   DFU_DNLOAD, 16'h????, 16'h????}: begin
                is_dfu_dnload  = 1;
                dfu_req_active = 1;
                dfu_req_len    = wLength;
            end
            {GET_CLASS_INF  ,   DFU_GETSTATUS, 16'h????, 16'h????}: begin
                is_dfu_getstatus = 1;
                dfu_req_active   = 1;
                dfu_req_len      = 16'd6; 
            end
            {SET_CLASS_INF  ,   DFU_CLRSTATUS, 16'h????, 16'h????}: begin
                is_dfu_clrstatus = 1;
                dfu_req_active   = 1;
                dfu_req_len      = wLength;
            end
            default: ;
        endcase
    end

    // ----------------------------------------------------------------
    // 2. OUT 指令
    // ----------------------------------------------------------------
logic [7:0]  dfu_state;
logic        flash_trigger;
logic        detach_trigger;
logic [31:0] dfu_spi_lba_q;
logic [63:0] dfu_ram [0:63] /*synthesis syn_ramstyle="block_ram"*/;

always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dfu_state      <= DFU_STATE_IDLE; 
        flash_trigger  <= 1'b0; 
        detach_trigger <= 1'b0; 
        dfu_spi_lba_q  <= 0; 
    end 
    else begin
        flash_trigger  <= 1'b0; 
        detach_trigger <= 1'b0; 

        // ---------------------------------------------------------
        // 侦听事件 1：SETUP 解析完成
        // ---------------------------------------------------------
        if (st_setup_done) begin 
            unique case (1'b1)
                is_dfu_clrstatus : begin
                    dfu_state <= DFU_STATE_IDLE; 
                end
                is_dfu_getstatus : begin
                    if (dfu_state == DFU_STATE_DNLOAD_SYNC || dfu_state == DFU_STATE_DNBUSY) begin 
                        if (o_dfu_spi_wr_req)   dfu_state <= DFU_STATE_DNBUSY;        // Flash 还没回 Ack，处于忙碌
                        else                    dfu_state <= DFU_STATE_DNLOAD_IDLE;   // Flash 写完了，可以接下一包
                    end
                    else if (dfu_state == DFU_STATE_MANIFEST_SYNC) begin 
                        if (!o_dfu_spi_wr_req)  dfu_state <= DFU_STATE_MANIFEST;    // Manifest 阶段的刷写也完成了
                    end
                    else if (dfu_state == DFU_STATE_MANIFEST) begin 
                        dfu_state      <= DFU_STATE_IDLE; 
                        detach_trigger <= 1'b1;                                     // 触发重枚举
                    end                     
                end
                is_dfu_dnload   : begin
                    if (wLength == 0) begin 
                        flash_trigger <= 1'b1; 
                        dfu_state     <= DFU_STATE_MANIFEST_SYNC; 
                    end 
                    else begin 
                        dfu_spi_lba_q <= {16'd0, wValue}; 
                        dfu_state     <= DFU_STATE_DNLOAD_SYNC; 
                    end
                end

                is_dfu_detach   : begin
                    detach_trigger <= 1'b1; 
                end
            endcase
        end

        // --------------------------------------------------------
        // 侦听事件 2：OUT 数据接收完成
        // ---------------------------------------------------------
        if (data_out_done && is_dfu_dnload) begin
            flash_trigger <= 1'b1; 
        end
    end
end
    

// BRAM 写入：直接捕获 USB3 的 64-bit 有效信号
always_ff @ (posedge clk) begin
    if (transfer_out_data_val && is_dfu_dnload && transfer_out_data_pt < 14'd64 ) begin //限定在512字节，防止溢出
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
   else if (is_setup_stage && is_dfu_dnload) begin
      if (wLength != 0) begin
         dfu_actual_len <= wLength;
      end
   end
end
// 当读取地址超出 wLength 时，直接硬件输出 0xFF，免去内部补齐状态机的开销
// 此处不得直接使用wLength，因为会被复位为0
assign o_dfu_spi_buf_rdata = (i_dfu_spi_buf_addr < dfu_actual_len) ? dfu_ram_byte_out : 8'hFF;




// ----------------------------------------------------------------
// 3. IN 指令
// ----------------------------------------------------------------
always_ff @(posedge clk) begin
    if (is_dfu_getstatus) begin
// USB 是小端模式，按照 byte 顺序排列: { byte7, byte6, byte5(iString), byte4(bState), byte3~1(bwPoll), byte0(bStatus) }
// bwPollTimeout 固定填入 0x000032
        dfu_in_data <= {
            16'h0000, 
            8'h00, 
            (i_dfu_mode ? dfu_state : APP_STATE_IDLE), 
            8'h00, 
            8'h00, 
            8'h32, 
            8'h00
        };
    end else begin
        dfu_in_data <= '0;
    end
end

// ----------------------------------------------------------------
// 4. 外部 IO 
// ----------------------------------------------------------------
// DFU2FLASH 接口
logic [27:0] detach_delay_cnt;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_dfu_spi_wr_req    <= 1'b0; 
            o_dfu_spi_wr_flush  <= 1'b0; 
            detach_delay_cnt    <= 28'd0; 

            o_dfu_detach_flag   <= 1'b0; 
        end 
        else begin
            if (flash_trigger) begin 
                o_dfu_spi_wr_req <= 1'b1; 
                if (wLength == 16'd0) o_dfu_spi_wr_flush <= 1'b1; 
            end 
            else if (i_dfu_spi_wr_ack) begin 
                o_dfu_spi_wr_req    <= 1'b0; 
                o_dfu_spi_wr_flush  <= 1'b0; 
            end

        // Detach 重枚举脉冲计时
            if (detach_trigger) begin 
                detach_delay_cnt <= 28'd1_200_000;  
            end 
            else if (detach_delay_cnt > 0) begin 
                detach_delay_cnt <= detach_delay_cnt - 1'b1; 
            end
            // 重枚举脉冲
            o_dfu_detach_flag   <= (detach_delay_cnt == 28'd1); 
        end
    end

    assign o_dfu_spi_lba        = dfu_spi_lba_q;

endmodule
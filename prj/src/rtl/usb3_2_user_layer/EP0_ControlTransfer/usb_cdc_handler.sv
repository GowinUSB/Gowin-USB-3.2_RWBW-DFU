
import usb_std_pkg::*;

module usb_cdc_handler (
     input  logic         clk
    ,input  logic         rst_n

    // 广播 SETUP 指令
    ,input  logic [47:0]  route_word
    
    // OUT数据相关
    ,input  logic         transfer_out_data_val // EP0 OUT 数据 有效
    ,input  logic [63:0]  transfer_out_data     // EP0 OUT 数据
    ,input  logic [13:0]  transfer_out_data_pt  // EP0 OUT 数据 计数器

    //
    ,output logic         cdc_req_active        // 握手反馈
    ,output logic [15:0]  cdc_req_len           // EP0 IN 数据 长度
    ,output logic [63:0]  cdc_in_data           // EP0 IN 数据

    // 输出给外部 IO
    ,output cdc_ep0_io_t  cdc_io
);

    // ----------------------------------------------------------------
    // 1. SETUP 指令
    // ----------------------------------------------------------------
    logic is_set_line_coding;
    logic is_get_line_coding;

    always_comb begin
        is_set_line_coding = 0;
        is_get_line_coding = 0;
        cdc_req_active     = 0;
        cdc_req_len        = 16'd0;

        casez (route_word)
            {REQ_TYPE_OUT_CLS_INTF, SET_LINE_CODING, 16'h????, 16'h????}: begin
                is_set_line_coding = 1;
                cdc_req_active     = 1;
                cdc_req_len        = 16'd7; // 线路编码固定 7 字节
            end
            {REQ_TYPE_IN_CLS_INTF, GET_LINE_CODING, 16'h????, 16'h????}: begin
                is_get_line_coding = 1;
                cdc_req_active     = 1;
                cdc_req_len        = 16'd7;
            end
            default: ;
        endcase
    end

    // ----------------------------------------------------------------
    // 2. OUT 指令
    // ----------------------------------------------------------------
    logic             update_valid_q;
    cdc_line_coding_t line_coding;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            update_valid_q          <= 1'b0;
            line_coding.baud_rate   <= 32'd115200;
            line_coding.stop_bit    <= 8'd0;
            line_coding.parity_type <= 8'd0;
            line_coding.data_bit    <= 8'd8;
        end 
        else begin
            update_valid_q <= 1'b0; // 脉冲
            if (is_set_line_coding && transfer_out_data_val && transfer_out_data_pt == 0) begin
                // 低 56 bit (7 bytes)，pt仅计数至0
                update_valid_q <= 1'b1;
                {line_coding.data_bit, line_coding.parity_type, line_coding.stop_bit, line_coding.baud_rate} <= transfer_out_data[55:0];
            end
        end
    end

    // ----------------------------------------------------------------
    // 3. IN 指令
    // ----------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (is_get_line_coding) begin
            cdc_in_data <= {8'h00, line_coding.data_bit, line_coding.parity_type, line_coding.stop_bit, line_coding.baud_rate};
        end else begin
            cdc_in_data <= '0;
        end
    end

    // ----------------------------------------------------------------
    // 4. 外部 IO
    // ----------------------------------------------------------------
    assign cdc_io.update_valid = update_valid_q;
    assign cdc_io.cfg          = line_coding;

endmodule
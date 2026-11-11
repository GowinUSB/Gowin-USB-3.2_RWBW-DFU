module EP2_speed(

    input wire         clk 
   ,input wire         rst_n
    // ep2 IN
   ,output  reg        transfer_in_mem_wr              
   ,output  reg [7:0]  transfer_in_mem_wr_mask       
   ,output  reg [13:0] transfer_in_mem_wr_addr           
   ,output  reg [63:0] transfer_in_mem_wr_data                    
   ,output  reg        transfer_in_mem_commit                
   ,output  reg [16:0] transfer_in_mem_commit_len        
   ,input   wire       transfer_in_mem_ready         
   ,input   wire       transfer_in_done            
    // ep2 OUT
   ,input   wire        transfer_out_mem_has_data    
   ,input   wire [16:0] transfer_out_mem_len        
   ,output  reg  [13:0] transfer_out_mem_rd_addr    
   ,input   wire [63:0] transfer_out_mem_rd_data    
   ,output  reg         transfer_out_mem_clr    


);

reg [3:0] rx_state;
localparam RX_IDLE      = 0;
localparam RX_READ      = 1;
localparam RX_CLR       = 2;
localparam RX_CLR_DONE  = 3;
localparam RX_WT        = 4;
reg [15:0] rx_cnt;
reg        rx_val;
reg        rx_clr;

reg [23:0] payload_cnt ;
reg add_0_payload ;
reg transfer_in_mem_ready_d ;
reg transfer_out_mem_has_data_d ;
reg [16:0] transfer_out_mem_len_d ;

always @ ( posedge clk or negedge rst_n ) begin
    if(!rst_n) begin 
        transfer_in_mem_ready_d <= 0 ;
        transfer_out_mem_has_data_d <= 0 ;
        transfer_out_mem_len_d <= 0 ;
    end
    else begin
        transfer_in_mem_ready_d <= transfer_in_mem_ready ;
        transfer_out_mem_has_data_d <= transfer_out_mem_has_data ;
        transfer_out_mem_len_d <= transfer_out_mem_len ;
    end
end

always @ ( posedge clk or negedge rst_n ) begin
   if(!rst_n) begin
       rx_state <= RX_IDLE;
       rx_val   <= 1'b0;
       transfer_out_mem_rd_addr <= 14'd0;
       transfer_out_mem_clr <= 'd0;
   end
   else begin
        if (rx_state == RX_IDLE) begin
            if (transfer_out_mem_has_data_d) begin
                rx_state <= RX_READ;
                rx_val   <= 1'b1;
            end
            else begin
                rx_val   <= 1'b0;
                transfer_out_mem_clr <= 'd0;
            end
        end
        else if (rx_state == RX_READ) begin
          if (transfer_out_mem_rd_addr + 1 >= transfer_out_mem_len_d[16:3] + (|transfer_out_mem_len_d[2:0])) begin
               transfer_out_mem_rd_addr <= 14'd0; // 
               rx_state <= RX_CLR;
               rx_val   <= 1'b0;
           end
           else begin
               transfer_out_mem_rd_addr <= transfer_out_mem_rd_addr + 14'd1;
               rx_val   <= 1'b1;
           end
        end
        else if (rx_state == RX_CLR) begin
            transfer_out_mem_clr <= 1'b1; 
            rx_state <= RX_CLR_DONE;         //
            rx_val   <= 1'b0;            //
        end
        else if ( rx_state == RX_CLR_DONE  ) begin
            transfer_out_mem_clr <= 1'b0; 
            rx_state <= RX_WT;         //
            rx_val   <= 1'b0;            //            
        end
        else if ( rx_state == RX_WT  ) begin
            rx_state <= RX_IDLE;         //            
        end
    end
end

reg [63:0] dbg_data;
reg        dbg_val;

always @ ( posedge clk or negedge rst_n ) begin
   if(!rst_n) begin
       dbg_data <= 'd0;
       dbg_val  <= 'd0;
   end
   else begin
       if (rx_val) begin
           dbg_data <= transfer_out_mem_rd_data;
           dbg_val  <= 1'd1;
       end
       else begin
           dbg_data <= 'd0;
           dbg_val  <= 'd0;
       end
   end
end

reg [3:0] tx_state;
localparam TX_IDLE  = 0;
localparam TX_WRITE = 1;
localparam TX_DONE  = 2;
localparam TX_WAIT  = 3;

always @ ( posedge clk or negedge rst_n ) begin
   if(!rst_n) begin
       tx_state <= TX_IDLE;
       transfer_in_mem_wr      <= 'd0;
       transfer_in_mem_wr_mask <= 'd0;
       transfer_in_mem_wr_addr <= 'd0;
       transfer_in_mem_wr_data <= 'd0;
       transfer_in_mem_commit     <= 'd0;
       transfer_in_mem_commit_len <= 'd0;
   end
   else begin
       if (tx_state == TX_IDLE) begin
           if (transfer_in_mem_ready_d) begin
                transfer_in_mem_wr      <= 1'b1;
                transfer_in_mem_wr_addr <= -1 ;
                transfer_in_mem_wr_data <= 'd0;
                transfer_in_mem_commit     <= 'd0;
                transfer_in_mem_commit_len <= 'd0;
                tx_state <= TX_WRITE;
           end
           else begin
                transfer_in_mem_wr      <= 'd0;
                transfer_in_mem_wr_mask <= 'd0;
                transfer_in_mem_wr_addr <= 'd0;
                transfer_in_mem_wr_data <= 'd0;
                transfer_in_mem_commit     <= 'd0;
                transfer_in_mem_commit_len <= 'd0;
           end
       end
       else if (tx_state == TX_WRITE) begin
           if (transfer_in_mem_wr_addr[13:0]== 1024 * 8 / 8 ) begin
               transfer_in_mem_wr      <= 1'b0;
               transfer_in_mem_commit     <= 1'b1;
               transfer_in_mem_commit_len <= 1024 * 8 ;
               tx_state <= TX_DONE;
           end
           else if ( add_0_payload ) begin
               transfer_in_mem_wr      <= 1'b0;
               transfer_in_mem_commit     <= 1'b1;
               transfer_in_mem_commit_len <= 0 ;
               tx_state <= TX_DONE;
           end
           else begin
               transfer_in_mem_wr      <= 1'b1;
               transfer_in_mem_wr_addr <= transfer_in_mem_wr_addr + 1'd1;
               transfer_in_mem_wr_data <= 0;
               transfer_in_mem_commit     <= 'd0;
               transfer_in_mem_commit_len <= 'd0;
           end
       end
       else if (tx_state == TX_DONE) begin
           tx_state <= TX_WAIT;
           transfer_in_mem_commit     <= 'd0;
           transfer_in_mem_wr      <= 'd0;
           transfer_in_mem_wr_mask <= 'd0;
           transfer_in_mem_wr_addr <= 'd0;
           transfer_in_mem_wr_data <= 'd0;
       end
       else if (tx_state == TX_WAIT) begin
           tx_state <= TX_IDLE;
       end
   end
end

always @ ( posedge clk or negedge rst_n ) begin
    if(!rst_n) begin
        payload_cnt <= 0 ;
    end
    else if ( transfer_in_mem_commit ) begin
        payload_cnt <= payload_cnt + transfer_in_mem_commit_len ;
    end
    else if ( add_0_payload ) begin
        payload_cnt <= 0 ;
    end
end

always @ ( posedge clk or negedge rst_n ) begin
    if(!rst_n) begin
        add_0_payload <= 0 ;
    end
end

//debug
reg [9:0] clk_cnt ;
always @ ( posedge clk or negedge rst_n ) begin
    if(!rst_n) begin
        clk_cnt <= 0 ;
    end
    else if ( !transfer_in_mem_wr ) begin
        clk_cnt <= ( &clk_cnt ) ? clk_cnt : clk_cnt + 1 ;
    end
    else begin
        clk_cnt <= 0 ;
    end
end

reg clk_cnt_max ;
always @ ( posedge clk or negedge rst_n ) begin
    if(!rst_n) begin
        clk_cnt_max <= 0 ;
    end
    else begin
        clk_cnt_max <= &clk_cnt ;
    end
end

reg [23:0] transfer_payload_cnt ;
reg payload_sent; 

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        transfer_payload_cnt <= 0 ;
        payload_sent <= 0 ;
    end
    else if ( transfer_in_done ) begin
        if ( transfer_payload_cnt + 1024 * 16 >= 1024 * 1024 ) begin
            transfer_payload_cnt <= 0 ;
            payload_sent <= 1 ;
        end
        else begin
            transfer_payload_cnt <= transfer_payload_cnt + 1024 * 16 ;
            payload_sent <= 0 ;
        end
    end
    else begin
        payload_sent <= 0 ;
    end
end

reg [23:0] payload_sent_cnt ;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        payload_sent_cnt <= 0 ;
    end
    else if ( payload_sent ) begin
        payload_sent_cnt <= payload_sent_cnt + 1 ;
    end
end
 
//debug
reg [31:0] transfer_out_byte_cnt ;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        transfer_out_byte_cnt <= 0 ;
    end
    else begin
        transfer_out_byte_cnt <= ( transfer_out_mem_clr ) ? transfer_out_byte_cnt + transfer_out_mem_len_d : transfer_out_byte_cnt ;
    end
end


endmodule

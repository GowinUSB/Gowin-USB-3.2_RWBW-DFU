module EP1_loopback(

	input wire 	clk 
	,input wire rst_n
   
	// ep1 IN  
   ,output  reg        transfer_in_mem_wr              
   ,output  reg [7:0]  transfer_in_mem_wr_mask       
   ,output  reg [13:0] transfer_in_mem_wr_addr       	
   ,output  reg [63:0] transfer_in_mem_wr_data       		 	
   ,output  reg        transfer_in_mem_commit        		
   ,output  reg [16:0] transfer_in_mem_commit_len    	
   ,input   wire       transfer_in_mem_ready         
   ,input   wire       transfer_in_done            
   
	// ep1 OUT	
   ,input   wire        transfer_out_mem_has_data    
   ,input   wire [16:0] transfer_out_mem_len        
   ,output  reg  [13:0] transfer_out_mem_rd_addr    
   ,input   wire [63:0] transfer_out_mem_rd_data    
   ,output  reg         transfer_out_mem_clr    


);

localparam ST_W               = 3;
localparam ST_IDLE            = 3'd0;
localparam ST_LOOPBACK_WT     = 3'd1;
localparam ST_LOOPBACK        = 3'd2;
localparam ST_LOOPBACK_CLR    = 3'd3;
localparam ST_LOOPBACK_CMT    = 3'd4;
localparam ST_DISCARD_CLR     = 3'd5;
reg [ST_W-1:0] state ;

reg [15:0] rd_cnt ;
reg rd_loopback_end ;

reg transfer_out_mem_rd_data_val ;

always @ ( posedge clk or negedge rst_n ) begin
   if(!rst_n) begin
      state  <= ST_IDLE ;
   end
   else begin
      case ( state ) 
      ST_IDLE:begin
         if ( transfer_out_mem_has_data ) begin
            if ( transfer_in_mem_ready ) begin
               state    <= ST_LOOPBACK_WT ;
            end
            else begin
               state    <= ST_DISCARD_CLR ;
            end
         end
      end
      ST_LOOPBACK_WT:begin
         state    <= ST_LOOPBACK ;
      end
      ST_LOOPBACK:begin
         if ( rd_loopback_end ) begin
            state    <= ST_LOOPBACK_CLR ;
         end
      end
      ST_LOOPBACK_CLR:begin
         state <= ST_LOOPBACK_CMT ;
      end
      ST_LOOPBACK_CMT:begin
         state <= ST_IDLE ;
      end  
      ST_DISCARD_CLR:begin
         state <= ST_IDLE ;
      end
      default:;
      endcase 
   end
end

always @ ( posedge clk or negedge rst_n ) begin
   if(!rst_n) begin
      rd_cnt <= 0 ;
   end
   else if ( state == ST_LOOPBACK ) begin
      rd_cnt <= rd_cnt + 1 ;
   end
   else begin
      rd_cnt <= 0 ;
   end
end

reg [15:0] transfer_out_mem_len_d0 ;
always @ ( posedge clk ) begin
   transfer_out_mem_len_d0 <= transfer_out_mem_len ;
end

always @ ( posedge clk or negedge rst_n ) begin
   if(!rst_n) begin
      rd_loopback_end <= 0 ;
   end
   else if ( transfer_out_mem_len_d0[15:3] == 0 ) begin
      rd_loopback_end <= 1 ;
   end
   else if ( state == ST_LOOPBACK && rd_cnt + 1 + 1  >= transfer_out_mem_len_d0[15:3] + (|transfer_out_mem_len_d0[2:0]) ) begin
      rd_loopback_end <= 1 ;
   end
   else begin
      rd_loopback_end <= 0 ;
   end
end



always @ ( posedge clk or negedge rst_n ) begin
   if(!rst_n) begin
      transfer_out_mem_rd_addr      <= 0 ;
      transfer_out_mem_clr          <= 0 ;
      
      transfer_out_mem_rd_data_val  <= 0 ;
   end
   else if ( state == ST_LOOPBACK ) begin
      transfer_out_mem_rd_addr      <= transfer_out_mem_rd_addr + 1 ;
      transfer_out_mem_clr          <= 0 ;  

      transfer_out_mem_rd_data_val  <= 1 ;  
   end
   else if ( state == ST_LOOPBACK_CLR || state == ST_DISCARD_CLR ) begin
      transfer_out_mem_rd_addr      <= 0 ;
      transfer_out_mem_clr          <= 1 ;  

      transfer_out_mem_rd_data_val  <= 0 ;        
   end
   else begin
      transfer_out_mem_rd_addr      <= 0 ;
      transfer_out_mem_clr          <= 0 ;
      
      transfer_out_mem_rd_data_val  <= 0 ;   
   end
end   

always @ ( posedge clk or negedge rst_n ) begin
   if(!rst_n) begin
      transfer_in_mem_wr            <= 0 ;   
      transfer_in_mem_wr_mask       <= 0 ;
      transfer_in_mem_wr_addr       <= 0 ;
      transfer_in_mem_wr_data       <= 0 ;
      transfer_in_mem_commit        <= 0 ;
      transfer_in_mem_commit_len    <= 0 ;   
   end
   else if ( transfer_out_mem_rd_data_val ) begin
      transfer_in_mem_wr            <= 1 ;   
      transfer_in_mem_wr_mask       <= 0 ;
      transfer_in_mem_wr_addr       <= ( transfer_in_mem_wr )  ? transfer_in_mem_wr_addr + 1 : transfer_in_mem_wr_addr  ;
      transfer_in_mem_wr_data       <= transfer_out_mem_rd_data ; 
      transfer_in_mem_commit        <= 0 ;
      transfer_in_mem_commit_len    <= transfer_out_mem_len ;    
   end
   else if ( state == ST_LOOPBACK_CMT ) begin
      transfer_in_mem_wr            <= 0 ;   
      transfer_in_mem_wr_mask       <= 0 ;
      transfer_in_mem_wr_addr       <= 0 ;
      transfer_in_mem_wr_data       <= 0 ;
      transfer_in_mem_commit        <= 1 ;
      transfer_in_mem_commit_len    <= transfer_in_mem_commit_len ;      
   end
   else begin
      transfer_in_mem_wr            <= 0 ;   
      transfer_in_mem_wr_mask       <= 0 ;
      transfer_in_mem_wr_addr       <= 0 ;
      transfer_in_mem_wr_data       <= 0 ;
      transfer_in_mem_commit        <= 0 ;
      transfer_in_mem_commit_len    <= 0 ;     
   end
end


endmodule
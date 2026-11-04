`include "usb3_macro_define.v"	
module transfer_in_mem #(
    parameter TRANSFER_MAX_SIZE           = 0 
   ,parameter TRANSFER_MEM_ADDR_W         = clog2 ( TRANSFER_MAX_SIZE/8 )   
   ,parameter TRANSFER_EDNPT_TYPE         = 0 
)
(
    input wire clk 
   ,input wire rst_n

   ,input wire                            transfer_in_mem_wr
   ,input wire [7:0]                      transfer_in_mem_wr_mask
   ,input wire [13:0]                     transfer_in_mem_wr_addr
   ,input wire [63:0]                     transfer_in_mem_wr_data
   ,input wire                            transfer_in_mem_commit
   ,input wire [16:0]                     transfer_in_mem_commit_len
   ,output reg                            transfer_in_mem_ready 
   ,output reg                            transfer_in_done 
   
   
   ,output reg         transfer_in_pkt_ready
   ,output reg [10:0]  transfer_in_pkt_len
   ,output reg         transfer_in_pkt_last   
   ,input wire          transfer_in_pkt_rd_en
   ,input wire          transfer_in_pkt_sent 
   ,output reg [63:0]  transfer_in_pkt_rd_data 
   
   ,input wire         transfer_in_pkt_acked 
   ,input wire         transfer_in_pkt_rty 

   ,input wire ep_in_pending 

   ,output reg transfer_in_pkt_wt_last_ack 
   ,output reg  payload_empty 
   

)/*synthesis syn_ramstyle="block_ram"*/;

localparam CTRL = 2'b00 ;
localparam ISO  = 2'b01 ;
localparam BULK = 2'b10 ;
localparam INT  = 2'b11 ;

localparam ST_W                   = 2   ; 
localparam ST_IDLE                = 'd0 ;
localparam ST_TRANSFER_TO_PKT     = 'd1 ;
localparam ST_WT_TRANSFER_DONE    = 'd2 ;
localparam ST_TRANSFER_DONE       = 'd3 ;
reg [ST_W-1:0] state ;   


localparam TRANSFER_PKT_MAX_SIZE = ( TRANSFER_EDNPT_TYPE ==  CTRL ) ? 512 : 1024 ;

localparam  K_BYTE_NUM      = get_mem_depth_kbyte_c(TRANSFER_MAX_SIZE) ;
localparam  MEM0_K_BYTE_NUM = ( K_BYTE_NUM >= 64 ) ? 64 : K_BYTE_NUM ;
localparam  MEM1_K_BYTE_NUM = ( K_BYTE_NUM >= 64 ) ? ( K_BYTE_NUM - 64 ) : 0 ;



//reg [63:0] mem0 [0:K_BYTE_NUM*128-1] ;

reg [13:0] transfer_in_mem_rd_addr;
reg [16:0] transfer_in_byte_len   ;

reg [6:0] pkt_num ;
reg [6:0] pkt_num_cp ;
reg       pkt_num_val ;

//reg [95:0] pkt_ready          ;
reg [7:0] pkt_ready          ;
//reg [95:0] pkt_ready_last     ;
reg [7:0] pkt_ready_last     ;
//reg [10:0] pkt_len   [0:95]   ;
reg [10:0] pkt_len_last ;

reg [6:0] pkt_send_pt ;
reg [6:0] pkt_send_pt_cp /*synthesis syn_preserve = 1*/;
reg [6:0] pkt_ack_pt  ;

reg [13:0] transfer_in_mem_rd_offset ;

reg [7:0] transfer_in_pkt_rd_addr ; 

genvar i ;
integer j ;

reg [63:0] mem0 [0:MEM0_K_BYTE_NUM*128 - 1 ] ;
reg [63:0] mem1 [0:MEM1_K_BYTE_NUM*128 - 1 ] ;
reg [63:0] mem0_rd_data ;
reg [63:0] mem1_rd_data ;

generate
   for ( i = 0 ; i < 8 ; i = i + 1 )  begin
      if ( MEM1_K_BYTE_NUM != 0) begin
         always @ ( posedge clk ) begin
            if ( transfer_in_mem_wr & !transfer_in_mem_wr_mask[i] & (!(|transfer_in_mem_wr_addr[13]))) begin
                mem0[transfer_in_mem_wr_addr[12:0]] [((i+1)*8-1)-:8]  <= transfer_in_mem_wr_data [((i+1)*8-1)-:8] ;               
            end
         end             
      end
      else begin
         always @ ( posedge clk ) begin
            if ( transfer_in_mem_wr & !transfer_in_mem_wr_mask[i] ) begin
               mem0[transfer_in_mem_wr_addr[12:0]] [((i+1)*8-1)-:8]  <= transfer_in_mem_wr_data [((i+1)*8-1)-:8] ;               
            end          
         end              
      end
  
   end
endgenerate


generate
   if ( MEM1_K_BYTE_NUM != 0 ) begin
      for ( i = 0 ; i < 8 ; i = i + 1 )  begin
         always @ ( posedge clk ) begin
            if ( transfer_in_mem_wr & !transfer_in_mem_wr_mask[i] & ((|transfer_in_mem_wr_addr[13]))) begin
               mem1[transfer_in_mem_wr_addr[12:0]][((i+1)*8-1)-:8] <= transfer_in_mem_wr_data [((i+1)*8-1)-:8];              
            end             
         end
      end
   end
endgenerate

always @ ( posedge clk ) begin
   mem0_rd_data <= mem0[transfer_in_mem_rd_addr[12:0]] ;
end

generate
   if ( MEM1_K_BYTE_NUM != 0 ) begin
      always @ ( posedge clk ) begin      
         mem1_rd_data <= mem1[transfer_in_mem_rd_addr[12:0]] ; 
      end
   end
endgenerate

generate
   if ( MEM1_K_BYTE_NUM != 0 ) begin
      always @ ( * ) begin
         if ( !(|transfer_in_mem_rd_addr[13]) ) begin
            transfer_in_pkt_rd_data <= mem0_rd_data ;
         end
         else begin
            transfer_in_pkt_rd_data <= mem1_rd_data ;      
         end
      end
   end
   else begin
      always @ ( * ) begin
         transfer_in_pkt_rd_data <= mem0_rd_data ;
      end      
   end
endgenerate


//always @ ( posedge clk or negedge rst_n ) begin
//   if ( !rst_n ) begin
//      `ifdef SIM
//      for ( j = 0 ; j <= TRANSFER_MAX_SIZE/8 ; j = j + 1 ) begin
//         mem0[j] <= 0 ;
//      end
//      `endif
//   end
//   else begin
//   
//      if ( transfer_in_mem_wr && !transfer_in_mem_wr_mask[0] ) begin
//         mem[transfer_in_mem_wr_addr[13:10]][transfer_in_mem_wr_addr[9:0]][((1*8)-1)-:(1)*8] <= transfer_in_mem_wr_data [((1*8)-1)-:(1)*8] ;
//      end
//
//      if ( transfer_in_mem_wr && !transfer_in_mem_wr_mask[1] ) begin
//         mem[transfer_in_mem_wr_addr[13:10]][transfer_in_mem_wr_addr[9:0]][((2*8)-1)-:(1)*8]  <=  transfer_in_mem_wr_data [((2*8)-1)-:(1)*8] ;        
//      end
//      
//      if ( transfer_in_mem_wr && !transfer_in_mem_wr_mask[2] ) begin
//         mem[transfer_in_mem_wr_addr[13:10]][transfer_in_mem_wr_addr[9:0]][((3*8)-1)-:(1)*8] <=  transfer_in_mem_wr_data [((3*8)-1)-:(1)*8];        
//      end
//      
//      if ( transfer_in_mem_wr && !transfer_in_mem_wr_mask[3] ) begin
//         mem[transfer_in_mem_wr_addr[13:10]][transfer_in_mem_wr_addr[9:0]][((4*8)-1)-:(1)*8] <=  transfer_in_mem_wr_data [((4*8)-1)-:(1)*8];  
//      end
//
//      if ( transfer_in_mem_wr && !transfer_in_mem_wr_mask[4] ) begin
//         mem[transfer_in_mem_wr_addr[13:10]][transfer_in_mem_wr_addr[9:0]][((5*8)-1)-:(1)*8] <=  transfer_in_mem_wr_data [((5*8)-1)-:(1)*8];  
//      end
//      
//      if ( transfer_in_mem_wr && !transfer_in_mem_wr_mask[5] ) begin
//         mem[transfer_in_mem_wr_addr[13:10]][transfer_in_mem_wr_addr[9:0]][((6*8)-1)-:(1)*8] <=  transfer_in_mem_wr_data [((6*8)-1)-:(1)*8];  
//      end
//
//      if ( transfer_in_mem_wr && !transfer_in_mem_wr_mask[6] ) begin
//         mem[transfer_in_mem_wr_addr[13:10]][transfer_in_mem_wr_addr[9:0]][((7*8)-1)-:(1)*8] <=  transfer_in_mem_wr_data [((7*8)-1)-:(1)*8];  
//      end
//
//      if ( transfer_in_mem_wr && !transfer_in_mem_wr_mask[7] ) begin
//         mem[transfer_in_mem_wr_addr[13:10]][transfer_in_mem_wr_addr[9:0]][((8*8)-1)-:(1)*8] <=  transfer_in_mem_wr_data [((8*8)-1)-:(1)*8];  
//      end      
//   end
//   
//end 




always @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      state                   <= ST_IDLE ;
      transfer_in_byte_len    <= 0 ;
      pkt_num                 <= 0 ;
      pkt_num_cp              <= 0 ;
      pkt_num_val             <= 0 ;
      transfer_in_mem_ready   <= 0 ;
      transfer_in_done        <= 0 ;
      payload_empty           <= 0 ;      
   end
   else begin
      case ( state ) 
      ST_IDLE:begin
         state                 <= ( transfer_in_mem_ready && transfer_in_mem_commit ) ? ST_TRANSFER_TO_PKT         : state ;    
         transfer_in_byte_len  <= ( transfer_in_mem_ready && transfer_in_mem_commit ) ? transfer_in_mem_commit_len : transfer_in_byte_len ;
         pkt_num               <= 0 ;
         pkt_num_cp            <= 0 ;
         pkt_num_val           <= 0 ;
         transfer_in_mem_ready <= ( transfer_in_mem_ready && transfer_in_mem_commit ) ? 0                          : 1                    ;
         transfer_in_done      <= 0 ;
         payload_empty         <= transfer_in_mem_commit_len == 0 ;         
      end
      ST_TRANSFER_TO_PKT:begin
         state                 <= ST_WT_TRANSFER_DONE ;
         transfer_in_byte_len  <= transfer_in_byte_len ;
         if ( TRANSFER_EDNPT_TYPE ==  CTRL ) begin
            if ( payload_empty ) begin
               pkt_num <= 1 ;
               pkt_num_cp <= 1 ;
            end
            else begin
               pkt_num <=  transfer_in_byte_len[16:9 ] + 1 ;
               pkt_num_cp <=  transfer_in_byte_len[16:9 ] + 1 ;
            end
         end
         else if ( TRANSFER_EDNPT_TYPE ==  ISO ) begin
            if ( payload_empty ) begin
               pkt_num <= 1 ;
               pkt_num_cp <= 1 ;
            end
            else begin
               pkt_num <=  transfer_in_byte_len[16:10] + (|transfer_in_byte_len[9:0]) ;
               pkt_num_cp <=  transfer_in_byte_len[16:10] + (|transfer_in_byte_len[9:0]) ;
            end
         end
         else if ( TRANSFER_EDNPT_TYPE ==  BULK ) begin
            if ( payload_empty ) begin
               pkt_num <= 1 ;
               pkt_num_cp <= 1 ;
            end
            else begin
               pkt_num <=  transfer_in_byte_len [16:10] + (|transfer_in_byte_len[9:0]) ;
               pkt_num_cp <=  transfer_in_byte_len [16:10] + (|transfer_in_byte_len[9:0]) ;
            end
         end
         else if ( TRANSFER_EDNPT_TYPE ==  INT ) begin
            if ( payload_empty ) begin
               pkt_num <= 1 ;
               pkt_num_cp <= 1 ;
            end
            else begin
               pkt_num <=  transfer_in_byte_len [16:10] + (|transfer_in_byte_len[9:0]) ;  
               pkt_num_cp <=  transfer_in_byte_len [16:10] + (|transfer_in_byte_len[9:0]) ;  
            end
         end                                                               
         pkt_num_val           <= 1 ;
         transfer_in_mem_ready <= transfer_in_mem_ready ;
         transfer_in_done      <= 0 ;
      end
      ST_WT_TRANSFER_DONE:begin
         state                   <= ( TRANSFER_EDNPT_TYPE == ISO && pkt_send_pt >= pkt_num ) ? ST_TRANSFER_DONE :
                                    ( TRANSFER_EDNPT_TYPE != ISO && pkt_ack_pt  >= pkt_num ) ? ST_TRANSFER_DONE : state ;
                                    
         transfer_in_byte_len    <= transfer_in_byte_len ;
         pkt_num                 <= pkt_num ;        
         pkt_num_cp              <= pkt_num_cp ;        
         pkt_num_val             <= 0 ;
         transfer_in_mem_ready   <= transfer_in_mem_ready ;
         transfer_in_done        <= 0 ;
      end
      ST_TRANSFER_DONE: begin
         state                   <= ST_IDLE ;        
         transfer_in_byte_len    <= 0 ;
         pkt_num                 <= 0 ;
         pkt_num_cp              <= 0 ;
         pkt_num_val             <= 0 ;
         transfer_in_mem_ready   <= 1 ;  
         transfer_in_done        <= 1 ;
      end
      default:;
      endcase 
   end
end



//generate 
//   for ( i = 0 ; i < 96 ; i = i + 1 ) begin
//      always @ ( posedge clk or negedge rst_n ) begin
//         if (!rst_n) begin
//            pkt_ready      [i]     <= 0 ;
//            //pkt_ready_last [i]     <= 0 ;
//         end   
//         else if ( pkt_num_val && pkt_num - 1 >= i  ) begin
//            pkt_ready [i] <= 1 ;
//            //pkt_ready_last [i] <= ( pkt_num - 1 == i ) ? 1 : 0 ;
//         end
//         else if ( state == ST_TRANSFER_DONE ) begin
//            pkt_ready      [i]     <= 0 ;
//            //pkt_ready_last [i]     <= 0 ;           
//         end
//      end
//   end
//endgenerate
//
//generate 
//   for ( i = 0 ; i < 96 ; i = i + 1 ) begin
//      always @ ( posedge clk or negedge rst_n ) begin
//         if (!rst_n) begin
//            pkt_ready_last [i]     <= 0 ;
//         end   
//         //else if ( pkt_num_val && pkt_num - 1 == i  ) begin
//         else if ( pkt_num_val && pkt_num_cp - 1 == i  ) begin
//            pkt_ready_last [i]      <=  1 ;
//         end
//         else if ( state == ST_TRANSFER_DONE ) begin
//            pkt_ready_last [i]      <= 0 ;           
//         end
//      end
//   end
//endgenerate

always @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      pkt_ready <= 0 ;
   end
   else if ( pkt_num_val ) begin
      pkt_ready <= pkt_num ;
   end
   else if ( state == ST_TRANSFER_DONE ) begin
      pkt_ready <= 0 ;
   end
end

always @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      pkt_ready_last <= 0 ;
   end
   else if ( pkt_num_val ) begin
      pkt_ready_last <= pkt_num - 1 ;
   end
   else if ( state == ST_TRANSFER_DONE ) begin
      pkt_ready_last <= 0 ;
   end
end



always @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      pkt_len_last <= 0 ;
   end
   else if ( pkt_num_val ) begin
      if ( payload_empty ) begin
         pkt_len_last <= 0 ;
      end
      else begin
         case( TRANSFER_EDNPT_TYPE )
               CTRL : pkt_len_last <= { {2'b0} ,  {(|transfer_in_byte_len[8:0] == 0 ) ?  0   : transfer_in_byte_len[8:0] } } ;
               ISO  : pkt_len_last <= { {1'b0} ,  {(|transfer_in_byte_len[9:0] == 0 ) ? 1024 : transfer_in_byte_len[9:0] } } ;
               BULK : pkt_len_last <= { {1'b0} ,  {(|transfer_in_byte_len[9:0] == 0 ) ? 1024 : transfer_in_byte_len[9:0] } } ;
               INT  : pkt_len_last <= { {1'b0} ,  {(|transfer_in_byte_len[9:0] == 0 ) ? 1024 : transfer_in_byte_len[9:0] } } ;
               default:;         
         endcase 
      end
   end
end

//always @ ( * ) begin
//always @ ( posedge clk ) begin
//   transfer_in_pkt_ready <= pkt_ready        [pkt_send_pt] ;
//   transfer_in_pkt_len   <= ( pkt_ready_last   [pkt_send_pt] ) ? pkt_len_last : TRANSFER_PKT_MAX_SIZE ;
//   transfer_in_pkt_last  <= pkt_ready_last   [pkt_send_pt] ;
//end
always @ ( posedge clk ) begin
   transfer_in_pkt_ready <= ( pkt_ready == 0 ) ? 0 : pkt_send_pt <= pkt_ready - 1 ;
   transfer_in_pkt_len   <= ( pkt_ready_last == pkt_send_pt ) ? pkt_len_last : TRANSFER_PKT_MAX_SIZE ;
   transfer_in_pkt_last  <= pkt_ready_last <= pkt_send_pt ;
end

//assign transfer_in_pkt_wt_last_ack = pkt_ack_pt + 1  >= pkt_num ;

always @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      transfer_in_pkt_wt_last_ack <= 0 ;
   end
   else if ( state == ST_TRANSFER_DONE ) begin
      transfer_in_pkt_wt_last_ack <= 0 ;
   end
   else if ( pkt_num == 1 ) begin
      transfer_in_pkt_wt_last_ack <= 1 ;
   end
   else if ( pkt_ack_pt + 2 == pkt_num && transfer_in_pkt_acked ) begin
      transfer_in_pkt_wt_last_ack <= 1 ;
   end
end

always @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      pkt_send_pt <= 0 ;
      pkt_send_pt_cp <= 0 ;
   end
   else if ( state == ST_WT_TRANSFER_DONE ) begin
      pkt_send_pt    <=    ( transfer_in_pkt_rty  ) ? pkt_ack_pt      :
                           ( transfer_in_pkt_sent ) ? pkt_send_pt + 1 :  pkt_send_pt ;

      pkt_send_pt_cp <=    ( transfer_in_pkt_rty  ) ? pkt_ack_pt      :
                           ( transfer_in_pkt_sent ) ? pkt_send_pt + 1 :  pkt_send_pt ;
                    
   end
   else if ( state == ST_TRANSFER_DONE  )begin   
      pkt_send_pt <= 0 ;
      pkt_send_pt_cp <= 0 ;
   end
end


always @ ( * ) begin
   if ( TRANSFER_EDNPT_TYPE ==  CTRL ) begin
      transfer_in_mem_rd_offset <= {1'b0,pkt_send_pt_cp,6'b0};
      transfer_in_mem_rd_addr   <= {transfer_in_mem_rd_offset[13:6],transfer_in_pkt_rd_addr[5:0]};
   end
   else begin
      transfer_in_mem_rd_offset <= {pkt_send_pt_cp,7'b0};   
      transfer_in_mem_rd_addr   <= {transfer_in_mem_rd_offset[13:7],transfer_in_pkt_rd_addr[6:0]};      
   end 
end


always @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      transfer_in_pkt_rd_addr <= 0 ;
   end
   else if ( transfer_in_pkt_sent  ) begin
      transfer_in_pkt_rd_addr <= 0 ;
   end
   else if ( transfer_in_pkt_rd_en ) begin
      transfer_in_pkt_rd_addr <= transfer_in_pkt_rd_addr + 1 ;
   end
end

//always @ ( * ) begin
//   transfer_in_mem_rd_addr <= transfer_in_mem_rd_offset + transfer_in_pkt_rd_addr ;
//end

//always @ ( posedge clk ) begin
//   transfer_in_pkt_rd_data <= mem0 [transfer_in_mem_rd_addr[TRANSFER_MEM_ADDR_W-1:0]];                                                                                                                                                                           
//end

always @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      pkt_ack_pt <= 0 ;
   end
   else if ( state == ST_WT_TRANSFER_DONE ) begin
      pkt_ack_pt <= ( transfer_in_pkt_acked ) ? pkt_ack_pt + 1 : pkt_ack_pt ;
   end
   else if ( state == ST_TRANSFER_DONE ) begin  
      pkt_ack_pt <= 0 ;
   end
end


function integer clog2;
    input integer value;
    integer i;
    begin
        clog2 = 0;
        for (i = value - 1; i > 0; i = i >> 1)
            clog2 = clog2 + 1;
    end
endfunction 

function integer get_mem_addr_w ;
   input integer transfer_maximun_size_byte ;

   begin
      if ( transfer_maximun_size_byte >= 32*1024 ) begin
         get_mem_addr_w = clog2(48*1024/4) ;
      end
      else begin
         get_mem_addr_w = clog2(transfer_maximun_size_byte/4);
      end     
   end

endfunction

function [16:0] get_mem_depth_kbyte_c ;

   input [16:0] transfer_size_byte ;
   
   begin     
      get_mem_depth_kbyte_c = (transfer_size_byte[16:10]) + (|transfer_size_byte[9:0]);   
   end


endfunction


//debug
reg burst_in_err_flg ;
always @ ( posedge clk or negedge rst_n ) begin
	if ( !rst_n  ) begin
		burst_in_err_flg <= 0 ;
	end
	else begin
		burst_in_err_flg <= ep_in_pending == 0 && ( pkt_send_pt != pkt_ack_pt  ) ;
	end
end
endmodule

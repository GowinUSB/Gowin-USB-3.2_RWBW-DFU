`include "usb3_macro_define.v"	
module transfer_in_mem_ping_pong #(

    parameter TRANSFER_MAX_SIZE           = 0   
   ,parameter TRANSFER_EDNPT_TYPE         = 0 
   ,parameter TRANSFER_MEM_PP_NUM         = 0
)
(
    input wire clk 
   ,input wire rst_n

   ,input wire         transfer_in_mem_wr
   ,input wire [7:0]   transfer_in_mem_wr_mask
   ,input wire [13:0]  transfer_in_mem_wr_addr
   ,input wire [63:0]  transfer_in_mem_wr_data
   ,input wire         transfer_in_mem_commit
   ,input wire [16:0]  transfer_in_mem_commit_len
   ,output reg         transfer_in_mem_ready 
   ,output reg         transfer_in_done   
   ,output wire        transfer_in_mem_empty 
   
   
   
   ,output reg          transfer_in_pkt_ready
   ,output reg  [10:0]  transfer_in_pkt_len
   ,output reg          transfer_in_pkt_last   
   ,input wire          transfer_in_pkt_rd_en
   ,input wire          transfer_in_pkt_sent 
   ,output reg  [63:0]  transfer_in_pkt_rd_data 
   ,output reg          transfer_in_pkt_payload_empty
   
   ,input wire         transfer_in_pkt_acked 
   ,input wire         transfer_in_pkt_rty 
   ,input wire         ep_in_pending
   
);

localparam PT_W = $clog2 (  TRANSFER_MEM_PP_NUM ) ;

localparam CTRL = 2'b00 ;
localparam ISO  = 2'b01 ;
localparam BULK = 2'b10 ;
localparam INT  = 2'b11 ;

reg [PT_W-1:0] wr_pt ;
reg [PT_W-1:0] wr_pt_n ;
reg [PT_W-1:0] wr_pt_cp ;
reg [PT_W-1:0] rd_pt ;
reg [PT_W-1:0] rd_pt_cp ;
reg [PT_W-1:0] ack_pt ;

reg         mem_wr            [0:TRANSFER_MEM_PP_NUM-1] ;
reg [7:0]   mem_wr_mask       [0:TRANSFER_MEM_PP_NUM-1] ;
reg [13:0]  mem_wr_addr       [0:TRANSFER_MEM_PP_NUM-1] ;
reg [63:0]  mem_wr_data       [0:TRANSFER_MEM_PP_NUM-1] ;
reg         mem_commit        [0:TRANSFER_MEM_PP_NUM-1] ;
reg [16:0]  mem_commit_len    [0:TRANSFER_MEM_PP_NUM-1] ;
reg         pkt_rd_en         [0:TRANSFER_MEM_PP_NUM-1] ;
reg         pkt_sent          [0:TRANSFER_MEM_PP_NUM-1] ;
reg         pkt_acked         [0:TRANSFER_MEM_PP_NUM-1] ;
reg         pkt_rty           [0:TRANSFER_MEM_PP_NUM-1] ;


wire [TRANSFER_MEM_PP_NUM-1:0]        mem_ready      ;
wire         done          [0:TRANSFER_MEM_PP_NUM-1] ;
wire         pkt_ready     [0:TRANSFER_MEM_PP_NUM-1] ;
wire [10:0]  pkt_len       [0:TRANSFER_MEM_PP_NUM-1] ;
wire         pkt_last      [0:TRANSFER_MEM_PP_NUM-1] ;
wire [63:0]  pkt_rd_data   [0:TRANSFER_MEM_PP_NUM-1] ;
wire         pkt_wt_last_ack   [0:TRANSFER_MEM_PP_NUM-1] ;
wire         pkt_payload_empty   [0:TRANSFER_MEM_PP_NUM-1] ;

genvar i ;

assign transfer_in_mem_empty = &mem_ready ;

always @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      wr_pt <= 0 ;
      wr_pt_cp <= 0 ;
   end
   else if ( transfer_in_mem_commit && transfer_in_mem_ready  ) begin
      wr_pt <= ( wr_pt + 1 >=  TRANSFER_MEM_PP_NUM ) ? 0 : wr_pt + 1 ;
      wr_pt_cp <= ( wr_pt_cp + 1 >=  TRANSFER_MEM_PP_NUM ) ? 0 : wr_pt_cp + 1 ;
   end
end

always @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      rd_pt <= 0 ;
      rd_pt_cp <= 0 ;
   end
   else if ( transfer_in_pkt_rty ) begin
      rd_pt    <= ack_pt ;  
      rd_pt_cp <= ack_pt ;  
   end
   else if ( pkt_last [rd_pt] && transfer_in_pkt_sent ) begin
      rd_pt <= ( rd_pt + 1 >=  TRANSFER_MEM_PP_NUM ) ? 0 : rd_pt + 1 ;
      rd_pt_cp <= ( rd_pt_cp + 1 >=  TRANSFER_MEM_PP_NUM ) ? 0 : rd_pt_cp + 1 ;
      
   end
end

wire act_pt_shift ;
wire rd_pt_shift ;

assign  act_pt_shift   = transfer_in_pkt_acked & pkt_wt_last_ack[ack_pt] == 1 ;
assign  rd_pt_shift    = transfer_in_pkt_sent & pkt_last [rd_pt] == 1  ;

always @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      transfer_in_done <= 0 ;
   end
   else if ( TRANSFER_EDNPT_TYPE == ISO ) begin
      transfer_in_done    <=  rd_pt_shift ;
   end
   else begin
      transfer_in_done    <=  act_pt_shift ; 
   end
end 

always @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      ack_pt <= 0 ;
   end
   //else if ( done [ack_pt] ) begin
   else if ( act_pt_shift ) begin
      ack_pt <= ( ack_pt + 1 >= TRANSFER_MEM_PP_NUM ) ?  0 : ack_pt + 1 ;
   end
end

generate 
   for ( i = 0 ; i < TRANSFER_MEM_PP_NUM ; i = i + 1 ) begin
      always @ ( posedge clk or negedge rst_n ) begin
         if (!rst_n) begin
            mem_wr [i]<= 0 ;
            mem_commit [i]<= 0 ;
         end
         else begin
            mem_wr         [i] <=  ( wr_pt == i && mem_ready [i] )  ?    transfer_in_mem_wr           : 0 ;
            mem_commit     [i] <=  ( wr_pt_cp == i && mem_ready [i] )  ?    transfer_in_mem_commit       : 0 ;                           
         end
      end
      always @ ( posedge clk ) begin
         mem_wr_mask    [i] <=  ( wr_pt == i && mem_ready [i] )  ?    transfer_in_mem_wr_mask      : 0 ;
         mem_wr_addr    [i] <=  ( wr_pt == i && mem_ready [i] )  ?    transfer_in_mem_wr_addr      : 0 ;
         mem_wr_data    [i] <=  ( wr_pt == i && mem_ready [i] )  ?    transfer_in_mem_wr_data      : 0 ;
         mem_commit_len [i] <=  ( wr_pt_cp == i && mem_ready [i] )  ?    transfer_in_mem_commit_len   : 0 ;           
      end

      always @ ( * ) begin
         
         pkt_rd_en      [i] <=  (rd_pt == i ) ? transfer_in_pkt_rd_en : 0 ;
         pkt_sent       [i] <=  (rd_pt == i ) ? transfer_in_pkt_sent  : 0 ;
         
         pkt_acked      [i] <=  (ack_pt == i ) ? transfer_in_pkt_acked : 0 ; 
         
         pkt_rty        [i] <=  transfer_in_pkt_rty ;
         
         
      end
   end

endgenerate

reg [TRANSFER_MEM_PP_NUM-1:0] pkt_ready_n ;
always @ ( * ) begin
   
   if ( TRANSFER_MEM_PP_NUM == 1 ) begin
      transfer_in_mem_ready <= mem_commit[wr_pt_cp] ?  0 : mem_ready     [wr_pt_cp] ;
   end  
   else begin
      transfer_in_mem_ready   <=  mem_commit[wr_pt_cp] ?  mem_ready [wr_pt_n] : mem_ready     [wr_pt_cp] ;
   end
   
   //transfer_in_done        <=  done          [ack_pt] ;     

   transfer_in_pkt_ready   <=  pkt_ready     [rd_pt] ;
   transfer_in_pkt_len     <=  pkt_len       [rd_pt] ;

   transfer_in_pkt_payload_empty <= pkt_payload_empty [rd_pt] ;

   if ( TRANSFER_EDNPT_TYPE == ISO ) begin
      transfer_in_pkt_last    <=  pkt_last      [rd_pt] ;
   end
   else begin
      if ( TRANSFER_MEM_PP_NUM == 1 ) begin
         transfer_in_pkt_last <= pkt_last[rd_pt] ;
      end
      else begin
         if ( rd_pt + 1 == ack_pt ) begin
            transfer_in_pkt_last <= 1 ;         
         end
         else begin
            transfer_in_pkt_last <= pkt_last[rd_pt] && !pkt_ready_n  [rd_pt] ; 
         end
      end
   end

   if ( TRANSFER_MEM_PP_NUM == 1 ) begin
      wr_pt_n <= wr_pt ;
   end
   else begin
      wr_pt_n <= wr_pt + 1 ;
   end


end

always @ ( posedge clk  ) begin
   transfer_in_pkt_rd_data <=  pkt_rd_data   [rd_pt_cp] ;     
end

generate 
   for ( i = 0 ; i < TRANSFER_MEM_PP_NUM ; i = i + 1 ) begin : GEN_TRANSFER_IN_PKT_RDY_N
      if ( i == TRANSFER_MEM_PP_NUM - 1 ) begin
         always @ ( posedge clk or negedge rst_n ) begin
            if (!rst_n) begin
               pkt_ready_n[i] <=  0 ;               
            end        
            else begin
               pkt_ready_n[i] <=  pkt_ready [0] ;
            end 
         end
      end
      else begin
         always @ ( posedge clk or negedge rst_n ) begin
            if (!rst_n) begin
               pkt_ready_n[i] <=  0 ;               
            end        
            else begin
               pkt_ready_n[i] <=  pkt_ready [i+1] ;
            end 
         end
      end
   end
endgenerate

generate 
   for ( i = 0 ; i < TRANSFER_MEM_PP_NUM ; i = i + 1 ) begin : GEN_TRANSFER_IN_MEM 
      transfer_in_mem #(
         .TRANSFER_MAX_SIZE     (TRANSFER_MAX_SIZE   )  
         ,.TRANSFER_EDNPT_TYPE  (TRANSFER_EDNPT_TYPE )
      )
      transfer_in_mem_inst
      (
         .clk      //input 
         ,.rst_n    //input
      
         ,.transfer_in_mem_wr             ( mem_wr        [i] ) //input          
         ,.transfer_in_mem_wr_mask        ( mem_wr_mask   [i] ) //input  [7:0]   
         ,.transfer_in_mem_wr_addr        ( mem_wr_addr   [i] ) //input  [13:0]  
         ,.transfer_in_mem_wr_data        ( mem_wr_data   [i] ) //input  [63:0]  
         ,.transfer_in_mem_commit         ( mem_commit    [i] ) //input          
         ,.transfer_in_mem_commit_len     ( mem_commit_len[i] ) //input  [16:0]  
         ,.transfer_in_mem_ready          ( mem_ready     [i] ) //output         
         ,.transfer_in_done               ( done          [i] ) //output         
         
         
         ,.transfer_in_pkt_ready          ( pkt_ready  [i] ) //output         
         ,.transfer_in_pkt_len            ( pkt_len    [i] ) //output [10:0]  
         ,.transfer_in_pkt_last           ( pkt_last   [i] ) //output         
         ,.transfer_in_pkt_rd_en          ( pkt_rd_en  [i] ) //input          
         ,.transfer_in_pkt_sent           ( pkt_sent   [i] ) //input           
         ,.transfer_in_pkt_rd_data        ( pkt_rd_data[i] ) //output  [63:0]  
         
         ,.transfer_in_pkt_acked          ( pkt_acked [i]  ) // input        
         ,.transfer_in_pkt_rty            ( pkt_rty   [i]  ) // input     


         ,.ep_in_pending                  (ep_in_pending)    

         ,.transfer_in_pkt_wt_last_ack    (pkt_wt_last_ack[i])    
         ,.payload_empty                  (pkt_payload_empty[i])
      
      );
   end
endgenerate

function get_c_log2 ;

input num ;

integer i ;
integer shifter ;

   begin
      get_c_log2 = 0 ;
      shifter = num - 1 ;
      
      for ( i = 0 ; shifter > 0 ; i = i + 1 ) begin
         shifter = shifter >> 1 ;
         get_c_log2 = get_c_log2 + 1 ;
      end
      
   end

endfunction



endmodule
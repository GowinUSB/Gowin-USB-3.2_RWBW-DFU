`include "usb3_macro_define.v"	
module transfer_out_mem_ping_pong #(
    parameter TRANSFER_MAX_SIZE           = 0   
   ,parameter TRANSFER_EDNPT_TYPE         = 0 
   ,parameter TRANSFER_MEM_PP_NUM         = 0
)
(
    input wire clk 
   ,input wire rst_n

   ,input wire         transfer_out_mem_wr
   ,input wire [63:0]  transfer_out_mem_wr_data
   ,input wire         transfer_out_mem_commit
   ,input wire [10:0]  transfer_out_mem_commit_len
   ,input wire         transfer_out_mem_lpf
   ,output reg         transfer_out_mem_ready 
   ,input wire         transfer_out_mem_discard
   
   
   ,output reg          transfer_out_mem_has_data
   ,output reg  [16:0]  transfer_out_mem_len
   ,input  wire [13:0]  transfer_out_mem_rd_addr 
   ,output reg  [63:0]  transfer_out_mem_rd_data 
   ,input  wire         transfer_out_mem_clr 
   
);

localparam PT_W = $clog2 (  TRANSFER_MEM_PP_NUM ) ;

reg [PT_W-1:0] wr_pt ;
reg [PT_W-1:0] rd_pt ;

   
reg          mem_wr                [0:TRANSFER_MEM_PP_NUM-1] ;    
reg  [63:0]  mem_wr_data           [0:TRANSFER_MEM_PP_NUM-1] ;
reg          mem_commit            [0:TRANSFER_MEM_PP_NUM-1] ;
reg  [10:0]  mem_commit_len        [0:TRANSFER_MEM_PP_NUM-1] ;
reg          mem_lpf               [0:TRANSFER_MEM_PP_NUM-1] ;
reg  [13:0]  mem_rd_addr           [0:TRANSFER_MEM_PP_NUM-1] ;
reg          mem_clr               [0:TRANSFER_MEM_PP_NUM-1] ;
reg         mem_discard     [0:TRANSFER_MEM_PP_NUM-1] ;
wire         mem_full     [0:TRANSFER_MEM_PP_NUM-1] ;

wire         mem_ready     [0:TRANSFER_MEM_PP_NUM-1] ;
wire         mem_has_data  [0:TRANSFER_MEM_PP_NUM-1] ;
wire  [16:0] mem_len       [0:TRANSFER_MEM_PP_NUM-1] ;
wire  [63:0] mem_rd_data   [0:TRANSFER_MEM_PP_NUM-1] ;

reg transfer_out_mem_full ;

genvar i ;

always @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      wr_pt <= 0 ;
   end
   else if ( transfer_out_mem_commit && transfer_out_mem_ready && !transfer_out_mem_discard ) begin
      if ( transfer_out_mem_lpf ) begin
         wr_pt <= ( wr_pt + 1 >=  TRANSFER_MEM_PP_NUM ) ? 0 : wr_pt + 1 ;
      end  
      else if ( transfer_out_mem_full ) begin
         wr_pt <= ( wr_pt + 1 >=  TRANSFER_MEM_PP_NUM ) ? 0 : wr_pt + 1 ;
      end
   end
end

always @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      rd_pt <= 0 ;
   end
   else if ( transfer_out_mem_clr && transfer_out_mem_has_data ) begin
      rd_pt <= ( rd_pt + 1 >=  TRANSFER_MEM_PP_NUM ) ? 0 : rd_pt + 1 ;
   end
end

generate 
   for ( i = 0 ; i < TRANSFER_MEM_PP_NUM ; i = i + 1 ) begin
      always @ ( * ) begin
      
         mem_wr          [i] <= (wr_pt == i ) ?   transfer_out_mem_wr           : 0 ;           
         mem_wr_data     [i] <= (wr_pt == i ) ?   transfer_out_mem_wr_data      : 0 ;
         mem_commit      [i] <= (wr_pt == i ) ?   transfer_out_mem_commit       : 0 ;
         mem_commit_len  [i] <= (wr_pt == i ) ?   transfer_out_mem_commit_len   : 0 ;
         mem_lpf         [i] <= (wr_pt == i ) ?   transfer_out_mem_lpf          : 0 ;
         mem_discard     [i] <= (wr_pt == i ) ?   transfer_out_mem_discard      : 0 ;
             
         
         mem_rd_addr     [i] <= (rd_pt == i && mem_has_data [i] ) ?   transfer_out_mem_rd_addr  : 0 ;
         mem_clr         [i] <= (rd_pt == i && mem_has_data [i] ) ?   transfer_out_mem_clr      : 0 ;
      end
   end
endgenerate

always @ ( * ) begin

   transfer_out_mem_ready           <=  mem_ready [wr_pt] ;
   transfer_out_mem_full            <=  mem_full [wr_pt] ;

   transfer_out_mem_has_data        <=  mem_has_data [rd_pt] ;
   transfer_out_mem_len             <=  mem_len      [rd_pt] ;
   transfer_out_mem_rd_data         <=  mem_rd_data  [rd_pt] ;
   
end



generate 
   for ( i = 0 ; i < TRANSFER_MEM_PP_NUM ; i = i + 1 ) begin : GEN_TRANSFER_OUT_MEM
      transfer_out_mem #(
          .TRANSFER_MAX_SIZE     (TRANSFER_MAX_SIZE   )  
         ,.TRANSFER_EDNPT_TYPE  (TRANSFER_EDNPT_TYPE )
      )transfer_out_mem_inst
      (
          .clk       (clk  ) //input  
         ,.rst_n     (rst_n) //input  
      
         ,.transfer_out_mem_wr               (mem_wr        [i]) //input  
         ,.transfer_out_mem_wr_data          (mem_wr_data   [i]) //input  [31:0]
         ,.transfer_out_mem_commit           (mem_commit    [i]) //input        
         ,.transfer_out_mem_commit_len       (mem_commit_len[i]) //input  [10:0]
         ,.transfer_out_mem_lpf              (mem_lpf       [i]) //input        
         ,.transfer_out_mem_ready            (mem_ready     [i]) //output 
         ,.transfer_out_mem_discard          (mem_discard   [i]) //input 
         ,.transfer_out_mem_full             (mem_full      [i]) //output
         
         
         ,.transfer_out_mem_has_data         (mem_has_data[i]) //output          
         ,.transfer_out_mem_len              (mem_len     [i]) //output  [15:0]  
         ,.transfer_out_mem_rd_addr          (mem_rd_addr [i]) //input   [13:0]  
         ,.transfer_out_mem_rd_data          (mem_rd_data [i]) //output  [31:0]  
         ,.transfer_out_mem_clr              (mem_clr     [i]) //input           
      
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
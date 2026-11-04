`include "usb3_macro_define.v"	
module transfer_out_mem #(

    parameter TRANSFER_MAX_SIZE           = 0 
   ,parameter TRANSFER_MEM_ADDR_W         = clog2 ( TRANSFER_MAX_SIZE/8 )   
   ,parameter TRANSFER_EDNPT_TYPE         = 0 
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
   ,output reg         transfer_out_mem_full
   
   
   ,output reg                               transfer_out_mem_has_data
   ,output reg  [16:0]                       transfer_out_mem_len
   ,input  wire [13:0]                       transfer_out_mem_rd_addr 
   ,output reg  [63:0]                       transfer_out_mem_rd_data 
   ,input  wire                              transfer_out_mem_clr
   
   

)/*synthesis syn_ramstyle="block_ram"*/;

localparam CTRL = 2'b00 ;
localparam ISO  = 2'b01 ;
localparam BULK = 2'b10 ;
localparam INT  = 2'b11 ;

localparam ST_W                   = 1   ; 
localparam ST_IDLE                = 'd0 ;
localparam ST_WT_CLR              = 'd1 ;
reg [ST_W-1:0] state ;   


localparam TRANSFER_PKT_MAX_SIZE = ( TRANSFER_EDNPT_TYPE ==  CTRL ) ? 512 : 1024 ;

integer i ;


reg transfer_out_done ;
reg [6:0] pkt_receive_pt ;
reg [13:0] transfer_out_mem_wr_offset_c ;
reg [13:0] transfer_out_mem_wr_offset_n ;
reg [TRANSFER_MEM_ADDR_W-1:0]  transfer_out_mem_wr_addr ;
reg[16:0] transfer_out_len_cnt ;

localparam  K_BYTE_NUM      = get_mem_depth_kbyte_c(TRANSFER_MAX_SIZE) ;
localparam  MEM0_K_BYTE_NUM = ( K_BYTE_NUM >= 32 ) ? 32 : K_BYTE_NUM ;
localparam  MEM1_K_BYTE_NUM = ( K_BYTE_NUM >= 32 ) ? ( K_BYTE_NUM - 32 ) : 0 ;
localparam  MEM0_DEPTH      = MEM0_K_BYTE_NUM * 256 - 1 ; 
localparam  MEM1_DEPTH      = ( MEM1_K_BYTE_NUM == 0 ) ? 0 : MEM1_K_BYTE_NUM * 256 - 1 ; 

//reg [31:0] mem0 [0:256*32 - 1 ] ;
//reg [31:0] mem1 [0:256*16 - 1 ] ;

reg [63:0] mem0 [0:K_BYTE_NUM*128-1] ;
//reg [31:0] mem1 [0:MEM1_DEPTH] ;






//transfer_out_done: asserts 1 beat by last pkt commits for each transfer 
always @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      transfer_out_done <= 0 ; 
   end
   else begin
      //transfer_out_done <= ( transfer_out_mem_commit && transfer_out_mem_lpf && !transfer_out_mem_discard  ) ? 1 : 0 ;   
      if ( transfer_out_mem_commit && !transfer_out_mem_discard ) begin
         if ( transfer_out_mem_lpf ) begin
            transfer_out_done <= 1 ;
         end
         else if ( pkt_receive_pt + 1 >= K_BYTE_NUM ) begin
            transfer_out_done <= 1 ;
         end
         else begin
            transfer_out_done <= 0 ;            
         end
      end
      else begin
         transfer_out_done <= 0 ;
      end
   end
end  

always @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      transfer_out_mem_full <= 0 ; 
   end
   else if ( pkt_receive_pt + 1 >= K_BYTE_NUM ) begin
      transfer_out_mem_full <= 1 ;
   end
   else begin
      transfer_out_mem_full <= 0 ;
   end
end



// pkt_receive_pt: indicates base addr for each rec pkt
// inc by each pkt commits 
// reset by transfer done
always @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      pkt_receive_pt <= 0 ; 
   end
   else begin
      pkt_receive_pt <= ( transfer_out_done ) ? 0 : ( transfer_out_mem_commit && !transfer_out_mem_discard ) ? pkt_receive_pt + 1 : pkt_receive_pt ; 
   end
end  



//transfer_in_mem_rd_offset: base addr for each rec pkt 
// CTRL pkts : 512bytes per pkt
// INT&ISO&BULK pkts : 1024bytes per pkt
always @ ( * ) begin
   if ( TRANSFER_EDNPT_TYPE ==  CTRL ) begin
      transfer_out_mem_wr_offset_n <= {pkt_receive_pt+1,6'b0};
   end
   else begin
      transfer_out_mem_wr_offset_n <= {pkt_receive_pt+1,7'b0};   
   end    
end

always @ ( * ) begin
   if ( TRANSFER_EDNPT_TYPE ==  CTRL ) begin
      transfer_out_mem_wr_offset_c <= {pkt_receive_pt,6'b0};
   end
   else begin
      transfer_out_mem_wr_offset_c <= {pkt_receive_pt,7'b0};   
   end    
end


//transfer_out_mem_wr_addr: wr pt for each pkt 
// inc              when transfer_out_mem_wr == 1 
// load next base offset when transfer_out_mem_commit == 1 
always @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      transfer_out_mem_wr_addr <= 0 ; 
   end
   else begin
      transfer_out_mem_wr_addr <= ( transfer_out_done  		) ?  0						      :
							             ( transfer_out_mem_wr     ) ?  transfer_out_mem_wr_addr + 1 : 
                                  ( transfer_out_mem_commit &&  transfer_out_mem_discard ) ?  transfer_out_mem_wr_offset_c   :  
                                  ( transfer_out_mem_commit && !transfer_out_mem_discard ) ?  transfer_out_mem_wr_offset_n   : transfer_out_mem_wr_addr ; 
   end
end


//transfer_out_len_cnt: total byte len for each transfer
//inc pkt len when pkt commits 
//rst         when transfer done 
always @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      transfer_out_len_cnt <= 0 ; 
   end
   else begin
      transfer_out_len_cnt <= ( transfer_out_done ) ? 0 : ( transfer_out_mem_commit && !transfer_out_mem_discard )  ? transfer_out_len_cnt + transfer_out_mem_commit_len : transfer_out_len_cnt ; 
   end
end

//mem0,mem1: memory for transfer pkts, MSB when wr  
always @ ( posedge clk or negedge rst_n  ) begin

   if ( !rst_n ) begin
      `ifdef SIM
      for ( i = 0 ; i <= TRANSFER_MAX_SIZE/8 ; i = i + 1 ) begin
         mem0[i] <= 0 ;
      end
      `endif
   end

   else if ( transfer_out_mem_wr ) begin
      mem0 [ transfer_out_mem_wr_addr [TRANSFER_MEM_ADDR_W-1:0] ] [((1*8)-1)-:(1*8) ]   <= transfer_out_mem_wr_data [((1*8)-1)-:(1*8) ];     
      mem0 [ transfer_out_mem_wr_addr [TRANSFER_MEM_ADDR_W-1:0] ] [((2*8)-1)-:(1*8) ]   <= transfer_out_mem_wr_data [((2*8)-1)-:(1*8) ];     
      mem0 [ transfer_out_mem_wr_addr [TRANSFER_MEM_ADDR_W-1:0] ] [((3*8)-1)-:(1*8) ]   <= transfer_out_mem_wr_data [((3*8)-1)-:(1*8) ];     
      mem0 [ transfer_out_mem_wr_addr [TRANSFER_MEM_ADDR_W-1:0] ] [((4*8)-1)-:(1*8) ]   <= transfer_out_mem_wr_data [((4*8)-1)-:(1*8) ]; 
      mem0 [ transfer_out_mem_wr_addr [TRANSFER_MEM_ADDR_W-1:0] ] [((5*8)-1)-:(1*8) ]   <= transfer_out_mem_wr_data [((5*8)-1)-:(1*8) ];     
      mem0 [ transfer_out_mem_wr_addr [TRANSFER_MEM_ADDR_W-1:0] ] [((6*8)-1)-:(1*8) ]   <= transfer_out_mem_wr_data [((6*8)-1)-:(1*8) ];     
      mem0 [ transfer_out_mem_wr_addr [TRANSFER_MEM_ADDR_W-1:0] ] [((7*8)-1)-:(1*8) ]   <= transfer_out_mem_wr_data [((7*8)-1)-:(1*8) ];     
      mem0 [ transfer_out_mem_wr_addr [TRANSFER_MEM_ADDR_W-1:0] ] [((8*8)-1)-:(1*8) ]   <= transfer_out_mem_wr_data [((8*8)-1)-:(1*8) ];       
   end
end 



//transfer_out_mem_has_data: indicates a complete transfer ready for rd
//asserts when transfer done 
//rst     when transfer rd out 
 
//transfer_out_mem_len     : equals to a complete transfer length in bytes
//load transfer len when transfer done 
//rst               when rd out 

//transfer_out_mem_ready   : 1 - inicates momery ready for next transfer 
//asserts when transfer rd out
//rst     when transfer done 
always @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      state                      <= ST_IDLE ;
      transfer_out_mem_has_data  <= 0 ;   
      transfer_out_mem_len       <= 0 ;
      transfer_out_mem_ready     <= 1 ;
   end
   else begin
      case ( state ) 
      ST_IDLE:begin // rec pkts for transfer
         state                      <= ( transfer_out_done )  ? ST_WT_CLR              : state                          ;   
         transfer_out_mem_has_data  <= ( transfer_out_done )  ? 1                      : transfer_out_mem_has_data      ;   
         transfer_out_mem_len       <= ( transfer_out_done )  ? transfer_out_len_cnt   : transfer_out_mem_len           ;
         transfer_out_mem_ready     <= ( transfer_out_done )  ? 0                      : transfer_out_mem_ready         ;                 
      end
      ST_WT_CLR:begin // wait transfer pkts rd out 
         state                      <= ( transfer_out_mem_clr )  ? ST_IDLE : state                     ;   
         transfer_out_mem_has_data  <= ( transfer_out_mem_clr )  ? 0       : transfer_out_mem_has_data ;   
         transfer_out_mem_len       <= ( transfer_out_mem_clr )  ? 0       : transfer_out_mem_len      ;
         transfer_out_mem_ready     <= ( transfer_out_mem_clr )  ? 1       : transfer_out_mem_ready    ;          
      end
      default:;
      endcase 
   end
end

always @ ( posedge clk ) begin
   transfer_out_mem_rd_data <= mem0 [transfer_out_mem_rd_addr[TRANSFER_MEM_ADDR_W-1:0]];
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

endmodule
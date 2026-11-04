
module usb3_ep #(
   parameter ENDPT_BURST = 0 
   ,parameter BUFFER_NUM  = 2 
   ,parameter PT_W = clog2(BUFFER_NUM) 
   ,parameter BUFFER_NUM_CEIL = pow2(PT_W)
   ,parameter BUF_OUT_DP_ACKED_VAL = 1 
   ,parameter EP_ISO = 0 
)
(

	 input wire clk 
	,input wire rst_n
	,input wire [4:0] ltssm_state

	,input	wire	[31:0]	buf_in_data
	,input	wire			buf_in_wren
	,output	reg				buf_in_ready
	,input	wire			buf_in_commit
	,input	wire	[10:0]	buf_in_commit_len
	,input  wire			buf_in_eob
	,output reg 	[PT_W:0]	buf_in_nump
	
	,input wire				buf_out_dp_acked 
	,input wire				in_ep_rty

	
	,output	reg		[31:0]	buf_out_q
	,output	reg		[10:0]	buf_out_len
	,output	reg				buf_out_hasdata
	,input	wire			buf_out_arm
	,input  wire 			buf_out_rden
	,output reg 			buf_out_eob 
	,output reg		[PT_W:0]	buf_out_nump
   ,output reg          buf_out_burst_val 


);

`include "usb3_const.vh"

reg [PT_W :0] buf_in_pt ;  
reg [PT_W :0] buf_out_pt ;  
reg [PT_W :0] wt_ack_pt ;  


reg [7:0] buf_in_addr ;
reg [7:0] buf_out_addr;

reg [10:0] buf_out_len_mem [0:BUFFER_NUM_CEIL-1] ;
reg [31:0] buf_mem [0:(BUFFER_NUM_CEIL*1024)/4-1] ;
reg [BUFFER_NUM_CEIL-1:0] buf_ready ;
reg [BUFFER_NUM_CEIL-1:0] buf_hasdata ;
reg [BUFFER_NUM_CEIL-1:0] buf_eob ;
reg [BUFFER_NUM_CEIL-1:0] buf_wt_ack ;
reg [BUFFER_NUM_CEIL-1:0] buf_wt_eob      ;
reg [BUFFER_NUM_CEIL-1:0] buf_burst_val   ;
 
always @ ( * ) begin
	if ( BUF_OUT_DP_ACKED_VAL) begin
		buf_in_ready <= buf_ready [buf_in_pt[PT_W-1:0]] && !buf_wt_ack[buf_in_pt[PT_W-1:0]] ;
	end
	else begin
		buf_in_ready <= buf_ready [buf_in_pt[PT_W-1:0]] ;	
	end
end


always @ ( posedge clk or negedge rst_n ) begin
	if (!rst_n) begin
		buf_in_pt <= 0 ;
	end
	else if ( buf_in_ready && buf_in_commit ) begin
		buf_in_pt <= buf_in_pt + 1 ;
	end
end

genvar index ;
generate 
   for ( index = 0 ; index < BUFFER_NUM_CEIL ; index = index + 1 ) begin
      always @ ( posedge clk or negedge rst_n ) begin									 
         if (!rst_n) begin                                                            
            buf_ready [index] <= 1 ;                                                      
            buf_hasdata [index]  <= 0 ;                                                    
            buf_wt_ack [index] <= 0 ; 
            buf_eob[index] <= 0 ;            
         end                                                                          
         else if ( buf_ready[index] && buf_in_commit && buf_in_pt[PT_W-1:0] == index ) begin           
            buf_ready[index] <= 0 ;                                                      
            buf_hasdata[index] <= 1 ;                                                    
            buf_eob[index] <= buf_in_eob ;                                               
         end                                                                          
         else if ( buf_hasdata[index] && buf_out_arm && buf_out_pt[PT_W-1:0] == index ) begin         
            buf_ready[index] <= 1 ;                                                      
            buf_hasdata[index] <= 0 ;                                                    
            buf_wt_ack[index] <= ( BUF_OUT_DP_ACKED_VAL == 1 ) ? 1 : 0 ;                                                     
         end                                                                          
         else if ( BUF_OUT_DP_ACKED_VAL == 1  && buf_out_dp_acked && wt_ack_pt[PT_W-1] == index ) begin           
            buf_wt_ack[index] <= 0 ; 
            buf_eob[index] <= 0 ;               
         end                                                                          
      end        
   end
endgenerate



generate 
   for ( index = 0 ; index < BUFFER_NUM_CEIL ; index = index + 1 ) begin
      always @ ( posedge clk or negedge rst_n ) begin									 
         if (!rst_n) begin                                                            
            buf_wt_eob     [index] <= 0 ;            
            buf_burst_val  [index] <= 0 ;             
         end                                                                          
         else if ( buf_ready[index] && buf_in_commit && buf_in_pt[PT_W-1:0] == index ) begin           
            buf_wt_eob     [index] <= !buf_in_eob ;
            buf_burst_val  [index] <= buf_in_eob ;
         end                                                                          
         else if (  buf_wt_eob [index] && buf_in_commit ) begin         
            buf_wt_eob     [index] <= !buf_in_eob ; 
            buf_burst_val  [index] <= buf_in_eob ;            
         end                                                                          
         else if ( EP_ISO == 1 && buf_burst_val [index] && buf_out_arm && buf_out_pt[PT_W-1:0] == index ) begin
            buf_wt_eob     [index] <= 0 ;            
            buf_burst_val  [index] <= 0 ;            
         end    
         else if ( EP_ISO == 0 &&  buf_burst_val [index] && buf_out_dp_acked && wt_ack_pt[PT_W-1] == index ) begin 
            buf_wt_eob     [index] <= 0 ;            
            buf_burst_val  [index] <= 0 ;           
         end
      end        
   end
endgenerate

always @ ( posedge clk  ) begin
	if ( buf_in_ready && buf_in_wren  ) begin
		buf_mem [{buf_in_pt[PT_W-1:0],buf_in_addr}] <= buf_in_data ;
	end
end


always @ ( posedge clk or negedge rst_n ) begin
	if (!rst_n) begin
		buf_in_addr <= 0 ;
	end
	else if ( buf_in_ready && buf_in_commit ) begin
		buf_in_addr <= 0 ;
	end
	else if ( buf_in_ready && buf_in_wren ) begin
		buf_in_addr <= buf_in_addr + 1 ;
	end
end

always @ ( posedge clk  ) begin
	if ( buf_out_rden ) begin
		buf_out_q <= buf_mem [{buf_out_pt[PT_W-1:0],buf_out_addr}] ;
	end
end

always @ ( posedge clk or negedge rst_n ) begin
	if (!rst_n) begin
		buf_out_addr <= 0 ;
	end
	else if ( buf_out_hasdata && buf_out_arm ) begin
		buf_out_addr <= 0 ;
	end
	else if ( buf_out_hasdata && buf_out_rden ) begin
      if ( EP_ISO == 1 && buf_out_burst_val == 1 ) begin
         buf_out_addr <= buf_out_addr + 1 ;      
      end
      else if ( EP_ISO == 0 )begin
         buf_out_addr <= buf_out_addr + 1 ;        
      end
	end
end

always @ ( posedge clk ) begin
	if ( buf_in_ready && buf_in_commit  ) begin
		buf_out_len_mem[buf_in_pt[PT_W-1:0]] <= buf_in_commit_len ;
	end
end

always @ ( * ) begin
	buf_out_hasdata   <= buf_hasdata [buf_out_pt[PT_W-1:0]] | buf_wt_ack [buf_out_pt[PT_W-1:0]] ;
	buf_out_len		   <= buf_out_len_mem [buf_out_pt[PT_W-1:0]] ;
   buf_out_burst_val <= buf_burst_val [buf_out_pt[PT_W-1:0]] ;  
end



always @ ( posedge clk or negedge rst_n ) begin
	if (!rst_n) begin
		buf_out_pt <= 0 ;
	end
	else if ( buf_out_hasdata && buf_out_arm  ) begin
		buf_out_pt <= buf_out_pt + 1 ;
	end
	else if (  BUF_OUT_DP_ACKED_VAL == 1 && in_ep_rty ) begin
		buf_out_pt <= wt_ack_pt ;
	end	
end

always @ ( posedge clk or negedge rst_n ) begin
	if (!rst_n) begin
		wt_ack_pt <= 0 ;
	end
	else if ( buf_out_dp_acked && BUF_OUT_DP_ACKED_VAL == 1 ) begin
      wt_ack_pt <= wt_ack_pt + 1 ;
	end
end

//always @ ( posedge clk or negedge rst_n ) begin
always @ ( * ) begin
   //if ( !rst_n ) begin
   //   buf_out_eob <= 0  ;
   //end   
   //else begin
      buf_out_eob <=  buf_eob [buf_out_pt[PT_W-1:0]]  ;
   //end
end

//always @ ( posedge clk ) begin
always @ ( * ) begin
   
   if ( BUF_OUT_DP_ACKED_VAL ) begin
      buf_in_nump <= (  wt_ack_pt[PT_W] == buf_in_pt[PT_W] ) ? {1'b1,wt_ack_pt[PT_W-1:0]} - {1'b0,buf_in_pt[PT_W-1:0]} : {1'b0,wt_ack_pt[PT_W-1:0]} - {1'b0,buf_in_pt[PT_W-1:0]} ;
   end
   else begin  
      buf_in_nump <= ( buf_out_pt[PT_W] == buf_in_pt[PT_W] ) ? {1'b1,buf_out_pt[PT_W-1:0]} - {1'b0,buf_in_pt[PT_W-1:0]} : {1'b0,buf_out_pt[PT_W-1:0]} - {1'b0,buf_in_pt[PT_W-1:0]} ;          
   end 
    
   buf_out_nump <= ( buf_in_pt[PT_W] == buf_out_pt[PT_W] ) ?  {1'b0,buf_in_pt[PT_W-1:0]} - {1'b0,buf_out_pt[PT_W-1:0]} : {1'b1,buf_in_pt[PT_W-1:0]} - {1'b0,buf_out_pt[PT_W-1:0]} ;    
					
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

function integer pow2;
    input integer n;
    begin
        pow2 = 1 << n; // 2^n 等价于 1 左移 n 位
    end
endfunction

endmodule
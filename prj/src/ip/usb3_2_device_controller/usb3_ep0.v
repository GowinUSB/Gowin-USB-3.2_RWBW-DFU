
module usb3_ep0(


 input	wire			local_clk
,input	wire			reset_n

,input wire	[5:0]	    ltssm_state

,input	wire	[63:0]	buf_in_data
,input	wire			buf_in_wren
,input   wire           buf_in_lpf
,output	wire			buf_in_ready
,input	wire			buf_in_commit
,input	wire	[10:0]	buf_in_commit_len
,input   wire           rx_dpp_crcgood

,output	wire	[63:0]	buf_out_q
,output	wire	[10:0]	buf_out_len
,output	wire	      	buf_out_last
,output	wire			buf_out_hasdata
,input	wire			buf_out_arm
,input  wire 			buf_out_rden
,output wire            buf_out_payload_empty

,output	reg				reset_dp_seq

,input wire 			buf_out_dp_acked
,input wire				in_ep_rty				


,output reg				set_device_low_power_state
,input wire				set_device_low_power_state_ack  


// external interface 
,input  wire        transfer_in_mem_wr            
,input  wire [7:0]  transfer_in_mem_wr_mask       
,input  wire [13:0] transfer_in_mem_wr_addr       	
,input  wire [63:0] transfer_in_mem_wr_data       		 	
,input  wire        transfer_in_mem_commit        		
,input  wire [16:0] transfer_in_mem_commit_len    	
,output wire        transfer_in_mem_ready         
,output wire        transfer_in_done  
,output wire        transfer_in_mem_empty           	

,output wire        transfer_out_mem_has_data     
,output wire [16:0] transfer_out_mem_len         
,input  wire [13:0] transfer_out_mem_rd_addr     
,output wire [63:0] transfer_out_mem_rd_data     
,input  wire        transfer_out_mem_clr   
      
// requests

,output reg			request_active 	
,output reg	[7:0]	bmRequestType	
,output reg	[7:0]	bRequest		
,output reg	[15:0]	wValue			
,output reg	[15:0]	wIndex			
,output reg	[15:0]	wLength		
,output reg 		wait_user_commit_request
,input  wire        request_commit   	
 			
								
,output reg				set_address 
,output reg		[6:0]	dev_address 
,input wire				set_address_ack 

,input wire	enter_status_stage 
,output reg	ep0_stall 
											

);

`include "usb3_const.vh"


localparam [7:0]REQ_GET_STATUS		= 8'h0,
				REQ_CLEAR_FEAT		      = 8'h1,
				REQ_SET_FEAT		      = 8'h3,
				REQ_SET_ADDR		      = 8'h5,
				REQ_GET_DESCR		      = 8'h6,
				REQ_SET_DESCR		      = 8'h7,
				REQ_GET_CONFIG		      = 8'h8,
				REQ_SET_CONFIG		      = 8'h9,
				REQ_SET_INTERFACE	      = 8'hB,
				REQ_SYNCH_FRAME         = 8'h12,
				REQ_SET_SEL			      = 8'd48,
				REQ_GET_INTERFACE	      = 8'd10,
				REQ_GET_CONFIGURATION   = 8'd8,
				REQ_SET_IOSDELAY 	      = 8'd49;

localparam HOST_TO_DEVICE =  0 ;
localparam DEVICE_TO_HOST =  1 ;
localparam [1:0] SETUP_TYPE_STANDARD	= 2'h0 ;

reg parse_setup_pkt ;
reg setup_in_ready ;
reg buf_in_commit_d ;
reg pass_data_to_user ;
wire out_buf_ready ;
reg parse_setup_pkt_d;
reg rd_setup_pkt;
reg [1:0] rd_cnt ;
reg rd_setup_pkt_dval ;
reg rd_setup_pkt_dval_d ;
reg [63:0] packet_setup ;
reg packet_setup_latch_act; 
reg [63:0] packet_setup_latch ; 
reg setup_pkt_parsed  ; 
reg need_data_from_user  ; 
reg [6:0] descrip_addr_offset  ; 
reg [6:0] descrip_total_len ;
reg pass_request_to_user ;
reg [6:0 ] descrip_len ;
reg [7:0] setup_rd_addr ;
reg [63:0] setup_rd_data; 
wire [31:0] ep0_in_buf_out_q ;
wire [10:0] ep0_in_buf_out_len ;
wire		ep0_in_buf_out_hasdata ;
wire [31:0] desc_dat ;
reg set_address_act ;
reg [7:0] buf_in_addr ;
reg request_commit_timeout ;
reg [3:0] request_commit_timeout_cnt ;


always @ ( posedge local_clk or negedge reset_n ) begin
	if ( !reset_n ) begin
		buf_in_addr <= 0 ;
	end
	else if ( buf_in_commit ) begin
		buf_in_addr <= 0 ;
	end
	else if ( buf_in_wren ) begin
		buf_in_addr <= buf_in_addr + 1 ;
	end
end	


//managing  setup stage  
always @ ( posedge local_clk or negedge reset_n ) begin
	if ( !reset_n ) begin
		parse_setup_pkt <= 0 ;
	end
	else begin
		setup_in_ready <= 1 ;
		buf_in_commit_d <= buf_in_commit ;
		if ( buf_in_commit && !buf_in_commit_d && !pass_data_to_user  && ltssm_state == LT_U0 ) begin
			if ( rx_dpp_crcgood ) begin
            parse_setup_pkt <= 1 ;
         end
         else begin
            parse_setup_pkt <= 0 ;            
         end
		end
		else begin
			parse_setup_pkt <=  0 ;
		end
	end
end

// mux setup data , user data 
wire [7:0] 	setup_wr_addr =  (pass_data_to_user) ? 0 : buf_in_addr 	;
wire [63:0] setup_wr_data =  (pass_data_to_user) ? 0 : buf_in_data 	;
wire 		setup_wr_en   =  (pass_data_to_user) ? 0 : buf_in_wren 	;

wire 		datapkt_wr_en   	   = ( pass_data_to_user & !ep0_stall ) ? buf_in_wren : 0 ;
wire [63:0] datapkt_wr_data 	   = ( pass_data_to_user & !ep0_stall ) ? buf_in_data : 0 ;
wire 		datapkt_commit  	   = ( pass_data_to_user & !ep0_stall ) ? buf_in_commit : 0 ;
wire [10:0] datapkt_commit_len 	   = ( pass_data_to_user & !ep0_stall ) ? buf_in_commit_len : 0 ;
wire        datapkt_lpf            = ( pass_data_to_user & !ep0_stall ) ? buf_in_lpf : 0 ;
 

assign buf_in_ready  =  (pass_data_to_user) ? out_buf_ready : setup_in_ready  ;

transfer_out_mem_ping_pong
#(
    .TRANSFER_MAX_SIZE           (`ENDPT0_OUT_TRANSFER_MAX_SIZE)    
   ,.TRANSFER_EDNPT_TYPE         (2'b00)  
   ,.TRANSFER_MEM_PP_NUM         (`ENDPT0_OUT_MEM_PP_NUM) 
)
ep0_transfer_out_mem_ping_pong
(
    .clk                   (local_clk  ) //input    
   ,.rst_n                 (reset_n    ) //input  

   ,.transfer_out_mem_wr          (datapkt_wr_en) //input          
   ,.transfer_out_mem_wr_data     (datapkt_wr_data) //input  [31:0]  
   ,.transfer_out_mem_commit      (datapkt_commit) //input          
   ,.transfer_out_mem_commit_len  (datapkt_commit_len) //input  [10:0]  
   ,.transfer_out_mem_lpf         (datapkt_lpf) //input          
   ,.transfer_out_mem_ready       (out_buf_ready) //output    
   ,.transfer_out_mem_discard	  (!rx_dpp_crcgood)    
   
   
   ,.transfer_out_mem_has_data     (transfer_out_mem_has_data) //output          
   ,.transfer_out_mem_len          (transfer_out_mem_len     ) //output [15:0]  
   ,.transfer_out_mem_rd_addr      (transfer_out_mem_rd_addr ) //input  [13:0]  
   ,.transfer_out_mem_rd_data      (transfer_out_mem_rd_data ) //output [31:0]  
   ,.transfer_out_mem_clr          (transfer_out_mem_clr     ) //input          
   
);
//parse setup pkt
always @ ( posedge local_clk or negedge reset_n ) begin
	if ( !reset_n ) begin
		parse_setup_pkt_d <= 0 ;
		rd_setup_pkt <= 0 ;
	end
	else if ( !parse_setup_pkt_d && parse_setup_pkt ) begin
		rd_setup_pkt <= 1 ;
		setup_rd_addr <= 0 ;
	end
	else if ( rd_setup_pkt ) begin
		rd_setup_pkt <= 0 ;
	end	
end

always @ ( posedge local_clk or negedge reset_n ) begin
	if ( !reset_n ) begin
		setup_rd_data <= 0 ;
	end
	else if ( setup_wr_en && setup_wr_addr == 0 ) begin
		setup_rd_data <= setup_wr_data ;
	end
end

always @ ( posedge local_clk or negedge reset_n ) begin
	if ( !reset_n ) begin
		packet_setup_latch_act <= 0 ;
	end
	else if ( rd_setup_pkt ) begin
		packet_setup_latch <= setup_rd_data ;
		packet_setup_latch_act <= 1 ;
	end
	else begin
		packet_setup_latch_act <= 0 ;
	end
end

wire	[7:0]	   packet_setup_reqtype = packet_setup_latch  [(1*8-1)-:(1*8)];	
wire			   packet_setup_dir	    = packet_setup_reqtype[7];
wire	[1:0]	   packet_setup_type	= packet_setup_reqtype[6:5];
wire	[4:0]	   packet_setup_recpt   = packet_setup_reqtype[4:0];
wire	[7:0]	   packet_setup_req	    = packet_setup_latch  [(2*8-1)-:(1*8)];
wire	[15:0]	   packet_setup_wval	= packet_setup_latch  [(4*8-1)-:(2*8)];
wire	[15:0]	   packet_setup_widx	= packet_setup_latch  [(6*8-1)-:(2*8)];
wire	[15:0]	   packet_setup_wlen	= packet_setup_latch  [(8*8-1)-:(2*8)];

always @ ( posedge local_clk or negedge reset_n ) begin
	if ( !reset_n ) begin
		pass_data_to_user <= 0 ;
		need_data_from_user <= 0 ;
		setup_pkt_parsed <= 0 ;
		dev_address <= 0 ;
	end	
	else if ( packet_setup_latch_act ) begin
		setup_pkt_parsed <= 1 ;
		if ( packet_setup_type == SETUP_TYPE_STANDARD ) begin
			if ( packet_setup_req == REQ_SET_ADDR ) begin
				set_address_act <= 1 ;
				dev_address <= packet_setup_wval[6:0] ;	
				need_data_from_user <= 0 ;
				pass_request_to_user <= 0 ;
			end
			else if ( packet_setup_dir == DEVICE_TO_HOST && packet_setup_wlen > 0 ) begin
				pass_request_to_user <= 1 ;
				need_data_from_user <= 1 ; 
				pass_data_to_user <= 0 ;
			end
			else if ( packet_setup_dir == HOST_TO_DEVICE && packet_setup_wlen > 0 ) begin
				pass_request_to_user <= 1 ; 
				need_data_from_user <= 0 ; 
				pass_data_to_user <= 1 ;
			end
			else begin
				pass_request_to_user <= 1 ;
				need_data_from_user <= 0 ; 
				pass_data_to_user <= 0 ; 			
			end
		end
		else begin
			pass_request_to_user <= 1 ;
			if ( packet_setup_dir == DEVICE_TO_HOST && packet_setup_wlen > 0 ) begin
				need_data_from_user <= 1 ; 
				pass_data_to_user <= 0 ;
			end
			else if ( packet_setup_dir == HOST_TO_DEVICE && packet_setup_wlen > 0 ) begin
				need_data_from_user <= 0 ; 
				pass_data_to_user <= 1 ;			
			end
			else begin
				need_data_from_user <= 0 ; 
				pass_data_to_user <= 0 ; 
			end
		end		
	end
	else if ( enter_status_stage | ep0_stall  ) begin
		setup_pkt_parsed <= 0 ;		
		need_data_from_user <= 0 ; 
		pass_data_to_user <= 0 ; 		
	end
	else begin
		setup_pkt_parsed <= 0 ;
		pass_request_to_user <= 0 ;
		set_address_act <= 0 ;
	end
end

always @ ( posedge local_clk or negedge reset_n ) begin
	if ( !reset_n ) begin
		request_active 	<= 0 ;
	end
	else if ( pass_request_to_user ) begin
		request_active 	<= 1 ;
	end
	else begin
		request_active 	<= 0 ;	
	end
end

always @ ( posedge local_clk or negedge reset_n ) begin
	if ( !reset_n ) begin
		wait_user_commit_request <= 0 ;
		ep0_stall <= 0 ;
	end
	else if ( !wait_user_commit_request ) begin		
		if ( request_active ) begin
			wait_user_commit_request <= 1 ;	
			ep0_stall				 <= 0 ;		
		end
	end
	else if ( wait_user_commit_request ) begin
		if ( request_commit ) begin
			wait_user_commit_request <= 0 ;
			ep0_stall <= 0 ;
		end
		else if ( request_commit_timeout ) begin
			wait_user_commit_request <= 0 ;		
			ep0_stall <= 1 ;
		end		
	end
end

always @ ( posedge local_clk or negedge reset_n ) begin
	if ( !reset_n ) begin
		request_commit_timeout_cnt <= 0 ; 
	end
	else if ( wait_user_commit_request ) begin
		request_commit_timeout_cnt <= request_commit_timeout_cnt + 1 ;
	end
	else begin
		request_commit_timeout_cnt <= 0 ; 
	end
end


always @ ( posedge local_clk or negedge reset_n ) begin
	if ( !reset_n ) begin
		request_commit_timeout <= 0 ;		
	end
	else begin
		request_commit_timeout <= request_commit_timeout_cnt + 2 >= 10 ;
	end
end


always @ ( * ) begin
	bmRequestType	<= packet_setup_reqtype ;
	bRequest		<= packet_setup_req  ;
	wValue			<= packet_setup_wval ;
	wIndex			<= packet_setup_widx ;
	wLength			<= packet_setup_wlen ;	
end

always @ ( posedge local_clk or negedge reset_n ) begin
	if ( !reset_n ) begin
		set_address <= 0 ;
	end
	else if ( set_address_act ) begin
		set_address <= 1 ;
	end
	else if ( set_address_ack ) begin
		set_address <= 0 ;
	end
end

transfer_in_mem_ping_pong #(
    .TRANSFER_MAX_SIZE           (`ENDPT0_IN_TRANSFER_MAX_SIZE )  
   ,.TRANSFER_EDNPT_TYPE         (2'b00 )
   ,.TRANSFER_MEM_PP_NUM         (`ENDPT0_IN_MEM_PP_NUM        )   
)ep0_transfer_in_mem_ping_pong
(
    .clk               (local_clk) //input  
   ,.rst_n             (reset_n  ) //input  

   ,.transfer_in_mem_wr            (transfer_in_mem_wr        ) //input           
   ,.transfer_in_mem_wr_mask       (transfer_in_mem_wr_mask   ) //input  [7:0]   
   ,.transfer_in_mem_wr_addr       (transfer_in_mem_wr_addr   ) //input  [13:0]  
   ,.transfer_in_mem_wr_data       (transfer_in_mem_wr_data   ) //input  [63:0]  
   ,.transfer_in_mem_commit        (transfer_in_mem_commit    ) //input          
   ,.transfer_in_mem_commit_len    (transfer_in_mem_commit_len) //input  [15:0]  
   ,.transfer_in_mem_ready         (transfer_in_mem_ready     ) //output          
   ,.transfer_in_done              (transfer_in_done          ) //output          
   ,.transfer_in_mem_empty         (transfer_in_mem_empty     )
     
   ,.transfer_in_pkt_ready          (buf_out_hasdata) //output           
   ,.transfer_in_pkt_len            (buf_out_len    ) //output   [10:0]  
   ,.transfer_in_pkt_last           (  ) //output           
   ,.transfer_in_pkt_rd_en          (buf_out_rden   ) //input           
   ,.transfer_in_pkt_sent           (buf_out_arm    ) //input           
   ,.transfer_in_pkt_rd_data        (buf_out_q      ) //output   [63:0]  
   ,.transfer_in_pkt_payload_empty  (buf_out_payload_empty) //output 
   
   ,.transfer_in_pkt_acked          (buf_out_dp_acked)   //input          
   ,.transfer_in_pkt_rty            (in_ep_rty       )   //input          
   
);

assign buf_out_last = 0 ;


endmodule
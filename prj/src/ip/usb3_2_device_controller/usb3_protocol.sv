`include "usb3_macro_define.v"	
module usb3_protocol (
	
	 input	wire			local_clk
	,input	wire			reset_n
	,input	wire	[5:0]	ltssm_state
	,input  wire            speed

	// ========================================= 		link interface
	
	// received tp 
	,input	wire			rx_tp
	,input	wire			rx_tp_hosterr
	,input	wire			rx_tp_retry
	,input	wire			rx_tp_d
	,input	wire			rx_tp_pktpend
	,input	wire	[3:0]	rx_tp_subtype
	,input	wire	[3:0]	rx_tp_endp
	,input	wire	[4:0]	rx_tp_nump
	,input	wire	[4:0]	rx_tp_seq
	,input	wire	[15:0]	rx_tp_stream
	,input  wire            rx_tp_deferred

	// receive dph 
	,input	wire			rx_dph
	,input	wire			rx_dph_eob
	,input	wire			rx_dph_setup
	,input	wire			rx_dph_pktpend
	,input	wire	[3:0]	rx_dph_endp
	,input	wire	[4:0]	rx_dph_seq
	,input	wire	[15:0]	rx_dph_len
	,input	wire			rx_dpp_start // 1 beat later than rx_dph 
	,input	wire			rx_dpp_abort // 1 beat later than rx_dph 
	,input	wire			rx_dpp_done
	,input	wire			rx_dpp_crcgood
	,input  wire			rx_in_dpp_wasready 
	,input  wire            rx_dph_deferred	
	,input  wire            dpp_end_abort_det

	// send hp
	,output reg 		tx_hp   
	,input wire  		tx_hp_ack 
	,output reg [31:0]	hp_word_0 
	,output reg [31:0]	hp_word_1 
	,output reg [31:0]	hp_word_2 

	// send  dpp 
	,output reg 			tx_DP 		
	,input wire       		tx_DP_ack	
	,output reg				tx_DP_eob 	
	,output reg 			tx_DP_dir 	
	,output reg [3:0]		tx_DP_endp 	
	,output reg [4:0]		tx_DP_seq 	
	,output reg [15:0]		tx_DP_len 	
	,output reg [2:0]		tx_DP_TT 	

	,output reg 			tx_0_DP 	
	,input wire       		tx_0_DP_ack	
	,output reg				tx_0_DP_eob 
	,output reg 			tx_0_DP_dir 
	,output reg [3:0]		tx_0_DP_endp
	,output reg [4:0]		tx_0_DP_seq 
	,output reg [15:0]		tx_0_DP_len 
	,output reg [2:0]		tx_0_DP_TT 	
	
	// receive dpp 
	,input	wire	[63:0]   	buf_in_data
	,input	wire			   	buf_in_wren
	,output	reg 			   	buf_in_ready
	,input	wire			   	buf_in_commit
	,input	wire	[10:0]		buf_in_commit_len

	// send dpp 
	,output  reg      [63:0] 	buf_out_q 
	,input	wire			    buf_out_arm
	,input   wire			    buf_out_rden
	
	// protocol signals 
	,output wire 			set_device_low_power_state 
	,input	wire			set_device_low_power_state_ack 

	
	// protocol error report 
	,output reg			[6:0]	dev_address 

	,input wire	itp_received
	
	// ========================================== external interface
	
	,output	reg warm_or_hot_reset 
	
	,output wire   host_requests_data_from_endpt  [0:15]
	
	// requests
	,output wire			   	request_active 	
	,output wire	[7:0]	   	bmRequestType	
	,output wire	[7:0]	   	bRequest		
	,output wire	[15:0]		wValue			
	,output wire	[15:0]		wIndex			
	,output wire	[15:0]		wLength		
	,output wire				wait_user_commit_request
	,input  wire        		request_commit  
	
	// ep IN  
   ,input  wire        transfer_in_mem_wr          [0:15]    
   ,input  wire [7:0]  transfer_in_mem_wr_mask     [0:15]  
   ,input  wire [13:0] transfer_in_mem_wr_addr     [0:15]  	
   ,input  wire [63:0] transfer_in_mem_wr_data     [0:15]  		 	
   ,input  wire        transfer_in_mem_commit      [0:15]  		
   ,input  wire [16:0] transfer_in_mem_commit_len  [0:15]  	
   ,output wire        transfer_in_mem_ready       [0:15]  
   ,output wire        transfer_in_done            [0:15]
   ,output wire        transfer_in_mem_empty       [0:15]
   
   ,output wire        transfer_out_mem_has_data   [0:15]    
   ,output wire [16:0] transfer_out_mem_len        [0:15] 
   ,input  wire [13:0] transfer_out_mem_rd_addr    [0:15] 
   ,output wire [63:0] transfer_out_mem_rd_data    [0:15] 
   ,input  wire        transfer_out_mem_clr        [0:15]
 
	
);

localparam int IN_EP_TYPE [0:15] = '{ 
0:2'b00
`ifdef ENDPT1_IN                     ,1:`ENDPT1_IN_TYPE             `else                                ,1:2'b00                      `endif                          
`ifdef ENDPT2_IN                     ,2:`ENDPT2_IN_TYPE             `else                                ,2:2'b00                      `endif                          
`ifdef ENDPT3_IN                     ,3:`ENDPT3_IN_TYPE             `else                                ,3:2'b00                      `endif                          
`ifdef ENDPT4_IN                     ,4:`ENDPT4_IN_TYPE             `else                                ,4:2'b00                      `endif                          
`ifdef ENDPT5_IN                     ,5:`ENDPT5_IN_TYPE             `else                                ,5:2'b00                      `endif                          
`ifdef ENDPT6_IN                     ,6:`ENDPT6_IN_TYPE             `else                                ,6:2'b00                      `endif                          
`ifdef ENDPT7_IN                     ,7:`ENDPT7_IN_TYPE             `else                                ,7:2'b00                      `endif                          
`ifdef ENDPT8_IN                     ,8:`ENDPT8_IN_TYPE             `else                                ,8:2'b00                      `endif                          
`ifdef ENDPT9_IN                     ,9:`ENDPT9_IN_TYPE             `else                                ,9:2'b00                      `endif                          
`ifdef ENDPT10_IN                    ,10:`ENDPT10_IN_TYPE           `else                                ,10:2'b00                     `endif                          
`ifdef ENDPT11_IN                    ,11:`ENDPT11_IN_TYPE           `else                                ,11:2'b00                     `endif                          
`ifdef ENDPT12_IN                    ,12:`ENDPT12_IN_TYPE           `else                                ,12:2'b00                     `endif                          
`ifdef ENDPT13_IN                    ,13:`ENDPT13_IN_TYPE           `else                                ,13:2'b00                     `endif                          
`ifdef ENDPT14_IN                    ,14:`ENDPT14_IN_TYPE           `else                                ,14:2'b00                     `endif                          
`ifdef ENDPT15_IN                    ,15:`ENDPT15_IN_TYPE           `else                                ,15:2'b00                     `endif                          
}; 

localparam int OUT_EP_TYPE [0:15] = '{ 
0:2'b00
`ifdef ENDPT1_OUT                    ,1:`ENDPT1_OUT_TYPE           `else                                ,1:2'b00                      `endif                          
`ifdef ENDPT2_OUT                    ,2:`ENDPT2_OUT_TYPE           `else                                ,2:2'b00                      `endif                          
`ifdef ENDPT3_OUT                    ,3:`ENDPT3_OUT_TYPE           `else                                ,3:2'b00                      `endif                          
`ifdef ENDPT4_OUT                    ,4:`ENDPT4_OUT_TYPE           `else                                ,4:2'b00                      `endif                          
`ifdef ENDPT5_OUT                    ,5:`ENDPT5_OUT_TYPE           `else                                ,5:2'b00                      `endif                          
`ifdef ENDPT6_OUT                    ,6:`ENDPT6_OUT_TYPE           `else                                ,6:2'b00                      `endif                          
`ifdef ENDPT7_OUT                    ,7:`ENDPT7_OUT_TYPE           `else                                ,7:2'b00                      `endif                          
`ifdef ENDPT8_OUT                    ,8:`ENDPT8_OUT_TYPE           `else                                ,8:2'b00                      `endif                          
`ifdef ENDPT9_OUT                    ,9:`ENDPT9_OUT_TYPE           `else                                ,9:2'b00                      `endif                          
`ifdef ENDPT10_OUT                    ,10:`ENDPT10_OUT_TYPE           `else                                ,10:2'b00                      `endif                          
`ifdef ENDPT11_OUT                    ,11:`ENDPT11_OUT_TYPE           `else                                ,11:2'b00                      `endif                          
`ifdef ENDPT12_OUT                    ,12:`ENDPT12_OUT_TYPE           `else                                ,12:2'b00                      `endif                          
`ifdef ENDPT13_OUT                    ,13:`ENDPT13_OUT_TYPE           `else                                ,13:2'b00                      `endif                          
`ifdef ENDPT14_OUT                    ,14:`ENDPT14_OUT_TYPE           `else                                ,14:2'b00                      `endif                          
`ifdef ENDPT15_OUT                    ,15:`ENDPT15_OUT_TYPE           `else                                ,15:2'b00                      `endif                          
};    



localparam int IN_EP_DEF [0:15] = '{
0:1'b1 
`ifdef ENDPT1_IN        ,1:1'b1           `else                    ,1:1'b0           `endif             
`ifdef ENDPT2_IN        ,2:1'b1           `else                    ,2:1'b0           `endif             
`ifdef ENDPT3_IN        ,3:1'b1           `else                    ,3:1'b0           `endif             
`ifdef ENDPT4_IN        ,4:1'b1           `else                    ,4:1'b0           `endif             
`ifdef ENDPT5_IN        ,5:1'b1           `else                    ,5:1'b0           `endif             
`ifdef ENDPT6_IN        ,6:1'b1           `else                    ,6:1'b0           `endif             
`ifdef ENDPT7_IN        ,7:1'b1           `else                    ,7:1'b0           `endif             
`ifdef ENDPT8_IN        ,8:1'b1           `else                    ,8:1'b0           `endif             
`ifdef ENDPT9_IN        ,9:1'b1           `else                    ,9:1'b0           `endif             
`ifdef ENDPT10_IN       ,10:1'b1          `else                    ,10:1'b0          `endif             
`ifdef ENDPT11_IN       ,11:1'b1          `else                    ,11:1'b0          `endif             
`ifdef ENDPT12_IN       ,12:1'b1          `else                    ,12:1'b0          `endif             
`ifdef ENDPT13_IN       ,13:1'b1          `else                    ,13:1'b0          `endif             
`ifdef ENDPT14_IN       ,14:1'b1          `else                    ,14:1'b0          `endif             
`ifdef ENDPT15_IN       ,15:1'b1          `else                    ,15:1'b0          `endif             
};                 

localparam int OUT_EP_DEF [0:15] = '{ 
0:1'b1 
`ifdef ENDPT1_OUT        ,1:1'b1           `else                    ,1:1'b0           `endif             
`ifdef ENDPT2_OUT        ,2:1'b1           `else                    ,2:1'b0           `endif             
`ifdef ENDPT3_OUT        ,3:1'b1           `else                    ,3:1'b0           `endif             
`ifdef ENDPT4_OUT        ,4:1'b1           `else                    ,4:1'b0           `endif             
`ifdef ENDPT5_OUT        ,5:1'b1           `else                    ,5:1'b0           `endif             
`ifdef ENDPT6_OUT        ,6:1'b1           `else                    ,6:1'b0           `endif             
`ifdef ENDPT7_OUT        ,7:1'b1           `else                    ,7:1'b0           `endif             
`ifdef ENDPT8_OUT        ,8:1'b1           `else                    ,8:1'b0           `endif             
`ifdef ENDPT9_OUT        ,9:1'b1           `else                    ,9:1'b0           `endif             
`ifdef ENDPT10_OUT        ,10:1'b1           `else                    ,10:1'b0           `endif             
`ifdef ENDPT11_OUT        ,11:1'b1           `else                    ,11:1'b0           `endif             
`ifdef ENDPT12_OUT        ,12:1'b1           `else                    ,12:1'b0           `endif             
`ifdef ENDPT13_OUT        ,13:1'b1           `else                    ,13:1'b0           `endif             
`ifdef ENDPT14_OUT        ,14:1'b1           `else                    ,14:1'b0           `endif             
`ifdef ENDPT15_OUT        ,15:1'b1           `else                    ,15:1'b0           `endif             
}; 

localparam int IN_EP_BURST [0:15] = '{
0:5'd0
`ifdef ENDPT1_IN                    ,1:`ENDPT1_IN_BURST          `else                                ,1:5'd0                       `endif                          
`ifdef ENDPT2_IN                    ,2:`ENDPT2_IN_BURST          `else                                ,2:5'd0                       `endif                          
`ifdef ENDPT3_IN                    ,3:`ENDPT3_IN_BURST          `else                                ,3:5'd0                       `endif                          
`ifdef ENDPT4_IN                    ,4:`ENDPT4_IN_BURST          `else                                ,4:5'd0                       `endif                          
`ifdef ENDPT5_IN                    ,5:`ENDPT5_IN_BURST          `else                                ,5:5'd0                       `endif                          
`ifdef ENDPT6_IN                    ,6:`ENDPT6_IN_BURST          `else                                ,6:5'd0                       `endif                          
`ifdef ENDPT7_IN                    ,7:`ENDPT7_IN_BURST          `else                                ,7:5'd0                       `endif                          
`ifdef ENDPT8_IN                    ,8:`ENDPT8_IN_BURST          `else                                ,8:5'd0                       `endif                          
`ifdef ENDPT9_IN                    ,9:`ENDPT9_IN_BURST          `else                                ,9:5'd0                       `endif                          
`ifdef ENDPT10_IN                    ,10:`ENDPT10_IN_BURST          `else                                ,10:5'd0                       `endif                          
`ifdef ENDPT11_IN                    ,11:`ENDPT11_IN_BURST          `else                                ,11:5'd0                       `endif                          
`ifdef ENDPT12_IN                    ,12:`ENDPT12_IN_BURST          `else                                ,12:5'd0                       `endif                          
`ifdef ENDPT13_IN                    ,13:`ENDPT13_IN_BURST          `else                                ,13:5'd0                       `endif                          
`ifdef ENDPT14_IN                    ,14:`ENDPT14_IN_BURST          `else                                ,14:5'd0                       `endif                          
`ifdef ENDPT15_IN                    ,15:`ENDPT15_IN_BURST          `else                                ,15:5'd0                       `endif                          
};
	
localparam int OUT_EP_BURST [0:15] = '{
0:5'd0 
`ifdef ENDPT1_OUT                    ,1:`ENDPT1_OUT_BURST          `else                                ,1:5'd0                       `endif                          
`ifdef ENDPT2_OUT                    ,2:`ENDPT2_OUT_BURST          `else                                ,2:5'd0                       `endif                          
`ifdef ENDPT3_OUT                    ,3:`ENDPT3_OUT_BURST          `else                                ,3:5'd0                       `endif                          
`ifdef ENDPT4_OUT                    ,4:`ENDPT4_OUT_BURST          `else                                ,4:5'd0                       `endif                          
`ifdef ENDPT5_OUT                    ,5:`ENDPT5_OUT_BURST          `else                                ,5:5'd0                       `endif                          
`ifdef ENDPT6_OUT                    ,6:`ENDPT6_OUT_BURST          `else                                ,6:5'd0                       `endif                          
`ifdef ENDPT7_OUT                    ,7:`ENDPT7_OUT_BURST          `else                                ,7:5'd0                       `endif                          
`ifdef ENDPT8_OUT                    ,8:`ENDPT8_OUT_BURST          `else                                ,8:5'd0                       `endif                          
`ifdef ENDPT9_OUT                    ,9:`ENDPT9_OUT_BURST          `else                                ,9:5'd0                       `endif                          
`ifdef ENDPT10_OUT                    ,10:`ENDPT10_OUT_BURST          `else                                ,10:5'd0                       `endif                          
`ifdef ENDPT11_OUT                    ,11:`ENDPT11_OUT_BURST          `else                                ,11:5'd0                       `endif                          
`ifdef ENDPT12_OUT                    ,12:`ENDPT12_OUT_BURST          `else                                ,12:5'd0                       `endif                          
`ifdef ENDPT13_OUT                    ,13:`ENDPT13_OUT_BURST          `else                                ,13:5'd0                       `endif                          
`ifdef ENDPT14_OUT                    ,14:`ENDPT14_OUT_BURST          `else                                ,14:5'd0                       `endif                          
`ifdef ENDPT15_OUT                    ,15:`ENDPT15_OUT_BURST          `else                                ,15:5'd0                       `endif                          
};

localparam int IN_EP_TRANSFER_MAX_SIZE [0:15] = '{
0:`ENDPT0_IN_TRANSFER_MAX_SIZE 
`ifdef ENDPT1_IN                    ,1:`ENDPT1_IN_TRANSFER_MAX_SIZE          `else                                ,1:16'd0                      `endif                          
`ifdef ENDPT2_IN                    ,2:`ENDPT2_IN_TRANSFER_MAX_SIZE          `else                                ,2:16'd0                      `endif                          
`ifdef ENDPT3_IN                    ,3:`ENDPT3_IN_TRANSFER_MAX_SIZE          `else                                ,3:16'd0                      `endif                          
`ifdef ENDPT4_IN                    ,4:`ENDPT4_IN_TRANSFER_MAX_SIZE          `else                                ,4:16'd0                      `endif                          
`ifdef ENDPT5_IN                    ,5:`ENDPT5_IN_TRANSFER_MAX_SIZE          `else                                ,5:16'd0                      `endif                          
`ifdef ENDPT6_IN                    ,6:`ENDPT6_IN_TRANSFER_MAX_SIZE          `else                                ,6:16'd0                      `endif                          
`ifdef ENDPT7_IN                    ,7:`ENDPT7_IN_TRANSFER_MAX_SIZE          `else                                ,7:16'd0                      `endif                          
`ifdef ENDPT8_IN                    ,8:`ENDPT8_IN_TRANSFER_MAX_SIZE          `else                                ,8:16'd0                      `endif                          
`ifdef ENDPT9_IN                    ,9:`ENDPT9_IN_TRANSFER_MAX_SIZE          `else                                ,9:16'd0                      `endif                          
`ifdef ENDPT10_IN                    ,10:`ENDPT10_IN_TRANSFER_MAX_SIZE          `else                                ,10:16'd0                      `endif                          
`ifdef ENDPT11_IN                    ,11:`ENDPT11_IN_TRANSFER_MAX_SIZE          `else                                ,11:16'd0                      `endif                          
`ifdef ENDPT12_IN                    ,12:`ENDPT12_IN_TRANSFER_MAX_SIZE          `else                                ,12:16'd0                      `endif                          
`ifdef ENDPT13_IN                    ,13:`ENDPT13_IN_TRANSFER_MAX_SIZE          `else                                ,13:16'd0                      `endif                          
`ifdef ENDPT14_IN                    ,14:`ENDPT14_IN_TRANSFER_MAX_SIZE          `else                                ,14:16'd0                      `endif                          
`ifdef ENDPT15_IN                    ,15:`ENDPT15_IN_TRANSFER_MAX_SIZE          `else                                ,15:16'd0                      `endif                          
}; 

localparam int EP_TYPE_PKT_SIZE [0:3] = '{
 0:512
,1:1024
,2:1024
,3:1024
}; 

localparam int IN_EP_TYPE_PKT_SIZE [0:15] = '{
0:EP_TYPE_PKT_SIZE[`ENDPT0_IN_TYPE] 
`ifdef ENDPT1_IN                      ,1:EP_TYPE_PKT_SIZE[`ENDPT1_IN_TYPE]         `else                                ,1:16'd0                      `endif                          
`ifdef ENDPT2_IN                      ,2:EP_TYPE_PKT_SIZE[`ENDPT2_IN_TYPE]         `else                                ,2:16'd0                      `endif                          
`ifdef ENDPT3_IN                      ,3:EP_TYPE_PKT_SIZE[`ENDPT3_IN_TYPE]         `else                                ,3:16'd0                      `endif                          
`ifdef ENDPT4_IN                      ,4:EP_TYPE_PKT_SIZE[`ENDPT4_IN_TYPE]         `else                                ,4:16'd0                      `endif                          
`ifdef ENDPT5_IN                      ,5:EP_TYPE_PKT_SIZE[`ENDPT5_IN_TYPE]         `else                                ,5:16'd0                      `endif                          
`ifdef ENDPT6_IN                      ,6:EP_TYPE_PKT_SIZE[`ENDPT6_IN_TYPE]         `else                                ,6:16'd0                      `endif                          
`ifdef ENDPT7_IN                      ,7:EP_TYPE_PKT_SIZE[`ENDPT7_IN_TYPE]         `else                                ,7:16'd0                      `endif                          
`ifdef ENDPT8_IN                      ,8:EP_TYPE_PKT_SIZE[`ENDPT8_IN_TYPE]         `else                                ,8:16'd0                      `endif                          
`ifdef ENDPT9_IN                      ,9:EP_TYPE_PKT_SIZE[`ENDPT9_IN_TYPE]         `else                                ,9:16'd0                      `endif                          
`ifdef ENDPT10_IN                    ,10:EP_TYPE_PKT_SIZE[`ENDPT10_IN_TYPE]          `else                                ,10:16'd0                      `endif                          
`ifdef ENDPT11_IN                    ,11:EP_TYPE_PKT_SIZE[`ENDPT11_IN_TYPE]          `else                                ,11:16'd0                      `endif                          
`ifdef ENDPT12_IN                    ,12:EP_TYPE_PKT_SIZE[`ENDPT12_IN_TYPE]          `else                                ,12:16'd0                      `endif                          
`ifdef ENDPT13_IN                    ,13:EP_TYPE_PKT_SIZE[`ENDPT13_IN_TYPE]          `else                                ,13:16'd0                      `endif                          
`ifdef ENDPT14_IN                    ,14:EP_TYPE_PKT_SIZE[`ENDPT14_IN_TYPE]          `else                                ,14:16'd0                      `endif                          
`ifdef ENDPT15_IN                    ,15:EP_TYPE_PKT_SIZE[`ENDPT15_IN_TYPE]          `else                                ,15:16'd0                      `endif                          
}; 

localparam int OUT_EP_TRANSFER_MAX_SIZE [0:15] = '{
0:`ENDPT0_OUT_TRANSFER_MAX_SIZE
`ifdef ENDPT1_OUT                    ,1:`ENDPT1_OUT_TRANSFER_MAX_SIZE          `else                                ,1:16'd0                      `endif                          
`ifdef ENDPT2_OUT                    ,2:`ENDPT2_OUT_TRANSFER_MAX_SIZE          `else                                ,2:16'd0                      `endif                          
`ifdef ENDPT3_OUT                    ,3:`ENDPT3_OUT_TRANSFER_MAX_SIZE          `else                                ,3:16'd0                      `endif                          
`ifdef ENDPT4_OUT                    ,4:`ENDPT4_OUT_TRANSFER_MAX_SIZE          `else                                ,4:16'd0                      `endif                          
`ifdef ENDPT5_OUT                    ,5:`ENDPT5_OUT_TRANSFER_MAX_SIZE          `else                                ,5:16'd0                      `endif                          
`ifdef ENDPT6_OUT                    ,6:`ENDPT6_OUT_TRANSFER_MAX_SIZE          `else                                ,6:16'd0                      `endif                          
`ifdef ENDPT7_OUT                    ,7:`ENDPT7_OUT_TRANSFER_MAX_SIZE          `else                                ,7:16'd0                      `endif                          
`ifdef ENDPT8_OUT                    ,8:`ENDPT8_OUT_TRANSFER_MAX_SIZE          `else                                ,8:16'd0                      `endif                          
`ifdef ENDPT9_OUT                    ,9:`ENDPT9_OUT_TRANSFER_MAX_SIZE          `else                                ,9:16'd0                      `endif                          
`ifdef ENDPT10_OUT                    ,10:`ENDPT10_OUT_TRANSFER_MAX_SIZE          `else                                ,10:16'd0                      `endif                          
`ifdef ENDPT11_OUT                    ,11:`ENDPT11_OUT_TRANSFER_MAX_SIZE          `else                                ,11:16'd0                      `endif                          
`ifdef ENDPT12_OUT                    ,12:`ENDPT12_OUT_TRANSFER_MAX_SIZE          `else                                ,12:16'd0                      `endif                          
`ifdef ENDPT13_OUT                    ,13:`ENDPT13_OUT_TRANSFER_MAX_SIZE          `else                                ,13:16'd0                      `endif                          
`ifdef ENDPT14_OUT                    ,14:`ENDPT14_OUT_TRANSFER_MAX_SIZE          `else                                ,14:16'd0                      `endif                          
`ifdef ENDPT15_OUT                    ,15:`ENDPT15_OUT_TRANSFER_MAX_SIZE          `else                                ,15:16'd0                      `endif                          
};

localparam int IN_EP_MEM_PP_NUM [0:15] = '{ 
0:`ENDPT0_IN_MEM_PP_NUM
`ifdef ENDPT1_IN                    ,1:`ENDPT1_IN_MEM_PP_NUM          `else                                ,1:'d0                      `endif                          
`ifdef ENDPT2_IN                    ,2:`ENDPT2_IN_MEM_PP_NUM          `else                                ,2:'d0                      `endif                          
`ifdef ENDPT3_IN                    ,3:`ENDPT3_IN_MEM_PP_NUM          `else                                ,3:'d0                      `endif                          
`ifdef ENDPT4_IN                    ,4:`ENDPT4_IN_MEM_PP_NUM          `else                                ,4:'d0                      `endif                          
`ifdef ENDPT5_IN                    ,5:`ENDPT5_IN_MEM_PP_NUM          `else                                ,5:'d0                      `endif                          
`ifdef ENDPT6_IN                    ,6:`ENDPT6_IN_MEM_PP_NUM          `else                                ,6:'d0                      `endif                          
`ifdef ENDPT7_IN                    ,7:`ENDPT7_IN_MEM_PP_NUM          `else                                ,7:'d0                      `endif                          
`ifdef ENDPT8_IN                    ,8:`ENDPT8_IN_MEM_PP_NUM          `else                                ,8:'d0                      `endif                          
`ifdef ENDPT9_IN                    ,9:`ENDPT9_IN_MEM_PP_NUM          `else                                ,9:'d0                      `endif                          
`ifdef ENDPT10_IN                    ,10:`ENDPT10_IN_MEM_PP_NUM          `else                                ,10:'d0                      `endif                          
`ifdef ENDPT11_IN                    ,11:`ENDPT11_IN_MEM_PP_NUM          `else                                ,11:'d0                      `endif                          
`ifdef ENDPT12_IN                    ,12:`ENDPT12_IN_MEM_PP_NUM          `else                                ,12:'d0                      `endif                          
`ifdef ENDPT13_IN                    ,13:`ENDPT13_IN_MEM_PP_NUM          `else                                ,13:'d0                      `endif                          
`ifdef ENDPT14_IN                    ,14:`ENDPT14_IN_MEM_PP_NUM          `else                                ,14:'d0                      `endif                          
`ifdef ENDPT15_IN                    ,15:`ENDPT15_IN_MEM_PP_NUM          `else                                ,15:'d0                      `endif                          
};

localparam int OUT_EP_MEM_PP_NUM [0:15] = '{ 
0:`ENDPT0_OUT_MEM_PP_NUM
`ifdef ENDPT1_OUT                    ,1:`ENDPT1_OUT_MEM_PP_NUM          `else                                ,1:'d0                      `endif                          
`ifdef ENDPT2_OUT                    ,2:`ENDPT2_OUT_MEM_PP_NUM          `else                                ,2:'d0                      `endif                          
`ifdef ENDPT3_OUT                    ,3:`ENDPT3_OUT_MEM_PP_NUM          `else                                ,3:'d0                      `endif                          
`ifdef ENDPT4_OUT                    ,4:`ENDPT4_OUT_MEM_PP_NUM          `else                                ,4:'d0                      `endif                          
`ifdef ENDPT5_OUT                    ,5:`ENDPT5_OUT_MEM_PP_NUM          `else                                ,5:'d0                      `endif                          
`ifdef ENDPT6_OUT                    ,6:`ENDPT6_OUT_MEM_PP_NUM          `else                                ,6:'d0                      `endif                          
`ifdef ENDPT7_OUT                    ,7:`ENDPT7_OUT_MEM_PP_NUM          `else                                ,7:'d0                      `endif                          
`ifdef ENDPT8_OUT                    ,8:`ENDPT8_OUT_MEM_PP_NUM          `else                                ,8:'d0                      `endif                          
`ifdef ENDPT9_OUT                    ,9:`ENDPT9_OUT_MEM_PP_NUM          `else                                ,9:'d0                      `endif                          
`ifdef ENDPT10_OUT                    ,10:`ENDPT10_OUT_MEM_PP_NUM          `else                                ,10:'d0                      `endif                          
`ifdef ENDPT11_OUT                    ,11:`ENDPT11_OUT_MEM_PP_NUM          `else                                ,11:'d0                      `endif                          
`ifdef ENDPT12_OUT                    ,12:`ENDPT12_OUT_MEM_PP_NUM          `else                                ,12:'d0                      `endif                          
`ifdef ENDPT13_OUT                    ,13:`ENDPT13_OUT_MEM_PP_NUM          `else                                ,13:'d0                      `endif                          
`ifdef ENDPT14_OUT                    ,14:`ENDPT14_OUT_MEM_PP_NUM          `else                                ,14:'d0                      `endif                          
`ifdef ENDPT15_OUT                    ,15:`ENDPT15_OUT_MEM_PP_NUM          `else                                ,15:'d0                      `endif                          
};
					
`include "usb3_const.vh"	

genvar i ;

localparam CTRL = 2'b00 ;
localparam ISO  = 2'b01 ;
localparam BULK = 2'b10 ;
localparam INT  = 2'b11 ;

localparam GEN1X1 = 1'b0 ;
localparam GEN2X1 = 1'b1 ;

localparam ST_IN_W 				= 3;
localparam ST_IN_IDLE 			= 3'd0;
localparam ST_IN_CHECK 			= 3'd1;
localparam ST_IN_WT_NRDY_SENT 	= 3'd2;
localparam ST_IN_WT_0_DP_SENT 	= 3'd3;
localparam ST_IN_WT_DP_SENT 	= 3'd4;
localparam ST_IN_RTY 			= 3'd5;
localparam ST_WT_PT_SHIFT 	    = 3'd6;
reg [ST_IN_W-1:0] in_state [0:15];

localparam ST_OUT_W 			= 4;
localparam ST_OUT_IDLE 			= 4'd0;
localparam ST_OUT_WT_DP_START 	= 4'd1;
localparam ST_WT_RX_DP_DONE 	= 4'd2;
localparam ST_OUT_ACK_SENT 		= 4'd3;
localparam ST_OUT_WT_NRDY_SENT 	= 4'd4;
localparam ST_OUT_WT_EOF 		= 4'd5;
localparam ST_OUT_WT_ERDY_SENT 	= 4'd6;
localparam ST_OUT_WT_RETRY_SENT = 4'd7;
localparam ST_OUT_WT_RETRY 		= 4'd8;
localparam ST_OUT_STALL_SENT 	= 4'd9;
reg [ST_OUT_W-1:0] out_state [0:15] ;


localparam ST_TX_W 				= 4;
localparam ST_TX_IDLE 			= 4'd0;
localparam ST_TX_IN_NRDY 		= 4'd1;
localparam ST_TX_OUT_NRDY 		= 4'd2;
localparam ST_TX_IN_ERDY 		= 4'd3;
localparam ST_TX_OUT_ERDY		= 4'd4;
localparam ST_TX_OUT_ACK 		= 4'd5;
localparam ST_TX_STATUS_ACK 	= 4'd6;
localparam ST_TX_OUT_RETRY 		= 4'd7;
localparam ST_TX_STALL 	    	= 4'd8;
localparam ST_TX_PING_RESP 		= 4'd9;
localparam ST_TX_RX_SSD_NOTI 	= 4'd10;
localparam ST_TX_TX_SSD_NOTI 	= 4'd11;
reg [ST_TX_W-1:0] tx_state ;

localparam [3:0] 	NOTI_SUBLINK_SPEED 			= 4'b0101;
localparam [1:0] 	LANE_SPEED_EX_G 			= 2'b11;
localparam [1:0] 	SUBLINK_TYPE_SYM_RX_MODE 	= 2'b00;
localparam [1:0] 	SUBLINK_TYPE_SYM_TX_MODE 	= 2'b10;
localparam [3:0] 	LANE_COUNT_1				= 4'b0 ;
localparam [1:0] 	LP							= 2'b01 ;
localparam [15:0] 	LANE_SPEED_MANTISSA			= 16'd10 ;

reg  host_requests_data [0:15] ;
reg [15:0] transfer_out_lpf ;
wire [6:0] dev_address_q ; 
wire set_address ;
reg set_address_ack ;
reg enter_status_stage ; 
reg   [63:0]   	  	buf_in_data_mem          	[0:15]   ;
reg 		      	buf_in_wren_mem          	[0:15]   ;
wire			  	buf_in_ready_mem         	[0:15]   ;
reg			   		buf_in_commit_mem        	[0:15]   ;
reg			   		buf_in_discard_mem        	[0:15]   ;
reg	[10:0]			buf_in_commit_len_mem    	[0:15]   ;
wire     [63:0] buf_out_q_mem          		[0:15] ;
reg			    buf_out_arm_mem        		[0:15] ;
reg			    buf_out_rden_mem       		[0:15] ;
wire            buf_out_has_data_mem   		[0:15] ;
reg      [10:0] buf_out_len_mem        		[0:15] ;
wire            buf_out_last_mem       		[0:15] ;
wire            buf_out_payload_empty_mem   [0:15] ;
reg 		ep_in_pending [0:15];
reg 		ep_in_pending_mask [0:15];
reg 		ep_in_pending_en [0:15];
reg [4:0]  	ep_in_pending_last_seq [0:15] ;
reg [4:0]  	ep_in_pending_target_seq [0:15] ;
reg [4:0]	rx_tp_seq_latch [0:15] ;
reg [4:0]	ep_in_retry_seq_latch [0:15] ;
reg [4:0]	rx_tp_nump_latch [0:15];
reg 		ep_in_pending_clr_by_Host [15:0] ;
reg 		iso_in_ep_clr_pending [15:0] ;
reg [4:0] ep_in_pending_current_seq [0:15];
reg [15:0] ep_in_send_NRDY  ;
reg [15:0] ep_in_send_0_DP  ;
reg [15:0] ep_in_send_DP  ;
reg [15:0] ep_out_send_NRDY  ;
reg [15:0] ep_out_send_ERDY  ;
reg [15:0] ep_out_send_ACK   ;
reg [15:0] ep_out_send_RETRY ;
reg ep_out_rdy_mask [0:15] ;
reg ep_out_rx_deferred_dph [0:15] ;
reg [3:0] ep_out_wt_cnt [0:15] ;
reg [4:0] ep_out_ack_current_seq [0:15] ;
reg ep_in_retry [0:15];
reg ep_in_retry_latch [0:15];
reg send_STATUS_ACK ;
reg tx_PING_RESP_ack ;
reg tx_STALL_ack ;
reg 		tx_in_NRDY ;
reg 		tx_in_NRDY_retry ;
reg 		tx_in_NRDY_dir ;
reg [3:0] 	tx_in_NRDY_subtype ;
reg [4:0] 	tx_in_NRDY_nump ;
reg [4:0] 	tx_in_NRDY_seq ;
reg [15:0] 	tx_in_NRDY_stream ;
reg [3:0] 	tx_in_NRDY_endp ;
reg ep_in_send_NRDY_ack [0:15] ;
reg 		tx_out_NRDY ;
reg 		tx_out_NRDY_retry ;
reg 		tx_out_NRDY_dir ;
reg [3:0] 	tx_out_NRDY_subtype ;
reg [4:0] 	tx_out_NRDY_nump ;
reg [4:0] 	tx_out_NRDY_seq ;
reg [15:0] 	tx_out_NRDY_stream ;
reg [3:0] 	tx_out_NRDY_endp ;
reg ep_out_send_NRDY_ack [0:15] ;
reg tx_in_ERDY ;
reg tx_in_ERDY_retry ;
reg tx_in_ERDY_dir ;
reg [3:0] tx_in_ERDY_subtype ;
reg [4:0] tx_in_ERDY_nump ;
reg [4:0] tx_in_ERDY_seq ;
reg [15:0] tx_in_ERDY_stream ;
reg [3:0] tx_in_ERDY_endp ;
reg ep_in_send_ERDY_ack [0:15];
reg 		tx_out_ERDY ;
reg 		tx_out_ERDY_retry ;
reg 		tx_out_ERDY_dir ;
reg [3:0] 	tx_out_ERDY_subtype ;
reg [4:0] 	tx_out_ERDY_nump ;
reg [4:0] 	tx_out_ERDY_seq ;
reg [5:0] 	tx_out_ERDY_stream ;
reg [3:0] 	tx_out_ERDY_endp ;
reg ep_out_send_ERDY_ack [0:15] ;
reg ep_in_send_0_DP_ack [0:15] ;
reg ep_in_send_DP_ack [0:15] ;
reg tx_out_ACK ;
reg tx_out_ACK_retry ;
reg tx_out_ACK_dir ;
reg [3:0] tx_out_ACK_subtype ;
reg [4:0] tx_out_ACK_nump ;
reg [4:0] tx_out_ACK_seq ;
reg [15:0] tx_out_ACK_stream ;
reg [3:0] tx_out_ACK_endp ;
reg [2:0] tx_out_ACK_TT ;
reg ep_out_send_ACK_ack [0:15]; 
reg buf_out_dp_acked [0:15]; 
reg tx_STATUS_ACK;
reg tx_STATUS_ACK_retry;
reg tx_STATUS_ACK_dir;
reg [3:0] tx_STATUS_ACK_subtype;
reg [4:0] tx_STATUS_ACK_nump;
reg [4:0] tx_STATUS_ACK_seq;
reg [15:0] tx_STATUS_ACK_stream;
reg [3:0] tx_STATUS_ACK_endp;
reg [2:0] tx_STATUS_ACK_TT;
reg tx_STATUS_ACK_TPF;
reg send_STATUS_ACK_ack ;
reg tx_out_RETRY ;
reg tx_out_RETRY_retry ;
reg tx_out_RETRY_dir ;
reg [3:0] tx_out_RETRY_subtype ;
reg [4:0] tx_out_RETRY_nump ;
reg [4:0] tx_out_RETRY_seq ;
reg [15:0] tx_out_RETRY_stream ;
reg [3:0] tx_out_RETRY_endp ;
reg [2:0] tx_out_RETRY_TT ;
reg ep_out_send_RETRY_ack [0:15] ;
reg tx_PING_RESP ;
reg tx_PING_RESP_retry ;
reg tx_PING_RESP_dir ;
reg [3:0] tx_PING_RESP_subtype ;
reg [4:0] tx_PING_RESP_nump ;
reg [4:0] tx_PING_RESP_seq ;
reg [15:0] tx_PING_RESP_stream ;
reg [3:0] tx_PING_RESP_endp ;
reg tx_STALL ;
reg tx_rx_sublink_speed_device_noti ;
reg tx_rx_sublink_speed_device_noti_ack ;
reg tx_tx_sublink_speed_device_noti ;
reg tx_tx_sublink_speed_device_noti_ack ;
reg tx_STALL_retry ;
reg tx_STALL_dir ;
reg [3:0] tx_STALL_subtype ;
reg [4:0] tx_STALL_nump ;
reg [4:0] tx_STALL_seq ;
reg [15:0] tx_STALL_stream ;
reg [3:0] tx_STALL_endp ;
reg ep_rst_n ;
reg tx_in_NRDY_ack ;
reg tx_out_NRDY_ack ;
reg tx_in_ERDY_ack ;
reg tx_out_ERDY_ack ;
reg tx_out_ACK_ack ;
reg tx_STATUS_ACK_ack ;
reg tx_out_RETRY_ack ;
reg send_PING_RESP_ack ;
reg [15:0] ep_in_send_ERDY  ;
reg send_STALL ;
reg [15:0] ep_in_wt_ready;
wire [15:0] ep_in_stall  ;
wire [15:0] ep_out_stall  ;
wire ep_0_stall ;
reg [15:0] ep_in_send_STALL;
reg [15:0] ep_in_rx_deferred_ACK;
reg [15:0] ep_out_send_STALL;
reg send_STATUS_STALL ;

assign  ep_in_stall  [15:1]= 0 ; 
assign  ep_out_stall [15:1] = 0 ; 
assign ep_in_stall [0] = ep_0_stall ;
assign ep_out_stall [0] = ep_0_stall ;

always @ ( * ) begin
   buf_in_ready         <= buf_in_ready_mem     [rx_dph_endp] & !ep_out_rdy_mask[rx_dph_endp] ;
end

// send dpp 
always @ ( * ) begin
   buf_out_q        <= buf_out_q_mem        [tx_DP_endp] ;
end

generate
   for ( i = 0 ; i < 16 ; i = i + 1 ) begin
      assign buf_out_arm_mem  [i] = ( tx_DP_endp == i ) ? buf_out_arm  : 0 ;
      assign buf_out_rden_mem [i] = ( tx_DP_endp == i ) ? buf_out_rden : 0 ;  
   end
endgenerate



always @ ( posedge local_clk or negedge reset_n ) begin
	if (! reset_n ) begin
		warm_or_hot_reset <= 0 ;
	end
	else if ( ltssm_state == LT_RX_DETECT_RESET || ltssm_state == LT_HOTRESET  ) begin
		warm_or_hot_reset <= 1 ;
	end
	else begin
		warm_or_hot_reset <= 0 ;
	end
end	

// managing IN Transactions
generate 
   for ( i = 0 ; i < 16 ; i ++ ) begin : IN_ep_transaction
      	if ( IN_EP_DEF[i] == 1 ) begin
			
			// managing rx ACK
			always @( posedge local_clk  or negedge reset_n ) begin
				if (!reset_n) begin
					ep_in_pending_en  		  [i] <= 0 ;
					ep_in_retry			 	  [i] <= 0 ;
					rx_tp_seq_latch	  		  [i] <= 0 ;
					rx_tp_nump_latch  		  [i] <= 0 ;
					buf_out_dp_acked		  [i] <= 0 ;
					ep_in_send_STALL 		  [i] <= 0 ; 
					ep_in_rx_deferred_ACK     [i] <= 0 ;
					ep_in_pending_clr_by_Host [i] <= 0 ;					
				end
				else begin 
					if ( rx_tp && rx_tp_subtype == LP_TP_SUB_ACK && rx_tp_endp == i ) begin
						if ( rx_tp_deferred ) begin
							ep_in_rx_deferred_ACK [i] <= 1 ;
						end
						else if ( !ep_in_stall[i] ) begin
							ep_in_pending_en 			[i]  	<= rx_tp_nump != 0;
							ep_in_pending_clr_by_Host 	[i] 	<= rx_tp_nump == 0;
							ep_in_retry					[i]		<= rx_tp_retry 	 ;
							rx_tp_seq_latch				[i]		<= rx_tp_seq     ;
							rx_tp_nump_latch			[i]		<= rx_tp_nump    ;
							buf_out_dp_acked			[i]     <= ( ep_in_pending [i] && !rx_tp_retry ) ;							
						end
						else begin
							ep_in_send_STALL [i] <= 1 ;
						end
					end
					else begin
						ep_in_pending_en 			[i]	<= 0 ;
						ep_in_pending_clr_by_Host	[i]	<= 0 ;
						ep_in_retry 				[i]	<= 0 ;
						buf_out_dp_acked			[i] <= 0 ;
						ep_in_send_STALL			[i] <= 0 ;
						ep_in_rx_deferred_ACK       [i] <= 0 ;
 					end
				end
			end

			always @( posedge local_clk  or negedge reset_n ) begin
				if (!reset_n) begin
					ep_in_retry_latch [i] 		<= 0 ;
					ep_in_retry_seq_latch [i] 	<= 0 ;
				end
				else if ( ep_in_retry [i] ) begin
					ep_in_retry_latch [i] 		<= 1 ;
					ep_in_retry_seq_latch [i] 	<= rx_tp_seq_latch [i];
				end
				else if ( in_state[i] == ST_IN_RTY ) begin
					ep_in_retry_latch [i] 		<= 0 ;
					ep_in_retry_seq_latch [i] 	<= ep_in_retry_seq_latch [i] ;
				end
			end
 
			always @( posedge local_clk  or negedge reset_n ) begin
				if (!reset_n) begin
					ep_in_pending 		   		[i] <= 0 ;
					ep_in_pending_last_seq 		[i] <= 0 ;
					host_requests_data			[i] <= 0 ;
				end
				else if ( !ep_in_pending[i] && ep_in_pending_en [i] ) begin    
					ep_in_pending 		   		[i] <= 1 ;
					host_requests_data			[i] <= 1 ;
					ep_in_pending_target_seq    [i] <= rx_tp_seq_latch [i] + rx_tp_nump_latch [i] ;				
				end 
				else if ( ep_in_pending_en [i] ) begin
					ep_in_pending 		   		[i] <= 1 ;
					host_requests_data			[i] <= 0 ;
					ep_in_pending_target_seq 	[i] <= rx_tp_seq_latch [i] + rx_tp_nump_latch [i] ;							
				end    
				else if ( ep_in_pending_clr_by_Host [i] | ep_in_send_NRDY [i] | ( ep_in_send_0_DP [i] && IN_EP_TYPE[i] == ISO ) | ( ep_in_send_DP [i] && buf_out_last_mem[i] && IN_EP_TYPE[i] == ISO )  | ( iso_in_ep_clr_pending [i] &&  IN_EP_TYPE[i] == ISO ) ) begin
					ep_in_pending 		  	 	[i] <= 0 ;
					host_requests_data			[i] <= 0 ;
					ep_in_pending_target_seq 	[i] <= 0 ;				
				end
				else begin
					host_requests_data [i] <= 0 ;
				end
			end


			always @( posedge local_clk  or negedge reset_n ) begin
				if (!reset_n) begin
					ep_in_pending_mask 		   		[i] <= 0 ;			
				end
				else if ( !ep_in_pending [i] || in_state[i] == ST_IN_RTY ) begin
					ep_in_pending_mask 		   		[i] <= 0 ;
				end
				else if ( tx_DP_ack && tx_DP_endp == i ) begin
					if ( tx_DP_eob ) begin
						ep_in_pending_mask 		   		[i] <= 1 ;
					end
					else if ( tx_DP_len != IN_EP_TYPE_PKT_SIZE [i] ) begin
						ep_in_pending_mask 		   		[i] <= 1 ;
					end
				end	
				else if ( tx_0_DP_ack && tx_0_DP_endp == i )	begin
					ep_in_pending_mask  [i] <= 1 ;					
				end
			end			

			always @( posedge local_clk  or negedge reset_n ) begin
				if (!reset_n) begin
					ep_in_pending_current_seq[i] <= 0 ;
				end
				else if ( !ep_in_pending[i] && ep_in_pending_en [i] ) begin  
					ep_in_pending_current_seq[i] <= rx_tp_seq_latch [i] ;
				end  	
				else if (  in_state [i] == ST_IN_RTY ) begin
					ep_in_pending_current_seq[i] <= ep_in_retry_seq_latch [i] ;
				end	
				else if ( ep_in_send_DP_ack [i] ) begin
					ep_in_pending_current_seq[i] <= tx_DP_seq + 1 ;
				end
				else if ( ep_in_send_0_DP_ack [i]  ) begin
					ep_in_pending_current_seq[i] <= tx_0_DP_seq + 1 ;					
				end
			end		 

			always @( posedge local_clk  or negedge reset_n ) begin
				if (!reset_n) begin
					iso_in_ep_clr_pending [i] <= 0 ;
				end
				else if ( ep_in_pending [i] && ep_in_pending_current_seq [i] == ep_in_pending_target_seq [i] ) begin
					iso_in_ep_clr_pending [i] <= 1 ;					
				end
				else begin
					iso_in_ep_clr_pending [i] <= 0 ;
				end
			end

			assign  host_requests_data_from_endpt[i]  = host_requests_data [i] ;	

			always @( * ) begin
				if ( tx_in_NRDY && tx_in_NRDY_ack && tx_in_NRDY_endp == i  ) begin
					ep_in_send_NRDY_ack [i] <= 1 ;
				end
				else begin
					ep_in_send_NRDY_ack[i] <= 0 ; 
				end
			end

			always @( * ) begin
				if ( tx_in_ERDY && tx_in_ERDY_ack && tx_in_ERDY_endp == i ) begin
					ep_in_send_ERDY_ack [i] <= 1 ;
				end
				else begin
					ep_in_send_ERDY_ack [i] <= 0 ; 
				end
			end			

			always @( * ) begin
				if ( tx_0_DP && tx_0_DP_ack && tx_0_DP_endp == i ) begin
					ep_in_send_0_DP_ack [i] <= 1 ;
				end
				else begin
					ep_in_send_0_DP_ack [i]<= 0 ; 
				end
			end		
			
			always @( * ) begin
				if ( tx_DP && tx_DP_ack && tx_DP_endp == i ) begin
					ep_in_send_DP_ack [i] <= 1 ;
				end
				else begin
					ep_in_send_DP_ack[i] <= 0 ; 
				end
			end		

			always @( posedge local_clk  or negedge reset_n ) begin
				if (!reset_n) begin			
					ep_in_wt_ready [i] <= 0 ;
				end	
				else if ( ep_in_send_NRDY_ack [i] ) begin
					ep_in_wt_ready [i] <= 1 ;
				end
				else if ( ep_in_rx_deferred_ACK [i] ) begin
					ep_in_wt_ready [i] <= 1 ;					
				end
				else if ( ( ep_in_send_DP_ack [i] && tx_DP_eob) || (ep_in_send_0_DP_ack [i] && tx_0_DP_eob ) ) begin
					if ( IN_EP_TYPE [i] == ISO ) begin
						ep_in_wt_ready [i] <= 0 ;
					end
					else if ( IN_EP_TYPE [i] == CTRL ) begin
						ep_in_wt_ready [i] <= 0 ;
					end
					else begin
						ep_in_wt_ready [i] <= 1 ;
					end
				end
				else if ( ep_in_wt_ready [i] && buf_out_has_data_mem [i] && !ep_in_pending[i] ) begin
					ep_in_wt_ready [i] <= 0 ;
				end
			end

			always @( posedge local_clk  or negedge reset_n ) begin
				if (!reset_n) begin
					ep_in_send_ERDY[i] <= 0 ;
				end
				else if ( ep_in_wt_ready [i] && buf_out_has_data_mem [i] && !ep_in_pending[i] ) begin
					ep_in_send_ERDY[i] <= 1 ;
				end
				else if ( ep_in_send_ERDY_ack [i] ) begin
					ep_in_send_ERDY[i] <= 0 ;
				end
			end

			always @( posedge local_clk  or negedge reset_n ) begin
				if (!reset_n) begin
					in_state[i] <= ST_IN_IDLE ;
					ep_in_send_NRDY [i] <= 0 ;
					ep_in_send_0_DP [i] <= 0 ;
					ep_in_send_DP [i] <= 0 ;
				end
				else begin
					case ( in_state[i] ) 
					ST_IN_IDLE:begin
						if ( ep_in_pending [i] && ep_in_retry_latch [i] ) begin
							in_state[i] <= ST_IN_RTY ;
						end
						else if ( ep_in_pending [i] && !ep_in_pending_mask [i] && ep_in_pending_current_seq [i] != ep_in_pending_target_seq [i]) begin
							in_state[i] <= ST_WT_PT_SHIFT ; 
						end
					end
					ST_IN_RTY:begin				
						in_state[i] <= ST_WT_PT_SHIFT ;
					end
					ST_WT_PT_SHIFT:begin					
						in_state[i] <= ST_IN_CHECK ;
					end
					ST_IN_CHECK:begin
						if ( buf_out_has_data_mem [i] ) begin
							if ( buf_out_payload_empty_mem [i] ) begin
								ep_in_send_0_DP [i] <= 1 ;
								in_state [i] <= ST_IN_WT_0_DP_SENT ;								
							end
							else begin
								ep_in_send_DP [i] <= 1 ;
								in_state [i] <= ST_IN_WT_DP_SENT ;								
							end
						end
						else if ( !buf_out_has_data_mem [i] && IN_EP_TYPE[i] != ISO  )begin
							ep_in_send_NRDY [i] <= 1 ;
							in_state [i] <= ST_IN_WT_NRDY_SENT ;
						end
						else if ( !buf_out_has_data_mem [i] && IN_EP_TYPE[i] == ISO ) begin
							ep_in_send_0_DP [i] <= 1 ;
							in_state [i] <= ST_IN_WT_0_DP_SENT ;
						end
					end
					ST_IN_WT_NRDY_SENT:begin
						if ( ep_in_send_NRDY_ack [i] ) begin
							ep_in_send_NRDY [i] <= 0 ;
							in_state [i] <= ST_IN_IDLE ;						
						end  
					end
					ST_IN_WT_0_DP_SENT:begin
						if ( ep_in_send_0_DP_ack [i] ) begin
							ep_in_send_0_DP [i] <= 0 ;
							in_state [i] <= ST_IN_IDLE ;
						end
					end
					ST_IN_WT_DP_SENT:begin
						if ( ep_in_send_DP_ack [i] ) begin
							ep_in_send_DP [i] <= 0 ;
							in_state [i] <= ST_IN_IDLE ;					
						end
					end
					default:;					
					endcase
				end
			end

		end
   	end
endgenerate	

// managing OUT Transactions
generate 
    for ( i = 0 ; i < 16 ; i ++ ) begin : OUT_ep_transaction
      	if ( OUT_EP_DEF[i] == 1 ) begin
			always @( posedge local_clk  or negedge reset_n ) begin
				if (!reset_n) begin	
					buf_in_data_mem 		[i]	<= 0 ;
					buf_in_wren_mem 		[i]	<= 0 ;
					buf_in_commit_mem 		[i]	<= 0 ;
					buf_in_discard_mem  	[i] <= 0 ;
					buf_in_commit_len_mem	[i] <= 0 ;
				end		
				else if ( out_state [i] == ST_WT_RX_DP_DONE ) begin
					buf_in_data_mem 		[i] <= buf_in_data ;
					buf_in_wren_mem 		[i] <= buf_in_wren ;
					buf_in_commit_mem 		[i] <= buf_in_commit ;
					buf_in_commit_len_mem	[i] <= buf_in_commit_len ;					
					if ( OUT_EP_TYPE[i] != ISO ) begin
						buf_in_discard_mem  [i] <= ( buf_in_commit && ( !rx_dpp_crcgood | dpp_end_abort_det ) )  ;
					end
					else begin
						buf_in_discard_mem  [i] <= 0 ;
					end
				end
				else begin
					buf_in_data_mem 		[i]	<= 0 ;
					buf_in_wren_mem 		[i]	<= 0 ;
					buf_in_commit_mem 		[i]	<= 0 ;
					buf_in_discard_mem  	[i] <= 0 ;
					buf_in_commit_len_mem	[i] <= 0 ;		
				end
			end

			always @ ( posedge local_clk or negedge reset_n ) begin
				if ( !reset_n ) begin
					transfer_out_lpf [i] <= 0 ;               
				end
				else begin
					if ( rx_dph && rx_dph_endp == i ) begin
						if ( !rx_dph_pktpend ) begin
							transfer_out_lpf [i] <= 1 ; 
						end
						else if ( OUT_EP_TYPE [i] == CTRL && rx_dph_len[15:9] == 0 ) begin
							transfer_out_lpf [i] <= 1 ;
						end
						else if ( OUT_EP_TYPE[i] == ISO && rx_dph_eob ) begin
							transfer_out_lpf [i] <= 1 ;                  
						end
						else if ( OUT_EP_TYPE[i] == BULK  && rx_dph_len[15:10] == 0 ) begin
							transfer_out_lpf [i] <= 1 ;                  
						end                  
						else begin
							transfer_out_lpf [i] <= 0 ;   
						end
					end
				end	
			end		


			always @( * ) begin
				if ( tx_out_NRDY && tx_out_NRDY_ack && tx_out_NRDY_endp == i ) begin
					ep_out_send_NRDY_ack [i] <= 1 ;
				end
				else begin
					ep_out_send_NRDY_ack [i] <= 0 ; 
				end
			end

			always @( * ) begin
				if ( tx_out_ERDY && tx_out_ERDY_ack && tx_out_ERDY_endp == i ) begin
					ep_out_send_ERDY_ack [i] <= 1 ;
				end
				else begin
					ep_out_send_ERDY_ack [i] <= 0 ; 
				end
			end

			always @( * ) begin
				if ( tx_out_ACK && tx_out_ACK_ack && rx_dph_endp == i) begin
					ep_out_send_ACK_ack [i] <= 1 ;
				end
				else begin
					ep_out_send_ACK_ack [i] <= 0 ; 
				end
			end

			always @( * ) begin
				if ( tx_out_RETRY && tx_out_RETRY_ack && tx_out_RETRY_endp == i ) begin
					ep_out_send_RETRY_ack [i] <= 1 ;
				end
				else begin
					ep_out_send_RETRY_ack [i] <= 0 ; 
				end
			end	

			always @( posedge local_clk  or negedge reset_n ) begin
				if (!reset_n) begin	
					ep_out_send_ERDY [i] <= 0 ;
				end				
				else if ( itp_received && ep_out_rdy_mask[i] && buf_in_ready_mem[i] ) begin
					ep_out_send_ERDY [i] <= 1 ;
				end
				else if ( ep_out_rx_deferred_dph[i] ) begin
					ep_out_send_ERDY [i] <= 1 ;					
				end
				else if ( ep_out_send_ERDY_ack [i] ) begin
					ep_out_send_ERDY [i] <= 0 ;
				end
			end

			always @( posedge local_clk  or negedge reset_n ) begin
				if (!reset_n) begin
					out_state		 			[i] <= ST_OUT_IDLE ;
					ep_out_send_NRDY 			[i] <= 0 ;
					ep_out_rdy_mask	 			[i] <= 0 ;
					ep_out_wt_cnt	 			[i] <= 0 ;
					ep_out_ack_current_seq 		[i] <= 0 ; 
					ep_out_send_ACK 			[i] <= 0 ; 
					ep_out_send_RETRY 			[i] <= 0 ; 
					ep_out_send_STALL			[i] <= 0 ;
					ep_out_rx_deferred_dph 		[i] <= 0 ;								
				end
				else begin
					case ( out_state[i] ) 
					ST_OUT_IDLE:begin
						ep_out_send_ACK 			[i] <= 0 ;							
						ep_out_send_NRDY 			[i] <= 0 ;
						ep_out_rdy_mask	 			[i] <= 0 ;					
						ep_out_wt_cnt	 			[i] <= 0 ;
						ep_out_rx_deferred_dph 		[i] <= 0 ;												
						if ( rx_dph && rx_dph_endp == i  ) begin
							if ( rx_dph_deferred ) begin
								if ( !buf_in_ready ) begin
									ep_out_rdy_mask [i] <= 1 ;
									out_state [i] <= ST_OUT_WT_NRDY_SENT ;											
								end
								else begin
									ep_out_rx_deferred_dph [i] <= 1 ;											
								end				
							end
							else begin
								out_state [i]  <= ST_OUT_WT_DP_START ;
								ep_out_wt_cnt [i]  <= 0 ;
								ep_out_ack_current_seq [i] <= rx_dph_seq ;								
							end

						end	
						else if ( itp_received ) begin
							ep_out_rdy_mask [i] <= 0 ;
						end					
					end
					ST_OUT_WT_DP_START:begin
						ep_out_wt_cnt [i] <= ep_out_wt_cnt [i] + 1 ;
						if ( rx_dpp_abort ) begin
							out_state [i] <= ST_OUT_WT_RETRY_SENT ; 							
						end
						else if ( !rx_dpp_start && ep_out_wt_cnt[i] == 10 ) begin
							out_state [i] <= ST_OUT_WT_RETRY_SENT ; 
						end
						else if ( rx_dpp_start && buf_in_ready  ) begin
							out_state [i] <= ST_WT_RX_DP_DONE ; 
						end
						else if ( rx_dpp_start && !buf_in_ready ) begin
							ep_out_rdy_mask [i] <= 1 ;
							out_state [i] <= ST_OUT_WT_NRDY_SENT ;								
						end
					end
					ST_WT_RX_DP_DONE:begin
						if ( OUT_EP_TYPE [i] != ISO )  begin
							if ( rx_dpp_done && dpp_end_abort_det   ) begin
								out_state [i] 			<= ST_OUT_WT_RETRY_SENT ; 		
							end
							else if ( rx_dpp_done && rx_dpp_crcgood ) begin
								if ( rx_dph_setup ) begin
									ep_out_send_ACK [i] <= 1 ;	
									out_state[i] 		<= ST_OUT_IDLE ;																	
								end
								else begin
									if ( ep_out_stall[i] ) begin
										ep_out_send_STALL [i] <= 1 ;
										out_state[i]		  <= ST_OUT_STALL_SENT;										 									
									end
									else begin
										ep_out_send_ACK [i] <= 1 ;											
										out_state[i] <= ST_OUT_IDLE ;											
									end
								end								
							end
							else if ( rx_dpp_done && !rx_dpp_crcgood ) begin
								out_state[i] <= ST_OUT_WT_RETRY_SENT ;
							end
						end
						else if (  OUT_EP_TYPE [i] == ISO ) begin	
							if ( rx_dpp_done ) begin				
								out_state[i] <= ST_OUT_IDLE ;		
							end					
						end
					end
					ST_OUT_ACK_SENT:begin
						ep_out_send_ACK [i] <= 0 ;
						out_state[i] <= ST_OUT_IDLE ;							
						//if ( ep_out_send_ACK_ack [i] ) begin
						//	ep_out_send_ACK [i] <= 0 ;
						//	out_state[i] <= ST_OUT_IDLE ;	
						//end
					end
					ST_OUT_STALL_SENT:begin
						ep_out_send_STALL [i] <= 0 ;
						out_state[i] <= ST_OUT_IDLE ;							
					end
					ST_OUT_WT_NRDY_SENT: begin
						if (  OUT_EP_TYPE [i] != ISO ) begin  
							ep_out_send_NRDY [i] <= 1 ;
							if ( ep_out_send_NRDY_ack [i] ) begin
								ep_out_send_NRDY [i] <= 0 ;
								out_state [i] <= ST_OUT_IDLE ;
							end
						end
						else if ( OUT_EP_TYPE [i] == ISO ) begin
							out_state [i] <= ST_OUT_IDLE ;							
						end
					end
					ST_OUT_WT_RETRY_SENT: begin
						ep_out_send_RETRY [i] <= 1 ;
						//if ( ep_out_send_RETRY_ack [i] ) begin
						//	ep_out_send_RETRY [i] <= 0 ;				
							out_state [i] <= ST_OUT_WT_RETRY ;
						//end
					end
					ST_OUT_WT_RETRY:begin
						ep_out_send_RETRY [i] <= 0 ;
						if ( rx_dph && rx_dph_endp == i && rx_dph_seq == ep_out_ack_current_seq [i]) begin
							out_state [i]  <= ST_OUT_WT_DP_START ;
							ep_out_wt_cnt [i]  <= 0 ;
							ep_out_ack_current_seq [i] <= rx_dph_seq ;
						end	
					end
					default:;					
					endcase
				end
			end	
		end
    end

endgenerate


// managing rx STATUS
always @( posedge local_clk  or negedge reset_n ) begin
	if (!reset_n) begin
		send_STATUS_ACK <= 0 ;
		dev_address <= 0 ; 
		enter_status_stage <= 0 ;
		send_STATUS_STALL <= 0 ;
		set_address_ack <= 0 ;
	end
	else if ( warm_or_hot_reset ) begin
		dev_address <= 0 ;
	end
	else begin 
		if ( rx_tp && rx_tp_subtype == LP_TP_SUB_STATUS ) begin
			if ( !ep_0_stall ) begin
				send_STATUS_ACK 	<= 1 ;
				enter_status_stage  <= 1 ;						
			end
			else begin
				send_STATUS_STALL <= 1 ;
				enter_status_stage  <= 1 ;					
			end
		end
		else if ( send_STATUS_ACK_ack ) begin
			send_STATUS_ACK <= 0 ;
			enter_status_stage <= 0 ;
			if (set_address) begin
				set_address_ack <= 1 ;
				dev_address <= dev_address_q ;	
			end		
		end
		else begin
			set_address_ack <= 0 ;
			enter_status_stage <= 0 ;
			send_STATUS_STALL <= 0 ;
		end
	end
end



//TX NRDY ( IN endpoints )
always @( posedge local_clk  or negedge reset_n ) begin
	if (!reset_n) begin
		tx_in_NRDY <= 0 ;	
		tx_in_NRDY_retry	<= 0;
		tx_in_NRDY_dir		<= 0;
		tx_in_NRDY_subtype 	<= 0;
		tx_in_NRDY_nump		<= 0;
		tx_in_NRDY_seq		<= 0;
		tx_in_NRDY_stream	<= 0;	
		tx_in_NRDY_endp 	<= 0;
	end
	else if ( tx_in_NRDY_ack ) begin
		tx_in_NRDY <= 0 ;
	end		
	else if ( |ep_in_send_NRDY ) begin
		tx_in_NRDY			<= 1'b1;
		tx_in_NRDY_retry	<= LP_TP_NORETRY;
		tx_in_NRDY_dir		<= LP_TP_DEVICETOHOST;
		tx_in_NRDY_subtype 	<= LP_TP_SUB_NRDY;
		tx_in_NRDY_nump		<= 5'h0;
		tx_in_NRDY_seq		<= 5'h0;
		tx_in_NRDY_stream	<= 16'h0;	

							if 		( ep_in_send_NRDY[0]) begin  tx_in_NRDY_endp <= 0 ; end    
		`ifdef ENDPT1_IN 	else if ( ep_in_send_NRDY[1]) begin  tx_in_NRDY_endp <= 1 ; end  `endif 	
		`ifdef ENDPT2_IN 	else if ( ep_in_send_NRDY[2]) begin  tx_in_NRDY_endp <= 2 ; end  `endif 	
		`ifdef ENDPT3_IN 	else if ( ep_in_send_NRDY[3]) begin  tx_in_NRDY_endp <= 3 ; end  `endif 	
		`ifdef ENDPT4_IN 	else if ( ep_in_send_NRDY[4]) begin  tx_in_NRDY_endp <= 4 ; end  `endif 	
		`ifdef ENDPT5_IN 	else if ( ep_in_send_NRDY[5]) begin  tx_in_NRDY_endp <= 5 ; end  `endif 	
		`ifdef ENDPT6_IN 	else if ( ep_in_send_NRDY[6]) begin  tx_in_NRDY_endp <= 6 ; end  `endif 	
		`ifdef ENDPT7_IN 	else if ( ep_in_send_NRDY[7]) begin  tx_in_NRDY_endp <= 7 ; end  `endif 	
		`ifdef ENDPT8_IN 	else if ( ep_in_send_NRDY[8]) begin  tx_in_NRDY_endp <= 8 ; end  `endif 	
		`ifdef ENDPT9_IN 	else if ( ep_in_send_NRDY[9]) begin  tx_in_NRDY_endp <= 9 ; end  `endif 	
		`ifdef ENDPT10_IN 	else if ( ep_in_send_NRDY[10]) begin tx_in_NRDY_endp <= 10; end	 `endif 		
		`ifdef ENDPT11_IN 	else if ( ep_in_send_NRDY[11]) begin tx_in_NRDY_endp <= 11; end	 `endif 	
		`ifdef ENDPT12_IN 	else if ( ep_in_send_NRDY[12]) begin tx_in_NRDY_endp <= 12; end	 `endif 	
		`ifdef ENDPT13_IN 	else if ( ep_in_send_NRDY[13]) begin tx_in_NRDY_endp <= 13 ; end `endif 
		`ifdef ENDPT14_IN 	else if ( ep_in_send_NRDY[14]) begin tx_in_NRDY_endp <= 14 ; end `endif 
		`ifdef ENDPT15_IN 	else if ( ep_in_send_NRDY[15]) begin tx_in_NRDY_endp <= 15 ; end `endif 


	end	
end

//TX NRDY ( OUT endpoints )
always @( posedge local_clk  or negedge reset_n ) begin
	if (!reset_n) begin
		tx_out_NRDY 		<= 0;	
		tx_out_NRDY_retry	<= 0;
		tx_out_NRDY_dir		<= 0;
		tx_out_NRDY_subtype <= 0;
		tx_out_NRDY_nump	<= 0;
		tx_out_NRDY_seq		<= 0;
		tx_out_NRDY_stream	<= 0;	
		tx_out_NRDY_endp    <= 0 ;		
	end
	else if ( tx_out_NRDY_ack ) begin
		tx_out_NRDY <= 0 ;
	end		
	else if ( |ep_out_send_NRDY ) begin
		tx_out_NRDY			<= 1'b1;
		tx_out_NRDY_retry	<= LP_TP_NORETRY;
		tx_out_NRDY_dir		<= LP_TP_DEVICETOHOST;
		tx_out_NRDY_subtype <= LP_TP_SUB_NRDY;
		tx_out_NRDY_nump	<= 5'h0;
		tx_out_NRDY_seq		<= 5'h0;
		tx_out_NRDY_stream	<= 16'h0;	
		tx_out_NRDY_endp    <= rx_dph_endp ;
	end	
end


//TX ERDY (IN endpoints)
always @( posedge local_clk  or negedge reset_n ) begin
	if (!reset_n) begin
		tx_in_ERDY 			<= 0;
		tx_in_ERDY_retry	<= 0;
		tx_in_ERDY_dir		<= 0;
		tx_in_ERDY_subtype 	<= 0;
		tx_in_ERDY_nump		<= 0;
		tx_in_ERDY_seq		<= 0;
		tx_in_ERDY_stream	<= 0;
		tx_in_ERDY_endp		<= 0;				
	end
	else if ( tx_in_ERDY_ack ) begin
		tx_in_ERDY <= 0 ;
	end	
	else if ( |ep_in_send_ERDY ) begin
		tx_in_ERDY			<= 1'b1;
		tx_in_ERDY_retry	<= LP_TP_NORETRY;
		tx_in_ERDY_dir		<= LP_TP_DEVICETOHOST;
		tx_in_ERDY_subtype 	<= LP_TP_SUB_ERDY;
 
							if 		( ep_in_send_ERDY[0 ]) tx_in_ERDY_nump	<= IN_EP_BURST[0 ] + 1 ; 
		`ifdef ENDPT1_IN 	else if ( ep_in_send_ERDY[1 ]) tx_in_ERDY_nump	<= IN_EP_BURST[1 ] + 1 ;`endif 	
		`ifdef ENDPT2_IN 	else if ( ep_in_send_ERDY[2 ]) tx_in_ERDY_nump	<= IN_EP_BURST[2 ] + 1 ;`endif 	
		`ifdef ENDPT3_IN 	else if ( ep_in_send_ERDY[3 ]) tx_in_ERDY_nump	<= IN_EP_BURST[3 ] + 1 ;`endif 	
		`ifdef ENDPT4_IN 	else if ( ep_in_send_ERDY[4 ]) tx_in_ERDY_nump	<= IN_EP_BURST[4 ] + 1 ;`endif 	
		`ifdef ENDPT5_IN 	else if ( ep_in_send_ERDY[5 ]) tx_in_ERDY_nump	<= IN_EP_BURST[5 ] + 1 ;`endif 	
		`ifdef ENDPT6_IN 	else if ( ep_in_send_ERDY[6 ]) tx_in_ERDY_nump	<= IN_EP_BURST[6 ] + 1 ;`endif 	
		`ifdef ENDPT7_IN 	else if ( ep_in_send_ERDY[7 ]) tx_in_ERDY_nump	<= IN_EP_BURST[7 ] + 1 ;`endif 	
		`ifdef ENDPT8_IN 	else if ( ep_in_send_ERDY[8 ]) tx_in_ERDY_nump	<= IN_EP_BURST[8 ] + 1 ;`endif 	
		`ifdef ENDPT9_IN 	else if ( ep_in_send_ERDY[9 ]) tx_in_ERDY_nump	<= IN_EP_BURST[9 ] + 1 ;`endif 	
		`ifdef ENDPT10_IN 	else if ( ep_in_send_ERDY[10]) tx_in_ERDY_nump	<= IN_EP_BURST[10] + 1 ;`endif 		
		`ifdef ENDPT11_IN 	else if ( ep_in_send_ERDY[11]) tx_in_ERDY_nump	<= IN_EP_BURST[11] + 1 ;`endif 	
		`ifdef ENDPT12_IN 	else if ( ep_in_send_ERDY[12]) tx_in_ERDY_nump	<= IN_EP_BURST[12] + 1 ;`endif 	
		`ifdef ENDPT13_IN 	else if ( ep_in_send_ERDY[13]) tx_in_ERDY_nump	<= IN_EP_BURST[13] + 1 ;`endif 
		`ifdef ENDPT14_IN 	else if ( ep_in_send_ERDY[14]) tx_in_ERDY_nump	<= IN_EP_BURST[14] + 1 ;`endif 
		`ifdef ENDPT15_IN 	else if ( ep_in_send_ERDY[15]) tx_in_ERDY_nump	<= IN_EP_BURST[15] + 1 ;`endif 		
		
	
		tx_in_ERDY_seq		<= 5'h0;
		tx_in_ERDY_stream	<= 16'h0;	
							if 		( ep_in_send_ERDY[0]) begin tx_in_ERDY_endp <= 0 ; end    
		`ifdef ENDPT1_IN 	else if ( ep_in_send_ERDY[1]) begin tx_in_ERDY_endp <= 1 ; end 	 `endif 	
		`ifdef ENDPT2_IN 	else if ( ep_in_send_ERDY[2]) begin tx_in_ERDY_endp <= 2 ; end 	 `endif 	
		`ifdef ENDPT3_IN 	else if ( ep_in_send_ERDY[3]) begin tx_in_ERDY_endp <= 3 ; end 	 `endif 	
		`ifdef ENDPT4_IN 	else if ( ep_in_send_ERDY[4]) begin tx_in_ERDY_endp <= 4 ; end 	 `endif 	
		`ifdef ENDPT5_IN 	else if ( ep_in_send_ERDY[5]) begin tx_in_ERDY_endp <= 5 ; end 	 `endif 	
		`ifdef ENDPT6_IN 	else if ( ep_in_send_ERDY[6]) begin tx_in_ERDY_endp <= 6 ; end 	 `endif 	
		`ifdef ENDPT7_IN 	else if ( ep_in_send_ERDY[7]) begin tx_in_ERDY_endp <= 7 ; end 	 `endif 	
		`ifdef ENDPT8_IN 	else if ( ep_in_send_ERDY[8]) begin tx_in_ERDY_endp <= 8 ; end 	 `endif 	
		`ifdef ENDPT9_IN 	else if ( ep_in_send_ERDY[9]) begin tx_in_ERDY_endp <= 9 ; end 	 `endif 	
		`ifdef ENDPT10_IN 	else if ( ep_in_send_ERDY[10]) begin tx_in_ERDY_endp <= 10; end	 `endif 		
		`ifdef ENDPT11_IN 	else if ( ep_in_send_ERDY[11]) begin tx_in_ERDY_endp <= 11; end	 `endif 	
		`ifdef ENDPT12_IN 	else if ( ep_in_send_ERDY[12]) begin tx_in_ERDY_endp <= 12; end	 `endif 	
		`ifdef ENDPT13_IN 	else if ( ep_in_send_ERDY[13]) begin tx_in_ERDY_endp <= 13 ; end `endif 
		`ifdef ENDPT14_IN 	else if ( ep_in_send_ERDY[14]) begin tx_in_ERDY_endp <= 14 ; end `endif 
		`ifdef ENDPT15_IN 	else if ( ep_in_send_ERDY[15]) begin tx_in_ERDY_endp <= 15 ; end `endif 
	end
end


//TX ERDY (OUT endpoints)
always @( posedge local_clk  or negedge reset_n ) begin
	if (!reset_n) begin
		tx_out_ERDY 		<= 0 ;	
		tx_out_ERDY_retry	<= 0;
		tx_out_ERDY_dir		<= 0;
		tx_out_ERDY_subtype <= 0;
		tx_out_ERDY_nump	<= 5'h0;
		tx_out_ERDY_seq		<= 5'h0;
		tx_out_ERDY_stream	<= 16'h0;	
		tx_out_ERDY_endp	<= 0 ;	
	end
	else if ( tx_out_ERDY_ack ) begin
		tx_out_ERDY <= 0 ;
	end	
	else if ( |ep_out_send_ERDY ) begin
		tx_out_ERDY			<= 1'b1;
		tx_out_ERDY_retry	<= LP_TP_NORETRY;
		tx_out_ERDY_dir		<= LP_TP_HOSTTODEVICE;
		tx_out_ERDY_subtype <= LP_TP_SUB_ERDY;
		
							if 		( ep_out_send_ERDY[0] ) begin  tx_out_ERDY_nump <= OUT_EP_BURST[0]  + 1 ; end    
		`ifdef ENDPT1_IN 	else if ( ep_out_send_ERDY[1] ) begin  tx_out_ERDY_nump <= OUT_EP_BURST[1]  + 1 ; end   `endif 	
		`ifdef ENDPT2_IN 	else if ( ep_out_send_ERDY[2] ) begin  tx_out_ERDY_nump <= OUT_EP_BURST[2]  + 1 ; end   `endif 	
		`ifdef ENDPT3_IN 	else if ( ep_out_send_ERDY[3] ) begin  tx_out_ERDY_nump <= OUT_EP_BURST[3]  + 1 ; end   `endif 	
		`ifdef ENDPT4_IN 	else if ( ep_out_send_ERDY[4] ) begin  tx_out_ERDY_nump <= OUT_EP_BURST[4]  + 1 ; end   `endif 	
		`ifdef ENDPT5_IN 	else if ( ep_out_send_ERDY[5] ) begin  tx_out_ERDY_nump <= OUT_EP_BURST[5]  + 1 ; end   `endif 	
		`ifdef ENDPT6_IN 	else if ( ep_out_send_ERDY[6] ) begin  tx_out_ERDY_nump <= OUT_EP_BURST[6]  + 1 ; end   `endif 	
		`ifdef ENDPT7_IN 	else if ( ep_out_send_ERDY[7] ) begin  tx_out_ERDY_nump <= OUT_EP_BURST[7]  + 1 ; end   `endif 	
		`ifdef ENDPT8_IN 	else if ( ep_out_send_ERDY[8] ) begin  tx_out_ERDY_nump <= OUT_EP_BURST[8]  + 1 ; end   `endif 	
		`ifdef ENDPT9_IN 	else if ( ep_out_send_ERDY[9] ) begin  tx_out_ERDY_nump <= OUT_EP_BURST[9]  + 1 ; end   `endif 	
		`ifdef ENDPT10_IN 	else if ( ep_out_send_ERDY[10]) begin  tx_out_ERDY_nump <= OUT_EP_BURST[10] + 1 ; end   `endif 		
		`ifdef ENDPT11_IN 	else if ( ep_out_send_ERDY[11]) begin  tx_out_ERDY_nump <= OUT_EP_BURST[11] + 1 ; end   `endif 	
		`ifdef ENDPT12_IN 	else if ( ep_out_send_ERDY[12]) begin  tx_out_ERDY_nump <= OUT_EP_BURST[12] + 1 ; end   `endif 	
		`ifdef ENDPT13_IN 	else if ( ep_out_send_ERDY[13]) begin  tx_out_ERDY_nump <= OUT_EP_BURST[13] + 1 ; end 	`endif 
		`ifdef ENDPT14_IN 	else if ( ep_out_send_ERDY[14]) begin  tx_out_ERDY_nump <= OUT_EP_BURST[14] + 1 ; end 	`endif 
		`ifdef ENDPT15_IN 	else if ( ep_out_send_ERDY[15]) begin  tx_out_ERDY_nump <= OUT_EP_BURST[15] + 1 ; end 	`endif 


		tx_out_ERDY_seq		<= 5'h0;
		tx_out_ERDY_stream	<= 16'h0;	

							if 		( ep_out_send_ERDY[0]) begin  tx_out_ERDY_endp <= 0 ; end    
		`ifdef ENDPT1_IN 	else if ( ep_out_send_ERDY[1]) begin  tx_out_ERDY_endp <= 1 ; end  `endif 	
		`ifdef ENDPT2_IN 	else if ( ep_out_send_ERDY[2]) begin  tx_out_ERDY_endp <= 2 ; end  `endif 	
		`ifdef ENDPT3_IN 	else if ( ep_out_send_ERDY[3]) begin  tx_out_ERDY_endp <= 3 ; end  `endif 	
		`ifdef ENDPT4_IN 	else if ( ep_out_send_ERDY[4]) begin  tx_out_ERDY_endp <= 4 ; end  `endif 	
		`ifdef ENDPT5_IN 	else if ( ep_out_send_ERDY[5]) begin  tx_out_ERDY_endp <= 5 ; end  `endif 	
		`ifdef ENDPT6_IN 	else if ( ep_out_send_ERDY[6]) begin  tx_out_ERDY_endp <= 6 ; end  `endif 	
		`ifdef ENDPT7_IN 	else if ( ep_out_send_ERDY[7]) begin  tx_out_ERDY_endp <= 7 ; end  `endif 	
		`ifdef ENDPT8_IN 	else if ( ep_out_send_ERDY[8]) begin  tx_out_ERDY_endp <= 8 ; end  `endif 	
		`ifdef ENDPT9_IN 	else if ( ep_out_send_ERDY[9]) begin  tx_out_ERDY_endp <= 9 ; end  `endif 	
		`ifdef ENDPT10_IN 	else if ( ep_out_send_ERDY[10]) begin tx_out_ERDY_endp <= 10; end  `endif 		
		`ifdef ENDPT11_IN 	else if ( ep_out_send_ERDY[11]) begin tx_out_ERDY_endp <= 11; end  `endif 	
		`ifdef ENDPT12_IN 	else if ( ep_out_send_ERDY[12]) begin tx_out_ERDY_endp <= 12; end  `endif 	
		`ifdef ENDPT13_IN 	else if ( ep_out_send_ERDY[13]) begin tx_out_ERDY_endp <= 13 ; end `endif 
		`ifdef ENDPT14_IN 	else if ( ep_out_send_ERDY[14]) begin tx_out_ERDY_endp <= 14 ; end `endif 
		`ifdef ENDPT15_IN 	else if ( ep_out_send_ERDY[15]) begin tx_out_ERDY_endp <= 15 ; end `endif 

	end
end

//TX 0 DP
always @( posedge local_clk  or negedge reset_n ) begin
	if (!reset_n) begin
		tx_0_DP			<= 0 ;	
		tx_0_DP_eob		<= 0 ;	
		tx_0_DP_dir		<= 0 ;
		tx_0_DP_seq		<= 0 ;
		tx_0_DP_len		<= 0 ;
		tx_0_DP_TT 		<= 0 ;	
		tx_0_DP_endp    <= 0 ;		
	end
	else if ( tx_0_DP_ack ) begin
		tx_0_DP 			<= 0 ;
	end
	else if ( |ep_in_send_0_DP ) begin
		tx_0_DP			<= 1 ;		
		tx_0_DP_eob		<= 1 ;	
		tx_0_DP_dir		<= ep_in_send_0_DP[0] ? 1'b0 : LP_TP_DEVICETOHOST ;
		tx_0_DP_len		<= 0 ;

							if 		( ep_in_send_0_DP[0]) begin  tx_0_DP_endp <= 0  ; tx_0_DP_TT <= {1'b1,IN_EP_TYPE[0][1:0]}  ;  tx_0_DP_seq		<= ep_in_pending_current_seq[0] ; end    
		`ifdef ENDPT1_IN 	else if ( ep_in_send_0_DP[1]) begin  tx_0_DP_endp <= 1  ; tx_0_DP_TT <= {1'b1,IN_EP_TYPE[1][1:0]}  ;  tx_0_DP_seq		<= ep_in_pending_current_seq[1] ; end  `endif 	
		`ifdef ENDPT2_IN 	else if ( ep_in_send_0_DP[2]) begin  tx_0_DP_endp <= 2  ; tx_0_DP_TT <= {1'b1,IN_EP_TYPE[2][1:0]}  ;  tx_0_DP_seq		<= ep_in_pending_current_seq[2] ; end  `endif 	
		`ifdef ENDPT3_IN 	else if ( ep_in_send_0_DP[3]) begin  tx_0_DP_endp <= 3  ; tx_0_DP_TT <= {1'b1,IN_EP_TYPE[3][1:0]}  ;  tx_0_DP_seq		<= ep_in_pending_current_seq[3] ; end  `endif 	
		`ifdef ENDPT4_IN 	else if ( ep_in_send_0_DP[4]) begin  tx_0_DP_endp <= 4  ; tx_0_DP_TT <= {1'b1,IN_EP_TYPE[4][1:0]}  ;  tx_0_DP_seq		<= ep_in_pending_current_seq[4] ; end  `endif 	
		`ifdef ENDPT5_IN 	else if ( ep_in_send_0_DP[5]) begin  tx_0_DP_endp <= 5  ; tx_0_DP_TT <= {1'b1,IN_EP_TYPE[5][1:0]}  ;  tx_0_DP_seq		<= ep_in_pending_current_seq[5] ; end  `endif 	
		`ifdef ENDPT6_IN 	else if ( ep_in_send_0_DP[6]) begin  tx_0_DP_endp <= 6  ; tx_0_DP_TT <= {1'b1,IN_EP_TYPE[6][1:0]}  ;  tx_0_DP_seq		<= ep_in_pending_current_seq[6] ; end  `endif 	
		`ifdef ENDPT7_IN 	else if ( ep_in_send_0_DP[7]) begin  tx_0_DP_endp <= 7  ; tx_0_DP_TT <= {1'b1,IN_EP_TYPE[7][1:0]}  ;  tx_0_DP_seq		<= ep_in_pending_current_seq[7] ; end  `endif 	
		`ifdef ENDPT8_IN 	else if ( ep_in_send_0_DP[8]) begin  tx_0_DP_endp <= 8  ; tx_0_DP_TT <= {1'b1,IN_EP_TYPE[8][1:0]}  ;  tx_0_DP_seq		<= ep_in_pending_current_seq[8] ; end  `endif 	
		`ifdef ENDPT9_IN 	else if ( ep_in_send_0_DP[9]) begin  tx_0_DP_endp <= 9  ; tx_0_DP_TT <= {1'b1,IN_EP_TYPE[9][1:0]}  ;  tx_0_DP_seq		<= ep_in_pending_current_seq[9] ; end  `endif 	
		`ifdef ENDPT10_IN 	else if ( ep_in_send_0_DP[10]) begin tx_0_DP_endp <= 10 ; tx_0_DP_TT <= {1'b1,IN_EP_TYPE[10][1:0]} ;  tx_0_DP_seq		<= ep_in_pending_current_seq[10] ; end  `endif 		
		`ifdef ENDPT11_IN 	else if ( ep_in_send_0_DP[11]) begin tx_0_DP_endp <= 11 ; tx_0_DP_TT <= {1'b1,IN_EP_TYPE[11][1:0]} ;  tx_0_DP_seq		<= ep_in_pending_current_seq[11] ; end  `endif 	
		`ifdef ENDPT12_IN 	else if ( ep_in_send_0_DP[12]) begin tx_0_DP_endp <= 12 ; tx_0_DP_TT <= {1'b1,IN_EP_TYPE[12][1:0]} ;  tx_0_DP_seq		<= ep_in_pending_current_seq[12] ; end  `endif 	
		`ifdef ENDPT13_IN 	else if ( ep_in_send_0_DP[13]) begin tx_0_DP_endp <= 13 ; tx_0_DP_TT <= {1'b1,IN_EP_TYPE[13][1:0]} ;  tx_0_DP_seq		<= ep_in_pending_current_seq[13] ; end  `endif 
		`ifdef ENDPT14_IN 	else if ( ep_in_send_0_DP[14]) begin tx_0_DP_endp <= 14 ; tx_0_DP_TT <= {1'b1,IN_EP_TYPE[14][1:0]} ;  tx_0_DP_seq		<= ep_in_pending_current_seq[14] ; end  `endif 
		`ifdef ENDPT15_IN 	else if ( ep_in_send_0_DP[15]) begin tx_0_DP_endp <= 15 ; tx_0_DP_TT <= {1'b1,IN_EP_TYPE[15][1:0]} ;  tx_0_DP_seq		<= ep_in_pending_current_seq[15] ; end  `endif 

	end
end

//TX DP
always @( posedge local_clk  or negedge reset_n ) begin
	if (!reset_n) begin
		tx_DP			<= 0 ;		
		tx_DP_dir		<= 0 ;
		tx_DP_endp		<= 0 ;
		tx_DP_eob		<= 0 ;
		tx_DP_len		<= 0 ;
		tx_DP_seq		<= 0 ;
		tx_DP_TT		<= 0 ;
	end
	else if ( tx_DP_ack ) begin
		tx_DP 			<= 0 ;
	end
	else if ( !tx_DP & |ep_in_send_DP ) begin
		tx_DP			<= 1 ;		
		tx_DP_dir		<= ep_in_send_DP[0] ? 1'b0 : LP_TP_DEVICETOHOST ;

							if 		( ep_in_send_DP[0]) begin  tx_DP_endp <= 0 ; tx_DP_eob	<= 1'b0 ; tx_DP_len <= buf_out_len_mem [0] ;  tx_DP_seq	<= ep_in_pending_current_seq[0] ; tx_DP_TT <= {1'b1,IN_EP_TYPE[0][1:0]};end    
		`ifdef ENDPT1_IN 	else if ( ep_in_send_DP[1]) begin  tx_DP_endp <= 1 ; tx_DP_eob	<= ( IN_EP_TYPE[1]  == ISO ) ? buf_out_last_mem[1] : ( IN_EP_TYPE_PKT_SIZE [1]  !=  buf_out_len_mem [1]  ) ? 1 : buf_out_last_mem [1]  ? 1 : 0 ; tx_DP_len <= buf_out_len_mem [1] ;  tx_DP_seq	<= ep_in_pending_current_seq[1] ; tx_DP_TT <= {1'b1,IN_EP_TYPE[1][1:0]};end  `endif 	
		`ifdef ENDPT2_IN 	else if ( ep_in_send_DP[2]) begin  tx_DP_endp <= 2 ; tx_DP_eob	<= ( IN_EP_TYPE[2]  == ISO ) ? buf_out_last_mem[2] : ( IN_EP_TYPE_PKT_SIZE [2]  !=  buf_out_len_mem [2]  ) ? 1 : buf_out_last_mem [2]  ? 1 : 0 ; tx_DP_len <= buf_out_len_mem [2] ;  tx_DP_seq	<= ep_in_pending_current_seq[2] ; tx_DP_TT <= {1'b1,IN_EP_TYPE[2][1:0]};end  `endif 	
		`ifdef ENDPT3_IN 	else if ( ep_in_send_DP[3]) begin  tx_DP_endp <= 3 ; tx_DP_eob	<= ( IN_EP_TYPE[3]  == ISO ) ? buf_out_last_mem[3] : ( IN_EP_TYPE_PKT_SIZE [3]  !=  buf_out_len_mem [3]  ) ? 1 : buf_out_last_mem [3]  ? 1 : 0 ; tx_DP_len <= buf_out_len_mem [3] ;  tx_DP_seq	<= ep_in_pending_current_seq[3] ; tx_DP_TT <= {1'b1,IN_EP_TYPE[3][1:0]};end  `endif 	
		`ifdef ENDPT4_IN 	else if ( ep_in_send_DP[4]) begin  tx_DP_endp <= 4 ; tx_DP_eob	<= ( IN_EP_TYPE[4]  == ISO ) ? buf_out_last_mem[4] : ( IN_EP_TYPE_PKT_SIZE [4]  !=  buf_out_len_mem [4]  ) ? 1 : buf_out_last_mem [4]  ? 1 : 0 ; tx_DP_len <= buf_out_len_mem [4] ;  tx_DP_seq	<= ep_in_pending_current_seq[4] ; tx_DP_TT <= {1'b1,IN_EP_TYPE[4][1:0]};end  `endif 	
		`ifdef ENDPT5_IN 	else if ( ep_in_send_DP[5]) begin  tx_DP_endp <= 5 ; tx_DP_eob	<= ( IN_EP_TYPE[5]  == ISO ) ? buf_out_last_mem[5] : ( IN_EP_TYPE_PKT_SIZE [5]  !=  buf_out_len_mem [5]  ) ? 1 : buf_out_last_mem [5]  ? 1 : 0 ; tx_DP_len <= buf_out_len_mem [5] ;  tx_DP_seq	<= ep_in_pending_current_seq[5] ; tx_DP_TT <= {1'b1,IN_EP_TYPE[5][1:0]};end  `endif 	
		`ifdef ENDPT6_IN 	else if ( ep_in_send_DP[6]) begin  tx_DP_endp <= 6 ; tx_DP_eob	<= ( IN_EP_TYPE[6]  == ISO ) ? buf_out_last_mem[6] : ( IN_EP_TYPE_PKT_SIZE [6]  !=  buf_out_len_mem [6]  ) ? 1 : buf_out_last_mem [6]  ? 1 : 0 ; tx_DP_len <= buf_out_len_mem [6] ;  tx_DP_seq	<= ep_in_pending_current_seq[6] ; tx_DP_TT <= {1'b1,IN_EP_TYPE[6][1:0]};end  `endif 	
		`ifdef ENDPT7_IN 	else if ( ep_in_send_DP[7]) begin  tx_DP_endp <= 7 ; tx_DP_eob	<= ( IN_EP_TYPE[7]  == ISO ) ? buf_out_last_mem[7] : ( IN_EP_TYPE_PKT_SIZE [7]  !=  buf_out_len_mem [7]  ) ? 1 : buf_out_last_mem [7]  ? 1 : 0 ; tx_DP_len <= buf_out_len_mem [7] ;  tx_DP_seq	<= ep_in_pending_current_seq[7] ; tx_DP_TT <= {1'b1,IN_EP_TYPE[7][1:0]};end  `endif 	
		`ifdef ENDPT8_IN 	else if ( ep_in_send_DP[8]) begin  tx_DP_endp <= 8 ; tx_DP_eob	<= ( IN_EP_TYPE[8]  == ISO ) ? buf_out_last_mem[8] : ( IN_EP_TYPE_PKT_SIZE [8]  !=  buf_out_len_mem [8]  ) ? 1 : buf_out_last_mem [8]  ? 1 : 0 ; tx_DP_len <= buf_out_len_mem [8] ;  tx_DP_seq	<= ep_in_pending_current_seq[8] ; tx_DP_TT <= {1'b1,IN_EP_TYPE[8][1:0]};end  `endif 	
		`ifdef ENDPT9_IN 	else if ( ep_in_send_DP[9]) begin  tx_DP_endp <= 9 ; tx_DP_eob	<= ( IN_EP_TYPE[9]  == ISO ) ? buf_out_last_mem[9] : ( IN_EP_TYPE_PKT_SIZE [9]  !=  buf_out_len_mem [9]  ) ? 1 : buf_out_last_mem [9]  ? 1 : 0 ; tx_DP_len <= buf_out_len_mem [9] ;  tx_DP_seq	<= ep_in_pending_current_seq[9] ; tx_DP_TT <= {1'b1,IN_EP_TYPE[9][1:0]};end  `endif 	
		`ifdef ENDPT10_IN 	else if ( ep_in_send_DP[10]) begin tx_DP_endp <= 10 ; tx_DP_eob	<= ( IN_EP_TYPE[10] == ISO ) ? buf_out_last_mem[10]: ( IN_EP_TYPE_PKT_SIZE [10] !=  buf_out_len_mem [10] ) ? 1 : buf_out_last_mem [10] ? 1 : 0 ; tx_DP_len <= buf_out_len_mem [10] ;  tx_DP_seq	<= ep_in_pending_current_seq[10] ; tx_DP_TT <= {1'b1,IN_EP_TYPE[10][1:0]}; end  `endif 		
		`ifdef ENDPT11_IN 	else if ( ep_in_send_DP[11]) begin tx_DP_endp <= 11 ; tx_DP_eob	<= ( IN_EP_TYPE[11] == ISO ) ? buf_out_last_mem[11]: ( IN_EP_TYPE_PKT_SIZE [11] !=  buf_out_len_mem [11] ) ? 1 : buf_out_last_mem [11] ? 1 : 0 ; tx_DP_len <= buf_out_len_mem [11] ;  tx_DP_seq	<= ep_in_pending_current_seq[11] ; tx_DP_TT <= {1'b1,IN_EP_TYPE[11][1:0]}; end  `endif 	
		`ifdef ENDPT12_IN 	else if ( ep_in_send_DP[12]) begin tx_DP_endp <= 12 ; tx_DP_eob	<= ( IN_EP_TYPE[12] == ISO ) ? buf_out_last_mem[12]: ( IN_EP_TYPE_PKT_SIZE [12] !=  buf_out_len_mem [12] ) ? 1 : buf_out_last_mem [12] ? 1 : 0 ; tx_DP_len <= buf_out_len_mem [12] ;  tx_DP_seq	<= ep_in_pending_current_seq[12] ; tx_DP_TT <= {1'b1,IN_EP_TYPE[12][1:0]}; end  `endif 	
		`ifdef ENDPT13_IN 	else if ( ep_in_send_DP[13]) begin tx_DP_endp <= 13 ; tx_DP_eob	<= ( IN_EP_TYPE[13] == ISO ) ? buf_out_last_mem[13]: ( IN_EP_TYPE_PKT_SIZE [13] !=  buf_out_len_mem [13] ) ? 1 : buf_out_last_mem [13] ? 1 : 0 ; tx_DP_len <= buf_out_len_mem [13] ;  tx_DP_seq	<= ep_in_pending_current_seq[13] ; tx_DP_TT <= {1'b1,IN_EP_TYPE[13][1:0]}; end `endif 
		`ifdef ENDPT14_IN 	else if ( ep_in_send_DP[14]) begin tx_DP_endp <= 14 ; tx_DP_eob	<= ( IN_EP_TYPE[14] == ISO ) ? buf_out_last_mem[14]: ( IN_EP_TYPE_PKT_SIZE [14] !=  buf_out_len_mem [14] ) ? 1 : buf_out_last_mem [14] ? 1 : 0 ; tx_DP_len <= buf_out_len_mem [14] ;  tx_DP_seq	<= ep_in_pending_current_seq[14] ; tx_DP_TT <= {1'b1,IN_EP_TYPE[14][1:0]}; end `endif 
		`ifdef ENDPT15_IN 	else if ( ep_in_send_DP[15]) begin tx_DP_endp <= 15 ; tx_DP_eob	<= ( IN_EP_TYPE[15] == ISO ) ? buf_out_last_mem[15]: ( IN_EP_TYPE_PKT_SIZE [15] !=  buf_out_len_mem [15] ) ? 1 : buf_out_last_mem [15] ? 1 : 0 ; tx_DP_len <= buf_out_len_mem [15] ;  tx_DP_seq	<= ep_in_pending_current_seq[15] ; tx_DP_TT <= {1'b1,IN_EP_TYPE[15][1:0]}; end `endif 		

	end
end

//TX ACK (for DPs)
always @( posedge local_clk  or negedge reset_n ) begin
	if (!reset_n) begin
		tx_out_ACK 			<= 0 ;	
		tx_out_ACK_retry	<= 0 ;
		tx_out_ACK_dir		<= 0;
		tx_out_ACK_subtype 	<= 0;
		tx_out_ACK_nump		<= 0;
		tx_out_ACK_seq 	    <= 0; 
		tx_out_ACK_stream	<= 0;	
		tx_out_ACK_endp		<= 0 ;
		tx_out_ACK_TT		<= 0 ;		
	end
	//else if ( tx_out_ACK_ack ) begin
	//	tx_out_ACK <= 0 ;
	//end	
	else if ( |ep_out_send_ACK ) begin
		tx_out_ACK			<= 1'b1;
		tx_out_ACK_retry	<= LP_TP_NORETRY ;
		tx_out_ACK_dir		<= LP_TP_HOSTTODEVICE;
		tx_out_ACK_subtype 	<= LP_TP_SUB_ACK;
		tx_out_ACK_nump		<= OUT_EP_BURST[rx_dph_endp] + 1 ;
		tx_out_ACK_seq 	    <= ep_out_ack_current_seq[rx_dph_endp] + 1 ;
		tx_out_ACK_stream	<= 16'h0;	
		tx_out_ACK_endp		<= rx_dph_endp ;
		tx_out_ACK_TT		<= speed == GEN1X1 ? 3'b0 : {1'b1,OUT_EP_TYPE[rx_dph_endp][1:0]} ;  
	end
	else begin
		tx_out_ACK <= 0 ;
	end
end


reg 	    tx_out_ACK_retry_q 		; 
reg 	    tx_out_ACK_dir_q 		;
reg [3:0]  tx_out_ACK_subtype_q 	;
reg [4:0]  tx_out_ACK_nump_q 		;
reg [4:0]  tx_out_ACK_seq_q 		;
reg [15:0] tx_out_ACK_stream_q      ;
reg [3:0]  tx_out_ACK_endp_q 		;
reg [2:0]  tx_out_ACK_TT_q 	        ;
wire tx_out_ACK_empty ;

wire [39:0] out_ack_d ;
wire [39:0] out_ack_q ;
assign  out_ack_d = {
						tx_out_ACK_retry 	
						,tx_out_ACK_dir 	
						,tx_out_ACK_subtype
						,tx_out_ACK_nump	
						,tx_out_ACK_seq	
						,tx_out_ACK_stream
						,tx_out_ACK_endp	
						,tx_out_ACK_TT 
					};
 
hp_buffer 
#(
	 .DQ_WIDTH  (39) 
	,.PT_WIDTH  (2) 
	,.BUF_DEPTH (4) 
)OUT_ACK_BUF
(
	 .local_clk (local_clk) //input 	wire 				   
	,.reset_n 	(reset_n) //input 	wire 			 
	,.hp_d 		(out_ack_d) //input 	wire [DQ_W-1:0] 
	,.hp_push	(tx_out_ACK) //input 	wire 			
	,.hp_pop	(tx_out_ACK_ack) //input  wire            
	,.hp_q		(out_ack_q) //output reg  [DQ_W-1:0] 
	,.hp_empty	(tx_out_ACK_empty) //output reg  			
);

assign 
 	{
		  tx_out_ACK_retry_q 	
		 ,tx_out_ACK_dir_q 	
		 ,tx_out_ACK_subtype_q
		 ,tx_out_ACK_nump_q	
		 ,tx_out_ACK_seq_q	
		 ,tx_out_ACK_stream_q
		 ,tx_out_ACK_endp_q	
		 ,tx_out_ACK_TT_q 
	}	= out_ack_q ;




//TX ACK (for STATUSs)
always @( posedge local_clk  or negedge reset_n ) begin
	if (!reset_n) begin
		tx_STATUS_ACK 			<= 0 ;
		tx_STATUS_ACK_retry		<= 0 ;
		tx_STATUS_ACK_dir		<= 0 ;
		tx_STATUS_ACK_subtype 	<= 0 ;
		tx_STATUS_ACK_nump		<= 0 ;
		tx_STATUS_ACK_seq 	    <= 0 ; 
		tx_STATUS_ACK_stream	<= 0 ;	
		tx_STATUS_ACK_endp		<= 0 ;	
		tx_STATUS_ACK_TT		<= 0 ;	
		tx_STATUS_ACK_TPF		<= 0 ;	
	end
	else if ( tx_STATUS_ACK_ack ) begin
		tx_STATUS_ACK <= 0 ;
	end	
	else if ( send_STATUS_ACK ) begin
		tx_STATUS_ACK			<= 1'b1;
		tx_STATUS_ACK_retry		<= LP_TP_NORETRY ;
		tx_STATUS_ACK_dir		<= LP_TP_HOSTTODEVICE;
		tx_STATUS_ACK_subtype 	<= ( buf_in_ready_mem [0] == 1 ) ? LP_TP_SUB_ACK : LP_TP_SUB_NRDY;
		tx_STATUS_ACK_nump		<= 0 ;
		tx_STATUS_ACK_seq 	    <= 1 ; 
		tx_STATUS_ACK_stream	<= 16'h0;	
		tx_STATUS_ACK_endp		<= 0 ;
		tx_STATUS_ACK_TT 		<= speed == GEN1X1 ? 3'b0: {1'b1,OUT_EP_TYPE[rx_dph_endp][1:0]};
		`ifndef SIM 
		tx_STATUS_ACK_TPF		<= set_address & speed != GEN1X1 ;	
		`endif		
	end
end

always @ ( * ) begin
	if ( tx_STATUS_ACK && tx_STATUS_ACK_ack ) begin
		send_STATUS_ACK_ack <= 1 ;
	end
	else begin
		send_STATUS_ACK_ack <= 0 ; 
	end
end

//TX Retry 
always @( posedge local_clk  or negedge reset_n ) begin
	if (!reset_n) begin
		tx_out_RETRY 			<= 0 ;	
		tx_out_RETRY_retry		<= 0 ;
		tx_out_RETRY_dir		<= 0 ;
		tx_out_RETRY_subtype 	<= 0 ;
		tx_out_RETRY_nump		<= 0 ;
		tx_out_RETRY_seq 		<= 0 ;
		tx_out_RETRY_stream		<= 0 ;	
		tx_out_RETRY_endp 		<= 0 ;		
	end
	else if ( tx_out_RETRY_ack ) begin
		tx_out_RETRY <= 0 ;
	end	
	else if ( |ep_out_send_RETRY ) begin
		tx_out_RETRY				<= 1'b1;
		tx_out_RETRY_retry			<= 1'b1;
		tx_out_RETRY_dir			<= LP_TP_HOSTTODEVICE;
		tx_out_RETRY_subtype 		<= LP_TP_SUB_ACK;
		tx_out_RETRY_nump			<= OUT_EP_BURST[rx_dph_endp] + 1;
		tx_out_RETRY_seq 			<= ep_out_ack_current_seq [rx_dph_endp] ;
		tx_out_RETRY_stream			<= 16'h0;	
		tx_out_RETRY_endp 			<= rx_dph_endp  ;
		tx_out_RETRY_TT 			<= ( speed == GEN2X1 ) ? {1'b1,OUT_EP_TYPE [rx_dph_endp][1:0]} : 0 ;
	end
end

//TX Sublink Speed Device Notification
always @( posedge local_clk  or negedge reset_n ) begin
	if (!reset_n) begin
		tx_tx_sublink_speed_device_noti <= 0 ;
		tx_rx_sublink_speed_device_noti <= 0 ;
	end
	else if ( tx_rx_sublink_speed_device_noti_ack ) begin
		tx_tx_sublink_speed_device_noti <= 1 ;
		tx_rx_sublink_speed_device_noti <= 0 ;
	end
	else if ( tx_tx_sublink_speed_device_noti_ack ) begin
		tx_tx_sublink_speed_device_noti <= 0 ;		
	end
	`ifndef SIM 
	else if (  set_address_ack && speed != GEN1X1 ) begin
		tx_rx_sublink_speed_device_noti	<= 1 ;			
	end
	`endif

end

//TX PING RESP
always @( posedge local_clk  or negedge reset_n ) begin
	if (!reset_n) begin
		tx_PING_RESP 			<= 0 ;	
		tx_PING_RESP_retry		<= 0 ;
		tx_PING_RESP_dir		<= 0 ;
		tx_PING_RESP_subtype 	<= 0 ;
		tx_PING_RESP_nump		<= 0 ;
		tx_PING_RESP_seq 	    <= 0 ; 
		tx_PING_RESP_stream		<= 0 ;	
		tx_PING_RESP_endp		<= 0 ;		
	end	
	else if ( rx_tp && rx_tp_subtype == LP_TP_SUB_PING ) begin
		tx_PING_RESP			<= 1'b1;
		tx_PING_RESP_retry		<= LP_TP_NORETRY ;
		tx_PING_RESP_dir		<= rx_tp_d ;
		tx_PING_RESP_subtype 	<= LP_TP_SUB_PINGRSP;
		tx_PING_RESP_nump		<= 0 ;
		tx_PING_RESP_seq 	    <= 0 ; 
		tx_PING_RESP_stream		<= 16'h0;	
		tx_PING_RESP_endp		<= rx_tp_endp ;
	end
	else begin
		tx_PING_RESP <= 0 ;		
	end
end

reg 		tx_PING_RESP_retry_q 	;
reg 		tx_PING_RESP_dir_q 		;
reg [3:0] 	tx_PING_RESP_subtype_q 	;
reg [4:0] 	tx_PING_RESP_nump_q 	;
reg [4:0] 	tx_PING_RESP_seq_q 		;
reg [15:0] 	tx_PING_RESP_stream_q 	;
reg [3:0] 	tx_PING_RESP_endp_q 	;

wire tx_PING_RESP_empty ;

wire [35:0] tx_PING_d ;
wire [35:0] tx_PING_q ;
assign  tx_PING_d = {
						 tx_PING_RESP_retry 	
						,tx_PING_RESP_dir 	
						,tx_PING_RESP_subtype
						,tx_PING_RESP_nump	
						,tx_PING_RESP_seq	
						,tx_PING_RESP_stream
						,tx_PING_RESP_endp	
					};
 
hp_buffer 
#(
	 .DQ_WIDTH  (36) 
	,.PT_WIDTH  (4) 
	,.BUF_DEPTH (16) 
)PING_RSP_BUF
(
	 .local_clk (local_clk) //input 	wire 				   
	,.reset_n 	(reset_n) //input 	wire 			 
	,.hp_d 		(tx_PING_d) //input 	wire [DQ_W-1:0] 
	,.hp_push	(tx_PING_RESP) //input 	wire 			
	,.hp_pop	(tx_PING_RESP_ack) //input  wire            
	,.hp_q		(tx_PING_q) //output reg  [DQ_W-1:0] 
	,.hp_empty	(tx_PING_RESP_empty) //output reg  			
);

assign 
 	{
		 tx_PING_RESP_retry_q 	
		,tx_PING_RESP_dir_q 	
		,tx_PING_RESP_subtype_q
		,tx_PING_RESP_nump_q	
		,tx_PING_RESP_seq_q	
		,tx_PING_RESP_stream_q
		,tx_PING_RESP_endp_q	
	}	= tx_PING_q ;


//TX STALL
reg [4:0] send_STALL_ep_num ;
always @( posedge local_clk  or negedge reset_n ) begin
	if (!reset_n) begin
		tx_STALL 			<= 0 ;	
		tx_STALL_retry		<= 0 ;
		tx_STALL_dir		<= 0 ;
		tx_STALL_subtype 	<= 0 ;
		tx_STALL_nump		<= 0 ;
		tx_STALL_seq 	    <= 0 ; 
		tx_STALL_stream		<= 0 ;	
		tx_STALL_endp		<= 0 ;		
	end
	else if ( tx_STALL_ack ) begin
		tx_STALL <= 0 ;
	end	
	else if ( send_STALL ) begin
		tx_STALL			<= 1'b1;
		tx_STALL_retry		<= LP_TP_NORETRY ;
		tx_STALL_dir		<= LP_TP_HOSTTODEVICE ;
		tx_STALL_subtype 	<= LP_TP_SUB_STALL;
		tx_STALL_nump		<= send_STALL_ep_num ;
		tx_STALL_seq 	    <= 0 ; 
		tx_STALL_stream		<= 16'h0;	
		tx_STALL_endp		<= 0 ;
	end
end

always @( posedge local_clk  or negedge reset_n ) begin
	if (!reset_n) begin
		send_STALL <= 0 ;
		send_STALL_ep_num <= 0 ;
	end
	else if ( send_STATUS_STALL ) begin
		send_STALL <= 1 ;	
		send_STALL_ep_num <= 0 ;	
	end
	else if  (|ep_in_send_STALL) begin
		send_STALL <= 1 ;	
		send_STALL_ep_num <= rx_tp_endp;
	end
	else if  (|ep_out_send_STALL) begin
		send_STALL <= 1 ;
		send_STALL_ep_num <= rx_dph_endp ;
	end
	else if ( tx_STALL && tx_STALL_ack ) begin
		send_STALL <= 0 ;
		send_STALL_ep_num <= 0 ;
	end
end

//TX MUX 
always @ ( posedge local_clk or negedge reset_n ) begin
	if (!reset_n ) begin
		tx_state <= ST_TX_IDLE ;
		tx_hp <= 0 ;
		hp_word_0 <= 0 ;
		hp_word_1 <= 0 ;
		hp_word_2 <= 0 ;
		tx_in_NRDY_ack <= 0;	
		tx_out_NRDY_ack <= 0 ;	
		tx_in_ERDY_ack <= 0 ;			
		tx_out_ERDY_ack <= 0 ;			
		tx_out_ACK_ack <= 0 ;			
		tx_STATUS_ACK_ack <= 0 ;			
		tx_out_RETRY_ack <= 0 ;			
		tx_PING_RESP_ack <= 0 ;			
		tx_STALL_ack <= 0 ;			
		tx_rx_sublink_speed_device_noti_ack <= 0 ;
		tx_tx_sublink_speed_device_noti_ack <= 0 ;					
    end
	else begin
		case ( tx_state ) 
		ST_TX_IDLE:begin
			if ( tx_in_NRDY ) begin
				tx_state <= ST_TX_IN_NRDY ;
				tx_hp    <= 1 ;

				hp_word_0 <= {	dev_address, LP_TP_ROUTE0, LP_TYPE_TP};
				hp_word_1 <= {	6'h0, tx_in_NRDY_seq, tx_in_NRDY_nump, 
								1'b0, 3'h0, tx_in_NRDY_endp, tx_in_NRDY_dir, tx_in_NRDY_retry, 2'h0, tx_in_NRDY_subtype};
				hp_word_2 <= {	LP_TP_NBI_0, LP_TP_PPEND_NO, LP_TP_DBI_NO, LP_TP_WPA_NO, LP_TP_SSI_NO, 8'h0, tx_in_NRDY_stream};
				
				tx_in_NRDY_ack <= 1 ;	
			end
			else if ( tx_out_NRDY ) begin
				tx_state <= ST_TX_OUT_NRDY ;
				tx_hp    <= 1 ;

				hp_word_0 <= {	dev_address, LP_TP_ROUTE0, LP_TYPE_TP};
				hp_word_1 <= {	6'h0, tx_out_NRDY_seq, tx_out_NRDY_nump, 
								1'b0, 3'h0, tx_out_NRDY_endp, tx_out_NRDY_dir, tx_out_NRDY_retry, 2'h0, tx_out_NRDY_subtype};
				hp_word_2 <= {	LP_TP_NBI_0, LP_TP_PPEND_NO, LP_TP_DBI_NO, LP_TP_WPA_NO, LP_TP_SSI_NO, 8'h0, tx_out_NRDY_stream};
				
				tx_out_NRDY_ack <= 1 ;					
			end
			else if ( tx_in_ERDY ) begin
				tx_state <= ST_TX_IN_ERDY ;

				tx_hp    <= 1 ;

				hp_word_0 <= {	dev_address, LP_TP_ROUTE0, LP_TYPE_TP};
				hp_word_1 <= {	6'h0, tx_in_ERDY_seq, tx_in_ERDY_nump, 
								1'b0, 3'h0, tx_in_ERDY_endp, tx_in_ERDY_dir, tx_in_ERDY_retry, 2'h0, tx_in_ERDY_subtype};
				hp_word_2 <= {	LP_TP_NBI_0, LP_TP_PPEND_NO, LP_TP_DBI_NO, LP_TP_WPA_NO, LP_TP_SSI_NO, 8'h0, tx_in_ERDY_stream};
				
				tx_in_ERDY_ack <= 1 ;						
			end
			else if ( tx_out_ERDY ) begin
				tx_state <= ST_TX_OUT_ERDY;
				tx_hp    <= 1 ;

				hp_word_0 <= {	dev_address, LP_TP_ROUTE0, LP_TYPE_TP};
				hp_word_1 <= {	6'h0, tx_out_ERDY_seq, tx_out_ERDY_nump, 
								1'b0, 3'h0, tx_out_ERDY_endp, tx_out_ERDY_dir, tx_out_ERDY_retry, 2'h0, tx_out_ERDY_subtype};
				hp_word_2 <= {	LP_TP_NBI_0, LP_TP_PPEND_NO, LP_TP_DBI_NO, LP_TP_WPA_NO, LP_TP_SSI_NO, 8'h0, tx_out_ERDY_stream};
				
				tx_out_ERDY_ack <= 1 ;	

			end
			else if ( !tx_out_ACK_empty ) begin
				tx_state <= ST_TX_OUT_ACK;
				tx_hp    <= 1 ;		

				hp_word_0 <= {	dev_address, LP_TP_ROUTE0, LP_TYPE_TP};
				hp_word_1 <= {	6'h0, tx_out_ACK_seq_q, tx_out_ACK_nump_q, 
								1'b0, tx_out_ACK_TT_q, tx_out_ACK_endp_q, tx_out_ACK_dir_q, tx_out_ACK_retry_q, 2'h0, tx_out_ACK_subtype_q};
				hp_word_2 <= {	LP_TP_NBI_0, LP_TP_PPEND_NO, LP_TP_DBI_NO, LP_TP_WPA_NO, LP_TP_SSI_NO, 8'h0, tx_out_ACK_stream_q};

				tx_out_ACK_ack <= 1 ;
			end 
			else if ( tx_STATUS_ACK ) begin
				tx_state <= ST_TX_STATUS_ACK ;
				tx_hp    <= 1 ;					

				hp_word_0 <= {	dev_address, LP_TP_ROUTE0, LP_TYPE_TP};
				hp_word_1 <= {	tx_STATUS_ACK_TPF,5'h0, tx_STATUS_ACK_seq, tx_STATUS_ACK_nump, 
								1'b0, tx_STATUS_ACK_TT , tx_STATUS_ACK_endp, tx_STATUS_ACK_dir, tx_STATUS_ACK_retry, 2'h0, tx_STATUS_ACK_subtype};
				hp_word_2 <= {	LP_TP_NBI_0, LP_TP_PPEND_NO, LP_TP_DBI_NO, LP_TP_WPA_NO, LP_TP_SSI_NO, 8'h0, tx_STATUS_ACK_stream};
				
				tx_STATUS_ACK_ack <= 1 ;					
			end
			else if ( tx_out_RETRY ) begin
				tx_state <= ST_TX_OUT_RETRY ;
				tx_hp    <= 1 ;		

				hp_word_0 <= {	dev_address, LP_TP_ROUTE0, LP_TYPE_TP};
				hp_word_1 <= {	6'h0, tx_out_RETRY_seq, tx_out_RETRY_nump, 
								1'b0, tx_out_RETRY_TT, tx_out_RETRY_endp, tx_out_RETRY_dir, tx_out_RETRY_retry, 2'h0, tx_out_RETRY_subtype};
				hp_word_2 <= {	LP_TP_NBI_0, LP_TP_PPEND_NO, LP_TP_DBI_NO, LP_TP_WPA_NO, LP_TP_SSI_NO, 8'h0, tx_out_RETRY_stream};

				tx_out_RETRY_ack <= 1 ;
			end
			else if ( (!tx_DP) & (!tx_0_DP) & (!tx_PING_RESP_empty) )	begin
				tx_state <= ST_TX_PING_RESP	 ;							
				tx_hp <= 1 ;

				hp_word_0 <= {	dev_address, LP_TP_ROUTE0, LP_TYPE_TP};
				hp_word_1 <= {	6'h0, tx_PING_RESP_seq_q, tx_PING_RESP_nump_q, 
								1'b0, 3'h0, tx_PING_RESP_endp_q, tx_PING_RESP_dir_q, tx_PING_RESP_retry_q, 2'h0, tx_PING_RESP_subtype_q};
				hp_word_2 <= {	LP_TP_NBI_0, LP_TP_PPEND_NO, LP_TP_DBI_NO, LP_TP_WPA_NO, LP_TP_SSI_NO, 8'h0, tx_PING_RESP_stream_q};
				
				tx_PING_RESP_ack <= 1 ;					
			end
			else if ( tx_STALL ) begin
				tx_state <= ST_TX_STALL ;
				tx_hp 	 <= 1 ;

				hp_word_0 <= {	dev_address, LP_TP_ROUTE0, LP_TYPE_TP};
				hp_word_1 <= {	6'h0, tx_STALL_seq, tx_STALL_nump, 
								1'b0, 3'h0, tx_STALL_endp, tx_STALL_dir, tx_STALL_retry, 2'h0, tx_STALL_subtype};
				hp_word_2 <= {	LP_TP_NBI_0, LP_TP_PPEND_NO, LP_TP_DBI_NO, LP_TP_WPA_NO, LP_TP_SSI_NO, 8'h0, tx_STALL_stream};
				
				tx_STALL_ack <= 1 ;	
			end
			else if ( tx_rx_sublink_speed_device_noti ) begin
				tx_state <= ST_TX_RX_SSD_NOTI ;
				tx_hp 	 <= 1 ;

				hp_word_0 <= {	dev_address, LP_TP_ROUTE0, LP_TYPE_TP};
				hp_word_1 <= {	1'b1, 23'b0, NOTI_SUBLINK_SPEED, LP_TP_SUB_DEVNOTIFY};
				hp_word_2 <= {	LANE_SPEED_MANTISSA,LP,LANE_COUNT_1,2'b00,SUBLINK_TYPE_SYM_RX_MODE,LANE_SPEED_EX_G,4'b0};
				
				tx_rx_sublink_speed_device_noti_ack <= 1 ;					
			end
			else if ( tx_tx_sublink_speed_device_noti ) begin
				tx_state <= ST_TX_TX_SSD_NOTI ;
				tx_hp 	 <= 1 ;

				hp_word_0 <= {	dev_address, LP_TP_ROUTE0, LP_TYPE_TP};
				hp_word_1 <= {	1'b0, 23'b0, NOTI_SUBLINK_SPEED, LP_TP_SUB_DEVNOTIFY};
				hp_word_2 <= {	LANE_SPEED_MANTISSA,LP,LANE_COUNT_1,2'b00,SUBLINK_TYPE_SYM_TX_MODE,LANE_SPEED_EX_G,4'b0};
				
				tx_tx_sublink_speed_device_noti_ack <= 1 ;					
			end			
		end	
		ST_TX_IN_NRDY:begin
			tx_in_NRDY_ack <= 0 ;
			if ( tx_hp_ack ) begin
				tx_state <= ST_TX_IDLE ;  
				tx_hp <= 0 ; 
			end
		end
		ST_TX_OUT_NRDY:begin
			tx_out_NRDY_ack <= 0 ;
			if ( tx_hp_ack ) begin
				tx_state <= ST_TX_IDLE ;  
				tx_hp <= 0 ; 
			end
		end
		ST_TX_IN_ERDY:begin
			tx_in_ERDY_ack <= 0 ;
			if ( tx_hp_ack ) begin
				tx_state <= ST_TX_IDLE ;  
				tx_hp <= 0 ; 
			end			
		end
		ST_TX_OUT_ERDY:begin
			tx_out_ERDY_ack <= 1 ; 
			if ( tx_hp_ack ) begin
				tx_state <= ST_TX_IDLE ;  
				tx_hp <= 0 ; 
			end			
		end
		ST_TX_OUT_ACK:begin
			tx_out_ACK_ack <= 0 ;
			if ( tx_hp_ack ) begin
				tx_state <= ST_TX_IDLE ;  
				tx_hp <= 0 ; 
			end				
		end
		ST_TX_STATUS_ACK:begin
			tx_STATUS_ACK_ack <= 0 ;
			if ( tx_hp_ack ) begin
				tx_state <= ST_TX_IDLE ;  
				tx_hp <= 0 ; 
			end	
		end
		ST_TX_OUT_RETRY:begin
			tx_out_RETRY_ack <= 0 ;
			if ( tx_hp_ack ) begin
				tx_state <= ST_TX_IDLE ;  
				tx_hp <= 0 ; 
			end				
		end
		ST_TX_STALL:begin
			tx_STALL_ack <= 0 ;
			if ( tx_hp_ack ) begin
				tx_state <= ST_TX_IDLE ;  
				tx_hp <= 0 ; 
			end	
		end
		ST_TX_PING_RESP:begin
			tx_PING_RESP_ack <= 0 ;
			if ( tx_hp_ack ) begin
				tx_state <= ST_TX_IDLE ;  
				tx_hp <= 0 ; 
			end				
		end
		ST_TX_RX_SSD_NOTI:begin
			tx_rx_sublink_speed_device_noti_ack <= 0 ;
			if ( tx_hp_ack ) begin
				tx_state <= ST_TX_IDLE ;  
				tx_hp <= 0 ; 
			end				
		end
		ST_TX_TX_SSD_NOTI:begin
			tx_tx_sublink_speed_device_noti_ack <= 0 ;
			if ( tx_hp_ack ) begin
				tx_state <= ST_TX_IDLE ;  
				tx_hp <= 0 ; 
			end							
		end
		default:;
		endcase 
	end
end

////////////////////////////////////////////////////////////
//
// ENDPOINT 0 IN/OUT
//
////////////////////////////////////////////////////////////
always @ ( posedge local_clk or negedge reset_n ) begin
   if (!reset_n ) begin
      ep_rst_n <= 0 ;
   end
   else begin
      ep_rst_n <= 1 ;
   end
end

usb3_ep0
usb3_ep0_inst 
(
	 .local_clk			( local_clk )
	,.reset_n			( ep_rst_n & !warm_or_hot_reset )
	
	,.set_device_low_power_state ( set_device_low_power_state )
	,.set_device_low_power_state_ack ( set_device_low_power_state_ack )
	
	
	,.ltssm_state		(ltssm_state)
	
	,.buf_in_data		   ( buf_in_data_mem 		   [0])
	,.buf_in_wren		   ( buf_in_wren_mem 		   [0])
   ,.buf_in_lpf         ( transfer_out_lpf         [0])
	,.buf_in_ready		   ( buf_in_ready_mem 		   [0])
	,.buf_in_commit      ( buf_in_commit_mem 	      [0])
	,.buf_in_commit_len  ( buf_in_commit_len_mem    [0])
   ,.rx_dpp_crcgood     ( rx_dpp_crcgood & !dpp_end_abort_det  )
	
	,.buf_out_q							( buf_out_q_mem 		[0] )
	,.buf_out_len						( buf_out_len_mem		[0] )
	,.buf_out_last						( buf_out_last_mem      [0] )
	,.buf_out_hasdata					( buf_out_has_data_mem 	[0] )
	,.buf_out_arm						( buf_out_arm_mem 		[0] )
	,.buf_out_rden						( buf_out_rden_mem		[0] )
    ,.buf_out_payload_empty 		    ( buf_out_payload_empty_mem  [0] ) // output 	
	
	,.reset_dp_seq		(  )
	
	,.buf_out_dp_acked	( buf_out_dp_acked[0] )
	,.in_ep_rty			   ( in_state[0] == ST_IN_RTY )
	
	
	// external interface 
   ,.transfer_in_mem_wr             (transfer_in_mem_wr        [0]) //input              
   ,.transfer_in_mem_wr_mask        (transfer_in_mem_wr_mask   [0]) //input   [3:0]  
   ,.transfer_in_mem_wr_addr        (transfer_in_mem_wr_addr   [0]) //input   [13:0] 
   ,.transfer_in_mem_wr_data        (transfer_in_mem_wr_data   [0]) //input   [31:0] 	 	
   ,.transfer_in_mem_commit         (transfer_in_mem_commit    [0]) //input          	
   ,.transfer_in_mem_commit_len     (transfer_in_mem_commit_len[0]) //input   [15:0] 
   ,.transfer_in_mem_ready          (transfer_in_mem_ready     [0]) //output         
   ,.transfer_in_done               (transfer_in_done          [0]) //output         
   ,.transfer_in_mem_empty          (transfer_in_mem_empty     [0]) //output         

	
   ,.transfer_out_mem_has_data     (transfer_out_mem_has_data[0]) // output          
   ,.transfer_out_mem_len          (transfer_out_mem_len     [0]) // output  [15:0] 
   ,.transfer_out_mem_rd_addr      (transfer_out_mem_rd_addr [0]) // input   [13:0] 
   ,.transfer_out_mem_rd_data      (transfer_out_mem_rd_data [0]) // output  [31:0] 
   ,.transfer_out_mem_clr          (transfer_out_mem_clr     [0]) // input          
	
	
	// requests

	,.request_active 			         (request_active 	)
	,.bmRequestType			         (bmRequestType  	)
	,.bRequest				            (bRequest	   	)
	,.wValue			                  (wValue		 	)
	,.wIndex			                  (wIndex		 	)
	,.wLength				            (wLength		 	)
	,.wait_user_commit_request			(wait_user_commit_request	)
	,.request_commit   					(request_commit   			)	
		
	
	,.set_address 					      (set_address)
	,.dev_address                    (dev_address_q)
	,.set_address_ack				      (set_address_ack)

	,.enter_status_stage			      (enter_status_stage)
	,.ep0_stall						      (ep_0_stall)
);

////////////////////////////////////////////////////////////
//
// ENDPOINT 1 ~ 15  IN
//
////////////////////////////////////////////////////////////
generate 
   for ( i = 1 ; i < 16 ; i ++ ) begin : gen_in_ep_ping_pong
      if ( IN_EP_DEF[i] == 1 ) begin
		transfer_in_mem_ping_pong      
         #(
            .TRANSFER_MAX_SIZE           (IN_EP_TRANSFER_MAX_SIZE[i])   
            ,.TRANSFER_EDNPT_TYPE        (IN_EP_TYPE[i]) 
            ,.TRANSFER_MEM_PP_NUM        (IN_EP_MEM_PP_NUM[i]) 
         )
         transfer_in_mem_ping_pong_inst
         (
             .clk          (local_clk) //input  
            ,.rst_n        (ep_rst_n & !warm_or_hot_reset  ) //input  
               
            ,.transfer_in_mem_wr          (transfer_in_mem_wr        [i]) // input          
            ,.transfer_in_mem_wr_mask     (transfer_in_mem_wr_mask   [i]) // input  [3:0]   
            ,.transfer_in_mem_wr_addr     (transfer_in_mem_wr_addr   [i]) // input  [13:0]  
            ,.transfer_in_mem_wr_data     (transfer_in_mem_wr_data   [i]) // input  [31:0]  
            ,.transfer_in_mem_commit      (transfer_in_mem_commit    [i]) // input          
            ,.transfer_in_mem_commit_len  (transfer_in_mem_commit_len[i]) // input  [15:0]  
            ,.transfer_in_mem_ready       (transfer_in_mem_ready     [i]) // output          
            ,.transfer_in_done            (transfer_in_done          [i]) // output    
            ,.transfer_in_mem_empty       (transfer_in_mem_empty     [i]) // output 
            
            
            
            ,.transfer_in_pkt_ready       	(buf_out_has_data_mem[i]   ) //output           
            ,.transfer_in_pkt_len         	(buf_out_len_mem     [i]   ) //output   [10:0]  
            ,.transfer_in_pkt_last        	(buf_out_last_mem    [i]   ) //output           
            ,.transfer_in_pkt_rd_en       	(buf_out_rden_mem    [i]   ) //input           
            ,.transfer_in_pkt_sent        	(buf_out_arm_mem     [i]   ) //input           
            ,.transfer_in_pkt_rd_data     	(buf_out_q_mem       [i]   ) //output   [63:0]  
			,.transfer_in_pkt_payload_empty (buf_out_payload_empty_mem[i] ) // output 
            
            ,.transfer_in_pkt_acked       (buf_out_dp_acked[i]  ) // input          
            ,.transfer_in_pkt_rty         (in_state[i] == ST_IN_RTY  ) // input     
			,.ep_in_pending				  (ep_in_pending[i]	)//    
            
         );
      end
   end
endgenerate

////////////////////////////////////////////////////////////
//
// ENDPOINT 1 ~ 15  OUT
//
////////////////////////////////////////////////////////////
generate 
   for ( i = 1 ; i < 16 ; i ++ ) begin : gen_out_ep_ping_pong
      if ( OUT_EP_DEF[i] == 1 ) begin
		transfer_out_mem_ping_pong		
         #(
             .TRANSFER_MAX_SIZE           (OUT_EP_TRANSFER_MAX_SIZE[i])   
            ,.TRANSFER_EDNPT_TYPE         (OUT_EP_TYPE[i]) 
            ,.TRANSFER_MEM_PP_NUM         (OUT_EP_MEM_PP_NUM[i]) 
         )transfer_out_mem_ping_pong
         (
             .clk    (local_clk) //input  
            ,.rst_n  (ep_rst_n & !warm_or_hot_reset  ) //input  
         
            ,.transfer_out_mem_wr            (buf_in_wren_mem[i]      ) //input          
            ,.transfer_out_mem_wr_data       (buf_in_data_mem[i]      ) //input  [63:0]  
            ,.transfer_out_mem_commit        (buf_in_commit_mem[i]    ) //input          
            ,.transfer_out_mem_commit_len    (buf_in_commit_len_mem[i]) //input  [15:0]  
            ,.transfer_out_mem_lpf           (transfer_out_lpf[i] ) //input          
            ,.transfer_out_mem_ready         (buf_in_ready_mem[i]) //output        
			,.transfer_out_mem_discard       (buf_in_discard_mem[i]) // input
            
            ,.transfer_out_mem_has_data      (transfer_out_mem_has_data[i]) //output          
            ,.transfer_out_mem_len           (transfer_out_mem_len     [i]) //output  [15:0]  
            ,.transfer_out_mem_rd_addr       (transfer_out_mem_rd_addr [i]) //input   [13:0]  
            ,.transfer_out_mem_rd_data       (transfer_out_mem_rd_data [i]) //output  [63:0]  
            ,.transfer_out_mem_clr           (transfer_out_mem_clr     [i]) //input           
            
         );
      end
   end
endgenerate


//debug
reg ep2_send_ack;
always @ ( posedge local_clk or negedge reset_n ) begin
	if ( !reset_n  ) begin
		ep2_send_ack <= 0 ;
	end
	else begin
		ep2_send_ack <= 0 ;
		if ( ep_out_send_ACK [2] ) begin
			ep2_send_ack <= 1;
		end
	end
end

reg ep2_send_NRDY;
always @ ( posedge local_clk or negedge reset_n ) begin
	if ( !reset_n  ) begin
		ep2_send_NRDY <= 0 ;
	end
	else begin
		ep2_send_NRDY <= 0 ;
		if ( ep_out_send_NRDY [2] ) begin
			ep2_send_NRDY <= 1;
		end
	end
end

reg ep2_send_RTY;
always @ ( posedge local_clk or negedge reset_n ) begin
	if ( !reset_n  ) begin
		ep2_send_RTY <= 0 ;
	end
	else begin
		ep2_send_RTY <= 0 ;
		if ( ep_out_send_RETRY [2] ) begin
			ep2_send_RTY <= 1;
		end
	end
end

reg [3:0] ep2_send_RTY_pending_cnt ;
always @ ( posedge local_clk or negedge reset_n ) begin
	if ( !reset_n  ) begin
		ep2_send_RTY_pending_cnt <= 0 ;
	end
	else if ( ep2_send_RTY ) begin
		ep2_send_RTY_pending_cnt <= ep2_send_RTY_pending_cnt + 1 ;
	end
	else begin
		ep2_send_RTY_pending_cnt <= 0 ;
	end
end

reg ep_2_in_pending = 0;
always @ ( posedge local_clk  ) begin
	ep_2_in_pending <= ep_in_pending[2] ;
end

reg wt_dpp ;
always @ ( posedge local_clk or negedge reset_n ) begin
	if ( !reset_n  ) begin
		wt_dpp <= 0 ;
	end
	else if ( out_state[2] == ST_WT_RX_DP_DONE ) begin
		wt_dpp <= 1 ;
	end
	else begin
		wt_dpp <= 0 ;
	end
end

reg [7:0] wt_dpp_done_cnt ;
always @ ( posedge local_clk or negedge reset_n ) begin
	if ( !reset_n  ) begin
		wt_dpp_done_cnt <= 0 ;
	end
	else if ( wt_dpp ) begin
		wt_dpp_done_cnt <= wt_dpp_done_cnt + 1 ;
	end
	else begin
		wt_dpp_done_cnt <= 0 ;
	end
end

reg wt_dpp_done_timeout ;
always @ ( posedge local_clk or negedge reset_n ) begin
	if ( !reset_n  ) begin
		wt_dpp_done_timeout <= 0 ;
	end
	else if ( wt_dpp_done_cnt >= 150 ) begin
		wt_dpp_done_timeout <= 1  ;
	end
end


reg [15:0] in_ep_rx_AKC  ;
generate
	for ( i = 0 ; i < 16 ; i = i + 1 ) begin
		always @( posedge local_clk  or negedge reset_n ) begin
			if (!reset_n) begin
				in_ep_rx_AKC [i] <= 0 ;	
			end
			else if ( rx_tp && rx_tp_endp == i && rx_tp_subtype == LP_TP_SUB_ACK  ) begin
				in_ep_rx_AKC [i] <= 1 ;
			end
			else begin
				in_ep_rx_AKC [i] <= 0 ;
			end
		end		
	end 
endgenerate




endmodule


module hp_buffer 
#(
	 parameter DQ_WIDTH  = 10
	,parameter PT_WIDTH  = 2
	,parameter BUF_DEPTH = 4
)
(
	 input 	wire 				local_clk    
	,input 	wire 				reset_n  
	,input 	wire [DQ_WIDTH-1:0] hp_d 
	,input 	wire 				hp_push
	,input  wire            	hp_pop
	,output reg  [DQ_WIDTH-1:0] hp_q
	,output reg  				hp_empty
);

reg [PT_WIDTH-1:0] rd_pt ;
reg [PT_WIDTH-1:0] wr_pt ;
reg [DQ_WIDTH-1:0] mem [0:BUF_DEPTH-1] ;


always @ ( posedge local_clk  ) begin
	if ( !reset_n ) begin
		rd_pt <= 0 ;
		wr_pt <= 0 ;
		hp_empty <= 1 ; 
	end
	else begin
		if ( hp_push ) begin
			wr_pt <= wr_pt + 1 ;
		end
		
		if ( hp_pop ) begin
			rd_pt <= rd_pt + 1 ;
		end 
		
		if ( wr_pt == rd_pt ) begin
			hp_empty <= 1 ;
		end
		else begin
			hp_empty <= 0 ; 
		end	
	end
end

always @ ( posedge local_clk  ) begin	
	hp_q	<= mem [rd_pt] ;
end

always @ ( posedge local_clk  ) begin
	if ( hp_push ) begin
		mem [wr_pt] <=  hp_d ;
	end	
end

endmodule 
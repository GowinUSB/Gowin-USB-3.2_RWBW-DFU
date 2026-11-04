// Copyright (c) 2026 GOWIN SEMICONDUCTOR CORPORATION.
// SPDX-License-Identifier: MIT
module top
(
	 input           	fclk
    ,input           	sys_clk_p
    ,input           	sys_clk_n
    ,output          	clk_200M_P
    ,output          	clk_200M_N
	,inout	    	 	scl				// FUSB302BMPX USB_CC_SCL
	,inout	    	 	sda				// FUSB302BMPX USB_CC_SDA
	,input 		     	fusb_int_n		// FUSB302BMPX USB_CC_INT_L
	
	,output wire 		USB_PWR_EN

	,input wire 		USB_PULLUP_EN
	,input wire 		USB_TERM_DP 
	,input wire 		USB_TERM_DN 
	,input wire 		USB_RX_DP 
	,input wire 		USB_RX_DN 
	,input wire 		USB_TX_DP 
	,input wire 		USB_TX_DN 
	,input wire 		USB_DN 
	,input wire 		USB_D 
	,input wire 		USB_DP 

	,output 			led1 

//SPI
    ,output     		spi_sclk 
    ,output     		spi_cs 
    ,output     		spi_mosi 
    ,input      		spi_miso

);

assign USB_PWR_EN = 1'b0;

reg     [7:0]   cnt0 = 0;
reg     [15:0]  cnt1 = 0;
reg     [15:0]  cnt2 = 0;
reg     [31:0]  cnt3 = 0;
reg     [31:0]  cnt4 = 0;
reg     [7:0]   cnt5 = 0;
reg		[7:0]	key_resetn_r = 8'b11111111;
reg            	phy_resetn = 0;
reg            	phy_resetn2 = 0;
wire            phy_resetn_o;
wire            pclk/* synthesis syn_keep = 1 */;
reg				led1_r = 1'b0;
reg				led2_r = 1'b0;
wire	[1:0]	cc_orient;

wire	[2:0]	RxStatus;
wire			PhyStatus;
wire			phy_pipe_half_clk;        // 125MHz:  1/2 PCLK
wire			phy_pipe_half_clk_phase;  // 125MHz:  1/2 PCLK, phase shift 90
wire			phy_pipe_quarter_clk;     // 62.5MHz: 1/4 PCLK
wire	[3:0]	phy_pipe_rx_data_k;
wire	[63:0]	phy_pipe_rx_data;
wire	[3:0]	phy_pipe_rx_sync_head;
wire	        phy_pipe_rx_start_block;
wire	     	phy_pipe_rx_valid;
wire			phy_pipe_rx_valid_o;
wire	[3:0]	phy_pipe_tx_data_k;
wire	[63:0]	phy_pipe_tx_data;
wire	[3:0]	phy_pipe_tx_sync_head;
wire	        phy_pipe_tx_start_block;
wire	        phy_pipe_tx_valid;
wire			phy_reset_n;
wire			phy_out_enable;
wire			phy_phy_reset_n;
wire			phy_tx_detrx_lpbk;
wire			phy_tx_elecidle;
wire			phy_rx_elecidle;
wire	[2:0]	phy_rx_status;
wire	[1:0]	phy_power_down;
wire	[1:0]	phy_phy_status_i;
wire	        phy_phy_status_o;
wire			phy_phy_status;
wire			phy_pwrpresent;
wire	[1:0]	phy_tx_deemph;
wire	[2:0]	phy_tx_margin;
wire			phy_tx_swing;
wire			phy_rx_polarity;
wire			phy_rx_termination;
wire			phy_rate;
wire			phy_elas_buf_mode;
wire    [4:0]   phy_tx_fifo_wr_num;
wire			phy_serdes_pll_lock;

wire			request_active 	         ;
wire	[7:0]	bmRequestType	         ;
wire	[7:0]	bRequest		         ;
wire	[15:0]	wValue			         ;
wire	[15:0]	wIndex			         ;
wire	[15:0]	wLength		             ;
wire			wait_user_commit_request ; 
wire        	request_commit  		 ;	


wire 				warm_or_hot_reset ;
wire  				host_requests_data_from_endpt [0:15];  
wire  [3:0] 		host_requests_endpt_num;
wire				itp_received ;
wire				attached ;

logic		dfu_mode;


wire        transfer_in_mem_wr          [0:15]   ;
wire [7:0]  transfer_in_mem_wr_mask     [0:15]   ;
wire [13:0] transfer_in_mem_wr_addr     [0:15]   ;
wire [63:0] transfer_in_mem_wr_data     [0:15]   ;
wire        transfer_in_mem_commit      [0:15]   ;
wire [16:0] transfer_in_mem_commit_len  [0:15]   ;
wire        transfer_in_mem_ready       [0:15]   ;
wire        transfer_in_done            [0:15]   ;
wire        transfer_in_mem_empty       [0:15]   ;


wire        transfer_out_mem_has_data   [0:15]  ;  
wire [16:0] transfer_out_mem_len        [0:15]  ;
wire [13:0] transfer_out_mem_rd_addr    [0:15]  ;
wire [63:0] transfer_out_mem_rd_data    [0:15]  ;
wire        transfer_out_mem_clr        [0:15]  ;

wire CCSelect = !cc_orient[1];


assign led1 = led1_r;

wire sys_clk;
wire clk_200M ;
wire lock;
//=================================================================
//USB2

//=================================================================
//osc
TLVDS_IBUF Inst_sys_clk_in(
	.O(sys_clk),
	.I(sys_clk_p),
	.IB(sys_clk_n)
);

//===================================================================
//Serdes reference clock 
ELVDS_OBUF Inst_ref_clk_out(
.O(clk_200M_P),
.OB(clk_200M_N),
.I( sys_clk )
);

//===================================================================
//USB PHY power up reset 
reg cnt4_clr = 0 ;
always@(posedge pclk)
begin
	if ( cnt4_clr ) begin
		cnt4	<= 32'd0;
	end
	else begin
		cnt4	<= cnt4 + 1'b1;
	end	
end

always@(posedge pclk)
begin
	if ( cnt4 >= 125000000 ) begin
		cnt4_clr <= 1 ;		
	end
	else begin
		cnt4_clr <= 0 ;
	end
end

always@(posedge cnt4_clr ) 
begin
	led1_r	<= ~led1_r ;
end



reg sys_rst_n ;

always@(posedge sys_clk)
begin
	if(cnt0 < 255)
	begin
		cnt0                <= cnt0 + 1'b1;
	end
	else
	begin
		cnt0                <= cnt0;
	end
	
	if(cnt0 == 255)
	begin
		phy_resetn <= 1'b1;
		sys_rst_n <= 1 ;
	end
	else
	begin
		phy_resetn <= 1'b0;
		sys_rst_n <= 0 ;
	end
end


always@(posedge sys_clk or negedge sys_rst_n)
begin
	if(!sys_rst_n) begin
		cnt1 <= 32'd0;
	end
	else begin
		if(cnt1 < 65535)
		begin
			cnt1                <= cnt1 + 1'b1;
		end
		else
		begin
			cnt1                <= cnt1;
		end

		if(cnt1 == 65535)
		begin
			phy_resetn2 <= 1'b1;
		end
		else
		begin
			phy_resetn2 <= 1'b0;
		end
	end
end
//===============================================================
//CC chip controller for VBUS detection 
`ifndef SIM
gw_i2c_master cc_ctrl_inst (
    .clk_125m		(fclk),
    .rst_n			(phy_resetn),
    .scl			(scl),
	.scl_pull		(),
    .sda			(sda),
	.sda_pull		(),	
    .error_flag		(),
    .cstate_flag	(),
    .interupt		(),
	.vbus			(phy_pwrpresent),
	.cc_orient		(cc_orient),
	.i_fusb_int_n	(fusb_int_n)
);
assign USB_PWR_EN = 1'b0;
`endif

//==========================================================================================
//USB PHY
`ifndef SIM
SerDes_Top SerDes_Top_inst(
	.USB3_2_PHY_Top_pclk(pclk), //output USB3_2_PHY_Top_pclk
	.USB3_2_PHY_Top_PipeRxSyncHead_phy0(phy_pipe_rx_sync_head), //output [3:0] USB3_2_PHY_Top_PipeRxSyncHead_phy0
	.USB3_2_PHY_Top_PipeRxStartBlock_phy0(phy_pipe_rx_start_block), //output USB3_2_PHY_Top_PipeRxStartBlock_phy0
	.USB3_2_PHY_Top_PipeRxData_phy0(phy_pipe_rx_data), //output [63:0] USB3_2_PHY_Top_PipeRxData_phy0
	.USB3_2_PHY_Top_PipeRxDataValid_phy0(phy_pipe_rx_valid), //output USB3_2_PHY_Top_PipeRxDataValid_phy0
	.USB3_2_PHY_Top_PipeRxDataK_phy0(phy_pipe_rx_data_k), //output [3:0] USB3_2_PHY_Top_PipeRxDataK_phy0
	.USB3_2_PHY_Top_RxElecIdle_phy0(phy_rx_elecidle), //output USB3_2_PHY_Top_RxElecIdle_phy0
	.USB3_2_PHY_Top_RxStatus_phy0(phy_rx_status), //output [2:0] USB3_2_PHY_Top_RxStatus_phy0
	.USB3_2_PHY_Top_PhyStatus_phy0(phy_phy_status), //output USB3_2_PHY_Top_PhyStatus_phy0
	.USB3_2_PHY_Top_PowerPresent_phy0(phy_power_present), //output USB3_2_PHY_Top_PowerPresent_phy0
	.USB3_2_PHY_Top_TxFifoWrNum_phy0(phy_tx_fifo_wr_num), //output [4:0] USB3_2_PHY_Top_TxFifoWrNum_phy0
	.por_n_i(phy_resetn2), //input por_n_i
	.USB3_2_PHY_Top_phy_resetn_phy0(phy_resetn_o), //input USB3_2_PHY_Top_phy_resetn_phy0
	.USB3_2_PHY_Top_CCSelect(CCSelect), //input USB3_2_PHY_Top_CCSelect
	.USB3_2_PHY_Top_PipeTxDataValid_phy0(phy_pipe_tx_valid), //input USB3_2_PHY_Top_PipeTxDataValid_phy0
	.USB3_2_PHY_Top_PipeTxSyncHead_phy0(phy_pipe_tx_sync_head), //input [3:0] USB3_2_PHY_Top_PipeTxSyncHead_phy0
	.USB3_2_PHY_Top_PipeTxStartBlock_phy0(phy_pipe_tx_start_block), //input USB3_2_PHY_Top_PipeTxStartBlock_phy0
	.USB3_2_PHY_Top_PipeTxData_phy0(phy_pipe_tx_data), //input [63:0] USB3_2_PHY_Top_PipeTxData_phy0
	.USB3_2_PHY_Top_PipeTxDataK_phy0(phy_pipe_tx_data_k), //input [3:0] USB3_2_PHY_Top_PipeTxDataK_phy0
	.USB3_2_PHY_Top_TxDetectRx_loopback_phy0(phy_tx_detrx_lpbk), //input USB3_2_PHY_Top_TxDetectRx_loopback_phy0
	.USB3_2_PHY_Top_TxElecIdle_phy0(phy_tx_elecidle), //input USB3_2_PHY_Top_TxElecIdle_phy0
	.USB3_2_PHY_Top_TxSwing_phy0(1'b0), //input USB3_2_PHY_Top_TxSwing_phy0
	.USB3_2_PHY_Top_TxMargin_phy0(3'b000), //input [2:0] USB3_2_PHY_Top_TxMargin_phy0
	.USB3_2_PHY_Top_TxDeemph_phy0(12'b000000_001000), //input [11:0] USB3_2_PHY_Top_TxDeemph_phy0
	.USB3_2_PHY_Top_RxPolarity_phy0(phy_rx_polarity), //input USB3_2_PHY_Top_RxPolarity_phy0
	.USB3_2_PHY_Top_RxTermination_phy0(phy_rx_termination), //input USB3_2_PHY_Top_RxTermination_phy0
	.USB3_2_PHY_Top_PowerDown_phy0(phy_power_down), //input [1:0] USB3_2_PHY_Top_PowerDown_phy0
	.USB3_2_PHY_Top_ElasticityBufferMode_phy0(phy_elas_buf_mode), //input USB3_2_PHY_Top_ElasticityBufferMode_phy0
	.USB3_2_PHY_Top_Rate_phy0(phy_rate), //input USB3_2_PHY_Top_Rate_phy0
	.USB3_2_PHY_Top_LTSSM_is_Training_phy0(phy_ltssm_is_training) //input USB3_2_PHY_Top_LTSSM_is_Training_phy0
);

//sim model
`else 
USB_3_2_PHY_SIM_MODEL USB_3_2_PHY_SIM_MODEL_inst
(			
	 .USB3_1_PHY_Top_pclk					(pclk) // output 	 			
	,.USB3_1_PHY_Top_PipeRxDataK			(phy_pipe_rx_data_k) // output 	 [3:0] 	
	,.USB3_1_PHY_Top_PipeRxData				(phy_pipe_rx_data) // output 	 [63:0] 	
	,.USB3_1_PHY_Top_PipeRxSyncHead			(phy_pipe_rx_sync_head) // output 	 [3:0] 		
	,.USB3_1_PHY_Top_PipeRxStartBlock		(phy_pipe_rx_start_block) // output 	 			
	,.USB3_1_PHY_Top_PipeRxDataValid		(phy_pipe_rx_valid) // output 	 			
	,.USB3_1_PHY_Top_RxElecIdle				(phy_rx_elecidle) // output 	 			
	,.USB3_1_PHY_Top_RxStatus				(phy_rx_status) // output 	 [2:0]		
	,.USB3_1_PHY_Top_PhyStatus				(phy_phy_status) // output 	 			
	,.USB3_1_PHY_Top_PowerPresent			(phy_pwrpresent) // output 	 			
	,.USB3_1_PHY_Top_phy_resetn				(phy_resetn_o) // input 	 			
	,.USB3_1_PHY_Top_PipeTxDataK			(phy_pipe_tx_data_k) // input 	 [3:0] 			
	,.USB3_1_PHY_Top_PipeTxData				(phy_pipe_tx_data) // input 	 [63:0] 					
	,.USB3_1_PHY_Top_PipeTxSyncHead			(phy_pipe_tx_sync_head) // input 	 [3:0] 							
	,.USB3_1_PHY_Top_PipeTxStartBlock		(phy_pipe_tx_start_block) // input 	 				
	,.USB3_1_PHY_Top_PipeTxDataValid		(phy_pipe_tx_valid) // input 	 						
	,.USB3_1_PHY_Top_TxDetectRx_loopback	(phy_tx_detrx_lpbk) // input 	 					
	,.USB3_1_PHY_Top_TxElecIdle				(phy_tx_elecidle) // input 	 				
	,.USB3_1_PHY_Top_RxPolarity				(phy_rx_polarity) // input 	 				
	,.USB3_1_PHY_Top_RxTermination			(phy_rx_termination) // input 	 				
	,.USB3_1_PHY_Top_PowerDown				(phy_power_down) // input 	 [1:0] 		
	,.USB3_1_PHY_Top_ElasticityBufferMode	(phy_elas_buf_mode) // input 	 									
	,.USB3_1_PHY_Top_TxFifoWrNum			(phy_tx_fifo_wr_num) // output 	 [4:0] 								
	,.USB3_1_PHY_Top_Rate                   (phy_rate)           // input
);

`endif 

//==========================================================================================
//USB Controller
USB3_2_Device_Controller_Top USB3_2_Device_Controller_Top_inst (
	.phy_clk_i						(pclk)//input	wire			
	,.reset_n_i						(phy_resetn )//input	wire			
	,.phy_pipe_rx_data_k_i			(phy_pipe_rx_data_k)//input	wire	[3:0]	
	,.phy_pipe_rx_data_i			(phy_pipe_rx_data)//input	wire	[63:0]	
	,.phy_pipe_rx_sync_head_i		(phy_pipe_rx_sync_head)//input	wire	[3:0]	
	,.phy_pipe_rx_start_block_i		(phy_pipe_rx_start_block)//input	wire	[3:0]	
	,.phy_pipe_rx_valid_i			(phy_pipe_rx_valid)//input	wire	[1:0]	
	,.phy_pipe_tx_data_k_o			(phy_pipe_tx_data_k)//output	wire	[3:0]	
	,.phy_pipe_tx_data_o			(phy_pipe_tx_data)//output	wire	[63:0]	
	,.phy_pipe_tx_sync_head_o		(phy_pipe_tx_sync_head)//output	wire	[3:0]	
	,.phy_pipe_tx_start_block_o		(phy_pipe_tx_start_block)//output	wire	[3:0]	
	,.phy_pipe_tx_valid_o			(phy_pipe_tx_valid)//output	wire	
	,.phy_reset_n_o					(phy_resetn_o)//output	wire								
	,.phy_tx_detrx_lpbk_o			(phy_tx_detrx_lpbk)//output	wire			
	,.phy_tx_elecidle_o				(phy_tx_elecidle	)//output	wire			
	,.phy_rx_elecidle_i				(phy_rx_elecidle	)//inout	wire			
	,.phy_rx_status_i				(phy_rx_status		)//input	wire	[2:0]	
	,.phy_power_down_o				(phy_power_down		)//output	wire	[1:0]	
	,.phy_phy_status_i				(phy_phy_status		)//input   wire		        
	// ,.phy_pwrpresent_i				(phy_pwrpresent		)//input	wire						
	,.phy_pwrpresent_i				(usb_logic_rstn		)//input	wire						
	,.phy_tx_deemph_o				(phy_tx_deemph		)//output	wire	[1:0]	
	,.phy_tx_margin_o				(phy_tx_margin		)//output	wire	[2:0]	
	,.phy_tx_swing_o				(phy_tx_swing		)//output	wire			
	,.phy_rx_polarity_o				(phy_rx_polarity	)//output	wire			
	,.phy_rx_termination_o			(phy_rx_termination	)//output	wire			
	,.phy_rate_o					(phy_rate			)//output	wire			
	,.phy_elas_buf_mode_o			(phy_elas_buf_mode	)//output	wire	
	,.phy_tx_fifo_wrnum_i           (phy_tx_fifo_wr_num)	
	,.phy_serdes_pll_lock_i         (phy_serdes_pll_lock) // output
	,.phy_ltssm_is_training_i       (phy_ltssm_is_training )


	// external interface
	
	,.warm_or_hot_reset_o 				( warm_or_hot_reset 			 ) 
	,.host_requests_data_from_endpt_o  	( host_requests_data_from_endpt	 )
	,.itp_received_o					( itp_received 					 )
	,.attached_o						( attached						 ) 

	// requests 
	,.request_active_o 			(request_active				)
	,.bmRequestType_o			(bmRequestType				)
	,.bRequest_o				(bRequest					)
	,.wValue_o					(wValue						)
	,.wIndex_o					(wIndex						)
	,.wLength_o					(wLength					)
	,.wait_user_commit_request_o(wait_user_commit_request	)
	,.request_commit_i			(request_commit				)  

			
	//IN  					
   ,.transfer_in_mem_wr_i          (transfer_in_mem_wr        )    
   ,.transfer_in_mem_wr_mask_i     (transfer_in_mem_wr_mask   )  
   ,.transfer_in_mem_wr_addr_i     (transfer_in_mem_wr_addr   )  	
   ,.transfer_in_mem_wr_data_i     (transfer_in_mem_wr_data   )  		 	
   ,.transfer_in_mem_commit_i      (transfer_in_mem_commit    )  		
   ,.transfer_in_mem_commit_len_i  (transfer_in_mem_commit_len)  	
   ,.transfer_in_mem_ready_o       (transfer_in_mem_ready     )  
   ,.transfer_in_done_o            (transfer_in_done          )
   ,.transfer_in_mem_empty_o       (transfer_in_mem_empty     )
	
	
	// OUT	
   ,.transfer_out_mem_has_data_o   (transfer_out_mem_has_data)     
   ,.transfer_out_mem_len_o        (transfer_out_mem_len     )  
   ,.transfer_out_mem_rd_addr_i    (transfer_out_mem_rd_addr )  
   ,.transfer_out_mem_rd_data_o    (transfer_out_mem_rd_data )  
   ,.transfer_out_mem_clr_i        (transfer_out_mem_clr     ) 
	
	


);

//====================================================================================
//USB Controller User layer 
UserLayer_top UserLayer_top_inst
(
	.pclk 			(pclk 	   )
	,.phy_resetn    (attached  )
	
	,.warm_or_hot_reset				 (warm_or_hot_reset            )
	,.host_requests_data_from_endpt  (host_requests_data_from_endpt)
	,.itp_received					 (itp_received				   )

	,.i_dfu_mode				(dfu_mode					)

	// requests
	,.request_active 		    (request_active				)
	,.bmRequestType	         	(bmRequestType				)
	,.bRequest		            (bRequest					)
	,.wValue			        (wValue						)
	,.wIndex			        (wIndex						)
	,.wLength		            (wLength					)
	,.wait_user_commit_request	(wait_user_commit_request	) 
	,.request_commit			(request_commit				) 

	//IN  
   ,.transfer_in_mem_wr          (transfer_in_mem_wr         )    
   ,.transfer_in_mem_wr_mask     (transfer_in_mem_wr_mask    )  
   ,.transfer_in_mem_wr_addr     (transfer_in_mem_wr_addr    )  	
   ,.transfer_in_mem_wr_data     (transfer_in_mem_wr_data    )  		 	
   ,.transfer_in_mem_commit      (transfer_in_mem_commit     )  		
   ,.transfer_in_mem_commit_len  (transfer_in_mem_commit_len )  	
   ,.transfer_in_mem_ready       (transfer_in_mem_ready      )  
   ,.transfer_in_done            (transfer_in_done           )
   ,.transfer_in_mem_empty       (transfer_in_mem_empty      )


	//OUT
   ,.transfer_out_mem_has_data  (transfer_out_mem_has_data)    
   ,.transfer_out_mem_len       (transfer_out_mem_len     ) 
   ,.transfer_out_mem_rd_addr   (transfer_out_mem_rd_addr ) 
   ,.transfer_out_mem_rd_data   (transfer_out_mem_rd_data ) 
   ,.transfer_out_mem_clr       (transfer_out_mem_clr     ) 
   
	,.spi_sclk					(spi_sclk					)
	,.spi_cs  					(spi_cs 					)
	,.spi_mosi					(spi_mosi					)
	,.spi_miso					(spi_miso					)
   
);

assign  dfu_detach_flag = UserLayer_top_inst.ControlTransfer_inst.o_dfu_detach_flag;



logic	[27:0]	disconnect_timer;
always @(posedge pclk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        dfu_mode         <= 1'b0;
        disconnect_timer <= 28'd0;
    end 
    else begin
        // 直接捕获来自 Control 模块的单拍触发脉冲
        if (dfu_detach_flag) begin
            dfu_mode         <= ~dfu_mode;          // 翻转 DFU/APP 模式
            disconnect_timer <= 28'd62_500_000;     // 500ms 强制断开时间
        end
        else if (disconnect_timer > 0) begin
            disconnect_timer <= disconnect_timer - 1'b1;
        end
    end
end

assign usb_logic_rstn = phy_pwrpresent && (disconnect_timer == 0);



endmodule

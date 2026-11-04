
module USB3_2_Device_Controller_Top
(

input	wire			phy_clk_i
,input	wire			reset_n_i

,input	wire	[3:0]	phy_pipe_rx_data_k_i
,input	wire	[63:0]	phy_pipe_rx_data_i
,input	wire	[3:0]	phy_pipe_rx_sync_head_i
,input	wire			phy_pipe_rx_start_block_i
,input	wire			phy_pipe_rx_valid_i
,output	wire	[3:0]	phy_pipe_tx_data_k_o
,output	wire	[63:0]	phy_pipe_tx_data_o
,output	wire	[3:0]	phy_pipe_tx_sync_head_o
,output	wire			phy_pipe_tx_start_block_o
,output	wire			phy_pipe_tx_valid_o

,output	wire			phy_reset_n_o
,output	wire			phy_tx_detrx_lpbk_o
,output	wire			phy_tx_elecidle_o
,input	wire			phy_rx_elecidle_i
,input	wire	[2:0]	phy_rx_status_i
,output	wire	[1:0]	phy_power_down_o
,input   wire	    	phy_phy_status_i
,input	wire			phy_pwrpresent_i

,output	wire	[1:0]	phy_tx_deemph_o
,output	wire	[2:0]	phy_tx_margin_o
,output	wire			phy_tx_swing_o
,output	wire			phy_rx_polarity_o
,output	wire			phy_rx_termination_o
,output	wire			phy_rate_o
,output	wire			phy_elas_buf_mode_o
,input	wire	[4:0]	phy_tx_fifo_wrnum_i
,input	wire			phy_serdes_pll_lock_i
,input  wire 			phy_ltssm_is_training_i



,output wire 		warm_or_hot_reset_o
,output wire  		host_requests_data_from_endpt_o  [0:15]
,output wire		itp_received_o
,output wire		attached_o


// requests
,output wire			request_active_o	
,output wire	[7:0]	bmRequestType_o	
,output wire	[7:0]	bRequest_o		
,output wire	[15:0]	wValue_o		
,output wire	[15:0]	wIndex_o			
,output wire	[15:0]	wLength_o		
,output wire			wait_user_commit_request_o
,input  wire        	request_commit_i  


//  IN  
,input  wire        transfer_in_mem_wr_i          [0:15]    
,input  wire [7:0]  transfer_in_mem_wr_mask_i     [0:15]  
,input  wire [13:0] transfer_in_mem_wr_addr_i     [0:15]  	
,input  wire [63:0] transfer_in_mem_wr_data_i     [0:15]  		 	
,input  wire        transfer_in_mem_commit_i      [0:15]  		
,input  wire [16:0] transfer_in_mem_commit_len_i  [0:15]  	
,output wire        transfer_in_mem_ready_o       [0:15]  
,output wire        transfer_in_done_o            [0:15]
,output wire        transfer_in_mem_empty_o       [0:15]

// OUT
,output wire        transfer_out_mem_has_data_o   [0:15]    
,output wire [16:0] transfer_out_mem_len_o        [0:15] 
,input  wire [13:0] transfer_out_mem_rd_addr_i    [0:15] 
,output wire [63:0] transfer_out_mem_rd_data_o    [0:15] 
,input  wire        transfer_out_mem_clr_i        [0:15]

		

);

usb3_2_device_controller
usb3_2_device_controller_inst (
	.phy_clk					(phy_clk_i)//input	wire			
	,.reset_n					(reset_n_i )//input	wire			
	,.phy_pipe_rx_data_k		(phy_pipe_rx_data_k_i)//input	wire	[3:0]	
	,.phy_pipe_rx_data			(phy_pipe_rx_data_i)//input	wire	[63:0]	
	,.phy_pipe_rx_sync_head		(phy_pipe_rx_sync_head_i)//input	wire	[3:0]	
	,.phy_pipe_rx_start_block	(phy_pipe_rx_start_block_i)//input	wire
	,.phy_pipe_rx_valid			(phy_pipe_rx_valid_i)//input	wire		
	,.phy_pipe_tx_data_k		(phy_pipe_tx_data_k_o)//output	wire	[1:0]	
	,.phy_pipe_tx_data			(phy_pipe_tx_data_o)//output	wire	[63:0]	
	,.phy_pipe_tx_sync_head		(phy_pipe_tx_sync_head_o)//output	wire	[3:0]	
	,.phy_pipe_tx_start_block	(phy_pipe_tx_start_block_o)//output	wire	
	,.phy_pipe_tx_valid			(phy_pipe_tx_valid_o)//output	wire	
	,.phy_reset_n				(phy_reset_n_o)//output	wire								
	,.phy_tx_detrx_lpbk			(phy_tx_detrx_lpbk_o)//output	wire			
	,.phy_tx_elecidle			(phy_tx_elecidle_o	)//output	wire			
	,.phy_rx_elecidle			(phy_rx_elecidle_i	)//inout	wire			
	,.phy_rx_status				(phy_rx_status_i)//input	wire	[2:0]	
	,.phy_power_down			(phy_power_down_o		)//output	wire	[1:0]	
	,.phy_phy_status			(phy_phy_status_i		)//input   wire			        
	,.phy_pwrpresent			(phy_pwrpresent_i		)//input	wire					
	,.phy_tx_deemph				(phy_tx_deemph_o		)//output	wire	[1:0]	
	,.phy_tx_margin				(phy_tx_margin_o		)//output	wire	[2:0]	
	,.phy_tx_swing				(phy_tx_swing_o		)//output	wire			
	,.phy_rx_polarity			(phy_rx_polarity_o)//output	wire			
	,.phy_rx_termination		(phy_rx_termination_o	)//output	wire			
	,.phy_rate					(phy_rate_o			)//output	wire			
	,.phy_elas_buf_mode			(phy_elas_buf_mode_o)//output	wire	
	,.phy_tx_fifo_wrnum			(phy_tx_fifo_wrnum_i	)//input	wire	[4:0]
	,.phy_serdes_pll_lock		(phy_serdes_pll_lock_i	)//input	wire
	,.phy_ltssm_is_training     (phy_ltssm_is_training_i ) //input wire


	// external interface
	
	,.warm_or_hot_reset ( warm_or_hot_reset_o ) 
	,.host_requests_data_from_endpt (host_requests_data_from_endpt_o ) 
	,.itp_received					( itp_received_o)
	,.attached						( attached_o )
	
	// requests 
	,.request_active 			(request_active_o	)
	,.bmRequestType				(bmRequestType_o	)
	,.bRequest					(bRequest_o)
	,.wValue					(wValue_o			)
	,.wIndex					(wIndex_o			)
	,.wLength					(wLength_o)
	,.wait_user_commit_request  (wait_user_commit_request_o  ) 
	,.request_commit 			(request_commit_i 			)  	
		
	//IN 	
   ,.transfer_in_mem_wr            (transfer_in_mem_wr_i          ) //input  wire          [0:15]
   ,.transfer_in_mem_wr_mask       (transfer_in_mem_wr_mask_i     ) //input  wire [7:0]    [0:15]
   ,.transfer_in_mem_wr_addr       (transfer_in_mem_wr_addr_i     ) //input  wire [13:0]   [0:15]
   ,.transfer_in_mem_wr_data       (transfer_in_mem_wr_data_i     ) //input  wire [31:0]   [0:15]	 	
   ,.transfer_in_mem_commit        (transfer_in_mem_commit_i      ) //input  wire          [0:15]	
   ,.transfer_in_mem_commit_len    (transfer_in_mem_commit_len_i  ) //input  wire [16:0]   [0:15]
   ,.transfer_in_mem_ready         (transfer_in_mem_ready_o       ) //output wire          [0:15]
   ,.transfer_in_done              (transfer_in_done_o            ) //output wire          [0:15]
   ,.transfer_in_mem_empty         (transfer_in_mem_empty_o       ) //output wire          [0:15]

	//OUT
   ,.transfer_out_mem_has_data    (transfer_out_mem_has_data_o) // output         [0:15]    
   ,.transfer_out_mem_len         (transfer_out_mem_len_o     ) // output  [16:0] [0:15] 
   ,.transfer_out_mem_rd_addr     (transfer_out_mem_rd_addr_i ) // input   [13:0] [0:15] 
   ,.transfer_out_mem_rd_data     (transfer_out_mem_rd_data_o ) // output  [31:0] [0:15] 
   ,.transfer_out_mem_clr         (transfer_out_mem_clr_i     ) // input          [0:15]


);

endmodule
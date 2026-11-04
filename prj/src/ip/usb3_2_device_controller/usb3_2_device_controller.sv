`timescale 1ns/1ns
module usb3_2_device_controller(


input	wire			phy_clk
,input	wire			reset_n

,input	wire	[3:0]	phy_pipe_rx_data_k
,input	wire	[63:0]	phy_pipe_rx_data
,input	wire	[3:0]	phy_pipe_rx_sync_head
,input	wire			phy_pipe_rx_start_block
,input	wire			phy_pipe_rx_valid
,output	wire	[3:0]	phy_pipe_tx_data_k
,output	wire	[63:0]	phy_pipe_tx_data
,output	wire	[3:0]	phy_pipe_tx_sync_head
,output	wire			phy_pipe_tx_start_block
,output	wire			phy_pipe_tx_valid

,output	wire			phy_reset_n
,output	wire			phy_tx_detrx_lpbk
,output	wire			phy_tx_elecidle
,input	wire			phy_rx_elecidle
,input	wire	[2:0]	phy_rx_status
,output	wire	[1:0]	phy_power_down
,input   wire	     	phy_phy_status
,input	wire			phy_pwrpresent

,output	wire	[1:0]	phy_tx_deemph
,output	wire	[2:0]	phy_tx_margin
,output	wire			phy_tx_swing
,output	wire			phy_rx_polarity
,output	wire			phy_rx_termination
,output	wire			phy_rate
,output	wire			phy_elas_buf_mode
,input	wire	[4:0]	phy_tx_fifo_wrnum
,input	wire			phy_serdes_pll_lock
,output wire 			phy_ltssm_is_training




,output wire 	warm_or_hot_reset 
,output reg 	itp_received 
,output reg		attached 

,output wire  host_requests_data_from_endpt [0:15]

// requests
,output wire			request_active 	
,output wire	[7:0]	bmRequestType	
,output wire	[7:0]	bRequest		
,output wire	[15:0]	wValue			
,output wire	[15:0]	wIndex			
,output wire	[15:0]	wLength		
,output wire			wait_user_commit_request
,input  wire        	request_commit  	


// user 
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



wire GEN1X1 = 1'b0 ;
wire GEN2X1 = 1'b1 ;

	wire set_device_low_power_state ;
	wire set_device_low_power_state_ack ;

	reg 			reset_1, reset_2;				// local reset
	wire			local_reset		= reset_n & phy_pwrpresent;

	
	wire	[5:0]	ltssm_state/* synthesis syn_keep = 1 */;
	wire			ltssm_rate;

	wire			port_rx_term;
	wire			port_tx_detrx_lpbk;
	wire			port_tx_elecidle;

	wire	[1:0]	port_power_down;
	wire			port_power_go;
	wire			port_power_ack;
	wire			port_power_err;
	wire			ltssm_hot_reset;

	wire			ltssm_training;
	wire			ltssm_train_hot_reset;
	wire			ltssm_train_rxeq;
	wire			ltssm_train_rxeq_pass;
	wire			ltssm_train_active;
	wire			ltssm_train_ts1;
	wire			ltssm_train_ts2;
	wire			ltssm_train_config;
	wire			ltssm_train_idle;
	wire			ltssm_train_idle_pass;
	wire			ltssm_compliance;

	wire			partner_detect;
	wire			partner_looking;
	wire			partner_detected;

	wire			lfps_recv_active;
	wire			lfps_recv_poll_u1;
	wire			lfps_recv_ping;
	wire			lfps_recv_reset;
	wire			lfps_recv_u2lb;
	wire			lfps_recv_u3;

	wire			ltssm_warm_reset;
	wire			fallback_to_usb2;

	

	wire		[63:0]	link_in_data;
	wire		[3:0]	link_in_datak;
	wire				link_in_active;

	wire		[63:0]	link_out_data;
	wire		[3:0]	link_out_datak;
	wire				link_out_active;
	wire				link_out_stall;
	wire				ltssm_go_disabled;
	wire				ltssm_go_recovery;
	wire		[2:0]	ltssm_go_u;
	reg			[2:0]	ltssm_go_u_d0;
	wire                train_ts1_rec;
	reg                 train_ts1_rec_d0 ;
	
	wire [6:0] dev_address ;




	wire			prot_rx_tp;
	wire			prot_rx_tp_hosterr;
	wire			prot_rx_tp_retry;
	wire			prot_rx_tp_d;
	wire			prot_rx_tp_pktpend;
	wire	[3:0]	prot_rx_tp_subtype;
	wire	[3:0]	prot_rx_tp_endp;
	wire	[4:0]	prot_rx_tp_nump;
	wire	[4:0]	prot_rx_tp_seq;
	wire	[15:0]	prot_rx_tp_stream;

	wire			prot_rx_dph;
	wire			prot_rx_dph_eob;
	wire			prot_rx_dph_setup;
	wire			prot_rx_dph_pktpend;
	wire	[3:0]	prot_rx_dph_endp;
	wire	[4:0]	prot_rx_dph_seq;
	wire	[15:0]	prot_rx_dph_len;
	wire			prot_rx_dpp_start;
	wire			prot_rx_dpp_abort;
	wire			prot_rx_dpp_done;
	wire			prot_rx_dpp_crcgood;

	wire  			prot_tx_hp_ack		;
	wire       		prot_tx_DP_ack		;
	wire      		prot_tx_0_DP_ack	;
	wire 			prot_tx_hp		;		
	wire [31:0]		prot_hp_word_0 	;
	wire [31:0]		prot_hp_word_1 	;
	wire [31:0]		prot_hp_word_2	;
	wire 			prot_tx_DP 		;	
	wire			prot_tx_DP_eob 	;
	wire 			prot_tx_DP_dir 	;
	wire [3:0]		prot_tx_DP_endp 	;
	wire [4:0]		prot_tx_DP_seq 	;
	wire [15:0]		prot_tx_DP_len 	;
	wire [2:0]		prot_tx_DP_TT    ;
	wire 			prot_tx_0_DP 	;
	wire			prot_tx_0_DP_eob ;
	wire 			prot_tx_0_DP_dir ;
	wire [3:0]		prot_tx_0_DP_endp;
	wire [4:0]		prot_tx_0_DP_seq ;
	wire [15:0]		prot_tx_0_DP_len ;
	wire [2:0]		prot_tx_0_DP_TT 	;	

	wire	[63:0]	prot_buf_in_data;
	wire			prot_buf_in_wren;
	wire			prot_buf_in_ready;
	wire			prot_buf_in_commit;
	wire	[10:0]	prot_buf_in_commit_len;

	wire	[63:0]	prot_buf_out_q;
	reg		[63:0]	prot_buf_out_q_d0;
	reg		[63:0]	prot_buf_out_q_d1;
	reg		[63:0]	prot_buf_out_q_d;
	reg		[63:0]	prot_buf_out_q0_d;
	reg		[63:0]	prot_buf_out_q1_d;
	reg		[63:0]	prot_buf_out_q2_d;
	reg		[63:0]	prot_buf_out_q3_d;
	reg		[63:0]	prot_buf_out_q4_d;
	reg		[63:0]	prot_buf_out_q5_d;
	reg		[63:0]	prot_buf_out_q6_d;
	reg		[63:0]	prot_buf_out_q7_d;
	wire			prot_buf_out_arm;
	wire			prot_in_dpp_wasready ;
	wire			prot_rx_tp_deferred ;
	wire			prot_rx_dph_deferred ;
	wire			prot_dpp_end_abort_det ;
	
	reg		[63:0]	link_out_data_d0;
	reg		[3:0]	link_out_datak_d0;
	reg				link_out_active_d0;


always @(posedge phy_clk ) begin

	// synchronize external reset to local domain
	{reset_2, reset_1} <= {reset_1, local_reset};

end

	assign			phy_reset_n = reset_n;			// TUSB1310A has minimum 1uS pulse width for RESET
													// responsibility of the toplevel module to supply this reset
													// NOTE: reset entire phy will cause loss of PLL lock
													// reset the PHY along with all our core code if cable unplugged
	assign			phy_out_enable = 1'b1;

	wire	[2:0]	mux_tx_margin;

	parameter		XTAL_SEL			= 1'b0; 	// crystal input
	parameter		OSC_SEL				= 1'b1; 	// clock input
	parameter [2:0]	SSC_DIS				= 2'b11;	// spread spectrum clock disable
	parameter [2:0]	SSC_EN				= 2'b00;	// spread spectrum clock enable
	parameter		PIPE_16BIT			= 1'b0;		// sdr 16bit pipe interface
	// strap pins
//	assign			phy_rx_elecidle 	= reset_2 ? 1'bZ : XTAL_SEL;
	assign			phy_tx_margin	  	= reset_2 ? mux_tx_margin  : SSC_DIS;
	assign			phy_phy_status_o 	= reset_2 ? 1'bZ : PIPE_16BIT;

////////////////////////////////////////////////////////////
//
// USB 3.0 PIPE3 interface
//
////////////////////////////////////////////////////////////

	wire		ltssm_reset_n;
usb3_pipe
iu3p (

	.local_clk				( phy_clk ),
	.reset_n				( reset_n ),
	.ltssm_reset_n			( ltssm_reset_n ),

	.phy_pipe_rx_datak		( phy_pipe_rx_data_k ),
	.phy_pipe_rx_data		( phy_pipe_rx_data ),
	.phy_pipe_rx_sync_head	( phy_pipe_rx_sync_head ),
	.phy_pipe_rx_start_block( phy_pipe_rx_start_block ),
	.phy_pipe_rx_valid		( phy_pipe_rx_valid ),
	.phy_pipe_tx_datak		( phy_pipe_tx_data_k ),
	.phy_pipe_tx_data		( phy_pipe_tx_data ),
	.phy_pipe_tx_sync_head	( phy_pipe_tx_sync_head ),
	.phy_pipe_tx_start_block( phy_pipe_tx_start_block ),
	.phy_pipe_tx_valid		( phy_pipe_tx_valid ),

	.phy_tx_detrx_lpbk		( phy_tx_detrx_lpbk ),
	.phy_tx_elecidle		( phy_tx_elecidle ),
	.phy_rx_elecidle		( phy_rx_elecidle ),
	.phy_rx_status			( phy_rx_status ),
	.phy_power_down			( phy_power_down ),
	.phy_phy_status			( phy_phy_status ),
	.phy_pwrpresent			( phy_pwrpresent ),

	.phy_tx_deemph			( phy_tx_deemph ),
	.phy_tx_margin			( mux_tx_margin ),
	.phy_tx_swing			( phy_tx_swing ),
	.phy_rx_polarity		( phy_rx_polarity ),
	.phy_rx_termination		( phy_rx_termination ),
	.phy_rate				( phy_rate ),
	.phy_elas_buf_mode		( phy_elas_buf_mode ),
	.phy_tx_fifo_wrnum		( phy_tx_fifo_wrnum ),

	.link_in_datak			( link_in_datak ),
	`ifndef SIM_LINK	
	.link_in_data			( link_in_data ),
	.link_in_active			( link_in_active ),
	`endif	

	.link_out_datak			( link_out_datak ),
	.link_out_data			( link_out_data ),
	.link_out_active		( link_out_active ),
	`ifndef SIM_LINK
	.link_out_stall			( link_out_stall ),
	`endif
	.link_in_sync_head		(),
	.link_in_start_block	(),
	.link_out_sync_head		(4'b0),
	.link_out_start_block   (1'b0),

	.partner_detect			( partner_detect ),
	.partner_looking		( partner_looking ),
	.partner_detected		( partner_detected ),

	.ltssm_tx_detrx_lpbk	( port_tx_detrx_lpbk ),
	.ltssm_tx_elecidle		( port_tx_elecidle ),
	.ltssm_power_down		( port_power_down ),
	.ltssm_power_go			( port_power_go ),
	.ltssm_power_ack		( port_power_ack ),
	.ltssm_hot_reset		( ltssm_hot_reset ),
	.ltssm_loopback			( ltssm_loopback ),
	.ltssm_local_loopback	( ltssm_local_loopback ),
	.ltssm_rate				( ltssm_rate ),
	.ltssm_rate_changed		( ltssm_rate_changed),

	.ltssm_state				( ltssm_state ),
	.ltssm_training				( ltssm_training ),
	.ltssm_train_hot_reset		(ltssm_train_hot_reset),
	.ltssm_train_rxeq			( ltssm_train_rxeq ),
	.ltssm_train_rxeq_pass		( ltssm_train_rxeq_pass ),
	.ltssm_train_active			( ltssm_train_active ),
	.ltssm_train_ts1			( ltssm_train_ts1 ),
	.ltssm_train_ts2			( ltssm_train_ts2 ),
	.ltssm_train_config			( ltssm_train_config ),
	.ltssm_train_idle			( ltssm_train_idle ),
	.ltssm_train_idle_pass		( ltssm_train_idle_pass ),
	.ltssm_compliance			( ltssm_compliance ),
	.ltssm_warm_reset			( ltssm_warm_reset ),

	.lfps_recv_active		( lfps_recv_active ),
	.lfps_recv_poll_u1		( lfps_recv_poll_u1 ),
	.lfps_recv_ping			( lfps_recv_ping ),
	.lfps_recv_reset		( lfps_recv_reset ),
	.lfps_recv_u2lb			( lfps_recv_u2lb ),
	.lfps_recv_u3			( lfps_recv_u3 ),
	.dbg_state              (  ),
	.link_out_skp_inhibit	(1'b0),
	.link_out_skp_defer     (1'b0),
	.ltssm_power_err        ()
	
);

////////////////////////////////////////////////////////////
//
// USB 3.0 LTSSM, LFPS
//
////////////////////////////////////////////////////////////
`ifdef SIM_LINK 
usb3_ltssm_sim usb3_ltssm_sim_inst
(
     .clk	(phy_clk) //input  
    ,.rst_n	(reset_n) //input  
    
    ,.ltssm_state	(ltssm_state) //output [5:0] 
    ,.rate			(ltssm_rate) //output       
    ,.warm_reset	(ltssm_warm_reset) //output       
	,.train_ts1_rec (train_ts1_rec) //output
	,.out_stall		(link_out_stall) //output
	,.link_in_data	(link_out_data	) //input  [63:0]  
    ,.link_in_active(link_out_active) //input          

    ,.link_out_data 	(link_in_data ) //output  [63:0] 	
    ,.link_out_active 	(link_in_active) //output         	   

);
`else 
usb3_ltssm_device
iu3lt (

	.local_clk				( phy_clk ),
	.reset_n				( ltssm_reset_n ),

	// inputs
	.vbus_present			( phy_pwrpresent ),
	.port_rx_valid			( phy_pipe_rx_valid ),	// these signals are in the 250mhz source
	.port_rx_elecidle		( phy_rx_elecidle ),	// domain, but no problem for lfps in 62.5mhz
	.partner_looking		( partner_looking ),
	.partner_detected		( partner_detected ),
	.port_power_state		( phy_power_down ),		// reflect actual value driven by PIPE pd_fsm
	.port_power_ack			( port_power_ack ),
	.port_power_err			( 1'b0 ),

	.train_rxeq_pass		( ltssm_train_rxeq_pass ),
	.train_idle_pass		( ltssm_train_idle_pass ),
	.train_ts1				( ltssm_train_ts1 ),
	.train_ts2				( ltssm_train_ts2 ),
	.go_disabled			( ltssm_go_disabled ),
	.go_recovery			( ltssm_go_recovery ),
	.go_u					( ltssm_go_u_d0 ),
	.hot_reset				( ltssm_hot_reset ),
	.loopback				( ltssm_loopback ),
	.local_loopback			( ltssm_local_loopback ),
	.train_ts1_rec			( train_ts1_rec        ),

	.rate					( ltssm_rate ),
	.rate_changed			( ltssm_rate_changed ),

	// outputs
	.ltssm_state			( ltssm_state ),
	.port_rx_term			( port_rx_term ),
	.port_tx_detrx_lpbk		( port_tx_detrx_lpbk ),
	.port_tx_elecidle		( port_tx_elecidle ),
	.port_power_down		( port_power_down ),
	.port_power_go			( port_power_go ),
	.partner_detect			( partner_detect ),
	.ltssm_is_training      ( phy_ltssm_is_training ),

	.training				( ltssm_training ),
	.train_hot_reset		(ltssm_train_hot_reset),
	.train_rxeq				( ltssm_train_rxeq ),
	.train_active			( ltssm_train_active ),
	.train_config			( ltssm_train_config ),
	.train_idle				( ltssm_train_idle ),
	.train_compliance		( ltssm_compliance ),

	.lfps_recv_active		( lfps_recv_active ),
	.lfps_recv_poll_u1		( lfps_recv_poll_u1 ),
	.lfps_recv_ping			( lfps_recv_ping ),
	.lfps_recv_reset		( lfps_recv_reset ),
	.lfps_recv_u2lb			( lfps_recv_u2lb ),
	.lfps_recv_u3			( lfps_recv_u3 ),

	.warm_reset				( ltssm_warm_reset ),
	.dbg_state              (  ),
	
	.fallback_to_usb2		(fallback_to_usb2),

	.lfps_send_ack			(),	
	.lfps_send_poll         (1'b0),
	.lfps_send_ping         (1'b0),
	.lfps_send_u1           (1'b0),
	.lfps_send_u2lb         (1'b0),
	.lfps_send_u3           (1'b0)
	
);
`endif 


always @ ( posedge phy_clk or negedge reset_2 ) begin
	if ( !reset_2 ) begin
		attached <= 0 ;
	end
	else if ( ltssm_state == 7 ) begin
		attached <= 0 ;
	end	
	else if ( ltssm_state == 19 )begin
		attached <= 1 ;
	end
end

reg prot_rst_n ;
reg prot_rst_n_d0 /* synthesis  syn_preserve = 1 */;
reg prot_rst_n_d1 /* synthesis  syn_preserve = 1 */;
reg link_rst_n ;
reg link_rst_n_d0 ;
reg [14:0] speed /* synthesis  syn_preserve = 1 */;
//always @ ( posedge phy_clk or negedge reset_2 ) begin
always @ ( posedge phy_clk  ) begin
	if ( !reset_2 ) begin
		prot_rst_n <= 0 ;
		link_rst_n  <= 0 ;
	end
   else begin
      prot_rst_n <= !( ltssm_state == 7 ) ;
	  link_rst_n  <= !( ltssm_state == 7 ) ;
   end
end

always @ ( posedge phy_clk  ) begin
	prot_rst_n_d0 <= prot_rst_n ;
	prot_rst_n_d1 <= prot_rst_n_d0 ;
	link_rst_n_d0 <= link_rst_n ;
	speed[14:0]   <= {15{ltssm_rate}} ;
	train_ts1_rec_d0 <= train_ts1_rec ;
end


always @ ( posedge phy_clk  or negedge link_rst_n ) begin
	if ( !link_rst_n ) begin
		link_out_data_d0	<= 	0;
		link_out_datak_d0	<= 	0;
		link_out_active_d0	<= 	0;	
		ltssm_go_u_d0 <= 0 ;
	end
	else begin
		link_out_data_d0	<= 	link_out_data  ;
		link_out_datak_d0	<= 	link_out_datak  ;
		link_out_active_d0	<= 	link_out_active;		
		ltssm_go_u_d0 <= ltssm_go_u ;
	end
end


wire itp_received_link ;

////////////////////////////////////////////////////////////
//
// USB 3.0 Link layer interface
//
////////////////////////////////////////////////////////////
usb3_link
iu3l (

 	.local_clk				( phy_clk ),
 	.reset_n				(  link_rst_n_d0 		),

	.speed_0 				( speed[0]  ) ,
	.speed_1 				( speed[1]  ) ,
	.speed_2 				( speed[2]  ) ,
	.speed_3 				( speed[3]  ) ,
	.speed_4 				( speed[4]  ) ,
	.speed_5 				( speed[5]  ) ,
	.speed_6 				( speed[6]  ) ,
	.speed_7 				( speed[7]  ) ,
	.speed_8 				( speed[8]  ) ,
	.speed_9 				( speed[9]  ) ,
	.speed_10				( speed[10] ) ,
	.speed_11				( speed[11] ) ,
	.speed_12				( speed[12] ) ,
	.speed 					( speed[13] ) ,	

 	.ltssm_state			( ltssm_state ),
 	.ltssm_hot_reset		( ltssm_hot_reset ),
 	.ltssm_go_disabled		( ltssm_go_disabled ),
 	.ltssm_go_recovery		( ltssm_go_recovery ),
 	.ltssm_go_u				( ltssm_go_u),
	.train_ts1_rec			( train_ts1_rec ),
 	.in_data				( link_in_data ),
	.in_datak				( link_in_datak ),
 	.in_active				( link_in_active ),

 	.outp_data				( link_out_data ),
	.outp_datak				( link_out_datak),
 	.outp_active			( link_out_active ), 
 	.out_stall				( ltssm_rate == GEN2X1 && link_out_stall ),


	.set_device_low_power_state	(1'b0),
	.set_device_low_power_state_ack	( set_device_low_power_state_ack ) ,
	
	.itp_received ( itp_received_link ),


 	.prot_rx_tp				( prot_rx_tp ),
 	.prot_rx_tp_hosterr		( prot_rx_tp_hosterr ),
 	.prot_rx_tp_retry		( prot_rx_tp_retry ),
 	.prot_rx_tp_d		 ( prot_rx_tp_d ),
 	.prot_rx_tp_pktpend		( prot_rx_tp_pktpend ),
 	.prot_rx_tp_subtype		( prot_rx_tp_subtype ),
 	.prot_rx_tp_endp		( prot_rx_tp_endp ),
 	.prot_rx_tp_nump		( prot_rx_tp_nump ),
 	.prot_rx_tp_seq			( prot_rx_tp_seq ),
 	.prot_rx_tp_stream		( prot_rx_tp_stream ),
	.prot_rx_tp_deferred    ( prot_rx_tp_deferred ) ,

 	.prot_rx_dph			( prot_rx_dph ),
 	.prot_rx_dph_eob		( prot_rx_dph_eob ),
 	.prot_rx_dph_setup		( prot_rx_dph_setup ),
 	.prot_rx_dph_pktpend	( prot_rx_dph_pktpend ),
 	.prot_rx_dph_endp		( prot_rx_dph_endp ),
 	.prot_rx_dph_seq		( prot_rx_dph_seq ),
 	.prot_rx_dph_len		( prot_rx_dph_len ),
 	.prot_rx_dpp_start		( prot_rx_dpp_start ),
	.prot_rx_dpp_abort		( prot_rx_dpp_abort ),
 	.prot_rx_dpp_done		( prot_rx_dpp_done ),
 	.prot_rx_dpp_crcgood	( prot_rx_dpp_crcgood ),
	.prot_in_dpp_wasready	( prot_in_dpp_wasready ),
	.prot_rx_dph_deferred	( prot_rx_dph_deferred ),
	.prot_dpp_end_abort_det	( prot_dpp_end_abort_det ), 

	.prot_tx_hp    	(prot_tx_hp    ) ,
	.prot_tx_hp_ack	(prot_tx_hp_ack) , 
	.prot_hp_word_0	(prot_hp_word_0) , 
	.prot_hp_word_1	(prot_hp_word_1) , 
	.prot_hp_word_2	(prot_hp_word_2) , 

	.prot_tx_DP 		(prot_tx_DP 	),
	.prot_tx_DP_ack		(prot_tx_DP_ack	),
	.prot_tx_DP_eob 	(prot_tx_DP_eob ),
	.prot_tx_DP_dir 	(prot_tx_DP_dir ),
	.prot_tx_DP_endp 	(prot_tx_DP_endp),
	.prot_tx_DP_seq 	(prot_tx_DP_seq ),
	.prot_tx_DP_len 	(prot_tx_DP_len ),
	.prot_tx_DP_TT 		(prot_tx_DP_TT 	),
	.prot_tx_DP_pp		(1'b0			),
	.prot_tx_DP_setup   (1'b0			),

	.prot_tx_0_DP 		(prot_tx_0_DP 		),
	.prot_tx_0_DP_ack	(prot_tx_0_DP_ack	),
	.prot_tx_0_DP_eob 	(prot_tx_0_DP_eob 	),
	.prot_tx_0_DP_dir 	(prot_tx_0_DP_dir 	),
	.prot_tx_0_DP_endp 	(prot_tx_0_DP_endp 	),
	.prot_tx_0_DP_seq 	(prot_tx_0_DP_seq 	),
	.prot_tx_0_DP_len 	(prot_tx_0_DP_len 	),
	.prot_tx_0_DP_TT 	(prot_tx_0_DP_TT 	), 	


 	.buf_in_data			( prot_buf_in_data ),
 	.buf_in_wren			( prot_buf_in_wren ),
 	.buf_in_ready			( prot_buf_in_ready ),
 	.buf_in_commit			( prot_buf_in_commit ),
 	.buf_in_commit_len		( prot_buf_in_commit_len ),

	.buf_out_q				(prot_buf_out_q_d ),				
 	.buf_out_q0				( prot_buf_out_q0_d ),
 	.buf_out_q1				( prot_buf_out_q1_d ),
 	.buf_out_q2				( prot_buf_out_q2_d ),
 	.buf_out_q3				( prot_buf_out_q3_d ),
 	.buf_out_q4				( prot_buf_out_q4_d ),
 	.buf_out_q5				( prot_buf_out_q5_d ),
 	.buf_out_q6				( prot_buf_out_q6_d ),
 	.buf_out_q7				( prot_buf_out_q7_d ),
 	.buf_out_arm			( prot_buf_out_arm ),
	.buf_out_rden			( prot_buf_out_rden),


 	// current device address, driven by endpoint 0
 	.dev_address			( dev_address )
	
 );

always @ ( posedge phy_clk or negedge attached ) begin
   if ( !attached ) begin
	  prot_buf_out_q_d  <= 0 ;
      prot_buf_out_q0_d <= 0 ;
      prot_buf_out_q1_d <= 0 ;
      prot_buf_out_q2_d <= 0 ;
      prot_buf_out_q3_d <= 0 ;
      prot_buf_out_q4_d <= 0 ;
      prot_buf_out_q5_d <= 0 ;
      prot_buf_out_q6_d <= 0 ;
      prot_buf_out_q7_d <= 0 ;	  
	  {prot_buf_out_q_d1,prot_buf_out_q_d0} <= 0 ;
   end
   else begin
      prot_buf_out_q_d  <= prot_buf_out_q_d1 ;
	  {prot_buf_out_q_d1,prot_buf_out_q_d0} <= {prot_buf_out_q_d0,prot_buf_out_q};
      prot_buf_out_q0_d <= prot_buf_out_q ;
      prot_buf_out_q1_d <= prot_buf_out_q ;
      prot_buf_out_q2_d <= prot_buf_out_q ;
      prot_buf_out_q3_d <= prot_buf_out_q ;
      prot_buf_out_q4_d <= prot_buf_out_q ;
      prot_buf_out_q5_d <= prot_buf_out_q ;
      prot_buf_out_q6_d <= prot_buf_out_q ;
      prot_buf_out_q7_d <= prot_buf_out_q ;	 	  
   end
end

always @ ( posedge phy_clk or negedge attached ) begin
   if ( !attached ) begin
      itp_received <= 0 ;
   end
   else begin
      itp_received <= itp_received_link ;
   end
end
////////////////////////////////////////////////////////////
//
// USB 3.0 Protocol layer interface
//
////////////////////////////////////////////////////////////


reg prot_rx_dph_d0,prot_rx_dph_d1,prot_rx_dph_d2,prot_rx_dph_d3 ;
reg prot_rx_dpp_start_d0,prot_rx_dpp_start_d1,prot_rx_dpp_start_d2,prot_rx_dpp_start_d3 ;

always @ ( posedge phy_clk  ) begin
	{prot_rx_dph_d0,prot_rx_dph_d1,prot_rx_dph_d2,prot_rx_dph_d3} <= {prot_rx_dph,prot_rx_dph_d0,prot_rx_dph_d1,prot_rx_dph_d2} ;
	{prot_rx_dpp_start_d0,prot_rx_dpp_start_d1,prot_rx_dpp_start_d2,prot_rx_dpp_start_d3} <= {prot_rx_dpp_start,prot_rx_dpp_start_d0,prot_rx_dpp_start_d1,prot_rx_dpp_start_d2} ;
end




usb3_protocol
iu3r (

 	.local_clk				( phy_clk ),

 	.reset_n				   (  prot_rst_n_d1 ),
 	.ltssm_state			( ltssm_state ),
	.speed					(speed[14]),

 	.rx_tp					( prot_rx_tp ),
 	.rx_tp_hosterr			( prot_rx_tp_hosterr ),
 	.rx_tp_retry			( prot_rx_tp_retry ),
 	.rx_tp_d			      ( prot_rx_tp_d ),
 	.rx_tp_pktpend			( prot_rx_tp_pktpend ),
 	.rx_tp_subtype			( prot_rx_tp_subtype ),
 	.rx_tp_endp				( prot_rx_tp_endp ),
 	.rx_tp_nump				( prot_rx_tp_nump ),
 	.rx_tp_seq				( prot_rx_tp_seq ),
 	.rx_tp_stream			( prot_rx_tp_stream ),
	.rx_tp_deferred			( prot_rx_tp_deferred ),

 	//.rx_dph					( prot_rx_dph_d3 ),
 	.rx_dph					( prot_rx_dph ),
 	.rx_dph_eob				( prot_rx_dph_eob ),
 	.rx_dph_setup			( prot_rx_dph_setup ),
 	.rx_dph_pktpend			( prot_rx_dph_pktpend ),
 	.rx_dph_endp			( prot_rx_dph_endp ),
 	.rx_dph_seq				( prot_rx_dph_seq ),
 	.rx_dph_len				( prot_rx_dph_len ),
 	//.rx_dpp_start			( prot_rx_dpp_start_d3 ),
 	.rx_dpp_start			( prot_rx_dpp_start ),
 	.rx_dpp_abort			( prot_rx_dpp_abort ),
 	.rx_dpp_done			( prot_rx_dpp_done ),
 	.rx_dpp_crcgood			( prot_rx_dpp_crcgood ),
	.rx_in_dpp_wasready     ( prot_in_dpp_wasready),
	.rx_dph_deferred		( prot_rx_dph_deferred ),
	.dpp_end_abort_det 		( prot_dpp_end_abort_det ) ,	

	// sent hp
	.tx_hp     (prot_tx_hp    ),	
	.tx_hp_ack (prot_tx_hp_ack), 
	.hp_word_0 (prot_hp_word_0), 
	.hp_word_1 (prot_hp_word_1), 
	.hp_word_2 (prot_hp_word_2), 	

	// sent  dpp 
	.tx_DP 		(prot_tx_DP 		),
	.tx_DP_ack	(prot_tx_DP_ack	),
	.tx_DP_eob 	(prot_tx_DP_eob 	),
	.tx_DP_dir 	(prot_tx_DP_dir 	),
	.tx_DP_endp (prot_tx_DP_endp ),	
	.tx_DP_seq 	(prot_tx_DP_seq 	),
	.tx_DP_len 	(prot_tx_DP_len 	),
	.tx_DP_TT 	(prot_tx_DP_TT 	),

	.tx_0_DP 		(prot_tx_0_DP 		), 
	.tx_0_DP_ack	(prot_tx_0_DP_ack	), 
	.tx_0_DP_eob 	(prot_tx_0_DP_eob 	), 
	.tx_0_DP_dir 	(prot_tx_0_DP_dir 	), 
	.tx_0_DP_endp	(prot_tx_0_DP_endp	), 
	.tx_0_DP_seq 	(prot_tx_0_DP_seq 	), 
	.tx_0_DP_len 	(prot_tx_0_DP_len 	), 
	.tx_0_DP_TT  	(prot_tx_0_DP_TT  	), 

 	.buf_in_data			( prot_buf_in_data ),
 	.buf_in_wren			( prot_buf_in_wren ),
 	.buf_in_ready			( prot_buf_in_ready ),
 	.buf_in_commit			( prot_buf_in_commit ),
 	.buf_in_commit_len		( prot_buf_in_commit_len ),


 	.buf_out_q				( prot_buf_out_q ),
 	.buf_out_arm			( prot_buf_out_arm ),
    .buf_out_rden 			( prot_buf_out_rden ),
 	
	.dev_address 		(dev_address),
	.set_device_low_power_state	( set_device_low_power_state ) ,
	.set_device_low_power_state_ack	( set_device_low_power_state_ack ) ,

	.itp_received (itp_received_link ) ,
	
 	
	// external interface
	.warm_or_hot_reset	(warm_or_hot_reset),

	
	.host_requests_data_from_endpt (host_requests_data_from_endpt ),

	// requests 
	 .request_active 			(request_active			   )
	,.bmRequestType				(bmRequestType			   )
	,.bRequest					(bRequest				   )
	,.wValue					(wValue					   )
	,.wIndex					(wIndex					   )
	,.wLength					(wLength				   )
	,.wait_user_commit_request  (wait_user_commit_request  )
	,.request_commit 			(request_commit 		   )  
	
	//  IN 	
   ,.transfer_in_mem_wr            (transfer_in_mem_wr          ) //input            [0:15]
   ,.transfer_in_mem_wr_mask       (transfer_in_mem_wr_mask     ) //input   [7:0]    [0:15]
   ,.transfer_in_mem_wr_addr       (transfer_in_mem_wr_addr     ) //input   [13:0]   [0:15]
   ,.transfer_in_mem_wr_data       (transfer_in_mem_wr_data     ) //input   [31:0]   [0:15]	 	
   ,.transfer_in_mem_commit        (transfer_in_mem_commit      ) //input            [0:15]	
   ,.transfer_in_mem_commit_len    (transfer_in_mem_commit_len  ) //input   [15:0]   [0:15]
   ,.transfer_in_mem_ready         (transfer_in_mem_ready       ) //output           [0:15]
   ,.transfer_in_done              (transfer_in_done            ) //output           [0:15]
   ,.transfer_in_mem_empty         (transfer_in_mem_empty       )
	
	//  OUT
   ,.transfer_out_mem_has_data     (transfer_out_mem_has_data ) //output            [0:15]
   ,.transfer_out_mem_len          (transfer_out_mem_len      ) //output  [15:0]    [0:15]
   ,.transfer_out_mem_rd_addr      (transfer_out_mem_rd_addr  ) //input   [13:0]    [0:15]
   ,.transfer_out_mem_rd_data      (transfer_out_mem_rd_data  ) //output  [31:0]    [0:15]
   ,.transfer_out_mem_clr          (transfer_out_mem_clr      ) //input             [0:15]




 );

endmodule


module usb3_ltssm_device(

input	wire			local_clk,
input	wire			reset_n,

input	wire			vbus_present,
input	wire			port_rx_valid,
input	wire			port_rx_elecidle,
input	wire	[1:0]	port_power_state,
output	reg				port_rx_term,
output	reg				port_tx_detrx_lpbk,
output	reg				port_tx_elecidle,
output	wire	[5:0]	ltssm_state,
output	reg				ltssm_is_training,

input	wire			partner_looking,
input	wire			partner_detected,
output	reg				partner_detect,
output	reg				rate, // 0: 5g rate, 1: 10g rate
input	wire			rate_changed,

input	wire			port_power_ack,
input	wire			port_power_err,
output	reg		[1:0]	port_power_down,
output	reg				port_power_go,

output	reg				training,
output	reg				train_hot_reset,
output	reg				train_rxeq,
input	wire			train_rxeq_pass,
output	reg				train_active,
input	wire			train_ts1,
input	wire			train_ts2,
output	reg				train_config,
output	reg				train_idle,
input	wire			train_idle_pass,
output	reg				train_compliance,

input	wire			hot_reset,
input	wire			go_disabled,
input	wire			go_recovery,
input	wire	[2:0]	go_u,
input	wire			loopback,
input	wire			local_loopback,
output  reg             train_ts1_rec,	

output	reg				lfps_send_ack,
input	wire			lfps_send_poll,
input	wire			lfps_send_ping,
input	wire			lfps_send_u1,
input	wire			lfps_send_u2lb,
input	wire			lfps_send_u3,

output	reg				lfps_recv_active,
output	reg				lfps_recv_poll_u1,
output	reg				lfps_recv_ping,
output	reg				lfps_recv_reset,
output	reg				lfps_recv_u2lb,
output	reg				lfps_recv_u3,

output	reg				warm_reset,
output wire [5:0]       dbg_state,

output	wire			fallback_to_usb2

);
	
assign fallback_to_usb2 = ( state == LT_SS_DISABLED ) && vbus_present_2 ;



`include "usb3_const.vh"

	reg				vbus_present_1, vbus_present_2;
	reg				port_rx_elecidle_1, port_rx_elecidle_2;
	reg				port_rx_valid_1, port_rx_valid_2;

	reg		[5:0]	state;
	assign dbg_state = state;
	reg		[4:0]	lfps_send_state;
	reg		[4:0]	lfps_recv_state;
	reg		[4:0]	lbpm_scd_recv_state;
	reg		[4:0]	CP_X;
	
	reg				hot_reset_latch = 0;

	reg		[25:0]	dc;							// delay count
	reg 	dc_rst_n ;
	reg		[7:0]	tc = 0;							// train count
	reg		[7:0]	tsc = 0/* synthesis  syn_preserve = 1 */;							// train send count
	//reg		[24:0]	ic;							// interval count
	reg		[25:0]	sc/* synthesis  syn_preserve = 1 */;							// send FSM count
	reg		[25:0]	sic/* synthesis  syn_preserve = 1 */;						// send internal count
	reg		[25:0]	rc/* synthesis  syn_preserve = 1 */;							// receive FSM count
	reg		[25:0]	rc2;							// receive FSM count
	reg		[25:0]	ric;						// receive interval count
	reg		[2:0]	ts_timeout_cnt;						

	reg				lfps_send_ping_ack;

	reg				lfps_send_local;			// compliance need
	reg				lfps_send_poll_local;		// OR'd with external LFPS request
	reg				lfps_send_scd1_local;
	reg				lfps_send_scd2_local;
	reg				lfps_send_phy_cab_local;
	reg				lfps_send_phy_ready_local;
	reg				lfps_send_ping_local;		// inputs, so either source may invoke
	reg				lfps_send_u1_local;			// an LFPS transmission
	reg				lfps_send_u2lb_local;
	reg				lfps_send_u3_local;
	reg				lfps_send_reset_local;
	reg		[3:0]	lfps_type = 0;

	reg		[7:0]	lbpm_data_out = 0;
	reg		[7:0]	lbpm_data_out_latch = 0;
	reg		[7:0]	lbpm_data_in = 0;
	reg		[7:0]	lbpm_data_in_latch = 0;
	reg		[3:0]	lbpm_data_cnt = 0;
	reg		[3:0]	lbpm_recv_data_cnt = 0;
	reg		[3:0]	lfps_recv_data_cnt = 0;

	reg				lfps_recv_poll_u1_prev;		// used to detect these specific two LFPS
	reg				lfps_recv_scd1;		
	reg				lfps_recv_scd2;		
	reg				lfps_recv_ping_prev;		// patterns that dictate repeat lengths 
	reg				lfps_recv_port_match;		
	reg		[1:0]	recv_scd_0 = 0;
	reg		[1:0]	recv_scd_1 = 0;
	// reg				recv_lbpm_0;
	// reg				recv_lbpm_1;

	reg		[3:0]	rx_detect_attempts;
	reg		[3:0]	gen2_attempts;
	reg				gen2_attempts_equal_15;
	reg		[5:0]	polling_lfps_sent;
	reg		[3:0]	polling_lfps_received;
	reg		[5:0]	polling_scd_lfps_sent;
	reg		[3:0]	polling_scd_lfps_received;
	reg		[3:0]	polling_lfps_sent_after_recv;
	reg				has_trained;
	reg				go_recovery_latch;
	reg				partner_rate;
	reg				rate_r;
	reg				rate_d1;

	reg				dc_T_SS_INACTIVE_QUIET;
	reg				dc_T_RX_DETECT_QUIET;
	reg				dc_T_POLLING_LFPS;
	reg				dc_T_POLLING_ACTIVE;
	reg				dc_T_POLLING_CONFIG;
	reg				dc_T_POLLING_CONFIG_8MS;
	reg				dc_T_POLLING_IDLE;
	reg				dc_LFPS_BURST_PING_NOM;
	reg				dc_6250000;
	reg				dc_T_RECOV_ACTIVE;
	reg				dc_T_RECOV_CONFIG;
	reg				dc_T_RECOV_IDLE;
	reg				dc_T_HOTRESET_ACTIVE;
	reg				dc_T_HOTRESET_EXIT;
	reg				dc_LESS_T_POLLING_SCD_LFPS;

	reg [31:0]	cnt_ltssm = 0;


assign	ltssm_state = state;
reg [4:0] state_d ;
reg partner_looking_d ;
reg u3_detect ;
reg [31:0] recovery_cnt;
reg partner_detected_lfps = 0 ;


reg tc_equals_8 ;
reg tc_equals_10;
reg tc_equals_16;
reg tc_larger_1 ;
reg tc_less_8 ;

reg tsc_less_32 	;
reg tsc_equals_32 	;
reg tsc_less_64 	;
reg tsc_equals_64 	;
reg tsc_lager_64 	;
reg tsc_less_80 	;
reg tsc_equals_80 	;

reg sc_equals_1 ;

reg lfps_send_scd1_flg0 ;
reg lfps_send_scd1_flg1 ;
reg lfps_send_scd1_flg2 ;
reg lfps_send_scd1_flg3 ;
reg lfps_send_scd1_flg4 ;
reg lfps_send_scd1_flg5 ;
reg lfps_send_scd1_flg6 ;
reg lfps_send_scd1_flg7 ;
reg lfps_send_scd1_flg8 ;

reg lfps_send_scd2_flg0 ;
reg lfps_send_scd2_flg1 ;
reg lfps_send_scd2_flg2 ;
reg lfps_send_scd2_flg3 ;
reg lfps_send_scd2_flg4 ;
reg lfps_send_scd2_flg5 ;
reg lfps_send_scd2_flg6 ;
reg lfps_send_scd2_flg7 ;
reg lfps_send_scd2_flg8 ;

reg lfps_send_ecd_flg0 ;
reg lfps_send_ecd_flg1 ;
reg lfps_send_ecd_flg2 ;

reg lfps_send_lbmp_flg0  ;
reg lfps_send_lbmp_flg1  ;
reg lfps_send_lbmp_flg2  ;

reg lfps_send_lbmp_flg3  ;
reg lfps_send_lbmp_flg4  ;
reg lfps_send_lbmp_flg5  ;
	
reg lfps_send_lbmp_flg6  ;
reg lfps_send_lbmp_flg7  ;
reg lfps_send_lbmp_flg8  ;
reg lfps_send_lbmp_flg9  ;

reg lfps_send_lbmp_flg10  ;
reg lfps_send_lbmp_flg11  ;
reg lfps_send_lbmp_flg12  ;

reg lfps_recv_measure_flg0 ;
reg lfps_recv_measure_flg1 ;

reg lfps_recv_scd_flg0 ;
reg lfps_recv_scd_flg1 ;
reg lfps_recv_scd_flg2 ;
reg lfps_recv_scd_flg3 ;
reg lfps_recv_scd_flg4 ;

reg lfps_recv_lbpm_flg0 ;
reg lfps_recv_lbpm_flg1 ;
reg lfps_recv_lbpm_flg2 ;


always @(posedge local_clk) begin

	if(dc == T_SS_INACTIVE_QUIET)		dc_T_SS_INACTIVE_QUIET 		<= 1; else dc_T_SS_INACTIVE_QUIET 		<= 0;
	if(dc == T_RX_DETECT_QUIET)			dc_T_RX_DETECT_QUIET 		<= 1; else dc_T_RX_DETECT_QUIET 		<= 0;
	if(dc == T_POLLING_LFPS)			dc_T_POLLING_LFPS 			<= 1; else dc_T_POLLING_LFPS 			<= 0;
	if(dc == T_POLLING_ACTIVE)			dc_T_POLLING_ACTIVE 		<= 1; else dc_T_POLLING_ACTIVE 			<= 0;
	if(dc == T_POLLING_CONFIG)			dc_T_POLLING_CONFIG 		<= 1; else dc_T_POLLING_CONFIG 			<= 0;
	if(dc == T_POLLING_CONFIG_8MS)		dc_T_POLLING_CONFIG_8MS 	<= 1; else dc_T_POLLING_CONFIG_8MS 		<= 0;
	if(dc == T_POLLING_IDLE)			dc_T_POLLING_IDLE 			<= 1; else dc_T_POLLING_IDLE 			<= 0;
	if(dc == LFPS_BURST_PING_NOM + 10)	dc_LFPS_BURST_PING_NOM 		<= 1; else dc_LFPS_BURST_PING_NOM 		<= 0;
	if(dc == 26'd6250000)				dc_6250000 					<= 1; else dc_6250000 					<= 0;
	if(dc == T_RECOV_ACTIVE)			dc_T_RECOV_ACTIVE 			<= 1; else dc_T_RECOV_ACTIVE 			<= 0;
	if(dc == T_RECOV_CONFIG)			dc_T_RECOV_CONFIG 			<= 1; else dc_T_RECOV_CONFIG 			<= 0;
	if(dc == T_RECOV_IDLE)				dc_T_RECOV_IDLE 			<= 1; else dc_T_RECOV_IDLE 				<= 0;
	if(dc == T_HOTRESET_ACTIVE)			dc_T_HOTRESET_ACTIVE 		<= 1; else dc_T_HOTRESET_ACTIVE 		<= 0;
	if(dc == T_HOTRESET_EXIT)			dc_T_HOTRESET_EXIT 			<= 1; else dc_T_HOTRESET_EXIT 			<= 0;
	if(dc <= T_POLLING_SCD_LFPS)		dc_LESS_T_POLLING_SCD_LFPS 	<= 1; else dc_LESS_T_POLLING_SCD_LFPS 	<= 0;

	tc_equals_8 <= tc ==  8 ;
	tc_equals_10 <= tc ==  10 ;
	tc_equals_16 <= tc ==  16 ;
	tc_larger_1 <= tc > 1 ;
	tc_less_8 <= tc < 8 ;
	
	tsc_less_32 <= tsc < 16*2 ; 
	tsc_equals_32 <= tsc == 16*2 ;
	tsc_less_64 <= tsc < 16*4 ;
	tsc_equals_64 <= tsc == 16*4 ;
	tsc_lager_64 <= tsc > 16*4 ;
	tsc_less_80 <= tsc < 20*4 ;
	tsc_equals_80 <= tsc == 20*4 ;

	sc_equals_1 <= sc == 1 ;

	`ifndef DISABLE_USB_3_1
	lfps_send_scd1_flg0 <= sc < LFPS_SCD_0_NOM ;
	lfps_send_scd1_flg1 <= sc < LFPS_SCD_0_TOTAL_NOM;
	lfps_send_scd1_flg2 <= sc < LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_NOM;
	lfps_send_scd1_flg3 <= sc < LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM;
	lfps_send_scd1_flg4 <= sc < LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_NOM;
	lfps_send_scd1_flg5 <= sc < LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM;
	lfps_send_scd1_flg6 <= sc < LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_0_NOM;
	lfps_send_scd1_flg7 <= sc < LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM - 1;
	lfps_send_scd1_flg8 <= sc == LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM - 1;

	lfps_send_scd2_flg0 <= sc < LFPS_SCD_1_NOM;
	lfps_send_scd2_flg1 <= sc < LFPS_SCD_1_TOTAL_NOM;
	lfps_send_scd2_flg2 <= sc < LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_NOM;
	lfps_send_scd2_flg3 <= sc < LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM;
	lfps_send_scd2_flg4 <= sc < LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_NOM;
	lfps_send_scd2_flg5 <= sc < LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM;
	lfps_send_scd2_flg6 <= sc < LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_1_NOM;
	lfps_send_scd2_flg7 <= sc < LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM - 1;
	lfps_send_scd2_flg8 <= sc == LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM - 1;

	lfps_send_ecd_flg0 <= sc < LFPS_ECD_NOM ;
	lfps_send_ecd_flg1 <= sc < LFPS_ECD_TOTAL_NOM - 1 ;
	lfps_send_ecd_flg2 <= sc == LFPS_ECD_TOTAL_NOM - 1;

	lfps_send_lbmp_flg0  <= sc < LFPS_LBPM_PWM_TOTAL_NOM - 1 ;
	lfps_send_lbmp_flg1  <= sc < LFPS_LBPM_PWM_TOTAL_NOM ;
	lfps_send_lbmp_flg2  <= sc == LFPS_LBPM_PWM_TOTAL_NOM ;

	lfps_send_lbmp_flg3  <= sc < LFPS_LBPM_PWM_TOTAL_NOM - 1 ;
	lfps_send_lbmp_flg4  <= sc < LFPS_LBPM_PWM_TOTAL_NOM ;
	lfps_send_lbmp_flg5  <= sc == LFPS_LBPM_PWM_TOTAL_NOM ;
	
	lfps_send_lbmp_flg6  <=  sc < LFPS_LBPM_0_PWM_NOM;
	lfps_send_lbmp_flg7  <=  sc < LFPS_LBPM_1_PWM_NOM ;
	lfps_send_lbmp_flg8  <=  sc < LFPS_LBPM_PWM_TOTAL_NOM;
	lfps_send_lbmp_flg9  <=  sc == LFPS_LBPM_PWM_TOTAL_NOM;

	lfps_send_lbmp_flg10  <=  sc < LFPS_LBPM_PWM_TOTAL_NOM - 1 ;
	lfps_send_lbmp_flg11  <=  sc < LFPS_LBPM_PWM_TOTAL_NOM ;
	lfps_send_lbmp_flg12  <=  sc == LFPS_LBPM_PWM_TOTAL_NOM ;

	lfps_recv_measure_flg0 <= rc2 >= LFPS_POLLING_MIN && rc2 < LFPS_POLLING_MAX ;
	lfps_recv_measure_flg1 <= rc2 >= LFPS_LBPM_PWM_TOTAL_MIN && rc2 < LFPS_LBPM_PWM_TOTAL_MAX;

	lfps_recv_scd_flg0 <= rc2 >= LFPS_SCD_0_TOTAL_MIN && rc2 < LFPS_SCD_0_TOTAL_MAX ;
	lfps_recv_scd_flg1 <= rc2 >= LFPS_SCD_1_TOTAL_MIN && rc2 < LFPS_SCD_1_TOTAL_MAX;
	lfps_recv_scd_flg2 <= rc2 >= LFPS_SCD_0_TOTAL_MIN && rc2 < LFPS_SCD_0_TOTAL_MAX;
	lfps_recv_scd_flg3 <= rc2 >= LFPS_SCD_1_TOTAL_MIN && rc2 < LFPS_SCD_1_TOTAL_MAX;
	lfps_recv_scd_flg4 <= rc2 > LFPS_ECD_TOTAL_NOM;

	lfps_recv_lbpm_flg0 <= rc2 >= LFPS_LBPM_1_PWM_MIN && rc2 < LFPS_LBPM_1_PWM_MAX;
	lfps_recv_lbpm_flg1 <= rc2 >= LFPS_LBPM_0_PWM_MIN && rc2 < LFPS_LBPM_0_PWM_MAX;
	lfps_recv_lbpm_flg2 <= rc2 < LFPS_LBPM_PWM_TOTAL_MAX;
	`else
	lfps_send_scd1_flg0 <= 0;
	lfps_send_scd1_flg1 <= 0;
	lfps_send_scd1_flg2 <= 0;
	lfps_send_scd1_flg3 <= 0;
	lfps_send_scd1_flg4 <= 0;
	lfps_send_scd1_flg5 <= 0;
	lfps_send_scd1_flg6 <= 0;
	lfps_send_scd1_flg7 <= 0;
	lfps_send_scd1_flg8 <= 0;

	lfps_send_scd2_flg0 <= 0;
	lfps_send_scd2_flg1 <= 0;
	lfps_send_scd2_flg2 <= 0;
	lfps_send_scd2_flg3 <= 0;
	lfps_send_scd2_flg4 <= 0;
	lfps_send_scd2_flg5 <= 0;
	lfps_send_scd2_flg6 <= 0;
	lfps_send_scd2_flg7 <= 0;
	lfps_send_scd2_flg8 <= 0;

	lfps_send_ecd_flg0 <= 0;
	lfps_send_ecd_flg1 <= 0;
	lfps_send_ecd_flg2 <= 0;

	lfps_send_lbmp_flg0  <= 0;
	lfps_send_lbmp_flg1  <= 0;
	lfps_send_lbmp_flg2  <= 0;

	lfps_send_lbmp_flg3  <= 0;
	lfps_send_lbmp_flg4  <= 0;
	lfps_send_lbmp_flg5  <= 0;
	
	lfps_send_lbmp_flg6  <=  0;
	lfps_send_lbmp_flg7  <=  0;
	lfps_send_lbmp_flg8  <=  0;
	lfps_send_lbmp_flg9  <=  0;

	lfps_send_lbmp_flg10  <=  0;
	lfps_send_lbmp_flg11  <=  0;
	lfps_send_lbmp_flg12  <=  0;

	lfps_recv_measure_flg0 <= 0;
	lfps_recv_measure_flg1 <= 0;

	lfps_recv_scd_flg0 <= 0;
	lfps_recv_scd_flg1 <= 0;
	lfps_recv_scd_flg2 <= 0;
	lfps_recv_scd_flg3 <= 0;
	lfps_recv_scd_flg4 <= 0;

	lfps_recv_lbpm_flg0 <= 0;
	lfps_recv_lbpm_flg1 <= 0;
	lfps_recv_lbpm_flg2 <= 0;
	`endif

	rate_d1 <= rate_r ;
	rate <= rate_r ;
	
	`ifndef DISABLE_USB_3_1
	gen2_attempts_equal_15 <= gen2_attempts == 4'd15 ;
	`else
	gen2_attempts_equal_15 <= 1'b1 ;
	`endif
end


always @(posedge local_clk or negedge reset_n or negedge dc_rst_n ) begin
	if ( !reset_n ) begin
		dc <= 0 ;
	end
	else if ( !dc_rst_n ) begin
		dc <= 0 ;
	end
	else begin
		dc <= dc + 1 ;
	end
end

always @(posedge local_clk) begin

	
	partner_looking_d <= partner_looking ;
	if ( !reset_n ) begin
		partner_looking_d <= 0 ;
		u3_detect <= 0 ;
		CP_X <= 0;
		train_ts1_rec <= 0 ;
	end
	
	state_d <= state ;

	// synchronizers
	{vbus_present_2, vbus_present_1} <= {vbus_present_1, vbus_present};
	{port_rx_elecidle_2, port_rx_elecidle_1} <= {port_rx_elecidle_1, port_rx_elecidle};
	{port_rx_valid_2, port_rx_valid_1} <= {port_rx_valid_1, port_rx_valid};

	// default levels for outputs
	port_rx_term <= 1;
	port_tx_detrx_lpbk <= 0;
	port_tx_elecidle <= 1;
	partner_detect <= 0;
	port_power_go <= 0;
	ltssm_is_training <= 0;

	training <= 0;
	train_rxeq <= 0;
	train_active <= 0;
	train_config <= 0;
	train_idle <= 0;
	train_hot_reset <= 0;
	train_compliance <= 0;

	lfps_send_ping_ack <= 0;
	lfps_send_ack <= 0;
	lfps_send_local <= 0;
	lfps_send_poll_local <= 0;
	lfps_send_scd1_local <= 0;
	lfps_send_scd2_local <= 0;
	lfps_send_phy_cab_local <= 0;
	lfps_send_phy_ready_local <= 0;
	lfps_send_ping_local <= 0;
	lfps_send_u1_local <= 0;
	lfps_send_u2lb_local <= 0;
	lfps_send_u3_local <= 0;
	lfps_send_reset_local <= 0;

	lfps_recv_active <= 0;
	lfps_recv_poll_u1 <= 0;
	lfps_recv_scd1 <= 0;
	lfps_recv_scd2 <= 0;
	lfps_recv_ping <= 0;
	lfps_recv_reset <= 0;
	lfps_recv_u2lb <= 0;
	lfps_recv_u3 <= 0;
	// recv_lbpm_0 <= 0;
	// recv_lbpm_1 <= 0;

	warm_reset <= 0;
	go_recovery_latch <= go_recovery;
	ts_timeout_cnt <= 0;
	


	// counters
	if(!reset_n)
	begin
		//dc <= 0;
		sc <= 0;
		sic <= 0;
		rc <= 0;
		ric <= 0;
		recovery_cnt <= 0;
	end
	else
	begin
		//`INC(dc);
		`INC(sc);
		`INC(sic);
		`INC(rc);
		`INC(ric);
		`INC(recovery_cnt);
	end

	dc_rst_n <= 1 ;

	///////////////////////////////////////
	// LTSSM FSM
	///////////////////////////////////////
	case(state)
	LT_SS_DISABLED: begin
		port_power_down <= POWERDOWN_2;
		port_power_go <= 1;
		if(~gen2_attempts_equal_15) begin
			rate_r <= 1;
		end
		else begin
			rate_r <= 0;
		end
		partner_rate <= 1;
		has_trained <= 0;
		//port_rx_term <= 0;

		if(lfps_recv_reset) state <= LT_RX_DETECT_RESET;
		// if(dc_T_SS_INACTIVE_QUIET) begin
		// 	dc_rst_n <= 0;
		// 	state <= LT_RX_DETECT_RESET;
		// end
	end
	LT_SS_INACTIVE: begin
		// reset timeout counter and drop to P2 if not already
		//dc <= 0;
		dc_rst_n <= 0;
		port_power_down <= POWERDOWN_2;
		port_power_go <= 1;
		if(~gen2_attempts_equal_15) begin
			rate_r <= 1;
		end
		else begin
			rate_r <= 0;
		end
		partner_rate <= 1;
		has_trained <= 0;
		if(port_power_ack) state <= LT_SS_INACTIVE_QUIET;
	end
	LT_SS_INACTIVE_QUIET: begin
		if(dc_T_SS_INACTIVE_QUIET) begin
			state <= LT_SS_INACTIVE_DETECT_0;
		end
	end
	LT_SS_INACTIVE_DETECT_0: begin
		// partner_detect <= 1;
		// if(partner_looking) 
			state <= LT_SS_INACTIVE_DETECT_1;
	end
	LT_SS_INACTIVE_DETECT_1: begin
		//dc <= 0;
		dc_rst_n <= 0;		
		state <= LT_RX_DETECT_RESET;
		// if(~partner_looking) begin
		// 	if(partner_detected) begin
		// 		// we're still connected to the host, continue waiting for unplug
		// 		state <= LT_SS_INACTIVE_QUIET;
		// 	end else begin
		// 		// disconnect, start looking for new host
		// 		state <= LT_RX_DETECT_RESET;
		// 	end
		// end
	end

	LT_RX_DETECT_RESET: begin
		// IF WARM RESET:
		// finish transmitting LFPS.Reset until the duration
		// is reached. (TODO)
		port_power_down <= POWERDOWN_2;
		port_power_go <= 1;
		rx_detect_attempts <= 0;
		state <= LT_RX_DETECT_ACTIVE_0;
		hot_reset_latch <= 0;
		// rate_r <= 1; // default to USB3.1 rate
		if(~gen2_attempts_equal_15) begin
			rate_r <= 1;
		end
		else begin
			rate_r <= 0;
		end
		partner_rate <= 1;
		has_trained <= 0;
	end
	LT_RX_DETECT_ACTIVE_0: begin
		partner_detect <= 1;
		if(partner_looking) 
			state <= LT_RX_DETECT_ACTIVE_1;
	end
	LT_RX_DETECT_ACTIVE_1: begin
		// state <= LT_POLLING_LFPS;
		// state <= LT_POLLING_PORT_MATCH;
		// state <= LT_POLLING_RXEQ_0;
		if(~partner_looking) begin
			//dc <= 0;
			dc_rst_n <= 0;
			if(partner_detected) begin
				// far-end termination detected
				// if ( u3_detect ) begin
				// 	state <= LT_U3 ;
				// 	u3_detect <= 0 ;
				// end
				// else begin 
					polling_lfps_sent <= 0;
					polling_lfps_received <= 0;
					polling_scd_lfps_sent <= 0;
					polling_scd_lfps_received <= 0;
					polling_lfps_sent_after_recv <= 0;
					state <= LT_POLLING_LFPS;
				// end
			end 
			// else if(partner_detected_lfps) begin
			// 	// far-end termination detected via LFPS
			// 	polling_lfps_sent <= 0;
			// 	polling_lfps_received <= 0;
			// 	polling_scd_lfps_sent <= 0;
			// 	polling_scd_lfps_received <= 0;
			// 	polling_lfps_sent_after_recv <= 0;
			// 	partner_detected_lfps <= 0;
			// 	state <= LT_POLLING_LFPS;
			// end
			else begin
			// 261008 乆
				// not found

				`INC(rx_detect_attempts);
				if(rx_detect_attempts == 7) begin
					state <= LT_SS_DISABLED;
				end else begin
					state <= LT_RX_DETECT_QUIET;
				end
			// 旧设计
				// `INC(rx_detect_attempts);
				// 	state <= LT_RX_DETECT_QUIET;
			end
		end
		
		// if(lfps_recv_poll_u1 | lfps_recv_scd1) begin
		// 	partner_detected_lfps <= 1;
		// end
	end
	LT_RX_DETECT_QUIET: begin
		// wait a bit, then run the farend detection again
		if(dc_T_RX_DETECT_QUIET) begin
			// state <= LT_RX_DETECT_RESET;
			state <= LT_RX_DETECT_ACTIVE_0;
		end
	end
	LT_POLLING_LFPS: begin
		lfps_send_poll_local <= 1;
		lfps_send_scd2_local <= 0;
		`ifndef DISABLE_USB_3_1
		if(gen2_attempts_equal_15) begin
			lfps_send_scd1_local <= 0;
		end
		else if(polling_scd_lfps_received > 0) begin
			lfps_send_scd1_local <= 1;
		end
		else if(polling_lfps_received >= 8 && polling_scd_lfps_received == 0 && polling_scd_lfps_sent >= 4) begin
			lfps_send_scd1_local <= 0;
		end
		else if(dc_LESS_T_POLLING_SCD_LFPS) begin
			lfps_send_scd1_local <= 1;
		end 
		`endif

		// receiving Polling.LFPS from link partner
		`ifndef DISABLE_USB_3_1
		if(lfps_recv_scd1 | lfps_recv_scd2) begin
			if(polling_scd_lfps_received < 15)
				`INC(polling_scd_lfps_received);
		end
		`endif

		if(lfps_recv_poll_u1 ) begin
			if(polling_lfps_received < 15)
				`INC(polling_lfps_received);
		end

		// confirmed LFPS fsm sent
		if(lfps_send_scd1_local) begin
			if(lfps_send_ack) begin
				if(polling_lfps_sent_after_recv < 2 && polling_scd_lfps_received > 0)
					`INC(polling_lfps_sent_after_recv);
				if(polling_scd_lfps_sent < 27) //20
					`INC(polling_scd_lfps_sent);
			end
		end
		else begin
			if(lfps_send_ack) begin
				if(polling_lfps_sent_after_recv < 15 && polling_lfps_received > 0)
					`INC(polling_lfps_sent_after_recv);
				if(polling_lfps_sent < 54) //20
					`INC(polling_lfps_sent);
			end
		end

		// exit conditions
		if(polling_lfps_sent_after_recv >= 4 &&
			polling_lfps_sent >= 16 && //16
			polling_lfps_received >= 2) begin
			// done
			lfps_send_poll_local <= 0;
			lfps_send_scd1_local <= 0;
			rate_r <= 0;
			if(gen2_attempts_equal_15) begin
				polling_lfps_sent <= 0;
				polling_scd_lfps_sent <= 0;
				polling_scd_lfps_received <= 0;
				polling_lfps_received <= 0;
				polling_lfps_sent_after_recv <= 0;
				state <= LT_POLLING_RXEQ_0;
				dc_rst_n <= 0;
				has_trained <= 1;
			end
			else begin
				if(rate_changed ) begin
					polling_lfps_sent <= 0;
					polling_scd_lfps_sent <= 0;
					polling_scd_lfps_received <= 0;
					polling_lfps_received <= 0;
					polling_lfps_sent_after_recv <= 0;
					state <= LT_POLLING_RXEQ_0;
					dc_rst_n <= 0;
					has_trained <= 1;
					if(~gen2_attempts_equal_15) begin
						`INC(gen2_attempts);
					end
				end
			end
		end
		else if(polling_lfps_sent_after_recv >= 2 &&
			polling_scd_lfps_received > 0) begin

			// done
			if(~gen2_attempts_equal_15) begin
				`INC(gen2_attempts);
			end
			lfps_send_poll_local <= 0;
			lfps_send_scd1_local <= 0;
			polling_lfps_sent <= 0;
			polling_scd_lfps_sent <= 0;
			polling_scd_lfps_received <= 0;
			polling_lfps_received <= 0;
			polling_lfps_sent_after_recv <= 0;
			state <= LT_POLLING_LFPS_PLUS;
			dc_rst_n <= 0;
		end
		
		//if(dc_T_POLLING_LFPS) begin
		//	// timed out
		//	state <= LT_RX_DETECT_RESET;
		//	//dc <= 0;
		//	dc_rst_n <= 0;
		//end

		// if(dc_T_POLLING_LFPS) begin
			// state <= LT_RX_DETECT_RESET;		
			// dc_rst_n <= 0;
		// end
		
		if(dc_T_POLLING_LFPS) begin
			CP_X <= 0;
			state <= LT_COMPLIANCE;		
			dc_rst_n <= 0;
			port_power_down <= POWERDOWN_0;
			port_power_go <= 1;
		end
	end
	LT_POLLING_LFPS_PLUS : begin
		lfps_send_poll_local <= 1;
		lfps_send_scd2_local <= 1;

		// receiving Polling.LFPS from link partner
		if(lfps_recv_scd2) begin
			if(polling_lfps_received < 15)
				`INC(polling_lfps_received);
		end

		// confirmed LFPS fsm sent
		if(lfps_send_ack) begin
			if(polling_lfps_sent_after_recv < 2 && polling_lfps_received > 0)
				`INC(polling_lfps_sent_after_recv);
			if(polling_lfps_sent < 27) //20
				`INC(polling_lfps_sent);
		end

		// exit conditions
		if(	polling_lfps_sent_after_recv >= 2 &&
			polling_lfps_received >= 0) begin

			// done
			lfps_send_poll_local <= 0;
			lfps_send_scd2_local <= 0;
			polling_lfps_sent <= 0;
			polling_lfps_received <= 0;
			polling_lfps_sent_after_recv <= 0;
			state <= LT_POLLING_PORT_MATCH;
			dc_rst_n <= 0;
		end
		
		if(dc_T_POLLING_LFPS) begin
			// timed out
			state <= LT_RX_DETECT_RESET;
			//dc <= 0;
			dc_rst_n <= 0;
		end
	end
	LT_POLLING_PORT_MATCH : begin
		lfps_send_poll_local <= 1;
		lfps_send_phy_cab_local <= 1;
		// lbpm_data_out <= {PHY_CAPABILITY, PHY_LANE_RATE_10G, 2'b00, PHY_SIGNAL_LANE, 2'b00};
		if(!has_trained) begin
			lbpm_data_out <= {2'b00, PHY_SIGNAL_LANE, 2'b00, PHY_LANE_RATE_10G, PHY_CAPABILITY};
		end
		else begin
			lbpm_data_out <= {2'b00, PHY_SIGNAL_LANE, 2'b00, PHY_LANE_RATE_5G, PHY_CAPABILITY};
		end

		// receiving Polling.LFPS from link partner
		if(lfps_recv_port_match) begin
			lbpm_data_in_latch <= lbpm_data_in;
			partner_rate <= lbpm_data_in[2];
			if(polling_lfps_received < 15)
				`INC(polling_lfps_received);
		end

		// confirmed LFPS fsm sent
		if(lfps_send_ack) begin
			if(polling_lfps_sent_after_recv < 4 && polling_lfps_received > 0)
				`INC(polling_lfps_sent_after_recv);
			if(polling_lfps_sent < 27) //20
				`INC(polling_lfps_sent);
		end 

		// exit conditions
		if(	polling_lfps_sent_after_recv >= 4 &&
			polling_lfps_received >= 4) begin

			// done
			lfps_send_poll_local <= 0;
			lfps_send_phy_cab_local <= 0;
			polling_lfps_sent <= 0;
			polling_lfps_received <= 0;
			polling_lfps_sent_after_recv <= 0;
			state <= LT_POLLING_PORT_CONFIG;
			dc_rst_n <= 0;
		end
		
		if(dc_T_POLLING_CONFIG) begin
			// timed out
			state <= LT_RX_DETECT_RESET;
			//dc <= 0;
			dc_rst_n <= 0;
		end
	end
	LT_POLLING_PORT_CONFIG : begin
		lfps_send_poll_local <= 1;
		lfps_send_phy_cab_local <= 1;
		lbpm_data_out <= {6'b000000, PHY_READY};

		// receiving Polling.LFPS from link partner
		if(lfps_recv_port_match) begin
			lbpm_data_in_latch <= lbpm_data_in;
			if(polling_lfps_received < 15 && lbpm_data_in == {6'b000000, PHY_READY})
				`INC(polling_lfps_received);
		end

		// confirmed LFPS fsm sent
		if(lfps_send_ack) begin
			if(polling_lfps_sent_after_recv < 4 && polling_lfps_received > 0)
				`INC(polling_lfps_sent_after_recv);
			if(polling_lfps_sent < 27) //20
				`INC(polling_lfps_sent);
		end

		// exit conditions
		if(	polling_lfps_sent_after_recv >= 4 &&
			polling_lfps_received >= 2) begin

			// done
			if(partner_rate) begin
				rate_r <= 1;
				lfps_send_poll_local <= 0;
				lfps_send_phy_cab_local <= 0;
				polling_lfps_sent <= 0;
				polling_lfps_received <= 0;
				polling_lfps_sent_after_recv <= 0;
				state <= LT_POLLING_RXEQ_0;
				dc_rst_n <= 0;
			end
			else begin
				rate_r <= 0;
				if(rate_changed ) begin
					lfps_send_poll_local <= 0;
					lfps_send_phy_cab_local <= 0;
					polling_lfps_sent <= 0;
					polling_lfps_received <= 0;
					polling_lfps_sent_after_recv <= 0;
					state <= LT_POLLING_RXEQ_0;
					dc_rst_n <= 0;
				end
			end
		end
		
		if(dc_T_POLLING_CONFIG) begin
			// timed out
			state <= LT_RX_DETECT_RESET;
			//dc <= 0;
			dc_rst_n <= 0;
		end
		//if(dc == T_POLLING_LFPS) begin
		//	CP_X <= 0;
		//	state <= LT_COMPLIANCE;		
		//	dc <= 0;
		//	port_power_down <= POWERDOWN_0;
		//	port_power_go <= 1;
		//end
	end
	LT_POLLING_RXEQ_0: begin
		// wait for any straggling LFPS sends to clear
		//dc <= 0;
		ltssm_is_training <= 1;
		dc_rst_n <= 0;
		if(lfps_send_state == LFPS_IDLE) state <= LT_POLLING_RXEQ_1;
	end
	LT_POLLING_RXEQ_1: begin
		ltssm_is_training <= 1;
		port_power_down <= POWERDOWN_0;
		port_power_go <= 1;

		// maintain values, unless overridden below
		training <= 1;
		train_rxeq <= train_rxeq;

		// wait until P0 powerdown is entered so that
		// the transceiver proper is ready
		if(port_power_ack) begin
			// signal to PIPE module, TSEQ 65536 send
			train_rxeq <= 1;
		end
		if(train_rxeq_pass) begin
			// reset timeout count and proceed
			//dc <= 0;
			dc_rst_n <= 0;
			tc <= 0;
			state <= LT_POLLING_ACTIVE;
		end
	end
	LT_POLLING_ACTIVE: begin
		// send TS1 until 8 consecutive TS are received
		ltssm_is_training <= 1;
		training <= 1;
		train_active <= 1;

		if(train_ts1 | train_ts2) begin
			`INC(tc);
		end
		else begin
			`INC(ts_timeout_cnt);
			if(ts_timeout_cnt == 5) begin
				// timeout, reset count
				ts_timeout_cnt <= 0;
				tc <= 0;
			end
		end

		// if(train_ts2) `INC(tc);

		//if(tc == 8) begin
		if(tc_equals_8) begin
			// received 8 consecutive(TODO?) TS1/TS2
			// reset timeout count and proceed
			//dc <= 0;
			dc_rst_n <= 0;
			tc <= 0;
			tsc <= 0;
			ts_timeout_cnt <= 0;
			state <= LT_POLLING_CONFIG;
		end

		// timeout
		if(dc_T_POLLING_ACTIVE && !has_trained) begin 
			has_trained <= 1;
			port_power_down <= POWERDOWN_2;
			port_power_go <= 1;
			state <= LT_POLLING_PORT_MATCH;
		end 
		else if(dc_T_POLLING_ACTIVE && has_trained) begin 
			rate_r <= 1;
			state <= LT_RX_DETECT_RESET;
		end
	end
	LT_POLLING_CONFIG: begin
		ltssm_is_training <= 1;
		training <= 1;
		train_config <= 1;
		// train_active <= 1;
		
		if(hot_reset) begin
			hot_reset_latch <= 1;
		end

		// increment TS2 receive count up to 8
		// if(train_ts2) begin
		// 	if(tc < 8) `INC(tc);
		// end
		if(tc < 8) begin
			if(train_ts2) begin
				`INC(tc);
			end
			else begin
				`INC(ts_timeout_cnt);
				if(ts_timeout_cnt == 5) begin
					// timeout, reset count
					ts_timeout_cnt <= 0;
					tc <= 0;
				end
			end
		end
		// increment TS2 send count, sequence is 2 cycles long
		//if(tc > 0 && tsc < 16*2) `INC(tsc);
		if(tc > 0 && tsc_less_32 && rate_d1) `INC(tsc);
		if(tc > 0 && tsc_less_64 && !rate_d1) `INC(tsc);

		// exit criteria
		// received 8 and sent 16
		//if(tc == 8 && tsc == 16*2) begin
		//if(tc_equals_8 && tsc == 16*2) begin
		if(tc_equals_8 && tsc_equals_32 && rate_d1) begin
			// reset timeout count and proceed
			//dc <= 0;
			dc_rst_n <= 0;
			tc <= 0;
			tsc <= 0;
			state <= LT_POLLING_IDLE;
		end
		else if(tc_equals_8 && tsc_equals_64 && !rate_d1) begin
			// reset timeout count and proceed
			//dc <= 0;
			dc_rst_n <= 0;
			tc <= 0;
			tsc <= 0;
			state <= LT_POLLING_IDLE;
		end

		// timeout
		if(dc_T_POLLING_CONFIG && !has_trained) begin 
			has_trained <= 1;
			port_power_down <= POWERDOWN_2;
			port_power_go <= 1;
			state <= LT_POLLING_PORT_MATCH;
		end 
		else if(dc_T_POLLING_CONFIG && has_trained && gen2_attempts_equal_15) begin 
			rate_r <= 0;
			port_power_down <= POWERDOWN_2;
			port_power_go <= 1;
			state <= LT_RX_DETECT_RESET;
		end
		else if(dc_T_POLLING_CONFIG && has_trained && rate_r) begin 
			rate_r <= 1;
			port_power_down <= POWERDOWN_2;
			port_power_go <= 1;
			state <= LT_RX_DETECT_RESET;
		end
		else if(dc_T_POLLING_CONFIG && has_trained && !rate_r) begin 
			rate_r <= 1;
			port_power_down <= POWERDOWN_2;
			port_power_go <= 1;
			state <= LT_RX_DETECT_RESET;
		end

		if(lfps_recv_poll_u1 ) begin
			if(polling_lfps_received < 15)
				`INC(polling_lfps_received);
		end

		if(polling_lfps_received == 15 && !rate_d1) begin
			rate_r <= 1;
			port_power_down <= POWERDOWN_2;
			port_power_go <= 1;
			state <= LT_RX_DETECT_RESET;
		end
	end
	LT_POLLING_IDLE: begin
		ltssm_is_training <= 1;
		training <= 1;
		train_idle <= 1;

		if(train_idle_pass) begin
			// exit conditions:
			// 16 IDLE symbol sent after receiving
			// first of at least 8 symbols.
			//dc <= 0;
			dc_rst_n <= 0;
			state <= LT_U0;
			has_trained <= 1;
		end
		if(hot_reset) begin
			hot_reset_latch <= 1;
		end
		if(hot_reset_latch)
			state <= LT_HOTRESET;
		if(loopback) //local_loopback
			state <= LT_LOOPBACK;

		// timeout
		if(dc_T_POLLING_IDLE && !has_trained) begin 
			has_trained <= 1;
			state <= LT_POLLING_PORT_MATCH;
		end 
		else if(dc_T_POLLING_IDLE && has_trained) begin 
			rate_r <= 1;
			state <= LT_RX_DETECT_RESET;
		end
		
	end
	LT_U0: begin
		// N.B. relevant LTSSM timeouts were moved to the Link Layer
		// module since it is more practical to have them there, and not here

		if(!train_ts1_rec & train_ts1) begin
			// TS1 detected, go to Recovery
			train_ts1_rec <= 1 ;
			//state <= LT_RECOVERY;
		end else
		if(go_recovery_latch) begin
			// link layer had a problem, Recovery
			train_ts1_rec <= 0 ;
			state <= LT_RECOVERY;
		end else
		if(go_u == 3'b101) begin
			// link layer requests U1
			port_power_down <= POWERDOWN_1;
			port_power_go <= 1;
			if(port_power_ack) begin
				//dc <= 0;
				dc_rst_n <= 0;
				state <= LT_U1;
			end
		end else
		if(go_u == 3'b110) begin
			// link layer requests U2
			port_power_down <= POWERDOWN_2;
			port_power_go <= 1;
			if(port_power_ack) state <= LT_U2;
		end else 
		if(go_u == 3'b111) begin
			// link layer requests U3
			port_power_down <= POWERDOWN_2; // our clock depends on PHY so don't suicide
			port_power_go <= 1;
			if(port_power_ack) begin 
				state <= LT_U3;
				//dc <= 0 ;
				dc_rst_n <= 0;
			end
		end else 
		if(hot_reset)
			state <= LT_HOTRESET;
	end
	LT_U1: begin
		// U1 power saving state
		// PIPE module should turn off its bus and only use LFPS to resume

		if(lfps_recv_poll_u1) begin
			lfps_send_u1_local <= 1;
		end else
		//if(lfps_recv_u2lb ) begin
		//	lfps_send_u2lb_local <= 1;
		//end else
		if(lfps_send_ack) begin
			state <= LT_RECOVERY;
		end else
		if(go_u == 3'b110) begin
			// link layer requests U2
			port_power_down <= POWERDOWN_2;
			port_power_go <= 1;
			if(port_power_ack) state <= LT_U2;
		end else
		if(dc_LFPS_BURST_PING_NOM) begin
			// send Ping.LFPS every 200ms
			//dc <= 0;
			dc_rst_n <= 0;
			lfps_send_ping_local <= 1;
		end
	end
	LT_U2: begin
		// U2 power saving state

		if(lfps_recv_u2lb) begin
			lfps_send_u2lb_local <= 1;
		end
		if(lfps_send_ack) begin
			state <= LT_RECOVERY;
		end
	end
	LT_U3: begin
		// U3 power saving state

		if(lfps_recv_u3) begin
			lfps_send_u3_local <= 1;
		end
		if(lfps_send_ack) begin
			state <= LT_RECOVERY;
		end
		
		if ( dc_6250000 )
			partner_detect <= 1;
		else
			partner_detect <= 0;
		
		if(~partner_looking && partner_looking_d) begin
			//dc <= 0;
			dc_rst_n <= 0;
			if(!partner_detected) begin
				//if(tc == 10) begin
				if(tc_equals_10) begin
					tc <= 0;
					rate_r <= 1 ;
					state <= LT_RX_DETECT_QUIET; 
				end
				else begin
					`INC(tc);
				end
			end
			else begin
				tc <= 0 ;
			end
		end
		
		//if ( dc == 26'h3_ff_ff_ff ) begin
		//	u3_detect <= 1 ;
		//	dc <= 0 ;
		//	state  <= LT_RX_DETECT_ACTIVE_0 ;
		//end
		
		
	
		
	end

	LT_RECOVERY: begin
		// dc <= -10;
		state <= LT_RECOVERY_WAIT;
	end
	LT_RECOVERY_WAIT: begin
		// if(dc == 0) begin
			//dc <= 0;
			dc_rst_n <= 0;
			tc <= 0;
			tsc <= 0;
			recovery_cnt <= 0;

			port_power_down <= POWERDOWN_0;
			port_power_go <= 1;

			if(port_power_ack) state <= LT_RECOVERY_ACTIVE;
		// end
	end
	LT_RECOVERY_ACTIVE: begin
		// send TS1 until 8 consecutive TS are received
		if(train_ts1 | train_ts2)
		begin
			//training <= 1;
			//train_active <= 1;
			`INC(tc);
		end
		// else if(recovery_cnt == 500000) //4ms
		// begin
			training <= 1;
			train_active <= 1;
		// end


		// if(train_ts1 | train_ts2) `INC(tc);

		//if( tc == 8 ) begin
		if( tc_equals_8 ) begin
			// received 8 consecutive(TODO?) TS1/TS2
			// reset timeout count and proceed
			//dc <= 0;
			dc_rst_n <= 0;
			tc <= 0;
			tsc <= 0;
			state <= LT_RECOVERY_CONFIG;
		end

		if(dc_T_RECOV_ACTIVE) state <= LT_SS_INACTIVE;
	end
	LT_RECOVERY_CONFIG: begin
		training <= 1;
		//if (tc < 8) begin
		if (tc_less_8) begin
			train_active <= 1;
			train_config <= 0;
		end
		else begin
			train_active <= 0;
			train_config <= 1;
		end

		// increment TS2 receive count up to 8
		if(train_ts2) begin
			if(tc < 16 ) `INC(tc);
		end
		// increment TS2 send count, sequence is 2 cycles long
		//if(tc >= 8 ) if(tsc < 16*4) `INC(tsc);
		if(tc >= 8 ) if(tsc_less_64) `INC(tsc);

		// exit criteria
		// received 8 and sent 16
		//if(tc == 16 && tsc == 16*4) begin
		//if(tc_equals_16 && tsc == 16*4) begin
		if(tc_equals_16 && tsc_equals_64) begin
			// reset timeout count and proceed
			//dc <= 0;
			dc_rst_n <= 0;
			tc <= 0;
			tsc <= 0;
			state <= LT_RECOVERY_IDLE;
		end

		if(dc_T_RECOV_CONFIG) state <= LT_SS_INACTIVE;
	end
	LT_RECOVERY_IDLE: begin
		training <= 1;
		train_idle <= 1;

		if(hot_reset)
			state <= LT_HOTRESET;

		if(train_idle_pass) begin
			// exit conditions:
			// 16 IDLE symbol sent after receiving
			// first of at least 8 symbols.
			//dc <= 0;
			dc_rst_n <= 0;
			// if(hot_reset)
			// 	state <= LT_HOTRESET;
			// else
				state <= LT_U0;
		end

		if(dc_T_RECOV_IDLE) 
		begin
			state <= LT_SS_INACTIVE;
		end
	end

	LT_COMPLIANCE: begin
		training <= 0;
		train_compliance <= 1'b0;
		if(CP_X < 9) begin
			rate_r <= 1'b0;
		end
		else begin
			rate_r <= 1'b1;
		end
		// state <= LT_RX_DETECT_ACTIVE_0;
		`ifndef DISABLE_USB_3_1
		if(lfps_recv_ping && CP_X < 16)
			CP_X <= CP_X + 1'b1;
        else if(lfps_recv_ping && CP_X >= 16)
			CP_X <= 0;
		`else
		if(lfps_recv_ping && CP_X < 9)
			CP_X <= CP_X + 1'b1;
        else if(lfps_recv_ping && CP_X >= 9)
			CP_X <= 0;
		`endif
//		if(CP_X == 9)
//			state <= LT_RX_DETECT_ACTIVE_0;
		
		case(CP_X)
			4'd4 : begin
				lfps_send_local <= 1'b1;
			end
			4'd7 : begin
				lfps_send_local <= 1'b1;
			end
			4'd8 : begin
				lfps_send_local <= 1'b1;
			end
			default : begin
				lfps_send_local <= 1'b0;
				training <= 1;
				train_compliance <= 1'b1;
			end
		endcase
	end
	LT_LOOPBACK: begin
		state <= LT_LOOPBACK_ACTIVE;
	end
	LT_LOOPBACK_ACTIVE: begin
		if(lfps_recv_u2lb) begin
			lfps_send_u2lb_local <= 1;
		end
		if(lfps_send_ack) begin
			state <= LT_LOOPBACK_EXIT;
		end
	end
	LT_LOOPBACK_EXIT: begin
		state <= LT_RX_DETECT_RESET;
	end
	LT_HOTRESET: begin
		// reset Link Error Count is done by Link Layer
		//if(dc == 3)	
		state <= LT_HOTRESET_ACTIVE;
	end
	LT_HOTRESET_ACTIVE: begin
		training <= 1;
		train_config <= 1;
		if(hot_reset && train_ts2) begin
			hot_reset_latch <= 1;
		end
		else if(!hot_reset && train_ts2) begin
			hot_reset_latch <= 0;
		end
		if(tsc < 18*4 && !rate_d1) begin
			train_hot_reset <= 1;
		end
		else if(tsc < 18*2 && rate_d1) begin
			train_hot_reset <= 1;
		end
		// else if(hot_reset && train_ts2) begin
			// train_hot_reset <= 1;
		// end
		else if(!hot_reset_latch) begin
			train_hot_reset <= 0;
		end
		// increment TS2 receive count up to 8
		if(train_ts2 && !hot_reset) begin
			if(tc < 2) `INC(tc);
		end
		// increment TS2 hot_reset de_assert send count, sequence is 2 cycles long
		if(tsc < 18*4 && !rate_d1) 
		begin
			`INC(tsc);
		end
		else if(tsc < 18*2 && rate_d1) 
		begin
			`INC(tsc);
		end
		else if(tsc >= 18*4 && tsc < 23*4 && !train_hot_reset && !rate_d1)
		begin
			if(tc > 1)
			begin
				`INC(tsc);
			end
		end
		else if(tsc >= 18*2 && tsc < 23*2 && !train_hot_reset && rate_d1)
		begin
			if(tc > 1)
			begin
				`INC(tsc);
			end
		end

		// exit criteria
		// received 8 and sent 16
		if(tc == 2 && tsc == 23*4 && !rate_d1) begin
			// reset timeout count and proceed
			//dc <= 0;
			dc_rst_n <= 0;
			tc <= 0;
			tsc <= 0;
			state <= LT_HOTRESET_EXIT;
		end
		else if(tc == 2 && tsc == 23*2 && rate_d1) begin
			// reset timeout count and proceed
			//dc <= 0;
			dc_rst_n <= 0;
			tc <= 0;
			tsc <= 0;
			state <= LT_HOTRESET_EXIT;
		end
		
		if(dc_T_HOTRESET_ACTIVE) 
		begin
			train_hot_reset <= 0;
			state <= LT_SS_INACTIVE;
		end
	end
	LT_HOTRESET_EXIT: begin
		training <= 1;
		train_idle <= 1;

		if(train_idle_pass) begin
			// exit conditions:
			// 16 IDLE symbol sent after receiving
			// first of at least 8 symbols.
			//dc <= 0;
			dc_rst_n <= 0;
			state <= LT_U0;
		end

		if(dc_T_HOTRESET_EXIT) 
		begin
			state <= LT_SS_INACTIVE;
		end
	end
	LT_RESET: begin
		port_rx_term <= 0;
		port_power_down <= POWERDOWN_2;
		port_power_go <= 1;
		has_trained <= 0;
		gen2_attempts <= 0;
		state <= LT_RX_DETECT_RESET;
	end
	default: state <= LT_RESET;
	endcase



	///////////////////////////////////////
	// LFPS SEND FSM
	///////////////////////////////////////
	case(lfps_send_state)
	LFPS_RESET: begin
		lfps_send_state <= LFPS_IDLE;
	end
	LFPS_IDLE: begin
		port_tx_detrx_lpbk <= 0;
		if(!training) begin // port_rx_elecidle_2 &&
			// clear to go
			if(lfps_send_poll_local & lfps_send_scd1_local) begin
				sc <= 0;
				sic <= 0 ;//
				lfps_type <= 0;
				lfps_send_state <= LFPS_SEND_SCD1;
			end else if(lfps_send_poll_local & lfps_send_scd2_local) begin
				sc <= 0;
				sic <= 0 ;//
				lfps_type <= 0;
				lfps_send_state <= LFPS_SEND_SCD2;
			end else if(lfps_send_poll_local & lfps_send_phy_cab_local) begin
				sc <= 0;
				sic <= 0 ;//
				lbpm_data_out_latch <= lbpm_data_out;
				lbpm_data_cnt <= 0;
				lfps_type <= 0;
				lfps_send_state <= LFPS_SEND_LBPM;
			end else if(lfps_send_poll | lfps_send_poll_local) begin
				// Polling.LFPS
				lfps_type <= 0;
				if(rate_d1) begin
					sc <= LFPS_POLLING_NOM;
					sic <= LFPS_BURST_POLL_NOM + 1;//
				end 
				else begin
					sc <= LFPS_POLLING_NOM_5G;
					sic <= LFPS_BURST_POLL_NOM_5G + 1;//
				end
				lfps_send_state <= LFPS_SEND_1;
			end else if(lfps_send_ping | lfps_send_ping_local) begin
				// Ping.LFPS
				lfps_type <= 1;
				if(rate_d1) begin
					sc <= LFPS_PING_NOM;
					sic <= LFPS_BURST_PING_NOM + 1;
				end 
				else begin
					sc <= LFPS_PING_NOM_5G;
					sic <= LFPS_BURST_PING_NOM_5G + 1;
				end
				lfps_send_state <= LFPS_SEND_1;
			end else if(lfps_send_u1 | lfps_send_u1_local) begin
				// U1 Exit
				lfps_type <= 2;
				if(rate_d1) begin
					sc <= LFPS_U1EXIT_NOM;
					sic <= LFPS_U1EXIT_NOM + 1;
				end 
				else begin
					sc <= LFPS_U1EXIT_NOM_5G;
					sic <= LFPS_U1EXIT_NOM_5G + 1;
				end
				lfps_send_state <= LFPS_SEND_1;
			end else if(lfps_send_u2lb | lfps_send_u2lb_local) begin
				// U2 Exit
				lfps_type <= 3;
				if(rate_d1) begin
					sc <= LFPS_U2LBEXIT_NOM;
					sic <= LFPS_U2LBEXIT_NOM + 1;
				end 
				else begin
					sc <= LFPS_U2LBEXIT_NOM_5G;
					sic <= LFPS_U2LBEXIT_NOM_5G + 1;
				end
				lfps_send_state <= LFPS_SEND_1;
			end else if(lfps_send_u3 | lfps_send_u3_local) begin
				// U3 Exit
				lfps_type <= 4;
				if(rate_d1) begin
					sc <= LFPS_U3WAKEUP_NOM;
					sic <= LFPS_U3WAKEUP_NOM + 1;
				end 
				else begin
					sc <= LFPS_U3WAKEUP_NOM_5G;
					sic <= LFPS_U3WAKEUP_NOM_5G + 1;
				end
				lfps_send_state <= LFPS_SEND_1;
			end else if(lfps_send_local) begin
				lfps_send_state <= LFPS_SEND_3;
			end
		end
		if(lfps_send_reset_local) begin
			// WarmReset
			lfps_send_state <= LFPS_SEND_1;
		end
		if(state == LT_LOOPBACK_ACTIVE) begin
			lfps_send_state <= LFPS_LOOPBACK;
		end
	end
	LFPS_SEND_1: begin
		// decide how to send LFPS based on power state
		if(port_power_state == POWERDOWN_0) begin
			port_tx_elecidle <= 1;
			port_tx_detrx_lpbk <= 1;
		end else begin
			port_tx_elecidle <= 0;
		end
		// decrement pulse width and repeat interval
		 `DEC(sc);
		 `DEC(sic);
		 
		//if ( sc == 1 ) begin
		if ( sc_equals_1 ) begin
			lfps_send_state <= LFPS_SEND_2; 
		end
		 
		//if(ltssm_state == LT_U1 || ltssm_state == LT_U2 || ltssm_state == LT_U3)
		//begin
		//	if(sc == 1) 
		//	begin
		//		if(port_rx_elecidle_2)
		//			lfps_send_state <= LFPS_SEND_2;
		//		else
		//			lfps_send_state <= LFPS_SEND_1;
		//	end
		//	else
		//	begin
		//		`DEC(sc);
		//		`DEC(sic);
		//	end
		//end
		//else
		//begin
		//	if(sc == 1) 
		//	begin
		//		lfps_send_state <= LFPS_SEND_2;
		//	end
		//	else
		//	begin
		//		`DEC(sc);
		//		`DEC(sic);
		//	end
		//end

		if(lfps_send_reset_local) begin
			// special case here -- WarmReset must be ack'd
			// and in response send LFPS until it's deasserted by host
			lfps_send_state <= lfps_send_state;
			// catch the rising edge
			if(port_rx_elecidle_2) begin
				lfps_send_state <= LFPS_IDLE;
			end
		end
	end
	LFPS_SEND_2: begin
		// decrement repeat interval
		`DEC(sic);
		if(sic == 0) begin
			if(lfps_type == 1)
				lfps_send_ping_ack <= 1;
			else
				lfps_send_ack <= 1;
			lfps_send_state <= LFPS_IDLE;
		end
	end
	LFPS_SEND_3: begin
		// keep
		if(!lfps_send_local)
			lfps_send_state <= LFPS_IDLE;
			
		if(port_power_state == POWERDOWN_0) begin
			port_tx_elecidle <= 1;
			port_tx_detrx_lpbk <= 1;
		end else begin
			port_tx_elecidle <= 0;
		end
	end
	LFPS_SEND_SCD1: begin
		`INC(sc);
		// `INC(sic);
		port_tx_detrx_lpbk <= 0;
		//if(sc < LFPS_SCD_0_NOM) begin
		if(lfps_send_scd1_flg0) begin
			port_tx_elecidle <= 0;
		//end else if(sc < LFPS_SCD_0_TOTAL_NOM) begin
		end else if(lfps_send_scd1_flg1) begin
			port_tx_elecidle <= 1;
		//end else if(sc < LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_NOM) begin
		end else if(lfps_send_scd1_flg2) begin
			port_tx_elecidle <= 0;
		//end else if(sc < LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM) begin
		end else if(lfps_send_scd1_flg3) begin
			port_tx_elecidle <= 1;
		//end else if(sc < LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_NOM) begin
		end else if(lfps_send_scd1_flg4) begin
			port_tx_elecidle <= 0;
		//end else if(sc < LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM) begin
		end else if(lfps_send_scd1_flg5) begin
			port_tx_elecidle <= 1;
		//end else if(sc < LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_0_NOM) begin
		end else if(lfps_send_scd1_flg6) begin
			port_tx_elecidle <= 0;
		//end else if(sc < LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM - 1) begin
		end else if(lfps_send_scd1_flg7) begin
			port_tx_elecidle <= 1;
		//end else if(sc == LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM - 1) begin
		end else if(lfps_send_scd1_flg8) begin
			lfps_send_ack <= 1;
			port_tx_elecidle <= 1;
			if(lfps_send_poll_local & lfps_send_scd1_local) begin
				sc <= 0;
				// sic <= 0;
			end
			else if(lfps_send_poll_local & lfps_send_scd2_local) begin
				sc <= 0;
				// sic <= 0;
				lfps_send_state <= LFPS_SEND_SCD2;
			end
			else begin
				sc <= 0;
				// sic <= 0;
				lfps_send_state <= LFPS_SEND_ECD;
			end
		end
	end
	LFPS_SEND_SCD2: begin
		`INC(sc);
		// `INC(sic);
		port_tx_detrx_lpbk <= 0;
		//if(sc < LFPS_SCD_1_NOM) begin
		if( lfps_send_scd2_flg0 ) begin
			port_tx_elecidle <= 0;
		//end else if(sc < LFPS_SCD_1_TOTAL_NOM) begin
		end else if(lfps_send_scd2_flg1) begin
			port_tx_elecidle <= 1;
		//end else if(sc < LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_NOM) begin
		end else if(lfps_send_scd2_flg2) begin
			port_tx_elecidle <= 0;
		//end else if(sc < LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM) begin
		end else if(lfps_send_scd2_flg3) begin
			port_tx_elecidle <= 1;
		//end else if(sc < LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_NOM) begin
		end else if(lfps_send_scd2_flg4) begin
			port_tx_elecidle <= 0;
		//end else if(sc < LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM) begin
		end else if(lfps_send_scd2_flg5) begin
			port_tx_elecidle <= 1;
		end else if(lfps_send_scd2_flg6) begin
		//end else if(sc < LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_1_NOM) begin
			port_tx_elecidle <= 0;
		//end else if(sc < LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM - 1) begin
		end else if(lfps_send_scd2_flg7) begin
			port_tx_elecidle <= 1;
		//end else if(sc == LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_0_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM + LFPS_SCD_1_TOTAL_NOM - 1) begin
		end else if(lfps_send_scd2_flg8) begin
			port_tx_elecidle <= 1;
			lfps_send_ack <= 1;
			if(lfps_send_poll_local & lfps_send_scd2_local) begin
				sc <= 0;
				// sic <= 0;
			end
			else begin
				sc <= 0;
				// sic <= 0;
				lfps_send_state <= LFPS_SEND_ECD;
			end
		end
	end
	LFPS_SEND_ECD: begin
		`INC(sc);
		// `INC(sic);
		port_tx_detrx_lpbk <= 0;
		//if(sc < LFPS_ECD_NOM) begin
		if(lfps_send_ecd_flg0) begin
			port_tx_elecidle <= 0;
		//end else if(sc < LFPS_ECD_TOTAL_NOM - 1) begin
		end else if(lfps_send_ecd_flg1) begin
			port_tx_elecidle <= 1;
		//end else if(sc == LFPS_ECD_TOTAL_NOM - 1) begin
		end else if(lfps_send_ecd_flg2) begin
			sc <= 0;
			// sic <= 0;
			port_tx_elecidle <= 1;
			lfps_send_state <= LFPS_IDLE;
		end
	end
	LFPS_SEND_LBPM: begin
		`INC(sc);
		// `INC(sic);
		port_tx_detrx_lpbk <= 0;
		if(lbpm_data_cnt == 0) begin
			//if(sc < LFPS_LBPM_PWM_TOTAL_NOM - 1) begin
			if(lfps_send_lbmp_flg0) begin
				port_tx_elecidle <= 0;
			//end else if(sc < LFPS_LBPM_PWM_TOTAL_NOM) begin
			end else if( lfps_send_lbmp_flg1 ) begin
				port_tx_elecidle <= 1;
			//end else if(sc == LFPS_LBPM_PWM_TOTAL_NOM) begin
			end else if(lfps_send_lbmp_flg2) begin
				sc <= 0;
				// sic <= 0;
				port_tx_elecidle <= 1;
				`INC(lbpm_data_cnt);
			end
		end
		else if(lbpm_data_cnt == 1) begin
			//if(sc < LFPS_LBPM_PWM_TOTAL_NOM - 1) begin
			if(lfps_send_lbmp_flg3) begin
				port_tx_elecidle <= 1;
			//end else if(sc < LFPS_LBPM_PWM_TOTAL_NOM) begin
			end else if(lfps_send_lbmp_flg4) begin
				port_tx_elecidle <= 1;
			//end else if(sc == LFPS_LBPM_PWM_TOTAL_NOM) begin
			end else if(lfps_send_lbmp_flg5) begin
				sc <= 0;
				// sic <= 0;
				port_tx_elecidle <= 1;
				`INC(lbpm_data_cnt);
			end
		end
		else if(lbpm_data_cnt < 10) begin
			//if(sc < LFPS_LBPM_0_PWM_NOM) begin
			if(lfps_send_lbmp_flg6) begin
				port_tx_elecidle <= 0;
			//end else if(sc < LFPS_LBPM_1_PWM_NOM && lbpm_data_out_latch[0]) begin
			end else if(lfps_send_lbmp_flg7 && lbpm_data_out_latch[0]) begin
				port_tx_elecidle <= 0;
			//end else if(sc < LFPS_LBPM_PWM_TOTAL_NOM) begin
			end else if(lfps_send_lbmp_flg8) begin
				port_tx_elecidle <= 1;
			//end else if(sc == LFPS_LBPM_PWM_TOTAL_NOM) begin
			end else if(lfps_send_lbmp_flg9) begin
				sc <= 0;
				// sic <= 0;
				port_tx_elecidle <= 1;
				`INC(lbpm_data_cnt);
				lbpm_data_out_latch <= {1'b0, lbpm_data_out_latch[7:1]};
			end
		end
		else if(lbpm_data_cnt == 10) begin
			//if(sc < LFPS_LBPM_PWM_TOTAL_NOM - 1) begin
			if( lfps_send_lbmp_flg10 ) begin
				port_tx_elecidle <= 0;
			//end else if(sc < LFPS_LBPM_PWM_TOTAL_NOM) begin
			end else if(lfps_send_lbmp_flg11) begin
				port_tx_elecidle <= 1;
				lfps_send_ack <= 1;
			//end else if(sc == LFPS_LBPM_PWM_TOTAL_NOM) begin
			end else if(lfps_send_lbmp_flg12) begin
				sc <= 0;
				// sic <= 0;
				port_tx_elecidle <= 1;
				if(lfps_send_poll_local & lfps_send_phy_cab_local) begin
					lbpm_data_out_latch <= lbpm_data_out;
					lbpm_data_cnt <= 1;
				end
				else begin
					lfps_send_state <= LFPS_IDLE;
				end
			end
		end
	end
	LFPS_LOOPBACK: begin
		port_tx_elecidle <= 0;
		port_tx_detrx_lpbk <= 1;
		if(state == LT_LOOPBACK_EXIT)
			lfps_send_state <= LFPS_IDLE;
	end
	default: lfps_send_state <= LFPS_RESET;
	endcase



	///////////////////////////////////////
	// LFPS RECEIVE FSM
	///////////////////////////////////////
	case(lbpm_scd_recv_state)
		LFPS2_RESET: begin
			lbpm_scd_recv_state <= LFPS2_IDLE;
		end
		LFPS2_IDLE: begin
			// ���LFPS������ʼ���͵�ƽ��Ч��
			lfps_recv_scd1 <= 0;
			lfps_recv_scd2 <= 0;
			recv_scd_0 <= 0;
			recv_scd_1 <= 0;
			lfps_recv_port_match <= 0;
			if (~port_rx_elecidle_2 & rate_d1) begin
				rc2 <= 0;                        // ����������ȼ�����
				lbpm_recv_data_cnt <= 0;
				lbpm_scd_recv_state <= LFPS2_RECV_MEASURE;
			end
		end
		LFPS2_RECV_MEASURE: begin
			// ���������������
			`INC(rc2);                       // ��������������ȼ�����
			if (port_rx_elecidle_2) begin       // ��⵽��������������أ�
				//if (rc2 >= LFPS_POLLING_MIN && rc2 < LFPS_POLLING_MAX) begin
				if (lfps_recv_measure_flg0) begin
					lbpm_scd_recv_state <= LFPS2_RECV_SCD;
				end 
				//else if (rc2 >= LFPS_LBPM_PWM_TOTAL_MIN && rc2 < LFPS_LBPM_PWM_TOTAL_MAX) begin
				else if (lfps_recv_measure_flg1) begin
					lfps_recv_data_cnt <= 0;             // ��ʼ��LBPM����λ������
					lbpm_recv_data_cnt <= 0;
					lbpm_scd_recv_state <= LFPS2_RECV_LBPM;
				end 
				else begin
					// ��Ч���壬����
					lbpm_scd_recv_state <= LFPS2_IDLE;
					rc2 <= 0;
				end
			end
		end
		LFPS2_RECV_SCD: begin
			lfps_recv_scd1 <= 0;
			lfps_recv_scd2 <= 0;
			if (~port_rx_elecidle_2) begin
				rc2 <= 1;
				//if(rc2 >= LFPS_SCD_0_TOTAL_MIN && rc2 < LFPS_SCD_0_TOTAL_MAX) begin
				if(lfps_recv_scd_flg0) begin
					recv_scd_0 <= recv_scd_0 + 1;
				end
				//else if(rc2 >= LFPS_SCD_1_TOTAL_MIN && rc2 < LFPS_SCD_1_TOTAL_MAX) begin
				else if(lfps_recv_scd_flg1) begin
					recv_scd_1 <= recv_scd_1 + 1;
				end
				if(lfps_recv_data_cnt < 4) begin
					lfps_recv_data_cnt <= lfps_recv_data_cnt + 1;
					//if(rc2 >= LFPS_SCD_0_TOTAL_MIN && rc2 < LFPS_SCD_0_TOTAL_MAX) begin
					if(lfps_recv_scd_flg2) begin
						lbpm_scd_recv_state <= LFPS2_RECV_MEASURE;
					end
					//else if(rc2 >= LFPS_SCD_1_TOTAL_MIN && rc2 < LFPS_SCD_1_TOTAL_MAX) begin
					else if(lfps_recv_scd_flg3) begin
						lbpm_scd_recv_state <= LFPS2_RECV_MEASURE;
					end
					else begin
						lbpm_scd_recv_state <= LFPS2_IDLE;
					end
				end
				else begin
					lfps_recv_data_cnt <= 0;
					lbpm_scd_recv_state <= LFPS2_IDLE;
					if(recv_scd_0 > recv_scd_1) begin
						lfps_recv_scd1 <= 1;
					end
					else if(recv_scd_1 > recv_scd_0) begin
						lfps_recv_scd2 <= 1;
					end
					else begin
						// do nothing if equal

					end
				end
			end
			else begin
				`INC(rc2);
				//if(rc2 > LFPS_ECD_TOTAL_NOM) begin
				if(lfps_recv_scd_flg4) begin
					lbpm_scd_recv_state <= LFPS2_IDLE;
				end
			end
		end
		LFPS2_RECV_LBPM: begin
			// ����LBPM���ݰ���ʾ���߼���
			if (~port_rx_elecidle_2) begin      // �������λ��ʼ
				rc2 <= 1;
				lbpm_scd_recv_state <= LFPS2_RECV_LBPM_BIT;
			end
			if (lbpm_recv_data_cnt == 8) begin   // ����8λ����
				lbpm_data_in_latch <= lbpm_data_in;  // ��������
				lfps_recv_port_match <= 1;      // ���LBPMЭ��
				lbpm_scd_recv_state <= LFPS2_IDLE;
			end
		end
		LFPS2_RECV_LBPM_BIT: begin
			if (port_rx_elecidle_2) begin       // ����λ����
				// ����������Ƚ�������λ��0��1��
				//if (rc2 >= LFPS_LBPM_1_PWM_MIN && rc2 < LFPS_LBPM_1_PWM_MAX) begin
				if (lfps_recv_lbpm_flg0) begin
					`INC(lbpm_recv_data_cnt);
					lbpm_data_in <= {1'b1, lbpm_data_in[7:1]};  // ����1
				end 
				//else if (rc2 >= LFPS_LBPM_0_PWM_MIN && rc2 < LFPS_LBPM_0_PWM_MAX) begin
				else if (lfps_recv_lbpm_flg1) begin
					`INC(lbpm_recv_data_cnt);
					lbpm_data_in <= {1'b0, lbpm_data_in[7:1]};   // ����0
				end
				
				//if (rc2 < LFPS_LBPM_PWM_TOTAL_MAX) begin
				if (lfps_recv_lbpm_flg2) begin
					lbpm_scd_recv_state <= LFPS2_RECV_LBPM;  // ��������
				end
				else begin
					lbpm_scd_recv_state <= LFPS2_IDLE;
				end
			end else begin
				`INC(rc2);                       // ������������λ����
			end
		end
		default: lbpm_scd_recv_state <= LFPS2_RESET;
	endcase

	case(lfps_recv_state)
	LFPS_RESET: begin
		lfps_recv_state <= LFPS_IDLE;
		lfps_recv_poll_u1_prev <= 0;
		lfps_recv_ping_prev <= 0;
	end
	LFPS_IDLE: begin
		lfps_recv_poll_u1 <= 0;
		lfps_recv_u2lb <= 0;
		lfps_recv_u3 <= 0;
		lfps_recv_active <= 0;
		// lfps burst begin
		if(rate_d1 & ~port_rx_elecidle_2 & ((state != LT_POLLING_PORT_CONFIG) | (state != LT_POLLING_PORT_CONFIG))) begin
			rc <= 0;
			lfps_recv_state <= LFPS_RECV_1;
		end
		else if(~rate_d1 & ~port_rx_elecidle_2 & ((state != LT_POLLING_PORT_CONFIG) | (state != LT_POLLING_PORT_CONFIG))) begin
			rc <= 0;
			lfps_recv_state <= LFPS_RECV_2;
		end
	end
	LFPS_RECV_1: begin 
		// lfps burst end

		// detect WarmReset by seeing if LFPS continues past tResetDelay
		if(rc > LFPS_RESET_DELAY) begin
			// want to send LFPS to signal we acknowledge the WarmReset
			// N.B. per spec this is not acceptable during SS.Disabled
			if(~port_rx_elecidle_2) lfps_send_reset_local <= 1;
		end

		if(rc == LFPS_U1EXIT_MIN && ltssm_state == LT_U1 ) begin
			// link partner is sending U1Exit handshake, reciprocate
			lfps_recv_active <= 1;
			lfps_recv_poll_u1 <= 1;
		end

		if(rc == LFPS_U2LBEXIT_MIN && ltssm_state == LT_U2 ) begin
			// link partner is sending U2/LBExit handshake, reciprocate
			lfps_recv_active <= 1;
			lfps_recv_u2lb <= 1;
		end

		if(rc == LFPS_U3WAKEUP_MIN && ltssm_state == LT_U3 ) begin
			// link partner is sending U3 wakeup, reciprocate
			lfps_recv_active <= 1;
			lfps_recv_u3 <= 1;
		end

		// wait for rising edge
		if(port_rx_elecidle_2) begin
			lfps_recv_state <= LFPS_IDLE;
			lfps_recv_active <= 1;

			// reset these by default
			lfps_recv_poll_u1_prev <= 0;
			lfps_recv_ping_prev <= 0;

			ric <= 0;

			if(rc >= LFPS_POLLING_MIN && rc < LFPS_POLLING_MAX) begin
				// Polling.LFPS (or U1.Exit)
				if(lfps_recv_poll_u1_prev) begin
					// we've received this once already
					// now check burst length parameters
					if(ric >= LFPS_BURST_POLL_MIN && ric < LFPS_BURST_POLL_MAX)
						lfps_recv_poll_u1 <= 1;
				end else
					lfps_recv_active <= 0;

				lfps_recv_poll_u1_prev <= 1;
				ric <= 0;
			end else if(rc >= LFPS_PING_MIN && rc < LFPS_PING_MAX) begin
				// Ping.LFPS
				if(lfps_recv_ping_prev) begin
					// we've received this once already
					// now check burst length parameters
//					if(ric >= LFPS_BURST_PING_MIN && ric < LFPS_BURST_PING_MAX)
//						lfps_recv_ping <= 1;
				end else
					lfps_recv_active <= 0;
                
                lfps_recv_ping <= 1;
				lfps_recv_ping_prev <= 1;
				ric <= 0;
			end else if(rc >= LFPS_RESET_MIN && rc < LFPS_RESET_MAX) begin
				// WarmReset
				lfps_recv_reset <= 1;
			//end else if(rc >= LFPS_U1EXIT_MIN && rc < LFPS_U1EXIT_MAX) begin
				// U1.Exit
			//	lfps_recv_poll_u1 <= 1;
			//end else if(rc >= LFPS_U2LBEXIT_MIN && rc < LFPS_U2LBEXIT_MAX) begin
				// U2/Loopback.Exit
			//	lfps_recv_u2lb <= 1;
			//end else if(rc >= LFPS_U3WAKEUP_MIN && rc < LFPS_U3WAKEUP_MAX) begin
				// U3.Wakeup
			//	lfps_recv_u3 <= 1;
			end else begin
				// invalid burst
				//lfps_recv_state <= LFPS_IDLE;
				lfps_recv_active <= 0;
			end
		end
	end
	LFPS_RECV_2: begin
		if(rc > LFPS_RESET_DELAY_5G) begin
			if(~port_rx_elecidle_2) lfps_send_reset_local <= 1;
		end

		if(rc == LFPS_U1EXIT_MIN_5G && ltssm_state == LT_U1 ) begin
			lfps_recv_active <= 1;
			lfps_recv_poll_u1 <= 1;
		end

		if(rc == LFPS_U2LBEXIT_MIN_5G && ltssm_state == LT_U2 ) begin
			lfps_recv_active <= 1;
			lfps_recv_u2lb <= 1;
		end

		if(rc == LFPS_U3WAKEUP_MIN_5G && ltssm_state == LT_U3 ) begin
			lfps_recv_active <= 1;
			lfps_recv_u3 <= 1;
		end

		// wait for rising edge
		if(port_rx_elecidle_2) begin
			lfps_recv_state <= LFPS_IDLE;
			lfps_recv_active <= 1;

			// reset these by default
			lfps_recv_poll_u1_prev <= 0;
			lfps_recv_ping_prev <= 0;

			ric <= 0;

			if(rc >= LFPS_POLLING_MIN_5G && rc < LFPS_POLLING_MAX_5G) begin
				// Polling.LFPS (or U1.Exit)
				if(lfps_recv_poll_u1_prev) begin
					// we've received this once already
					// now check burst length parameters
					if(ric >= LFPS_BURST_POLL_MIN_5G && ric < LFPS_BURST_POLL_MAX_5G)
						lfps_recv_poll_u1 <= 1;
				end else
					lfps_recv_active <= 0;

				lfps_recv_poll_u1_prev <= 1;
				ric <= 0;
			end else if(rc >= LFPS_PING_MIN_5G && rc < LFPS_PING_MAX_5G) begin
				// Ping.LFPS
				if(lfps_recv_ping_prev) begin
					// we've received this once already
					// now check burst length parameters
//					if(ric >= LFPS_BURST_PING_MIN_5G && ric < LFPS_BURST_PING_MAX_5G)
//						lfps_recv_ping <= 1;
				end else
					lfps_recv_active <= 0;
                
                lfps_recv_ping <= 1;
				lfps_recv_ping_prev <= 1;
				ric <= 0;
			end else if(rc >= LFPS_RESET_MIN_5G && rc < LFPS_RESET_MAX_5G) begin
				// WarmReset
				lfps_recv_reset <= 1;
			end else begin
				// invalid burst
				//lfps_recv_state <= LFPS_IDLE;
				lfps_recv_active <= 0;
			end
		end
	end
	LFPS_RECV_3: begin
		// just wait for end of host LFPS to squelch generation of erroneous transfers
		if(port_rx_elecidle_2) begin
			ric <= 0;
			lfps_recv_state <= LFPS_IDLE;
		end
	end
	default: lfps_recv_state <= LFPS_RESET;
	endcase

	if(go_disabled) begin
		// SS.Disabled
		state <= LT_SS_DISABLED;
	end

	//if(hot_reset && state != LT_SS_DISABLED) begin
		// Hot Reset (TS2 Reset bit)
	//	dc <= 0;
	//	state <= LT_HOTRESET;
	//end

	if(lfps_recv_reset && state != LT_SS_DISABLED) begin
		// Warm Reset (LFPS)
		warm_reset <= 1;
		state <= LT_RX_DETECT_RESET;
	end

	if(~reset_n | ~vbus_present_2) begin
		// reset
		state <= LT_RESET;
		lfps_send_state <= LFPS_RESET;
		lfps_recv_state <= LFPS_RESET;
	end
end

always @(posedge local_clk or negedge reset_n) begin
	if(!reset_n) begin
		cnt_ltssm <= 0;
	end
	else begin
		if(state >= LT_POLLING_LFPS) begin
			cnt_ltssm <= cnt_ltssm + 1;
		end
		else begin
			cnt_ltssm <= 0;
		end
	end
end


endmodule

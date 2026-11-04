//usb3.0 5Gbps 125MHz
//usb3.1 10Gbps 156250MHz

localparam	[5:0]			LT_RESET			= 'd00,
					LT_SS_DISABLED			= 'd01,
					LT_SS_INACTIVE			= 'd02,
					LT_SS_INACTIVE_QUIET 	= 'd03,
					LT_SS_INACTIVE_DETECT_0	= 'd04,
					LT_SS_INACTIVE_DETECT_1	= 'd05,
					LT_RX_DETECT_RESET		= 'd06,
					LT_RX_DETECT_ACTIVE_0	= 'd07,
					LT_RX_DETECT_ACTIVE_1	= 'd08,
					LT_RX_DETECT_QUIET		= 'd09,
					LT_POLLING_LFPS			= 'd10,
					LT_POLLING_LFPS_PLUS	= 'd11,
					LT_POLLING_PORT_MATCH	= 'd12,
					LT_POLLING_PORT_CONFIG	= 'd13,
					LT_POLLING_RXEQ_0		= 'd14,
					LT_POLLING_RXEQ_1		= 'd15,
					LT_POLLING_ACTIVE		= 'd16,
					LT_POLLING_CONFIG		= 'd17,
					LT_POLLING_IDLE			= 'd18,
					LT_U0					= 'd19,
					LT_U1					= 'd20,
					LT_U2					= 'd21,
					LT_U3					= 'd22,
					LT_COMPLIANCE			= 'd23,
					LT_LOOPBACK				= 'd24,
					LT_LOOPBACK_ACTIVE		= 'd25,
					LT_LOOPBACK_EXIT		= 'd26,
					LT_HOTRESET				= 'd27,
					LT_HOTRESET_ACTIVE		= 'd28,
					LT_HOTRESET_EXIT		= 'd29,
					LT_RECOVERY				= 'd30,
					LT_RECOVERY_WAIT		= 'd31,
					LT_RECOVERY_ACTIVE		= 'd32,
					LT_RECOVERY_CONFIG		= 'd33,
					LT_RECOVERY_IDLE		= 'd34,
					LT_LAST					= 'b111111;

localparam	[4:0]	LFPS_RESET			= 'h00,
					LFPS_IDLE			= 'h01,
					LFPS_RECV_1			= 'h02,
					LFPS_RECV_2			= 'h03,
					LFPS_RECV_3			= 'h04,
					LFPS_SEND_1			= 'h05,
					LFPS_SEND_2			= 'h06,
					LFPS_SEND_3			= 'h07,
					LFPS_SEND_SCD1		= 'h08,
					LFPS_SEND_SCD2		= 'h09,
					LFPS_SEND_ECD		= 'h0A,
					LFPS_SEND_LBPM		= 'h0B,
					LFPS_LOOPBACK		= 'h0C,
					LFPS_LAST			= 'b11111;

localparam	[4:0]	LFPS2_RESET			= 'h00,
					LFPS2_IDLE			= 'h01,
					LFPS2_RECV_MEASURE	= 'h02,
					LFPS2_RECV_SCD		= 'h03,
					LFPS2_RECV_LBPM		= 'h04,
					LFPS2_RECV_LBPM_BIT	= 'h05,
					LFPS2_LAST			= 'b11111;
					
// timing parameters
// all are calculated for local clock of 62.5 MHz (1/4 PIPE CLK) , now change 125MHz MXY 2024.1.19
// except those denoted by *2 which compensates for 125 MHz Link clock domain.
//
// localparam	[25:0]	LFPS_SCD_0_MIN			= 'd93;			// 0.6 uS
localparam	[25:0]	LFPS_SCD_0_MIN			= 'd125;		// 0.8 uS
localparam	[25:0]	LFPS_SCD_0_NOM			= 'd156;		// 1.0 uS
localparam	[25:0]	LFPS_SCD_0_MAX			= 'd218;		// 1.4 uS
localparam	[25:0]	LFPS_SCD_0_TOTAL_MIN	= 'd936;		// 6 uS
localparam	[25:0]	LFPS_SCD_0_TOTAL_NOM	= 'd1092;		// 7 uS
localparam	[25:0]	LFPS_SCD_0_TOTAL_MAX	= 'd1404;		// 9 uS
// localparam	[25:0]	LFPS_SCD_1_MIN			= 'd93;			// 0.6 uS
localparam	[25:0]	LFPS_SCD_1_MIN			= 'd125;		// 0.8 uS
localparam	[25:0]	LFPS_SCD_1_NOM			= 'd156;		// 1.0 uS
localparam	[25:0]	LFPS_SCD_1_MAX			= 'd218;		// 1.4 uS
localparam	[25:0]	LFPS_SCD_1_TOTAL_MIN	= 'd1718;		// 11.0 uS
localparam	[25:0]	LFPS_SCD_1_TOTAL_NOM	= 'd1875;		// 12.0 uS
localparam	[25:0]	LFPS_SCD_1_TOTAL_MAX	= 'd2187;		// 14.0 uS
localparam	[25:0]	LFPS_ECD_MIN			= 'd93;			// 0.6 uS
localparam	[25:0]	LFPS_ECD_NOM			= 'd156;		// 1.0 uS
localparam	[25:0]	LFPS_ECD_MAX			= 'd218;		// 1.4 uS
localparam	[25:0]	LFPS_ECD_TOTAL_MIN		= 'd4375;		// 28.0 uS
localparam	[25:0]	LFPS_ECD_TOTAL_NOM		= 'd4531;		// 29.0 uS
localparam	[25:0]	LFPS_ECD_TOTAL_MAX		= 'd4687;		// 30.0 uS
localparam	[25:0]	LFPS_LBPM_0_PWM_MIN		= 'd78;			// 0.5 uS
localparam	[25:0]	LFPS_LBPM_0_PWM_NOM		= 'd93;			// 0.6 uS
localparam	[25:0]	LFPS_LBPM_0_PWM_MAX		= 'd135;		// 0.8 uS
localparam	[25:0]	LFPS_LBPM_1_PWM_MIN		= 'd202;		// 1.3 uS
localparam	[25:0]	LFPS_LBPM_1_PWM_NOM		= 'd234;		// 1.5 uS
localparam	[25:0]	LFPS_LBPM_1_PWM_MAX		= 'd280;		// 1.8 uS
localparam	[25:0]	LFPS_LBPM_PWM_TOTAL_MIN	= 'd312;		// 2.0 uS
localparam	[25:0]	LFPS_LBPM_PWM_TOTAL_NOM	= 'd343;		// 2.2 uS
localparam	[25:0]	LFPS_LBPM_PWM_TOTAL_MAX	= 'd374;		// 2.4 uS
localparam	[25:0]	LFPS_POLLING_MIN	= 'd93;			// 0.6 uS
localparam	[25:0]	LFPS_POLLING_NOM	= 'd156;		// 1.0 uS
localparam	[25:0]	LFPS_POLLING_MAX	= 'd218;		// 1.4 uS
localparam	[25:0]	LFPS_PING_MIN		= 'd6;			// 40 ns
localparam	[25:0]	LFPS_PING_NOM		= 'd30;			// 96 ns
localparam	[25:0]	LFPS_PING_MAX		= 'd31;			// 200 ns
localparam	[25:0]	LFPS_RESET_MIN		= 'd156250 * 80;	// 80 ms (nom 100 ms)
localparam	[25:0]	LFPS_RESET_NOM		= 'd156250 * 100;	// 100 ms (nom 100 ms)
localparam	[25:0]	LFPS_RESET_MAX		= 'd156250 * 120;	// 120 ms (nom 100 ms)
localparam	[25:0]	LFPS_RESET_DELAY	= 'd156250 * 30;	// 30 ms
localparam	[25:0]	LFPS_U1EXIT_MIN		= 'd93;			// 656 ns // now 616ns due to lecroy
localparam	[25:0]	LFPS_U1EXIT_NOM		= 'd156000 ;	// 656 ns // was 625*4 in testing
localparam	[25:0]	LFPS_U1EXIT_MAX		= 'd156250 * 2;		// 2 ms (1.5, fudged)
localparam	[25:0]	LFPS_U2LBEXIT_MIN	= 'd11718;		// 75 us 
localparam	[25:0]	LFPS_U2LBEXIT_NOM	= 'd15625;		// 100 us
localparam	[25:0]	LFPS_U2LBEXIT_MAX	= 'd156250 * 2;		// 2 ms
localparam	[25:0]	LFPS_U3WAKEUP_MIN	= 'd12500;		// 80 us
localparam	[25:0]	LFPS_U3WAKEUP_NOM	= 'd156250 * 1;		// 1 ms
localparam	[25:0]	LFPS_U3WAKEUP_MAX	= 'd156250 * 10;	// 10 ms

// localparam	[25:0]	LFPS_BURST_POLL_MIN	= 'd936;		// 6 us (nom 10 uS)
// localparam	[25:0]	LFPS_BURST_POLL_NOM	= 'd1562;		// 10 uS
// localparam	[25:0]	LFPS_BURST_POLL_MAX	= 'd2187;		// 14 us
localparam	[25:0]	LFPS_BURST_POLL_MIN	= 'd1248;		// 8 us (nom 10 uS)
localparam	[25:0]	LFPS_BURST_POLL_NOM	= 'd1562;		// 10 uS
localparam	[25:0]	LFPS_BURST_POLL_MAX	= 'd1716;		// 11 us
localparam	[25:0]	LFPS_BURST_PING_MIN	= 'd156250 * 160;	// 160 ms (nom 200 ms)
localparam	[25:0]	LFPS_BURST_PING_NOM	= 'd156250 * 200;	// 200 ms
localparam	[25:0]	LFPS_BURST_PING_MAX	= 'd156250 * 240;	// 240 ms

localparam	[25:0]	T_SS_INACTIVE_QUIET	= 'd156250 * 12;	// 12 ms
localparam	[25:0]	T_RX_DETECT_QUIET	= 'd156250 * 12;	// 12 ms
localparam	[25:0]	T_POLLING_LFPS		= 'd156250 * 360;	// 360 ms
localparam	[25:0]	T_POLLING_SCD_LFPS	= 'd156250 * 60;	// 60 ms
localparam	[25:0]	T_POLLING_ACTIVE	= 'd156250 * 12;	// 12 ms
localparam	[25:0]	T_POLLING_CONFIG	= 'd156250 * 12;	// 12 ms
localparam	[25:0]	T_POLLING_CONFIG_8MS = 'd125000 * 8;	// 8 ms
localparam	[25:0]	T_POLLING_IDLE		= 'd156250 * 2;		// 2 ms
localparam	[25:0]	T_U0_RECOVERY		= 'd1562*100;		// 1ms		
localparam	[25:0]	T_U0L_TIMEOUT		= 'd1562;		// 10 us		
localparam	[25:0]	T_PENDING_HP		= 'd1562;		// 10 us		
localparam	[25:0]	T_CREDIT_HP			= 'd781250;		// 5000 us		
//localparam	[25:0]	T_CREDIT_HP			= 'd1000;		// 5000 us	//debug	
localparam	[25:0]	T_NOLFPS_U1			= 'd156250 * 2;		// 2 ms
localparam	[25:0]	T_U1_PING			= 'd156250 * 300;	// 300 ms
localparam	[25:0]	T_NOLFPS_U2			= 'd156250 * 200;		// 2 ms
localparam	[25:0]	T_NOLFPS_U3			= 'd156250 * 10;	// 10 ms
localparam	[25:0]	T_HOTRESET_ACTIVE	= 'd156250 * 12;	// 12 ms
localparam	[25:0]	T_HOTRESET_EXIT		= 'd156250 * 2;		// 2 ms
localparam	[25:0]	T_RECOV_ACTIVE		= 'd156250 * 12;	// 12 ms
localparam	[25:0]	T_RECOV_CONFIG		= 'd156250 * 6;		// 6 ms
localparam	[25:0]	T_RECOV_IDLE		= 'd156250 * 2;		// 2 ms
localparam	[25:0]	T_LOOPBACK_EXIT		= 'd156250 * 2;		// 2 ms
localparam	[25:0]	T_WARM_RESET		= 'd156250 * 100;	// 100 ms

localparam	[25:0]	T_PM_LC				= 'd468;		// 3 us		4	
localparam	[25:0]	T_PM_ENTRY			= 'd937;		// 6 us		8	
localparam	[25:0]	T_UX_EXIT			= 'd156250 * 6;	// 6 ms			

localparam	[25:0]	T_PORT_CONFIG		= 'd5625;		// 20 us

localparam	[25:0]	LFPS_POLLING_MIN_5G	= 'd70;			// 0.6 uS (nom 1.0 us)
localparam	[25:0]	LFPS_POLLING_NOM_5G	= 'd125;		// 1.0 uS
localparam	[25:0]	LFPS_POLLING_MAX_5G	= 'd180;		// 1.4 uS

localparam	[25:0]	LFPS_PING_MIN_5G		= 'd5;			// 40 ns
localparam	[25:0]	LFPS_PING_NOM_5G		= 'd24;			// 96 ns
localparam	[25:0]	LFPS_PING_MAX_5G		= 'd50;//'d25;			// 200 ns
localparam	[25:0]	LFPS_RESET_MIN_5G		= 'd10000000;	// 80 ms (nom 100 ms)
localparam	[25:0]	LFPS_RESET_NOM_5G		= 'd12500000;	// 100 ms (nom 100 ms)
localparam	[25:0]	LFPS_RESET_MAX_5G		= 'd15000000;	// 120 ms (nom 100 ms)
localparam	[25:0]	LFPS_RESET_DELAY_5G	= 'd3750000;	// 30 ms
//localparam	[25:0]	LFPS_U1EXIT_MIN_5G		= 'd72;			// 656 ns // now 616ns due to lecroy
localparam	[25:0]	LFPS_U1EXIT_MIN_5G		= 'd30;			// 656 ns // now 616ns due to lecroy
localparam	[25:0]	LFPS_U1EXIT_NOM_5G		= 'd131 ;			// 656 ns // was 625*4 in testing
//localparam	[25:0]	LFPS_U1EXIT_NOM_5G		= 'd82 * 2 ;			// 656 ns // was 625*4 in testing
localparam	[25:0]	LFPS_U1EXIT_MAX_5G		= 'd250000;		// 2 ms (1.5, fudged)
localparam	[25:0]	LFPS_U2LBEXIT_MIN_5G	= 'd9375;		// 75 us 
localparam	[25:0]	LFPS_U2LBEXIT_NOM_5G	= 'd12500;		// 100 us // 5362
localparam	[25:0]	LFPS_U2LBEXIT_MAX_5G	= 'd250000;		// 2 ms
localparam	[25:0]	LFPS_U3WAKEUP_MIN_5G	= 'd10000;		// 80 us
localparam	[25:0]	LFPS_U3WAKEUP_NOM_5G	= 'd125000;		// 1 ms
localparam	[25:0]	LFPS_U3WAKEUP_MAX_5G	= 'd1250000;	// 10 ms

//localparam	[25:0]	LFPS_BURST_POLL_MIN_5G	= 'd750;		// 6 us (nom 10 uS)
//localparam	[25:0]	LFPS_BURST_POLL_NOM_5G	= 'd1250;		// 10 uS
//localparam	[25:0]	LFPS_BURST_POLL_MAX_5G	= 'd1750;		// 14 us

localparam	[25:0]	LFPS_BURST_POLL_MIN_5G	= 'd700;		// 6 us (nom 10 uS)
localparam	[25:0]	LFPS_BURST_POLL_NOM_5G	= 'd1250;		// 10 uS
localparam	[25:0]	LFPS_BURST_POLL_MAX_5G	= 'd1800;		// 14 us

localparam	[25:0]	LFPS_BURST_PING_MIN_5G	= 'd20000000;	// 160 ms (nom 200 ms)
localparam	[25:0]	LFPS_BURST_PING_NOM_5G	= 'd25000000;	// 200 ms
localparam	[25:0]	LFPS_BURST_PING_MAX_5G	= 'd30000000;	// 240 ms

localparam	[25:0]	T_SS_INACTIVE_QUIET_5G	= 'd1500000;	// 12 ms
//localparam	[25:0]	T_RX_DETECT_QUIET_5G	= 'd15000000;	// 120 ms
localparam	[25:0]	T_RX_DETECT_QUIET_5G	= 'd1500000;	// 12 ms
localparam	[25:0]	T_POLLING_LFPS_5G		= 'd45000000;	// 360 ms
localparam	[25:0]	T_POLLING_ACTIVE_5G	= 'd1500000;	// 12 ms
localparam	[25:0]	T_POLLING_CONFIG_5G	= 'd1500000;	// 12 ms
localparam	[25:0]	T_POLLING_IDLE_5G		= 'd250000;		// 2 ms
localparam	[25:0]	T_U0_RECOVERY_5G		= 'd125000;		// 1 ms			used in Link Layer, double cycles
localparam	[25:0]	T_U0L_TIMEOUT_5G		= 'd1250;		// 10 us		used in Link Layer, double cycles
localparam	[25:0]	T_PENDING_HP_5G		= 'd1250;		// 10 us			used in Link Layer, double cycles
localparam	[25:0]	T_CREDIT_HP_5G			= 'd625000;	    // 5000 us		used in Link Layer, double cycles
localparam	[25:0]	T_NOLFPS_U1_5G			= 'd250000;		// 2 ms
localparam	[25:0]	T_U1_PING_5G			= 'd37500000;	// 300 ms
localparam	[25:0]	T_NOLFPS_U2_5G			= 'd250000;		// 2 ms
localparam	[25:0]	T_NOLFPS_U3_5G			= 'd1250000;	// 10 ms
localparam	[25:0]	T_HOTRESET_ACTIVE_5G	= 'd1500000;	// 12 ms
localparam	[25:0]	T_HOTRESET_EXIT_5G		= 'd250000;		// 2 ms
localparam	[25:0]	T_RECOV_ACTIVE_5G		= 'd1500000;	// 12 ms
localparam	[25:0]	T_RECOV_CONFIG_5G		= 'd750000;		// 6 ms
localparam	[25:0]	T_RECOV_IDLE_5G		= 'd250000;		// 2 ms
localparam	[25:0]	T_LOOPBACK_EXIT_5G		= 'd250000;		// 2 ms
localparam	[25:0]	T_WARM_RESET_5G		= 'd1250000;	// 100 ms

localparam	[25:0]	T_PM_LC_5G				= 'd752;		// 3 us			used in Link Layer, double cycles
localparam	[25:0]	T_PM_ENTRY_5G			= 'd1000;		// 8 us			used in Link Layer, double cycles
localparam	[25:0]	T_UX_EXIT_5G			= 'd1500000;	// 6 ms			used in Link Layer, double cycles

localparam	[25:0]	T_PORT_CONFIG_5G		= 'd2500;		// 20 us		used in Link Layer, double cycles		

localparam	[1:0]	POWERDOWN_0			= 2'd0,		// active transmitting
					POWERDOWN_1			= 2'd1,		// slight powerdown	
					POWERDOWN_2			= 2'd2,		// slowest
					POWERDOWN_3			= 2'd3;		// deep sleep, clock stopped
localparam			SWING_FULL			= 1'b0,		// transmitter voltage swing
					SWING_HALF			= 1'b1;
localparam			ELASBUF_HALF		= 1'b0,		// elastic buffer mode
					ELASBUF_EMPTY		= 1'b1;
localparam	[2:0]	MARGIN_A			= 3'b000,	// Normal range
					MARGIN_B			= 3'b001,	// Decreasing voltage levels
					MARGIN_C			= 3'b010,	// See PHY datasheet
					MARGIN_D			= 3'b011,
					MARGIN_E			= 3'b100;			
localparam	[1:0]	DEEMPH_6_0_DB		= 2'b00,	// -6.0dB TX de-emphasis
					DEEMPH_3_5_DB		= 2'b01,	// -3.5dB TX de-emphasis
					DEEMPH_NONE			= 2'b10,	// no TX de-emphasis
					DEEMPH_RESVD		= 2'b11;	
					
//
// Link constants
//

localparam	[10:0]	LCMD_LGOOD			= 'b00_00_000_0_xxx,
					LCMD_LGOOD_0		= 'b00_00_000_0_000,
					LCMD_LGOOD_1		= 'b00_00_000_0_001,
					LCMD_LGOOD_2		= 'b00_00_000_0_010,
					LCMD_LGOOD_3		= 'b00_00_000_0_011,
					LCMD_LGOOD_4		= 'b00_00_000_0_100,
					LCMD_LGOOD_5		= 'b00_00_000_0_101,
					LCMD_LGOOD_6		= 'b00_00_000_0_110,
					LCMD_LGOOD_7		= 'b00_00_000_0_111,
					LCMD_LGOOD_8		= 'b00_00_000_1_000,
					LCMD_LGOOD_9		= 'b00_00_000_1_001,
					LCMD_LGOOD_10		= 'b00_00_000_1_010,
					LCMD_LGOOD_11		= 'b00_00_000_1_011,
					LCMD_LGOOD_12		= 'b00_00_000_1_100,
					LCMD_LGOOD_13		= 'b00_00_000_1_101,
					LCMD_LGOOD_14		= 'b00_00_000_1_110,
					LCMD_LGOOD_15		= 'b00_00_000_1_111;					
					
localparam	[10:0]	LCMD_LCRD			= 'b00_01_000_00_xx,
					LCMD_LCRD1_A		= 'b00_01_000_00_00,
					LCMD_LCRD1_B		= 'b00_01_000_00_01,
					LCMD_LCRD1_C		= 'b00_01_000_00_10,
					LCMD_LCRD1_D		= 'b00_01_000_00_11,
					LCMD_LCRD2_A		= 'b00_01_000_01_00,
					LCMD_LCRD2_B		= 'b00_01_000_01_01,
					LCMD_LCRD2_C		= 'b00_01_000_01_10,
					LCMD_LCRD2_D		= 'b00_01_000_01_11;					
					
localparam	[10:0]	LCMD_LRTY			= 'b00_10_000_0000,
					LCMD_LBAD			= 'b00_11_000_0000;
					
localparam	[10:0]	LCMD_LGO			= 'b01_00_000_00xx,
					LCMD_LGO_U1			= 'b01_00_000_0001,
					LCMD_LGO_U2			= 'b01_00_000_0010,
					LCMD_LGO_U3			= 'b01_00_000_0011;
					
localparam	[10:0]	LCMD_LAU			= 'b01_01_000_0000,
					LCMD_LXU			= 'b01_10_000_0000,
					LCMD_LPMA			= 'b01_11_000_0000;
					
localparam	[10:0]	LCMD_LDN			= 'b10_11_000_0000,
					LCMD_LUP			= 'b10_00_000_0000;
					
localparam	[4:0]	LP_TYPE_LMP			= 'b00000,				
					LP_TYPE_TP			= 'b00100,
					LP_TYPE_DP			= 'b01000,
					LP_TYPE_ITP			= 'b01100;

localparam	[3:0]	LP_LMP_SUB_RSVD			= 'b0000,
					LP_LMP_SUB_SETLINK		= 'b0001,
					LP_LMP_SUB_U2INACT		= 'b0010,
					LP_LMP_SUB_VENDTEST		= 'b0011,
					LP_LMP_SUB_PORTCAP		= 'b0100,
					LP_LMP_SUB_PORTCFG		= 'b0101,
					LP_LMP_SUB_PORTCFGRSP	= 'b0110;
					
localparam	[6:0]	LP_LMP_SPEED_5GBPS		= 'b000000_1;
localparam	[6:0]	LP_LMP_SPEED_10GBPS		= 'b000000_0;
localparam	[6:0]	LP_LMP_SPEED_DECLINE	= 'b000000_0;
localparam	[6:0]	LP_LMP_SPEED_ACCEPT		= 'b000000_1;
localparam	[7:0]	LP_LMP_NUM_HP_4			= 'd4;
localparam	[1:0]	LP_LMP_DIR_DOWN			= 'b01;
localparam	[1:0]	LP_LMP_DIR_UP			= 'b10;
localparam	[0:0]	LP_LMP_OTG_INCAPABLE	= 'b0;
localparam	[0:0]	LP_LMP_OTG_CAPABLE		= 'b1;
localparam	[3:0]	LP_LMP_TIEBREAK			= 'b0000;

localparam	[3:0]	LP_TP_SUB_RSVD			= 'b0000,
					LP_TP_SUB_ACK			= 'b0001,
					LP_TP_SUB_NRDY			= 'b0010,
					LP_TP_SUB_ERDY			= 'b0011,
					LP_TP_SUB_STATUS		= 'b0100,
					LP_TP_SUB_STALL			= 'b0101,
					LP_TP_SUB_DEVNOTIFY		= 'b0110,
					LP_TP_SUB_PING			= 'b0111,
					LP_TP_SUB_PINGRSP		= 'b1000;
					
localparam	[19:0]	LP_TP_ROUTE0			= 'b0;
localparam	[0:0]	LP_TP_NORETRY			= 'b0,
					LP_TP_RETRY				= 'b1;
localparam	[0:0]	LP_TP_HOSTTODEVICE		= 'b0,
					LP_TP_DEVICETOHOST		= 'b1;
localparam	[15:0]	LP_TP_STREAMID			= 'h0;
//
// the following are for isochronous endpoints only (Table 8-12)
//
localparam	[0:0]	LP_TP_SSI_NO			= 'b0,	// Support Smart Isochronous
					LP_TP_SSI_YES			= 'b1;
localparam	[0:0]	LP_TP_WPA_NO			= 'b0,	// Will Ping Again
					LP_TP_WPA_YES			= 'b1;
localparam	[0:0]	LP_TP_DBI_NO			= 'b0,	// Data in Bus Interval Done
					LP_TP_DBI_YES			= 'b1;
//
localparam	[0:0]	LP_TP_PPEND_NO			= 'b0,	// Packets Pending from Host
					LP_TP_PPEND_YES			= 'b1;
localparam	[3:0]	LP_TP_NBI_0				= 'b0;	// Number of Bus Intervals

localparam	[3:0]	LP_TP_DN_FUNC_AWAKE		= 'b0001,
					LP_TP_DN_LAT_TOL_MSG	= 'b0010,
					LP_TP_DN_BUS_INTER_ADJ	= 'b0011,
					LP_TP_DN_HOST_ROLE_REQ	= 'b0100;
					
localparam	[0:0]	LP_DP_EOB_LPF_NO		= 1'b0,
					LP_DP_EOB_LPF_YES		= 1'b1;
		
localparam	[1:0]	PHY_CAPABILITY			= 2'b00;
localparam	[1:0]	PHY_READY				= 2'b01;
localparam	[1:0]	PHY_LANE_RATE_5G		= 2'b00;
localparam	[1:0]	PHY_LANE_RATE_10G		= 2'b01;
localparam			PHY_SIGNAL_LANE			= 1'b0;
localparam			PHY_DUAL_LANE			= 1'b1;

function	[15:0]	swap16;
	input	[15:0]	i;
	swap16 = {i[7:0], i[15:8]};
endfunction

function	[31:0]	swap32;
	input	[31:0]	i;
	swap32 = {i[7:0], i[15:8], i[23:16], i[31:24]};
endfunction

function	[63:0]	swap64;
	input	[63:0]	i;
	swap64 = {i[7:0], i[15:8], i[23:16], i[31:24],i[(5*8-1)-:1*8],i[(6*8-1)-:1*8],i[(7*8-1)-:1*8],i[(8*8-1)-:1*8]};
endfunction

function [3:0] swap4bit;
	input [3:0] data_in ;
	integer i ;
	begin
		for ( i = 0 ; i < 4 ; i = i + 1 ) begin
			swap4bit [i] = data_in[3-i] ;  	
		end
	end

endfunction

function [16:0] swap16bit;
	input [15:0] data_in ;
	integer i ;
	begin
		for ( i = 0 ; i < 16 ; i = i + 1 ) begin
			swap16bit [i] = data_in[15-i] ;  	
		end
	end

endfunction

function [31:0] swap32bit;
	input [31:0] data_in ;
	integer i ;
	begin
		for ( i = 0 ; i < 32 ; i = i + 1 ) begin
			swap32bit [i] = data_in[31-i] ;  	
		end
	end

endfunction

function [63:0] swap64bit;
	input [63:0] data_in ;
	integer i ;
	begin
		for ( i = 0 ; i < 64 ; i = i + 1 ) begin
			swap64bit [i] = data_in[63-i] ;  	
		end
	end

endfunction

function [95:0] swap96bit;
	input [95:0] data_in ;
	integer i ;
	begin
		for ( i = 0 ; i < 96 ; i = i + 1 ) begin
			swap96bit [i] = data_in[95-i] ;  	
		end
	end

endfunction

`define INC(x) x<=x+1'b1
`define DEC(x) x<=x-1'b1


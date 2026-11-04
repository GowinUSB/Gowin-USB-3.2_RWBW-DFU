//Copyright (C)2014-2026 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.12.04 (64-bit)(88992)
//Device: GW5AT-60
//Device Version: B
//Part Number: GW5AT-LV60UG225C2/I1
//Device-Package: GW5AT-60B-UBGA225
//Created Time: Mon Sep 21 15:28:34 2026

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	USB3_2_PHY_Top your_instance_name(
		.phy_resetn_phy0(phy_resetn_phy0), //input phy_resetn_phy0
		.pclk(pclk), //output pclk
		.CCSelect(CCSelect), //input CCSelect
		.PipeTxDataValid_phy0(PipeTxDataValid_phy0), //input PipeTxDataValid_phy0
		.PipeTxSyncHead_phy0(PipeTxSyncHead_phy0), //input [3:0] PipeTxSyncHead_phy0
		.PipeTxStartBlock_phy0(PipeTxStartBlock_phy0), //input PipeTxStartBlock_phy0
		.PipeTxData_phy0(PipeTxData_phy0), //input [63:0] PipeTxData_phy0
		.PipeTxDataK_phy0(PipeTxDataK_phy0), //input [3:0] PipeTxDataK_phy0
		.PipeRxSyncHead_phy0(PipeRxSyncHead_phy0), //output [3:0] PipeRxSyncHead_phy0
		.PipeRxStartBlock_phy0(PipeRxStartBlock_phy0), //output PipeRxStartBlock_phy0
		.PipeRxData_phy0(PipeRxData_phy0), //output [63:0] PipeRxData_phy0
		.PipeRxDataValid_phy0(PipeRxDataValid_phy0), //output PipeRxDataValid_phy0
		.PipeRxDataK_phy0(PipeRxDataK_phy0), //output [3:0] PipeRxDataK_phy0
		.TxDetectRx_loopback_phy0(TxDetectRx_loopback_phy0), //input TxDetectRx_loopback_phy0
		.TxElecIdle_phy0(TxElecIdle_phy0), //input TxElecIdle_phy0
		.TxSwing_phy0(TxSwing_phy0), //input TxSwing_phy0
		.TxMargin_phy0(TxMargin_phy0), //input [2:0] TxMargin_phy0
		.TxDeemph_phy0(TxDeemph_phy0), //input [11:0] TxDeemph_phy0
		.RxPolarity_phy0(RxPolarity_phy0), //input RxPolarity_phy0
		.RxTermination_phy0(RxTermination_phy0), //input RxTermination_phy0
		.RxElecIdle_phy0(RxElecIdle_phy0), //output RxElecIdle_phy0
		.RxStatus_phy0(RxStatus_phy0), //output [2:0] RxStatus_phy0
		.PowerDown_phy0(PowerDown_phy0), //input [1:0] PowerDown_phy0
		.PhyStatus_phy0(PhyStatus_phy0), //output PhyStatus_phy0
		.PowerPresent_phy0(PowerPresent_phy0), //output PowerPresent_phy0
		.ElasticityBufferMode_phy0(ElasticityBufferMode_phy0), //input ElasticityBufferMode_phy0
		.Rate_phy0(Rate_phy0), //input Rate_phy0
		.TxFifoWrNum_phy0(TxFifoWrNum_phy0), //output [4:0] TxFifoWrNum_phy0
		.LTSSM_is_Training_phy0(LTSSM_is_Training_phy0), //input LTSSM_is_Training_phy0
		.serdes_upar_clk_i_phy0(serdes_upar_clk_i_phy0), //input serdes_upar_clk_i_phy0
		.serdes_upar_wren_o_phy0(serdes_upar_wren_o_phy0), //output serdes_upar_wren_o_phy0
		.serdes_upar_addr_o_phy0(serdes_upar_addr_o_phy0), //output [23:0] serdes_upar_addr_o_phy0
		.serdes_upar_wrdata_o_phy0(serdes_upar_wrdata_o_phy0), //output [31:0] serdes_upar_wrdata_o_phy0
		.serdes_upar_rden_o_phy0(serdes_upar_rden_o_phy0), //output serdes_upar_rden_o_phy0
		.serdes_upar_resp_i_phy0(serdes_upar_resp_i_phy0), //input serdes_upar_resp_i_phy0
		.serdes_upar_strb_o_phy0(serdes_upar_strb_o_phy0), //output [7:0] serdes_upar_strb_o_phy0
		.serdes_upar_rddata_i_phy0(serdes_upar_rddata_i_phy0), //input [31:0] serdes_upar_rddata_i_phy0
		.serdes_upar_rdvld_i_phy0(serdes_upar_rdvld_i_phy0), //input serdes_upar_rdvld_i_phy0
		.serdes_upar_ready_i_phy0(serdes_upar_ready_i_phy0), //input serdes_upar_ready_i_phy0
		.serdes_q0_qpll0_ok_i(serdes_q0_qpll0_ok_i), //input serdes_q0_qpll0_ok_i
		.serdes_q0_qpll1_ok_i(serdes_q0_qpll1_ok_i), //input serdes_q0_qpll1_ok_i
		.serdes_q1_qpll0_ok_i(serdes_q1_qpll0_ok_i), //input serdes_q1_qpll0_ok_i
		.serdes_q1_qpll1_ok_i(serdes_q1_qpll1_ok_i), //input serdes_q1_qpll1_ok_i
		.serdes_cpll_ok_i(serdes_cpll_ok_i), //input serdes_cpll_ok_i
		.serdes_fabric_rstn_o_phy0(serdes_fabric_rstn_o_phy0), //output serdes_fabric_rstn_o_phy0
		.serdes_pcs_tx_clk_i_phy0(serdes_pcs_tx_clk_i_phy0), //input serdes_pcs_tx_clk_i_phy0
		.serdes_fabric_tx_clk_o_phy0(serdes_fabric_tx_clk_o_phy0), //output serdes_fabric_tx_clk_o_phy0
		.serdes_pcs_tx_rst_o_phy0(serdes_pcs_tx_rst_o_phy0), //output serdes_pcs_tx_rst_o_phy0
		.serdes_fabric_tx_vld_o_phy0(serdes_fabric_tx_vld_o_phy0), //output serdes_fabric_tx_vld_o_phy0
		.serdes_tx_fifo_wrusewd_i_phy0(serdes_tx_fifo_wrusewd_i_phy0), //input [4:0] serdes_tx_fifo_wrusewd_i_phy0
		.serdes_txdata_o_phy0(serdes_txdata_o_phy0), //output [79:0] serdes_txdata_o_phy0
		.serdes_pcs_rx_clk_i_phy0(serdes_pcs_rx_clk_i_phy0), //input serdes_pcs_rx_clk_i_phy0
		.serdes_fabric_rx_clk_o_phy0(serdes_fabric_rx_clk_o_phy0), //output serdes_fabric_rx_clk_o_phy0
		.serdes_pma_rx_lock_i_phy0(serdes_pma_rx_lock_i_phy0), //input serdes_pma_rx_lock_i_phy0
		.serdes_pcs_rx_rst_o_phy0(serdes_pcs_rx_rst_o_phy0), //output serdes_pcs_rx_rst_o_phy0
		.serdes_rxfifo_rd_en_o_phy0(serdes_rxfifo_rd_en_o_phy0), //output serdes_rxfifo_rd_en_o_phy0
		.serdes_rxfifo_aempty_i_phy0(serdes_rxfifo_aempty_i_phy0), //input serdes_rxfifo_aempty_i_phy0
		.serdes_rx_fifo_rdusewd_i_phy0(serdes_rx_fifo_rdusewd_i_phy0), //input [4:0] serdes_rx_fifo_rdusewd_i_phy0
		.serdes_rxdata_i_phy0(serdes_rxdata_i_phy0), //input [87:0] serdes_rxdata_i_phy0
		.serdes_rx_vld_i_phy0(serdes_rx_vld_i_phy0), //input serdes_rx_vld_i_phy0
		.serdes_rxelecidle_i_phy0(serdes_rxelecidle_i_phy0), //input serdes_rxelecidle_i_phy0
		.serdes_astat_i_phy0(serdes_astat_i_phy0), //input [5:0] serdes_astat_i_phy0
		.serdes_fabric_rstn_o_phy1(serdes_fabric_rstn_o_phy1), //output serdes_fabric_rstn_o_phy1
		.serdes_pcs_tx_clk_i_phy1(serdes_pcs_tx_clk_i_phy1), //input serdes_pcs_tx_clk_i_phy1
		.serdes_fabric_tx_clk_o_phy1(serdes_fabric_tx_clk_o_phy1), //output serdes_fabric_tx_clk_o_phy1
		.serdes_pcs_tx_rst_o_phy1(serdes_pcs_tx_rst_o_phy1), //output serdes_pcs_tx_rst_o_phy1
		.serdes_fabric_tx_vld_o_phy1(serdes_fabric_tx_vld_o_phy1), //output serdes_fabric_tx_vld_o_phy1
		.serdes_tx_fifo_wrusewd_i_phy1(serdes_tx_fifo_wrusewd_i_phy1), //input [4:0] serdes_tx_fifo_wrusewd_i_phy1
		.serdes_txdata_o_phy1(serdes_txdata_o_phy1), //output [79:0] serdes_txdata_o_phy1
		.serdes_pcs_rx_clk_i_phy1(serdes_pcs_rx_clk_i_phy1), //input serdes_pcs_rx_clk_i_phy1
		.serdes_fabric_rx_clk_o_phy1(serdes_fabric_rx_clk_o_phy1), //output serdes_fabric_rx_clk_o_phy1
		.serdes_pma_rx_lock_i_phy1(serdes_pma_rx_lock_i_phy1), //input serdes_pma_rx_lock_i_phy1
		.serdes_pcs_rx_rst_o_phy1(serdes_pcs_rx_rst_o_phy1), //output serdes_pcs_rx_rst_o_phy1
		.serdes_rxfifo_rd_en_o_phy1(serdes_rxfifo_rd_en_o_phy1), //output serdes_rxfifo_rd_en_o_phy1
		.serdes_rxfifo_aempty_i_phy1(serdes_rxfifo_aempty_i_phy1), //input serdes_rxfifo_aempty_i_phy1
		.serdes_rx_fifo_rdusewd_i_phy1(serdes_rx_fifo_rdusewd_i_phy1), //input [4:0] serdes_rx_fifo_rdusewd_i_phy1
		.serdes_rxdata_i_phy1(serdes_rxdata_i_phy1), //input [87:0] serdes_rxdata_i_phy1
		.serdes_rx_vld_i_phy1(serdes_rx_vld_i_phy1), //input serdes_rx_vld_i_phy1
		.serdes_rxelecidle_i_phy1(serdes_rxelecidle_i_phy1), //input serdes_rxelecidle_i_phy1
		.serdes_astat_i_phy1(serdes_astat_i_phy1) //input [5:0] serdes_astat_i_phy1
	);

//--------Copy end-------------------

//Copyright (C)2014-2026 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.12.04 (64-bit)
//IP Version: 1.0
//Part Number: GW5AT-LV60UG225C2/I1
//Device: GW5AT-60
//Device Version: B
//Created Time: Mon Sep 21 15:28:36 2026

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    SerDes_Top your_instance_name(
        .USB3_2_PHY_Top_pclk(USB3_2_PHY_Top_pclk), //output USB3_2_PHY_Top_pclk
        .USB3_2_PHY_Top_PipeRxSyncHead_phy0(USB3_2_PHY_Top_PipeRxSyncHead_phy0), //output [3:0] USB3_2_PHY_Top_PipeRxSyncHead_phy0
        .USB3_2_PHY_Top_PipeRxStartBlock_phy0(USB3_2_PHY_Top_PipeRxStartBlock_phy0), //output USB3_2_PHY_Top_PipeRxStartBlock_phy0
        .USB3_2_PHY_Top_PipeRxData_phy0(USB3_2_PHY_Top_PipeRxData_phy0), //output [63:0] USB3_2_PHY_Top_PipeRxData_phy0
        .USB3_2_PHY_Top_PipeRxDataValid_phy0(USB3_2_PHY_Top_PipeRxDataValid_phy0), //output USB3_2_PHY_Top_PipeRxDataValid_phy0
        .USB3_2_PHY_Top_PipeRxDataK_phy0(USB3_2_PHY_Top_PipeRxDataK_phy0), //output [3:0] USB3_2_PHY_Top_PipeRxDataK_phy0
        .USB3_2_PHY_Top_RxElecIdle_phy0(USB3_2_PHY_Top_RxElecIdle_phy0), //output USB3_2_PHY_Top_RxElecIdle_phy0
        .USB3_2_PHY_Top_RxStatus_phy0(USB3_2_PHY_Top_RxStatus_phy0), //output [2:0] USB3_2_PHY_Top_RxStatus_phy0
        .USB3_2_PHY_Top_PhyStatus_phy0(USB3_2_PHY_Top_PhyStatus_phy0), //output USB3_2_PHY_Top_PhyStatus_phy0
        .USB3_2_PHY_Top_PowerPresent_phy0(USB3_2_PHY_Top_PowerPresent_phy0), //output USB3_2_PHY_Top_PowerPresent_phy0
        .USB3_2_PHY_Top_TxFifoWrNum_phy0(USB3_2_PHY_Top_TxFifoWrNum_phy0), //output [4:0] USB3_2_PHY_Top_TxFifoWrNum_phy0
        .por_n_i(por_n_i), //input por_n_i
        .USB3_2_PHY_Top_phy_resetn_phy0(USB3_2_PHY_Top_phy_resetn_phy0), //input USB3_2_PHY_Top_phy_resetn_phy0
        .USB3_2_PHY_Top_CCSelect(USB3_2_PHY_Top_CCSelect), //input USB3_2_PHY_Top_CCSelect
        .USB3_2_PHY_Top_PipeTxDataValid_phy0(USB3_2_PHY_Top_PipeTxDataValid_phy0), //input USB3_2_PHY_Top_PipeTxDataValid_phy0
        .USB3_2_PHY_Top_PipeTxSyncHead_phy0(USB3_2_PHY_Top_PipeTxSyncHead_phy0), //input [3:0] USB3_2_PHY_Top_PipeTxSyncHead_phy0
        .USB3_2_PHY_Top_PipeTxStartBlock_phy0(USB3_2_PHY_Top_PipeTxStartBlock_phy0), //input USB3_2_PHY_Top_PipeTxStartBlock_phy0
        .USB3_2_PHY_Top_PipeTxData_phy0(USB3_2_PHY_Top_PipeTxData_phy0), //input [63:0] USB3_2_PHY_Top_PipeTxData_phy0
        .USB3_2_PHY_Top_PipeTxDataK_phy0(USB3_2_PHY_Top_PipeTxDataK_phy0), //input [3:0] USB3_2_PHY_Top_PipeTxDataK_phy0
        .USB3_2_PHY_Top_TxDetectRx_loopback_phy0(USB3_2_PHY_Top_TxDetectRx_loopback_phy0), //input USB3_2_PHY_Top_TxDetectRx_loopback_phy0
        .USB3_2_PHY_Top_TxElecIdle_phy0(USB3_2_PHY_Top_TxElecIdle_phy0), //input USB3_2_PHY_Top_TxElecIdle_phy0
        .USB3_2_PHY_Top_TxSwing_phy0(USB3_2_PHY_Top_TxSwing_phy0), //input USB3_2_PHY_Top_TxSwing_phy0
        .USB3_2_PHY_Top_TxMargin_phy0(USB3_2_PHY_Top_TxMargin_phy0), //input [2:0] USB3_2_PHY_Top_TxMargin_phy0
        .USB3_2_PHY_Top_TxDeemph_phy0(USB3_2_PHY_Top_TxDeemph_phy0), //input [11:0] USB3_2_PHY_Top_TxDeemph_phy0
        .USB3_2_PHY_Top_RxPolarity_phy0(USB3_2_PHY_Top_RxPolarity_phy0), //input USB3_2_PHY_Top_RxPolarity_phy0
        .USB3_2_PHY_Top_RxTermination_phy0(USB3_2_PHY_Top_RxTermination_phy0), //input USB3_2_PHY_Top_RxTermination_phy0
        .USB3_2_PHY_Top_PowerDown_phy0(USB3_2_PHY_Top_PowerDown_phy0), //input [1:0] USB3_2_PHY_Top_PowerDown_phy0
        .USB3_2_PHY_Top_ElasticityBufferMode_phy0(USB3_2_PHY_Top_ElasticityBufferMode_phy0), //input USB3_2_PHY_Top_ElasticityBufferMode_phy0
        .USB3_2_PHY_Top_Rate_phy0(USB3_2_PHY_Top_Rate_phy0), //input USB3_2_PHY_Top_Rate_phy0
        .USB3_2_PHY_Top_LTSSM_is_Training_phy0(USB3_2_PHY_Top_LTSSM_is_Training_phy0) //input USB3_2_PHY_Top_LTSSM_is_Training_phy0
    );

//--------Copy end-------------------

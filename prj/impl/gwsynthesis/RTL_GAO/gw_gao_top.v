module gw_gao(
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_has_data ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[16] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[15] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[14] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[13] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[12] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[11] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[10] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[9] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[8] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[7] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[6] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[5] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[4] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[3] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[2] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[1] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[0] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[13] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[12] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[11] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[10] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[9] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[8] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[7] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[6] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[5] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[4] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[3] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[2] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[1] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[0] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[63] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[62] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[61] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[60] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[59] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[58] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[57] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[56] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[55] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[54] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[53] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[52] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[51] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[50] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[49] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[48] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[47] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[46] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[45] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[44] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[43] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[42] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[41] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[40] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[39] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[38] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[37] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[36] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[35] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[34] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[33] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[32] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[31] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[30] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[29] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[28] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[27] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[26] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[25] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[24] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[23] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[22] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[21] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[20] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[19] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[18] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[17] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[16] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[15] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[14] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[13] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[12] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[11] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[10] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[9] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[8] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[7] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[6] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[5] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[4] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[3] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[2] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[1] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[0] ,
    \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_clr ,
    \UserLayer_top_inst/EP1_UAC_inst/audio_tx_dval ,
    \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[7] ,
    \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[6] ,
    \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[5] ,
    \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[4] ,
    \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[3] ,
    \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[2] ,
    \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[1] ,
    \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[0] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_winc ,
    \UserLayer_top_inst/EP1_UAC_inst/o_addr[0] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[31] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[30] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[29] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[28] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[27] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[26] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[25] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[24] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[23] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[22] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[21] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[20] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[19] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[18] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[17] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[16] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[15] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[14] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[13] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[12] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[11] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[10] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[9] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[8] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[7] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[6] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[5] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[4] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[3] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[2] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[1] ,
    \UserLayer_top_inst/EP1_UAC_inst/o_data[0] ,
    \UserLayer_top_inst/speaker_CLK_GEN_inst/O_IIS_LRCK ,
    \UserLayer_top_inst/speaker_CLK_GEN_inst/O_IIS_BCLK ,
    \UserLayer_top_inst/EP1_UAC_inst/audio_tx_pcm2iis_inst/O_IIS_DATA[0] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_WINC ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_ADDR[0] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[31] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[30] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[29] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[28] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[27] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[26] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[25] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[24] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[23] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[22] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[21] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[20] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[19] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[18] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[17] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[16] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[15] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[14] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[13] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[12] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[11] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[10] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[9] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[8] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[7] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[6] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[5] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[4] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[3] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[2] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[1] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[0] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_val ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[63] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[62] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[61] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[60] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[59] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[58] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[57] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[56] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[55] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[54] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[53] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[52] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[51] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[50] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[49] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[48] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[47] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[46] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[45] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[44] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[43] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[42] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[41] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[40] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[39] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[38] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[37] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[36] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[35] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[34] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[33] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[32] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[31] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[30] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[29] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[28] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[27] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[26] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[25] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[24] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[23] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[22] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[21] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[20] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[19] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[18] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[17] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[16] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[15] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[14] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[13] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[12] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[11] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[10] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[9] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[8] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[7] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[6] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[5] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[4] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[3] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[2] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[1] ,
    \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[0] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[7] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[6] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[5] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[4] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[3] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[2] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[1] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[0] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[13] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[12] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[11] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[10] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[9] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[8] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[7] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[6] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[5] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[4] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[3] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[2] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[1] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[0] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[63] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[62] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[61] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[60] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[59] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[58] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[57] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[56] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[55] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[54] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[53] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[52] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[51] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[50] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[49] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[48] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[47] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[46] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[45] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[44] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[43] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[42] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[41] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[40] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[39] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[38] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[37] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[36] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[35] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[34] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[33] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[32] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[31] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[30] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[29] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[28] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[27] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[26] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[25] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[24] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[23] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[22] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[21] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[20] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[19] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[18] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[17] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[16] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[15] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[14] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[13] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[12] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[11] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[10] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[9] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[8] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[7] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[6] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[5] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[4] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[3] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[2] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[1] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[0] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[16] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[15] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[14] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[13] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[12] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[11] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[10] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[9] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[8] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[7] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[6] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[5] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[4] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[3] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[2] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[1] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[0] ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_ready ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_done ,
    \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_empty ,
    \UserLayer_top_inst/EP2_UAC_inst/u_FIFO_to_Pingpong_Adapter/state[2] ,
    \UserLayer_top_inst/EP2_UAC_inst/u_FIFO_to_Pingpong_Adapter/state[1] ,
    \UserLayer_top_inst/EP2_UAC_inst/u_FIFO_to_Pingpong_Adapter/state[0] ,
    \UserLayer_top_inst/EP2_UAC_inst/u_FIFO_to_Pingpong_Adapter/rst_n ,
    \transfer_in_mem_wr[2] ,
    \UserLayer_top_inst/EP2_UAC_inst/u_FIFO_to_Pingpong_Adapter/transfer_in_mem_commit ,
    pclk,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_has_data ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[16] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[15] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[14] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[13] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[12] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[11] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[10] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[9] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[8] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[7] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[6] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[5] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[4] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[3] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[2] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[1] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[0] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[13] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[12] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[11] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[10] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[9] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[8] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[7] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[6] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[5] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[4] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[3] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[2] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[1] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[0] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[63] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[62] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[61] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[60] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[59] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[58] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[57] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[56] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[55] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[54] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[53] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[52] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[51] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[50] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[49] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[48] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[47] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[46] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[45] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[44] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[43] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[42] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[41] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[40] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[39] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[38] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[37] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[36] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[35] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[34] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[33] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[32] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[31] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[30] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[29] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[28] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[27] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[26] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[25] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[24] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[23] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[22] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[21] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[20] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[19] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[18] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[17] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[16] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[15] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[14] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[13] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[12] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[11] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[10] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[9] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[8] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[7] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[6] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[5] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[4] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[3] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[2] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[1] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[0] ;
input \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_clr ;
input \UserLayer_top_inst/EP1_UAC_inst/audio_tx_dval ;
input \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[7] ;
input \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[6] ;
input \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[5] ;
input \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[4] ;
input \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[3] ;
input \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[2] ;
input \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[1] ;
input \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[0] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_winc ;
input \UserLayer_top_inst/EP1_UAC_inst/o_addr[0] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[31] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[30] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[29] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[28] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[27] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[26] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[25] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[24] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[23] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[22] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[21] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[20] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[19] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[18] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[17] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[16] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[15] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[14] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[13] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[12] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[11] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[10] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[9] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[8] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[7] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[6] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[5] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[4] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[3] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[2] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[1] ;
input \UserLayer_top_inst/EP1_UAC_inst/o_data[0] ;
input \UserLayer_top_inst/speaker_CLK_GEN_inst/O_IIS_LRCK ;
input \UserLayer_top_inst/speaker_CLK_GEN_inst/O_IIS_BCLK ;
input \UserLayer_top_inst/EP1_UAC_inst/audio_tx_pcm2iis_inst/O_IIS_DATA[0] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_WINC ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_ADDR[0] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[31] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[30] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[29] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[28] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[27] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[26] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[25] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[24] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[23] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[22] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[21] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[20] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[19] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[18] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[17] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[16] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[15] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[14] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[13] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[12] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[11] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[10] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[9] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[8] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[7] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[6] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[5] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[4] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[3] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[2] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[1] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[0] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_val ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[63] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[62] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[61] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[60] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[59] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[58] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[57] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[56] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[55] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[54] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[53] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[52] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[51] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[50] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[49] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[48] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[47] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[46] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[45] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[44] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[43] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[42] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[41] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[40] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[39] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[38] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[37] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[36] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[35] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[34] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[33] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[32] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[31] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[30] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[29] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[28] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[27] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[26] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[25] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[24] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[23] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[22] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[21] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[20] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[19] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[18] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[17] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[16] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[15] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[14] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[13] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[12] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[11] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[10] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[9] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[8] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[7] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[6] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[5] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[4] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[3] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[2] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[1] ;
input \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[0] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[7] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[6] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[5] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[4] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[3] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[2] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[1] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[0] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[13] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[12] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[11] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[10] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[9] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[8] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[7] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[6] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[5] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[4] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[3] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[2] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[1] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[0] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[63] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[62] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[61] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[60] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[59] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[58] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[57] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[56] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[55] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[54] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[53] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[52] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[51] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[50] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[49] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[48] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[47] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[46] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[45] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[44] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[43] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[42] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[41] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[40] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[39] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[38] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[37] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[36] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[35] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[34] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[33] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[32] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[31] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[30] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[29] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[28] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[27] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[26] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[25] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[24] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[23] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[22] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[21] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[20] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[19] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[18] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[17] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[16] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[15] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[14] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[13] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[12] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[11] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[10] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[9] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[8] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[7] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[6] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[5] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[4] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[3] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[2] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[1] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[0] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[16] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[15] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[14] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[13] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[12] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[11] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[10] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[9] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[8] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[7] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[6] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[5] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[4] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[3] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[2] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[1] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[0] ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_ready ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_done ;
input \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_empty ;
input \UserLayer_top_inst/EP2_UAC_inst/u_FIFO_to_Pingpong_Adapter/state[2] ;
input \UserLayer_top_inst/EP2_UAC_inst/u_FIFO_to_Pingpong_Adapter/state[1] ;
input \UserLayer_top_inst/EP2_UAC_inst/u_FIFO_to_Pingpong_Adapter/state[0] ;
input \UserLayer_top_inst/EP2_UAC_inst/u_FIFO_to_Pingpong_Adapter/rst_n ;
input \transfer_in_mem_wr[2] ;
input \UserLayer_top_inst/EP2_UAC_inst/u_FIFO_to_Pingpong_Adapter/transfer_in_mem_commit ;
input pclk;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_has_data ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[16] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[15] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[14] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[13] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[12] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[11] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[10] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[9] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[8] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[7] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[6] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[5] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[4] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[3] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[2] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[1] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[0] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[13] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[12] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[11] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[10] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[9] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[8] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[7] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[6] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[5] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[4] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[3] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[2] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[1] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[0] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[63] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[62] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[61] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[60] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[59] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[58] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[57] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[56] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[55] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[54] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[53] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[52] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[51] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[50] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[49] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[48] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[47] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[46] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[45] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[44] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[43] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[42] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[41] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[40] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[39] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[38] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[37] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[36] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[35] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[34] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[33] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[32] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[31] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[30] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[29] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[28] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[27] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[26] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[25] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[24] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[23] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[22] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[21] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[20] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[19] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[18] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[17] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[16] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[15] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[14] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[13] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[12] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[11] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[10] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[9] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[8] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[7] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[6] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[5] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[4] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[3] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[2] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[1] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[0] ;
wire \UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_clr ;
wire \UserLayer_top_inst/EP1_UAC_inst/audio_tx_dval ;
wire \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[7] ;
wire \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[6] ;
wire \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[5] ;
wire \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[4] ;
wire \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[3] ;
wire \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[2] ;
wire \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[1] ;
wire \UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[0] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_winc ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_addr[0] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[31] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[30] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[29] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[28] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[27] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[26] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[25] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[24] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[23] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[22] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[21] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[20] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[19] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[18] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[17] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[16] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[15] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[14] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[13] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[12] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[11] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[10] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[9] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[8] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[7] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[6] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[5] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[4] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[3] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[2] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[1] ;
wire \UserLayer_top_inst/EP1_UAC_inst/o_data[0] ;
wire \UserLayer_top_inst/speaker_CLK_GEN_inst/O_IIS_LRCK ;
wire \UserLayer_top_inst/speaker_CLK_GEN_inst/O_IIS_BCLK ;
wire \UserLayer_top_inst/EP1_UAC_inst/audio_tx_pcm2iis_inst/O_IIS_DATA[0] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_WINC ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_ADDR[0] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[31] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[30] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[29] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[28] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[27] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[26] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[25] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[24] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[23] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[22] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[21] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[20] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[19] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[18] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[17] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[16] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[15] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[14] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[13] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[12] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[11] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[10] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[9] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[8] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[7] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[6] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[5] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[4] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[3] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[2] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[1] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[0] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_val ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[63] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[62] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[61] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[60] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[59] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[58] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[57] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[56] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[55] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[54] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[53] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[52] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[51] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[50] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[49] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[48] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[47] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[46] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[45] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[44] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[43] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[42] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[41] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[40] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[39] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[38] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[37] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[36] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[35] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[34] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[33] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[32] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[31] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[30] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[29] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[28] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[27] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[26] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[25] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[24] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[23] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[22] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[21] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[20] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[19] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[18] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[17] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[16] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[15] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[14] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[13] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[12] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[11] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[10] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[9] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[8] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[7] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[6] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[5] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[4] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[3] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[2] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[1] ;
wire \UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[0] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[7] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[6] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[5] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[4] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[3] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[2] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[1] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[0] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[13] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[12] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[11] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[10] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[9] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[8] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[7] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[6] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[5] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[4] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[3] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[2] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[1] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[0] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[63] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[62] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[61] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[60] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[59] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[58] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[57] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[56] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[55] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[54] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[53] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[52] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[51] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[50] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[49] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[48] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[47] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[46] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[45] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[44] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[43] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[42] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[41] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[40] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[39] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[38] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[37] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[36] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[35] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[34] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[33] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[32] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[31] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[30] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[29] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[28] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[27] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[26] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[25] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[24] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[23] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[22] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[21] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[20] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[19] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[18] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[17] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[16] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[15] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[14] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[13] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[12] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[11] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[10] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[9] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[8] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[7] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[6] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[5] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[4] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[3] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[2] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[1] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[0] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[16] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[15] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[14] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[13] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[12] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[11] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[10] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[9] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[8] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[7] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[6] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[5] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[4] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[3] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[2] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[1] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[0] ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_ready ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_done ;
wire \UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_empty ;
wire \UserLayer_top_inst/EP2_UAC_inst/u_FIFO_to_Pingpong_Adapter/state[2] ;
wire \UserLayer_top_inst/EP2_UAC_inst/u_FIFO_to_Pingpong_Adapter/state[1] ;
wire \UserLayer_top_inst/EP2_UAC_inst/u_FIFO_to_Pingpong_Adapter/state[0] ;
wire \UserLayer_top_inst/EP2_UAC_inst/u_FIFO_to_Pingpong_Adapter/rst_n ;
wire \transfer_in_mem_wr[2] ;
wire \UserLayer_top_inst/EP2_UAC_inst/u_FIFO_to_Pingpong_Adapter/transfer_in_mem_commit ;
wire pclk;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top_0  u_la0_top(
    .control(control0[9:0]),
    .trig0_i({\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_has_data ,\transfer_in_mem_wr[2] }),
    .trig1_i(\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_val ),
    .trig2_i(\UserLayer_top_inst/EP2_UAC_inst/u_FIFO_to_Pingpong_Adapter/transfer_in_mem_commit ),
    .data_i({\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_has_data ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[16] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[15] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[14] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[13] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[12] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[11] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[10] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[9] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[8] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[7] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[6] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[5] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[4] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[3] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[2] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[1] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_len[0] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[13] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[12] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[11] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[10] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[9] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[8] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[7] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[6] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[5] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[4] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[3] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[2] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[1] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_addr[0] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[63] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[62] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[61] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[60] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[59] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[58] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[57] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[56] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[55] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[54] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[53] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[52] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[51] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[50] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[49] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[48] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[47] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[46] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[45] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[44] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[43] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[42] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[41] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[40] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[39] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[38] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[37] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[36] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[35] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[34] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[33] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[32] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[31] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[30] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[29] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[28] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[27] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[26] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[25] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[24] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[23] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[22] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[21] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[20] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[19] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[18] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[17] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[16] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[15] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[14] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[13] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[12] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[11] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[10] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[9] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[8] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[7] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[6] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[5] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[4] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[3] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[2] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[1] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_rd_data[0] ,\UserLayer_top_inst/EP1_UAC_inst/transfer_out_mem_clr ,\UserLayer_top_inst/EP1_UAC_inst/audio_tx_dval ,\UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[7] ,\UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[6] ,\UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[5] ,\UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[4] ,\UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[3] ,\UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[2] ,\UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[1] ,\UserLayer_top_inst/EP1_UAC_inst/audio_tx_data[0] ,\UserLayer_top_inst/EP1_UAC_inst/o_winc ,\UserLayer_top_inst/EP1_UAC_inst/o_addr[0] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[31] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[30] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[29] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[28] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[27] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[26] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[25] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[24] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[23] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[22] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[21] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[20] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[19] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[18] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[17] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[16] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[15] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[14] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[13] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[12] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[11] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[10] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[9] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[8] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[7] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[6] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[5] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[4] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[3] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[2] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[1] ,\UserLayer_top_inst/EP1_UAC_inst/o_data[0] ,\UserLayer_top_inst/speaker_CLK_GEN_inst/O_IIS_LRCK ,\UserLayer_top_inst/speaker_CLK_GEN_inst/O_IIS_BCLK ,\UserLayer_top_inst/EP1_UAC_inst/audio_tx_pcm2iis_inst/O_IIS_DATA[0] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_WINC ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_ADDR[0] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[31] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[30] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[29] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[28] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[27] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[26] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[25] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[24] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[23] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[22] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[21] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[20] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[19] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[18] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[17] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[16] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[15] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[14] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[13] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[12] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[11] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[10] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[9] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[8] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[7] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[6] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[5] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[4] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[3] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[2] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[1] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_pcm2usb_inst/I_DATA[0] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_val ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[63] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[62] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[61] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[60] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[59] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[58] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[57] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[56] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[55] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[54] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[53] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[52] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[51] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[50] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[49] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[48] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[47] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[46] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[45] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[44] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[43] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[42] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[41] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[40] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[39] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[38] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[37] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[36] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[35] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[34] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[33] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[32] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[31] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[30] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[29] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[28] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[27] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[26] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[25] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[24] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[23] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[22] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[21] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[20] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[19] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[18] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[17] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[16] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[15] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[14] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[13] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[12] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[11] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[10] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[9] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[8] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[7] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[6] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[5] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[4] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[3] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[2] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[1] ,\UserLayer_top_inst/EP2_UAC_inst/audio_rx_frame_data[0] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[7] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[6] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[5] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[4] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[3] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[2] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[1] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_mask[0] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[13] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[12] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[11] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[10] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[9] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[8] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[7] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[6] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[5] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[4] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[3] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[2] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[1] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_addr[0] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[63] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[62] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[61] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[60] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[59] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[58] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[57] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[56] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[55] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[54] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[53] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[52] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[51] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[50] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[49] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[48] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[47] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[46] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[45] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[44] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[43] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[42] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[41] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[40] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[39] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[38] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[37] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[36] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[35] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[34] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[33] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[32] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[31] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[30] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[29] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[28] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[27] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[26] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[25] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[24] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[23] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[22] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[21] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[20] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[19] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[18] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[17] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[16] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[15] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[14] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[13] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[12] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[11] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[10] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[9] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[8] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[7] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[6] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[5] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[4] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[3] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[2] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[1] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_wr_data[0] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[16] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[15] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[14] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[13] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[12] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[11] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[10] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[9] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[8] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[7] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[6] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[5] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[4] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[3] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[2] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[1] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_commit_len[0] ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_ready ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_done ,\UserLayer_top_inst/EP2_UAC_inst/transfer_in_mem_empty ,\UserLayer_top_inst/EP2_UAC_inst/u_FIFO_to_Pingpong_Adapter/state[2] ,\UserLayer_top_inst/EP2_UAC_inst/u_FIFO_to_Pingpong_Adapter/state[1] ,\UserLayer_top_inst/EP2_UAC_inst/u_FIFO_to_Pingpong_Adapter/state[0] ,\UserLayer_top_inst/EP2_UAC_inst/u_FIFO_to_Pingpong_Adapter/rst_n }),
    .clk_i(pclk)
);

endmodule

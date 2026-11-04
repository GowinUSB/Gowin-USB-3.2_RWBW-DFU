// Copyright (c) 2026 GOWIN SEMICONDUCTOR CORPORATION.
// SPDX-License-Identifier: MIT
module UserLayer_top 
(

	 input wire pclk 
	,input wire phy_resetn
	
	,input wire 	   warm_or_hot_reset				
	,input wire 	   host_requests_data_from_endpt[0:15]   
	,input wire		   itp_received

	,input wire		   i_dfu_mode
	

	// requests
	,input wire			   request_active 	
	,input wire	[7:0]	   bmRequestType	
	,input wire	[7:0]	   bRequest		
	,input wire	[15:0]	wValue			
	,input wire	[15:0]	wIndex			
	,input wire	[15:0]	wLength	
	,input wire				wait_user_commit_request
	,output  wire        request_commit     

	//IN  
   ,output  wire        transfer_in_mem_wr          [0:15]    
   ,output  wire [7:0]  transfer_in_mem_wr_mask     [0:15]  
   ,output  wire [13:0] transfer_in_mem_wr_addr     [0:15]  	
   ,output  wire [63:0] transfer_in_mem_wr_data     [0:15]  		 	
   ,output  wire        transfer_in_mem_commit      [0:15]  		
   ,output  wire [16:0] transfer_in_mem_commit_len  [0:15]  	
   ,input   wire        transfer_in_mem_ready       [0:15]  
   ,input   wire        transfer_in_done            [0:15]
   ,input   wire        transfer_in_mem_empty       [0:15]

	//OUT	
	
   ,input   wire        transfer_out_mem_has_data   [0:15]    
   ,input   wire [16:0] transfer_out_mem_len        [0:15] 
   ,output  wire [13:0] transfer_out_mem_rd_addr    [0:15] 
   ,input   wire [63:0] transfer_out_mem_rd_data    [0:15] 
   ,output  wire        transfer_out_mem_clr        [0:15]   
 

   ,output     spi_sclk 
   ,output     spi_cs 
   ,output     spi_mosi 
   ,input      spi_miso

);

wire 	 [7:0] 		current_config_value 		;
wire	 			   set_interface				;
wire	 [15:0]		set_interface_num           ;
wire	 [15:0]  	set_interface_alt_setting   ;



ControlTransfer ControlTransfer_inst
(
	.clk 	(pclk)
	,.rst_n (phy_resetn)

	// requests
	,.request_active 	         (request_active	       )	
	,.bmRequestType	         (bmRequestType           )
	,.bRequest		            (bRequest		          )
	,.wValue			            (wValue			          )
	,.wIndex			            (wIndex			          )
	,.wLength	               (wLength	                )
	,.wait_user_commit_request (wait_user_commit_request)
	,.request_commit           (request_commit          )  

	// ep0 IN  
   ,.transfer_in_mem_wr                (transfer_in_mem_wr        [0]) //output          
   ,.transfer_in_mem_wr_mask           (transfer_in_mem_wr_mask   [0]) //output  [7:0]  
   ,.transfer_in_mem_wr_addr       	   (transfer_in_mem_wr_addr   [0]) //output  [13:0] 
   ,.transfer_in_mem_wr_data       		(transfer_in_mem_wr_data   [0]) //output  [63:0]  	
   ,.transfer_in_mem_commit        		(transfer_in_mem_commit    [0]) //output         
   ,.transfer_in_mem_commit_len    	   (transfer_in_mem_commit_len[0]) //output  [15:0] 
   ,.transfer_in_mem_ready             (transfer_in_mem_ready     [0]) //input          
   ,.transfer_in_done                  (transfer_in_done          [0]) //input          
   
	// ep0 OUT	
   ,.transfer_out_mem_has_data         (transfer_out_mem_has_data [0]) //input             
   ,.transfer_out_mem_len              (transfer_out_mem_len      [0]) //input    [15:0] 
   ,.transfer_out_mem_rd_addr          (transfer_out_mem_rd_addr  [0]) //output   [13:0] 
   ,.transfer_out_mem_rd_data          (transfer_out_mem_rd_data  [0]) //input    [63:0] 
   ,.transfer_out_mem_clr              (transfer_out_mem_clr      [0]) //output          

	,.current_config_value 		   (current_config_value      )
	,.set_interface				   (set_interface			      )
	,.set_interface_num           (set_interface_num         )
	,.set_interface_alt_setting   (set_interface_alt_setting )
//==================================================
	// DFU Control  
    ,.i_dfu_mode            (i_dfu_mode         )
    ,.o_dfu_detach_flag     (dfu_detach_flag    )
   // EP0 DFU DATA     
    ,.o_dfu_spi_wr_req      (dfu_spi_wr_req     )
    ,.i_dfu_spi_wr_ack      (m_spi_wr_ack       )
    ,.o_dfu_spi_wr_flush    (dfu_spi_wr_flush   )
    ,.o_dfu_spi_lba         (dfu_spi_lba        )
    ,.i_dfu_spi_buf_addr    (m_spi_buf_addr     )
    ,.o_dfu_spi_buf_rdata   (dfu_spi_buf_rdata  ) 
);


EP1_loopback EP1_loopback_inst
(
      
	 .clk          (pclk) //input 
	,.rst_n        (phy_resetn) //input 
   
	// ep1 IN  
   ,.transfer_in_mem_wr           (transfer_in_mem_wr        [1]) //output                
   ,.transfer_in_mem_wr_mask      (transfer_in_mem_wr_mask   [1]) //output  [7:0]   
   ,.transfer_in_mem_wr_addr      (transfer_in_mem_wr_addr   [1]) //output  [13:0]  	
   ,.transfer_in_mem_wr_data      (transfer_in_mem_wr_data   [1]) //output  [31:0]  		 	
   ,.transfer_in_mem_commit       (transfer_in_mem_commit    [1]) //output          		
   ,.transfer_in_mem_commit_len   (transfer_in_mem_commit_len[1]) //output  [15:0]  	
   ,.transfer_in_mem_ready        (transfer_in_mem_ready     [1]) //input           
   ,.transfer_in_done             (transfer_in_done          [1]) //input          
   
	// ep1 OUT	
   ,.transfer_out_mem_has_data    (transfer_out_mem_has_data[1]) //input              
   ,.transfer_out_mem_len         (transfer_out_mem_len     [1]) //input   [15:0] 
   ,.transfer_out_mem_rd_addr     (transfer_out_mem_rd_addr [1]) //output  [13:0] 
   ,.transfer_out_mem_rd_data     (transfer_out_mem_rd_data [1]) //input   [31:0] 
   ,.transfer_out_mem_clr         (transfer_out_mem_clr     [1]) //output         


);


 EP2_speed EP2_speed_inst
(
    .clk                          (pclk                         ) //input
   ,.rst_n                        (phy_resetn                   ) //input
    // ep2 IN  
   ,.transfer_in_mem_wr           (transfer_in_mem_wr        [2]) //output
   ,.transfer_in_mem_wr_mask      (transfer_in_mem_wr_mask   [2]) //output  [3:0]
   ,.transfer_in_mem_wr_addr      (transfer_in_mem_wr_addr   [2]) //output  [13:0]
   ,.transfer_in_mem_wr_data      (transfer_in_mem_wr_data   [2]) //output  [31:0]
   ,.transfer_in_mem_commit       (transfer_in_mem_commit    [2]) //output
   ,.transfer_in_mem_commit_len   (transfer_in_mem_commit_len[2]) //output  [15:0]
   ,.transfer_in_mem_ready        (transfer_in_mem_ready     [2]) //input
   ,.transfer_in_done             (transfer_in_done          [2]) //input
    // ep2 OUT
   ,.transfer_out_mem_has_data    (transfer_out_mem_has_data[2]) //input
   ,.transfer_out_mem_len         (transfer_out_mem_len     [2]) //input   [15:0]
   ,.transfer_out_mem_rd_addr     (transfer_out_mem_rd_addr [2]) //output  [13:0]
   ,.transfer_out_mem_rd_data     (transfer_out_mem_rd_data [2]) //input   [31:0]
   ,.transfer_out_mem_clr         (transfer_out_mem_clr     [2]) //output
); 




//===================================================================================================================================================================================
//6) SPI flash controller （DFU）
//  UMS + DFU  Perform read and write operations on SPIflash using “spi_flash_controller”
//  The two will not work at the same time. 
//  UMS is not included here.
//  UMS + DFU  均会对spi flash进行操作 “spi_flash_controller”
//  两者不会同时工作. 
//  此处不包含 UMS.
//====================================================================================================================================================================================
//==============================================================
//====== SPI Bus Multiplexer (UMS vs DFU)
//==============================================================
//MUX selects to enter the flash_ctr bus
wire [31:0] m_spi_lba;
wire        m_spi_wr_req;
wire        m_spi_wr_flush;
wire [7:0]  m_spi_buf_rdata;

wire        m_spi_rd_req;
//UMS dedicated control line no used
//DFU dedicated control line
wire [31:0] dfu_spi_lba;
wire        dfu_spi_wr_req;
wire        dfu_spi_wr_flush;
wire [7:0]  dfu_spi_buf_rdata;
//Shared line
wire        m_spi_rd_ack;
wire        m_spi_wr_ack;
wire        m_spi_buf_we;
wire  [8:0] m_spi_buf_addr;
wire  [7:0] m_spi_buf_wdata;

assign m_spi_lba       = dfu_spi_lba       ;
assign m_spi_wr_req    = dfu_spi_wr_req    ;
assign m_spi_wr_flush  = dfu_spi_wr_flush  ;
assign m_spi_buf_rdata = dfu_spi_buf_rdata ;
assign m_spi_rd_req    = 1'b0              ; // DFU only writes and does not read, forcibly pulling low


spi_flash_controller #(
    .CLK_DIV  ( 2   ) 
)
spi_flash_controller
(
     .clk               (pclk          )
    ,.rst_n             (phy_resetn    )
    
    ,.is_dfu_mode       (i_dfu_mode       )

    ,.spi_lba           (m_spi_lba        ) 

    ,.spi_rd_req        (m_spi_rd_req     )
    ,.spi_rd_ack        (m_spi_rd_ack     )

    ,.spi_wr_req        (m_spi_wr_req     )
    ,.spi_wr_ack        (m_spi_wr_ack     )
    ,.spi_wr_flush      (m_spi_wr_flush  )

    ,.spi_buf_we        (m_spi_buf_we     )
    ,.spi_buf_addr      (m_spi_buf_addr   )
    ,.spi_buf_wdata     (m_spi_buf_wdata  )
    ,.spi_buf_rdata     (m_spi_buf_rdata  )

    ,.spi_clk           (spi_sclk       )
    ,.spi_cs_n          (spi_cs         )
    ,.spi_mosi          (spi_mosi       )
    ,.spi_miso          (spi_miso       )
);


endmodule
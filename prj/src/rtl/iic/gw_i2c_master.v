// Copyright (c) 2026 GOWIN SEMICONDUCTOR CORPORATION.
// SPDX-License-Identifier: MIT
`timescale 1ns/1ps

`define IF_DATA_WIDTH 8
   
module gw_i2c_master (
    clk_125m,
    rst_n,
    scl,
	scl_pull,
    sda,
	sda_pull,	
    i_fusb_int_n,
    cc_orient,
	vbus,
    error_flag,
    cstate_flag,
    interupt
);
    
 input	    clk_125m;
 input	    rst_n;
 inout	    scl;
 inout	    sda;
 output     scl_pull;
 output     sda_pull;	
 input      i_fusb_int_n;
 output     [1:0] cc_orient;
 output     vbus;	
 output     error_flag;
         
 output reg cstate_flag=1'b0;
 output     interupt;

/////////////////////////////////////////////////////////////////////
/*reg/wire 												 		   */
 
 wire                        I_TX_EN;
 wire [2:0]                  I_WADDR;
 wire [`IF_DATA_WIDTH-1:0]   I_WDATA;
 wire                        I_RX_EN;
 wire [2:0]                  I_RADDR;
 wire [`IF_DATA_WIDTH-1:0]   O_RDATA;
 
 wire                        rstn1;
 wire                        start = 1;
 reg [7:0]                   delay_rst=0;
 reg [7:0]                   delay=0;
 reg [15:0]                  counter0=0;
 reg                         clk_en=0; 
 
 wire                        cstate_flag_temp;
 reg                         cstate_flag_temp1;  
///////////////////////////////////////////////////////////////////////////////////////////////////
 wire                        clk_sys;

// Gowin_rPLL your_instance_name(
    // .clkout(clk_sys), //output clkout
    // .clkin(clk_50m) //input clkin
// );


// assign rstn1=&{delay_rst[5],!delay_rst[4],!delay_rst[3],!delay_rst[2],!delay_rst[1],!delay_rst[0]};

// assign start=&{delay[5],!delay[4],!delay[3],!delay[2],!delay[1],!delay[0]};

// always @(posedge clk_sys) 
     // if(counter0==16'd49999) begin
	    // counter0 <= 16'd0;
		// clk_en <= 1'b1;
	 // end
	 // else begin
	    // counter0 <= counter0 + 16'd1;
		// clk_en <= 1'b0;	 
	 // end

// always @(posedge clk_sys)
     // if(clk_en==1'b1) begin
        // delay[7:1] <= delay[6:0];
        // delay[0] <= key2;	 
	 
        // delay_rst[7:1] <= delay_rst[6:0];
        // delay_rst[0] <= rst_n;
     // end
	 
// always @(posedge clk_sys)
     // begin
        // cstate_flag_temp1 <= cstate_flag_temp;
     // end

// always @(posedge clk_sys)
     // if(cstate_flag_temp1 == 1'b0 && cstate_flag_temp == 1'b1) begin
        // cstate_flag <= ~cstate_flag;
     // end	 
	 
/////////////////////////////////////////////////////////////////////
//   master_sram_iic 	    u_master_sram_iic
//   (
//       .I_CLK              ( clk_125m                ),
//       .I_RESETN           ( rst_n                   ),
// 	  .start              ( start                   ),
//       .I_TX_EN            ( I_TX_EN                 ),
//       .I_WADDR            ( I_WADDR                 ),
//       .I_WDATA            ( I_WDATA                 ),
//       .I_RX_EN            ( I_RX_EN                 ),
//       .I_RADDR            ( I_RADDR                 ),
//       .O_RDATA            ( O_RDATA                 ),
//       .cstate_flag        ( cstate_flag_temp        ),
//       .error_flag         ( error_flag              ),
// 	  .vbus				  ( vbus					)
//   );

  iic_controller u_iic_controller 
  (
    .I_CLK              ( clk_125m                ),
    .I_RESETN           ( rst_n                   ),
    .start              ( start                   ),
    .i_fusb_int_n       ( i_fusb_int_n            ),
    .I_TX_EN            ( I_TX_EN                 ),
    .I_WADDR            ( I_WADDR                 ),
    .I_WDATA            ( I_WDATA                 ),
    .I_RX_EN            ( I_RX_EN                 ),
    .I_RADDR            ( I_RADDR                 ),
    .O_RDATA            ( O_RDATA                 ),
    .cstate_flag        ( cstate_flag_temp        ),
    .error_flag         ( error_flag              ),
    .vbus_ok		    ( vbus				      ),
    .cc_orient			( cc_orient				  )
  );

  I2C_MASTER_Top        u_i2c_master_top
  (
      .I_CLK              ( clk_125m                ),
      .I_RESETN           ( rst_n                   ),
      .I_TX_EN            ( I_TX_EN                 ),
      .I_WADDR            ( I_WADDR                 ),
      .I_WDATA            ( I_WDATA                 ),
      .I_RX_EN            ( I_RX_EN                 ),
      .I_RADDR            ( I_RADDR                 ),
      .O_RDATA            ( O_RDATA                 ),
      .O_IIC_INT          ( interupt                ),
      .SCL                ( scl                     ),
      .SDA                ( sda                     )
  );               
    
assign scl_pull =1'b1;	
assign sda_pull =1'b1;

endmodule
  


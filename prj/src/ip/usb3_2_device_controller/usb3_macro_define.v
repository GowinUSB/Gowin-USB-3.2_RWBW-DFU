`define getname(oriName,tmodule_name) \~oriName.tmodule_name
`define module_name USB3_2_Device_Controller_Top  

`define ENDPT0_IN
`define ENDPT0_IN_TYPE 		         2'b00
`define ENDPT0_IN_BURST  	         5'd0
`define ENDPT0_IN_TRANSFER_MAX_SIZE  16'd1024 
`define ENDPT0_IN_MEM_PP_NUM         'd1

`define ENDPT0_OUT      
`define ENDPT0_OUT_TYPE 	          2'b00
`define ENDPT0_OUT_BURST  	          5'd0
`define ENDPT0_OUT_TRANSFER_MAX_SIZE  16'd1024
`define ENDPT0_OUT_MEM_PP_NUM         'd1

`define ENDPT1_IN
`define ENDPT1_IN_TYPE 		         2'b10
`define ENDPT1_IN_BURST  	         5'd15
`define ENDPT1_IN_TRANSFER_MAX_SIZE (2*1024)
`define ENDPT1_IN_MEM_PP_NUM        'd2

`define ENDPT1_OUT
`define ENDPT1_OUT_TYPE 		         2'b10
`define ENDPT1_OUT_BURST  	            5'd15
`define ENDPT1_OUT_TRANSFER_MAX_SIZE   (2*1024)
`define ENDPT1_OUT_MEM_PP_NUM          'd2

`define ENDPT2_IN
`define ENDPT2_IN_TYPE 		         2'b10
`define ENDPT2_IN_BURST  	         5'd15
`define ENDPT2_IN_TRANSFER_MAX_SIZE (8*1024)
`define ENDPT2_IN_MEM_PP_NUM        'd3

`define ENDPT2_OUT
`define ENDPT2_OUT_TYPE 		       2'b10
`define ENDPT2_OUT_BURST  	           5'd15
`define ENDPT2_OUT_TRANSFER_MAX_SIZE   (8*1024)
`define ENDPT2_OUT_MEM_PP_NUM          'd3


import usb_std_pkg::*;
`include "descriptors/usb_desc_config.vh"
//===========================================
module ControlTransfer #(
    parameter bit ENABLE_DFU  = 1'b1
   ,parameter bit ENABLE_CDC  = 1'b0
   ,parameter bit ENABLE_UVC  = 1'b0
)(
	 input   logic 	         clk 
	,input   logic             rst_n

	// requests 
	,input   logic			      request_active 	
	,input   logic	[7:0]	      bmRequestType	
	,input   logic	[7:0]	      bRequest		
	,input   logic	[15:0]	   wValue			
	,input   logic	[15:0]	   wIndex			
	,input   logic	[15:0]	   wLength	
	,input   logic				   wait_user_commit_request
	,output  logic             request_commit  

	// ep0 IN   
   ,output  logic             transfer_in_mem_wr              
   ,output  logic [7:0]       transfer_in_mem_wr_mask       
   ,output  logic [13:0]      transfer_in_mem_wr_addr       	
   ,output  logic [63:0]      transfer_in_mem_wr_data       		 	
   ,output  logic             transfer_in_mem_commit        		
   ,output  logic [16:0]      transfer_in_mem_commit_len    	
   ,input   logic             transfer_in_mem_ready         
   ,input   logic             transfer_in_done            

	// ep0 OUT	   
   ,input   logic             transfer_out_mem_has_data    
   ,input   logic [16:0]      transfer_out_mem_len        
   ,output  logic [13:0]      transfer_out_mem_rd_addr    
   ,input   logic [63:0]      transfer_out_mem_rd_data    
   ,output  logic             transfer_out_mem_clr        
   
	,output logic  [7:0]       current_config_value
	,output logic  		      set_interface
	,output logic  [15:0]      set_interface_num 
	,output logic  [15:0]      set_interface_alt_setting

// DFU Control  
   ,input  logic           i_dfu_mode          // 重枚举后 进入 1：DFU_mode 0：APP_mode
   ,output logic           o_dfu_detach_flag   // 接收DFU_DETACH指令
    // EP0 DFU DATA     
   ,output logic           o_dfu_spi_wr_req    // 写请求
   ,input  logic           i_dfu_spi_wr_ack    // 写应答
   ,output logic           o_dfu_spi_wr_flush  // 强制刷写Flash 
   ,output logic [31:0]    o_dfu_spi_lba       // 逻辑块地址 (512B为单位)
   ,input  logic [8:0]     i_dfu_spi_buf_addr  // Flash控制器给出的读地址
   ,output logic [7:0]     o_dfu_spi_buf_rdata // 输出给Flash控制器的数据




)/*synthesis syn_ramstyle="block_ram"*/;


//===================================================================================================================================================================================
// 1) SETUP 锁存
//====================================================================================================================================================================================
typedef struct packed {
    logic [ 7:0] bmRequestType;
    logic [ 7:0] bRequest;
    logic [15:0] wValue;
    logic [15:0] wIndex;
    logic [15:0] wLength;
} usb_setup_pkt_t;
usb_setup_pkt_t setup_pkt_latch;

// 拼接顺序：[RequestType 8] + [Request 8]  + [wValue 16] + [wIndex 16]
//===================================================================================================================================================================================
// 2) 数据状态机
// SETUP指令 → 数据阶段（0/OUT/IN）→ 状态阶段
// ST_IDLE   ==>  ST_SETUP_STAGE ==> ST_CMT_REQ (0长度 结束)
//                               ==> ST_DATA_IN_STAGE_PREP (BRAM延迟)   ==> ST_DATA_IN_STAGE ==> ST_DATA_IN_STAGE_COMMIT
//                               ==> ST_DATA_OUT_STAGE_PREP (等hasdata) ==> ST_DATA_OUT_STAGE ++> ST_DATA_OUT_STAGE_COMMIT
//====================================================================================================================================================================================
logic setup_stage_en    ;     // SETUP   阶段解析中      （64bit已锁存，等待功能模块回应）

logic st_setup_done     ;     // SETUP   阶段解析完毕   （CMD/length已就绪）
logic st_data_out_done  ;     // 数据OUT 阶段接收完毕   （主机发给设备的数据已存入 RAM）
logic st_data_in_done   ;     // 数据in  阶段发送完毕   （设备发给主机的数据已完成）
logic st_status_done    ;     // 状态应答阶段完毕       (未使用)

localparam ST_W                     =  4     ;
localparam ST_IDLE                  =  4'd0  ;
localparam ST_SETUP_STAGE           =  4'd1  ;
localparam ST_DATA_IN_STAGE         =  4'd2  ;
localparam ST_DATA_IN_STAGE_PREP    =  4'd3  ;
localparam ST_DATA_IN_STAGE_LEN_CAL =  4'd4  ;
localparam ST_DATA_IN_STAGE_COMMIT  =  4'd5  ;
localparam ST_DATA_OUT_STAGE        =  4'd6  ;
localparam ST_DATA_OUT_STAGE_PREP   =  4'd7  ;
localparam ST_DATA_OUT_STAGE_COMMIT =  4'd8  ;
localparam ST_CMT_REQ               =  4'd9  ;
logic       [ST_W-1:0] state ;

logic [15:0] transfer_len_mux_out ; //本次传输实际长度
logic [15:0] ep0_bytes_left; // 当前指令数据阶段剩余数据长度 （OUT/IN）


logic             transfer_out_mem_rd ;
logic             transfer_out_data_val ;
logic [63:0]      transfer_out_data ;
logic [15-2:0]    transfer_out_data_idx ;

assign setup_stage_en = (state == ST_SETUP_STAGE);


always_ff @ ( posedge clk or negedge rst_n ) begin
   if ( !rst_n ) begin
      state                         <= ST_IDLE ;
      
      setup_pkt_latch.bmRequestType	<=  0 ; 
      setup_pkt_latch.bRequest		<=  0 ;
      setup_pkt_latch.wValue			<=  0 ;
      setup_pkt_latch.wIndex			<=  0 ;
      setup_pkt_latch.wLength	      <=  0 ; 
         
      transfer_in_mem_wr            <= 0 ;
      transfer_in_mem_wr_mask       <= 0 ;
      transfer_in_mem_wr_addr       <= 0 ;
      transfer_in_mem_wr_data       <= 0 ;
      transfer_in_mem_commit        <= 0 ;
      transfer_in_mem_commit_len    <= 0 ;
      
      transfer_out_mem_rd           <= 0 ;
      transfer_out_mem_rd_addr      <= 0 ;
      transfer_out_mem_clr          <= 0 ;   

      request_commit                <= 0 ;     
      st_setup_done                 <= 0 ;
      st_data_out_done              <= 0 ;
      st_data_in_done               <= 0 ;
   end   
   else begin  
      st_setup_done                 <= 0 ;
      st_data_out_done              <= 0 ;
      st_data_in_done               <= 0 ;


      case ( state ) 
      ST_IDLE:begin
         if (request_active) begin
            state                         <= ST_SETUP_STAGE;
            setup_pkt_latch.bmRequestType <= bmRequestType;
            setup_pkt_latch.bRequest      <= bRequest;
            setup_pkt_latch.wValue        <= wValue;
            setup_pkt_latch.wIndex        <= wIndex;
            setup_pkt_latch.wLength       <= wLength;
         end

         transfer_in_mem_wr            <= 0 ;
         transfer_in_mem_wr_mask       <= 0 ;
         transfer_in_mem_wr_addr       <= 0 ;
         transfer_in_mem_wr_data       <= 0 ;
         transfer_in_mem_commit        <= 0 ;
         transfer_in_mem_commit_len    <= 0 ;
         
         transfer_out_mem_rd           <= 0 ;
         transfer_out_mem_rd_addr      <= 0 ;
         transfer_out_mem_clr          <= 0 ;   

         request_commit <= 0 ;  
      end            

      // ---------------- [解析阶段] ----------------
      ST_SETUP_STAGE: begin
         if ( setup_req_valid ) begin
            st_setup_done <= 1;
            request_commit <= 1;

            //确定数据阶段 实际长度
            transfer_len_mux_out <= transfer_in_len_mux;
            ep0_bytes_left       <= transfer_in_len_mux;

            state                <= ST_CMT_REQ;
         end 
         else begin
            // 遇到不支持的请求 (丢弃或 STALL？ )
            request_commit       <= 0;
            st_setup_done        <= 0;
            transfer_len_mux_out <= 0;
            ep0_bytes_left       <= 0;
            state                <= ST_IDLE; 
         end
      end
      ST_CMT_REQ :begin
         request_commit <= 0 ;
         if ( !request_commit ) begin  
            state <= ST_IDLE ;      // 避免异常进入该状态
         end
         else begin       
            if (setup_pkt_latch.wLength == 0) begin
                state <= ST_IDLE;                  // 无数据阶段，直接等待下一包或底层自动发状态阶段 0长包
            end 
            else if (setup_pkt_latch.bmRequestType[7] == DIR_HOST_TO_DEVICE) begin
                state <= ST_DATA_OUT_STAGE_PREP;   // 等待接收 OUT 数据
            end 
            else begin //(setup_pkt_latch.bmRequestType[7] == DIR_DEVICE_TO_HOST)
                state <= ST_DATA_IN_STAGE_PREP;    // 准备发送 IN 数据 (给RAM寻址留1拍)
            end
         end
      end

   // ---------------- [IN 数据阶段] ----------------
     ST_DATA_IN_STAGE_PREP: begin
         state <= ST_DATA_IN_STAGE;
     end

     ST_DATA_IN_STAGE: begin
         transfer_in_mem_wr            <= 1;
         transfer_in_mem_wr_mask       <= 0 ;
         transfer_in_mem_wr_addr       <= transfer_in_mem_wr ? transfer_in_mem_wr_addr + 1 : transfer_in_mem_wr_addr;
         transfer_in_mem_wr_data       <= transfer_in_data_mux;
         transfer_in_mem_commit        <= 0 ;
         transfer_in_mem_commit_len    <= 0 ;   
         
         if (ep0_bytes_left <= 16'd8) begin //等效于 data_in_stage_end
             state <= ST_DATA_IN_STAGE_COMMIT;
         end 
         else begin
             ep0_bytes_left <= ep0_bytes_left - 16'd8;
         end

     end

      ST_DATA_IN_STAGE_COMMIT: begin
         st_data_in_done              <= 1; // IN 数据发送完成

         transfer_in_mem_wr            <= 0;
         transfer_in_mem_wr_mask       <= 0 ;
         transfer_in_mem_wr_addr       <= 0;
         transfer_in_mem_wr_data       <= 0 ;
         transfer_in_mem_commit        <= 1;
         transfer_in_mem_commit_len    <= transfer_len_mux_out;
         state                         <= ST_IDLE;
      end

   // ---------------- [OUT 数据阶段] ----------------
      ST_DATA_OUT_STAGE_PREP: begin
          if (transfer_out_mem_has_data) begin
              state <= ST_DATA_OUT_STAGE;         
          end
      end

      ST_DATA_OUT_STAGE: begin
         transfer_out_mem_rd      <= (transfer_out_mem_has_data ) ? 1 : 0;
         transfer_out_mem_rd_addr <= (transfer_out_mem_has_data ) ? transfer_out_mem_rd_addr + 1 : transfer_out_mem_rd_addr;
         transfer_out_mem_clr          <= 0 ; 

         if (transfer_out_mem_has_data) begin
             if (ep0_bytes_left <= 16'd8) begin //等效于data_out_stage_end
                 state <= ST_DATA_OUT_STAGE_COMMIT;
             end 
             else begin
                 ep0_bytes_left <= ep0_bytes_left - 16'd8;
             end
         end
      end

      ST_DATA_OUT_STAGE_COMMIT: begin
         st_data_out_done          <= 1; // OUT 数据接收完成，通知业务层可提取 RAM


         transfer_out_mem_rd        <= 0;
         transfer_out_mem_rd_addr   <= 0;
         transfer_out_mem_clr       <= 1;       
         state                      <= ST_IDLE;
      end

      default:;
      endcase 
   end
end


// passing through data and its index of data_stage of OUT transfer 
always_ff @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      transfer_out_data_val <= 0 ;
      transfer_out_data     <= 0 ;
   end
   else if ( transfer_out_mem_rd ) begin
      transfer_out_data_val <= 1 ;
      transfer_out_data     <= transfer_out_mem_rd_data ;
   end
   else begin
      transfer_out_data_val <= 0 ;
      transfer_out_data     <= 0 ; 
   end
end

always_ff @ ( posedge clk or negedge rst_n ) begin
   if (!rst_n) begin
      transfer_out_data_idx <= 0 ;
   end
   else if ( transfer_out_data_val ) begin
      transfer_out_data_idx <= transfer_out_data_idx + 1 ;
   end
   else begin
      transfer_out_data_idx <= 0 ;
   end
end

logic [13:0] transfer_in_data_idx ;
always_ff @ ( posedge clk or negedge rst_n ) begin
   if ( !rst_n ) begin
      transfer_in_data_idx <= 0 ;
   end 
   else begin
      transfer_in_data_idx <= ( state == ST_DATA_IN_STAGE || state ==  ST_DATA_IN_STAGE_PREP ) ? transfer_in_data_idx + 1 : 0 ; 
   end
end


//===================================================================================================================================================================================
// 3) IN数据 
// 广播分发 + 监听各处理模块
//====================================================================================================================================================================================
logic        std_setup_req_active      ,  cdc_setup_req_active       ,  dfu_setup_req_active       ,  uvc_setup_req_active       ;
logic [15:0] std_transfer_in_data_len  ,  cdc_transfer_in_data_len   ,  dfu_transfer_in_data_len   ,  uvc_transfer_in_data_len   ;
logic [63:0] std_transfer_in_data      ,  cdc_transfer_in_data       ,  dfu_transfer_in_data       ,  uvc_transfer_in_data       ;

logic        setup_req_valid;
logic [15:0] transfer_in_len_mux;
logic [63:0] transfer_in_data_mux;

always_comb begin
   unique case (1'b1)
      std_setup_req_active: begin
         setup_req_valid               = 1'b1;
         transfer_in_len_mux           = std_transfer_in_data_len;
         transfer_in_data_mux          = std_transfer_in_data;
      end
      dfu_setup_req_active: begin
         setup_req_valid               = 1'b1;
         transfer_in_len_mux           = dfu_transfer_in_data_len;
         transfer_in_data_mux          = dfu_transfer_in_data;
      end
      // cdc_setup_req_active: begin
      //    setup_req_valid               = 1'b1;
      //    transfer_in_len_mux           = cdc_transfer_in_data_len;
      //    transfer_in_data_mux          = cdc_transfer_in_data;
      // end
      // uvc_setup_req_active: begin
      //    setup_req_valid               = 1'b1;
      //    transfer_in_len_mux           = uvc_transfer_in_data_len;
      //    transfer_in_data_mux          = uvc_transfer_in_data;
      // end
      default: begin
         setup_req_valid               = 1'b0;
         transfer_in_len_mux           = setup_pkt_latch.wLength; 
         transfer_in_data_mux          = '0;
      end
   endcase
end

//===================================================================================================================================================================================
// 4) 处理模块例化
// 
//====================================================================================================================================================================================


usb_ep0_core u_ep0_core (
    .clk                         (clk              )
   ,.rst_n                       (rst_n            )  
   ,.i_dfu_mode                  (i_dfu_mode       )    //0:APP mode ; 1:DFU mode ,不使用DFU功能时固定为0

   // 广播总线 
   ,.setup_stage_en              (setup_stage_en   )
   ,.bmRequestType	         	(setup_pkt_latch.bmRequestType)
	,.bRequest		               (setup_pkt_latch.bRequest		)
	,.wValue			               (setup_pkt_latch.wValue			)
	,.wIndex			               (setup_pkt_latch.wIndex			)
	,.wLength		               (setup_pkt_latch.wLength		)
   ,.setup_req_active            (std_setup_req_active         )
   ,.st_setup_done               (st_setup_done    ) 

   // OUT 数据
   ,.transfer_out_data_val       (transfer_out_data_val        )
   ,.transfer_out_data_idx       (transfer_out_data_idx        )
   ,.transfer_out_data           (transfer_out_data            )
   ,.st_data_out_done            (st_data_out_done )

   // IN 数据  
   ,.transfer_in_data_len        (std_transfer_in_data_len     )
   ,.transfer_in_data_idx        (transfer_in_data_idx         ) 
   ,.transfer_in_data            (std_transfer_in_data         )
   ,.st_data_in_done             (st_data_in_done  )

   // EP0输出配置 
   ,.current_config_value        (current_config_value         )
   ,.set_interface               (set_interface                )
   ,.set_interface_num           (set_interface_num            )
   ,.set_interface_alt_setting   (set_interface_alt_setting    )
);

generate if (ENABLE_DFU) begin : gen_dfu
   usb_dfu_handler u_dfu_handler (
       .clk                         (clk              )
      ,.rst_n                       (rst_n            )

   // 基础广播与时序    
      ,.setup_stage_en              (setup_stage_en   )
      ,.bmRequestType	            (setup_pkt_latch.bmRequestType	)
	   ,.bRequest		               (setup_pkt_latch.bRequest			)
	   ,.wValue			               (setup_pkt_latch.wValue				)
	   ,.wIndex			               (setup_pkt_latch.wIndex				)
	   ,.wLength		               (setup_pkt_latch.wLength			)
      ,.setup_req_active            (dfu_setup_req_active            )
      ,.st_setup_done               (st_setup_done    ) 

   // OUT 广播数据
      ,.transfer_out_data_val       (transfer_out_data_val        )
      ,.transfer_out_data_idx       (transfer_out_data_idx        )
      ,.transfer_out_data           (transfer_out_data            )
      ,.st_data_out_done            (st_data_out_done )
       
   // IN 组装与反馈
      ,.transfer_in_data_len        (dfu_transfer_in_data_len     )
      ,.transfer_in_data_idx        (transfer_in_data_idx         ) 
      ,.transfer_in_data            (dfu_transfer_in_data         )
      ,.st_data_in_done             (st_data_in_done  )
   // 离散外部 IO
      ,.i_dfu_mode                  (i_dfu_mode       ) 
      ,.o_dfu_detach_flag           (o_dfu_detach_flag            )
      ,.o_dfu_spi_wr_req            (o_dfu_spi_wr_req             )   
      ,.i_dfu_spi_wr_ack            (i_dfu_spi_wr_ack             )
      ,.o_dfu_spi_wr_flush          (o_dfu_spi_wr_flush           )
      ,.o_dfu_spi_lba               (o_dfu_spi_lba                )
      ,.i_dfu_spi_buf_addr          (i_dfu_spi_buf_addr           ) 
      ,.o_dfu_spi_buf_rdata         (o_dfu_spi_buf_rdata          )
   );
end 
else begin : gen_no_dfu
    assign dfu_setup_req_active        = 1'b0;
    assign dfu_transfer_in_data_len    = 16'd0;
    assign dfu_transfer_in_data        = 64'd0;
    assign o_dfu_detach_flag           = 1'b0;
    assign o_dfu_spi_wr_req            = 1'b0;
    assign o_dfu_spi_wr_flush          = 1'b0;
    assign o_dfu_spi_lba               = 32'd0;
    assign o_dfu_spi_buf_rdata         = 8'h00;
end
endgenerate



generate if (ENABLE_CDC) begin : gen_cdc

end 
else begin : gen_no_cdc
    assign cdc_setup_req_active        = 1'b0;
    assign cdc_transfer_in_data_len    = 16'd0;
    assign cdc_transfer_in_data        = 64'd0;
end
endgenerate




generate if (ENABLE_UVC) begin : gen_dfu
   usb_uvc_handler u_uvc_handler (
       .clk                         (clk              )
      ,.rst_n                       (rst_n            )

   // 基础广播与时序    
      ,.setup_stage_en              (setup_stage_en   )
      ,.bmRequestType	            (setup_pkt_latch.bmRequestType	)
	   ,.bRequest		               (setup_pkt_latch.bRequest			)
	   ,.wValue			               (setup_pkt_latch.wValue				)
	   ,.wIndex			               (setup_pkt_latch.wIndex				)
	   ,.wLength		               (setup_pkt_latch.wLength			)
      ,.setup_req_active            (uvc_setup_req_active            )
      ,.st_setup_done               (st_setup_done    ) 

   // OUT 广播数据
      ,.transfer_out_data_val       (transfer_out_data_val        )
      ,.transfer_out_data_idx       (transfer_out_data_idx        )
      ,.transfer_out_data           (transfer_out_data            )
      ,.st_data_out_done            (st_data_out_done )
       
   // IN 组装与反馈
     ,.transfer_in_data_len         (uvc_transfer_in_data_len     )
     ,.transfer_in_data_idx         (transfer_in_data_idx         ) 
     ,.transfer_in_data             (uvc_transfer_in_data         )
     ,.st_data_in_done              (st_data_in_done  )
   // 离散外部 IO

   );

end 
else begin : gen_no_dfu
   assign uvc_setup_req_active           = 1'b0;
   assign uvc_transfer_in_data_len       = 16'd0;
   assign uvc_transfer_in_data           = 64'd0;
end
endgenerate





endmodule 






package uvc_pkg;
//==================================== bmRequestType =========================================    

//==================================== bRequest =========================================    
localparam SET_CUR = 8'h01 ;
localparam GET_CUR = 8'h81 ;
localparam GET_MIN = 8'h82 ;
localparam GET_MAX = 8'h83 ;


//==================================== wValue =========================================    
localparam VS_PROBE_CONTROL  = 8'h01 ;
localparam VS_COMMIT_CONTROL = 8'h02 ;

//GET_DESCRIPTOR (High byte 15:8 )
//localparam DEVICE_DESCRIPTOR_TYPE                                          = 8'h01   ;
//localparam CONFIGURATION_DESCRIPTOR_TYPE                                   = 8'h02   ;


//SET_FEATURE / CLEAR_FEATURE 
localparam ENDPOINT_HALT_FS         = 16'h0000;     // RECIPIENT_ENDPT

//==================================== wIndex =========================================

// localparam  FRAME_INTERVAL                  = 'd166666      ;
// localparam  MAX_VIDEO_FRAME_SIZE            = 'd16588800    ;
// localparam  FPS                             = 'd60          ;
// localparam  WIDTH                           = 'd1920        ;
// localparam  HIGHT                           = 'd1080        ;
// localparam  MAX_PAYLOAD_TRANSFER_SIZE       = 'd131072      ;
// localparam  PAYLOAD_LINE_NUM                = 'd17          ;
// localparam  PAYLOAD_NUM                     = 'd128         ;
// localparam  LAST_PAYLOAD_LINE_NUM           = 'd1           ;
// localparam  PAYLOAD_LEN                     = 'd130562      ;
// localparam  LAST_PAYLOAD_LEN                = 'd7682        ;
// localparam  PAYLOAD_COMMIT_NUM              = 'd16          ;
// localparam  PAYLOAD_COMMIT_LEN              = 'd8192        ;
// localparam  PAYLOAD_LAST_COMMIT_LEN         = 'd7682        ;
// localparam  LAST_PAYLOAD_COMMIT_NUM         = 'd1           ;
// localparam  LAST_PAYLOAD_COMMIT_LEN         = 'd8192        ;
// localparam  LAST_PAYLOAD_LAST_COMMIT_LEN    = 'd7682        ;


localparam  FRAME_INTERVAL                  = 'd166666      ;
localparam  MAX_VIDEO_FRAME_SIZE            = 'd4147200     ; // 1920 * 1080 * 2
localparam  FPS                             = 'd60          ;
localparam  WIDTH                           = 'd1920        ;
localparam  HIGHT                           = 'd1080        ;
localparam  MAX_PAYLOAD_TRANSFER_SIZE       = 'd131072      ; // 128KB 保持不变
localparam  PAYLOAD_LINE_NUM                = 'd34          ; // 130560 Bytes / 3840 Bytes(一行)
localparam  PAYLOAD_NUM                     = 'd32          ; // 总计32个Payload (31个满载 + 1个尾包)
localparam  LAST_PAYLOAD_LINE_NUM           = 'd26          ; // 1080 - (31 * 34) = 26 行
localparam  PAYLOAD_LEN                     = 'd130562      ; // 34 * 3840 + 2(UVC头)
localparam  LAST_PAYLOAD_LEN                = 'd99842       ; // 26 * 3840 + 2(UVC头)
localparam  PAYLOAD_COMMIT_NUM              = 'd16          ; // 130562 / 8192 = 15余7682，总共16次
localparam  PAYLOAD_COMMIT_LEN              = 'd8192        ;
localparam  PAYLOAD_LAST_COMMIT_LEN         = 'd7682        ; // 130562 - (15 * 8192)
localparam  LAST_PAYLOAD_COMMIT_NUM         = 'd13          ; // 99842 / 8192 = 12余1538，总共13次
localparam  LAST_PAYLOAD_COMMIT_LEN         = 'd8192        ;
localparam  LAST_PAYLOAD_LAST_COMMIT_LEN    = 'd1538        ; // 99842 - (12 * 8192)


//================================== 参数 =============================================

// parameter  [15:0] IMAGE_H_TOTAL  = 4400   	 	;
// parameter  [15:0] IMAGE_H_RES    = `WIDTH   	;
// parameter  [15:0] IMAGE_H_BPORCH = 296     	 	;
// parameter  [15:0] IMAGE_H_SYNC   = 88 		 	;
// parameter  [15:0] IMAGE_V_BPORCH = 72     		;
// parameter  [15:0] IMAGE_V_TOTAL  = 2250  		;
// parameter  [15:0] IMAGE_V_RES    = `HIGHT   	;
// parameter  [15:0] IMAGE_V_SYNC   = 10   		;
// parameter  [15:0] PIXEL_SIZE     = 16     		;
// parameter  [15:0] PIXEL_PER_RD   = 64/16  		;

//原有设计 低帧率50M(rgb_clk)生成，高帧率148.5M（frame_rd_clk）输出


parameter  [15:0] IMAGE_H_TOTAL  = 2200   	 	;
parameter  [15:0] IMAGE_H_RES    = 1920   	    ; 
parameter  [15:0] IMAGE_H_BPORCH = 148     	 	;
parameter  [15:0] IMAGE_H_SYNC   = 44 		 	;
parameter  [15:0] IMAGE_V_TOTAL  = 1125  		;
parameter  [15:0] IMAGE_V_RES    = 1080   	    ; 
parameter  [15:0] IMAGE_V_BPORCH = 36     		;
parameter  [15:0] IMAGE_V_SYNC   = 5   		    ;
parameter  [15:0] PIXEL_SIZE     = 16     		;
parameter  [15:0] PIXEL_PER_RD   = 64/16  		;

//2200*1125*60=148.5Mhz → 148.5M/4 = 37.125MHZ(rgb_clk)

endpackage
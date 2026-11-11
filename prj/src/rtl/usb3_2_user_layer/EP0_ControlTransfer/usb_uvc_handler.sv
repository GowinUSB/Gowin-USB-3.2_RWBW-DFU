
import usb_std_pkg::*;
import uvc_pkg::*;

module usb_uvc_handler (
     input  logic               clk
    ,input  logic               rst_n

// 广播 SETUP 指令
    ,input  logic               setup_stage_en
    ,input  logic   [7:0]	    bmRequestType	
    ,input  logic   [7:0]	    bRequest		
    ,input  logic   [15:0]      wValue			
    ,input  logic   [15:0]      wIndex			
    ,input  logic   [15:0]      wLength	    
    ,output logic               setup_req_active        // 该子模块响应当前SETUP命令
    ,input  logic               st_setup_done

// OUT数据相关      
    ,input  logic               transfer_out_data_val   // EP0 OUT 数据 有效
    ,input  logic [13:0]        transfer_out_data_idx   // EP0 OUT 数据 计数器
    ,input  logic [63:0]        transfer_out_data       // EP0 OUT 数据
    ,input  logic               st_data_out_done  

// IN数据相关
    ,output logic [15:0]        transfer_in_data_len   // EP0 IN 数据 长度
    ,input  logic [13:0]        transfer_in_data_idx
    ,output logic [63:0]        transfer_in_data       // EP0 IN 数据
    ,input  logic               st_data_in_done       
 
// 链接至外部 IO

);

// ----------------------------------------------------------------
// 1. SETUP 指令
// ----------------------------------------------------------------
// VS_PROBE_CONTROL
// VS_COMMIT_CONTROL
logic is_uvc_set_cur;
logic is_uvc_get_cur;

logic [15:0]   raw_req_len;

always_comb begin
    is_uvc_set_cur    = 0;
    is_uvc_get_cur    = 0;

    setup_req_active   = 0;
    raw_req_len      = 16'd0;

     casez ({bmRequestType,bRequest,wValue,wIndex})
        {GET_CLASS_INF  ,   GET_CUR, 16'h????, 16'h????},
        {GET_CLASS_INF  ,   GET_MIN, 16'h????, 16'h????},
        {GET_CLASS_INF  ,   GET_MAX, 16'h????, 16'h????}: begin
            is_uvc_get_cur = 1;
            setup_req_active = 1;
            raw_req_len    = 16'd34;
        end
        {SET_CLASS_INF  ,   SET_CUR, 16'h????, 16'h????}: begin
            is_uvc_set_cur = 1;
            setup_req_active = 1;
            raw_req_len    = wLength;
        end
        default: ;
    endcase
end

assign transfer_in_data_len = (raw_req_len < wLength) ? raw_req_len : wLength;

// ----------------------------------------------------------------
// 2. OUT 指令
// ----------------------------------------------------------------
logic   [15:0]  bmHint ;
logic   [7:0]   bFormatIndex ;
logic   [7:0]   bFrameIndex ;
logic   [31:0]  dwFrameInterval ;
logic   [15:0]  wKeyFrameRate ;
logic   [15:0]  wPFrameRate ;
logic   [15:0]  wCompQuality ;
logic   [15:0]  wCompWindowSize ;
logic   [15:0]  wDelay ;
logic   [31:0]  dwMaxVideoFrameSize ;
logic   [31:0]  dwMaxPayloadTransferSize ;
logic   [31:0]  dwClockFrequency ;
logic   [7:0]   bmFramingInfo ;
logic   [7:0]   bPreferedVersion ;
logic   [7:0]   bMinVersion ;
logic   [7:0]   bMaxVersion ;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		bmHint <= 0 ;
		bFormatIndex <= 1 ;	// format 1 
		bFrameIndex <= 1 ;	// frame  1 
		dwFrameInterval <= FRAME_INTERVAL ; //
		wKeyFrameRate <= 0 ; // None 
		wPFrameRate <= 0 ; // None 
		wCompQuality <= 0 ; // None 
		wCompWindowSize <= 0 ; // None 
		wDelay <= 0 ; // no latency 
		dwMaxVideoFrameSize <= MAX_VIDEO_FRAME_SIZE ; //  ( bytes per vedio frame  )
		dwMaxPayloadTransferSize <= MAX_PAYLOAD_TRANSFER_SIZE ; // ( bytes per usb uframe  )
		dwClockFrequency <= 32'd156_250_000 ; // 156.25Mhz
		bmFramingInfo <= 0 ; // None
		bPreferedVersion <= 0 ; // None
		bMinVersion <= 0 ; // None
		bMaxVersion <= 0 ; // None  
    end 
    else begin
        if ( is_uvc_set_cur && transfer_out_data_val ) begin
            case(transfer_out_data_idx)
                0:begin
                   {dwFrameInterval,bFrameIndex,bFormatIndex,bmHint} <= transfer_out_data ;           
                end
                1:begin
                   {wCompWindowSize,wCompQuality,wPFrameRate,wKeyFrameRate} <= transfer_out_data ;
                end
                2:begin
                   //{dwMaxPayloadTransferSize[15:0],dwMaxVideoFrameSize,wDelay} <= transfer_out_data ;
                   {dwMaxVideoFrameSize,wDelay} <= transfer_out_data[(6*8-1)-:(6*8)] ;
                end
                3:begin
                   //{bPreferedVersion,bmFramingInfo,dwClockFrequency,dwMaxPayloadTransferSize[31:16]} <= transfer_out_data ;    
                   {bPreferedVersion,bmFramingInfo,dwClockFrequency} <= transfer_out_data [(8*8-1)-:(6*8)] ;    
                end
                4:begin
                   {bMaxVersion,bMinVersion} <= transfer_out_data[((2)*8-1)-:(2)*8] ;            
                end
                default:;
            endcase
        end
    end
end


// ----------------------------------------------------------------
// 3. IN 指令
// ----------------------------------------------------------------
always_ff @(posedge clk) begin
    if (is_uvc_get_cur) begin
        case (transfer_in_data_idx)
            14'd0: transfer_in_data <= {dwFrameInterval,bFrameIndex,bFormatIndex,bmHint} ;        
            14'd1: transfer_in_data <= {wCompWindowSize,wCompQuality,wPFrameRate,wKeyFrameRate} ;
            14'd2: transfer_in_data <= {dwMaxPayloadTransferSize[15:0],dwMaxVideoFrameSize,wDelay} ;
            14'd3: transfer_in_data <= {bPreferedVersion,bmFramingInfo,dwClockFrequency,dwMaxPayloadTransferSize[31:16]} ;
            14'd4: transfer_in_data <= {bMaxVersion,bMinVersion} ;
            default: transfer_in_data <= 64'd0;
        endcase
    end else begin
        transfer_in_data <= '0;
    end
end

// ----------------------------------------------------------------
// 4. 外部 IO 
// ----------------------------------------------------------------


endmodule
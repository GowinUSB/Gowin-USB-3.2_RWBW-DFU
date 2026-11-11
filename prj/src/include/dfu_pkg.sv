package dfu_pkg;

localparam DFU_DETACH            = 8'h00;
localparam DFU_DNLOAD            = 8'h01;
localparam DFU_GETSTATUS         = 8'h03;
localparam DFU_CLRSTATUS         = 8'h04;

// DFU States (bState)
localparam APP_STATE_IDLE          = 8'd1; // appIDLE               APP状态 空闲
localparam DFU_STATE_IDLE          = 8'd2; // dfuIDLE               DFU状态 空闲
localparam DFU_STATE_DNLOAD_SYNC   = 8'd3; // dfuDNLOAD-SYNC        接收到数据包，等待主机GETSTATUS命令
localparam DFU_STATE_DNBUSY        = 8'd4; // dfuDNBUSY             接收到数据包，正在下载到flash中 
localparam DFU_STATE_DNLOAD_IDLE   = 8'd5; // dfuDNLOAD-IDLE        flash等待新的数据包
localparam DFU_STATE_MANIFEST_SYNC = 8'd6; // dfuMANIFEST-SYNC      文件完全传输，等待主机GETSTATUS命令
localparam DFU_STATE_MANIFEST      = 8'd7; // dfuMANIFEST           收尾工作，CDC/解密等操作

endpackage



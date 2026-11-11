`timescale 1ns/1ps

module iic_controller (
    input             I_CLK,
    input             I_RESETN,
    input             start,          // 启动初始化的信号
    input             i_fusb_int_n,   // 新增: FUSB302的中断引脚(低电平有效)，如无连接请拉高
    
    // I2C Master IP Interface (保持原接口不变)
    output reg        I_TX_EN,
    output reg [2:0]  I_WADDR,
    output reg [7:0]  I_WDATA,
    output reg        I_RX_EN,
    output reg [2:0]  I_RADDR,
    input      [7:0]  O_RDATA,
    
    // Status Outputs
    output reg        cstate_flag,    // 初始化完成标志
    output reg        error_flag,
    output reg        vbus_ok,        // VBUS 电压正常
    output reg [1:0]  cc_orient       // 0:None, 1:CC1, 2:CC2 (正反插状态)
);

    //==========================================================================
    // Parameters & Registers
    //==========================================================================
    
    // --- I2C IP Register Addresses ---
    localparam REG_PRERLO = 3'b000;
    localparam REG_PRERHI = 3'b001;
    localparam REG_CTR    = 3'b010;
    localparam REG_TXR    = 3'b011; // Write Data
    localparam REG_RXR    = 3'b011; // Read Data
    localparam REG_CR     = 3'b100; // Command
    localparam REG_SR     = 3'b100; // Status

    // --- I2C IP Commands ---
    localparam CMD_START  = 8'h80;
    localparam CMD_STOP   = 8'h40;
    localparam CMD_RD     = 8'h20;
    localparam CMD_WR     = 8'h10;
    localparam CMD_ACK    = 8'h08; // Not used in CR directly usually, depends on core
    localparam CMD_IACK   = 8'h01; // Interrupt Ack

    // --- FUSB302 Registers ---
    localparam FUSB_ADDR     = 7'b0100_010; // 0x22
    localparam FUSB_ID       = 8'h01;
    localparam FUSB_SWITCHES0= 8'h02;
    localparam FUSB_MEASURE  = 8'h04;
    localparam FUSB_CONTROL0 = 8'h06;
    localparam FUSB_POWER    = 8'h0B;
    localparam FUSB_RESET    = 8'h0C;
    localparam FUSB_MASK     = 8'h0A;
    localparam FUSB_STATUS0  = 8'h40;
    localparam FUSB_INT      = 8'h42;
    
    // --- Timing Parameters ---
    // 126MHz clk / (5 * 100kHz) - 1 ~= 0xF9 (249)
    localparam PRESCALE_L = 8'h2F;
    localparam PRESCALE_H = 8'h00;

    //==========================================================================
    // Internal Signals
    //==========================================================================
    
    // Main FSM States
    localparam S_IDLE         = 0;
    localparam S_RESET_FUSB   = 1;
    localparam S_POWER_UP     = 2;
    localparam S_CONFIG_SINK  = 3;
    localparam S_CONFIG_MASK  = 4;
    localparam S_UNMASK_INT   = 5;
    localparam S_CONFIG_CTRL0   = 6;
    localparam S_CONFIG_MEASURE_VBUS = 7;
    localparam S_WAIT_EVENT   = 8; // 等待中断或轮询
    localparam S_READ_INT   = 9; 
    localparam S_READ_STATUS_VBUS = 10;
    localparam S_CONFIG_MEASURE_CC = 11;
    localparam S_CONFIG_MEASURE_CC1 = 12;
    localparam S_READ_STATUS_CC1 = 13;
    localparam S_CONFIG_MEASURE_CC2 = 14;
    localparam S_READ_STATUS_CC2 = 15;
    
    reg [3:0] state, next_state;
    reg [31:0] timer; // 用于轮询
    reg [1:0] cnt; // 通用计数器

    reg i_fusb_int_n_dly1, i_fusb_int_n_dly2;

    reg vbus_ok_latch;
    reg [1:0] cc_orient_latch;
    reg addr_done_flag; // 标志：寄存器地址写入完成

    // 初始化I2C Core的单独逻辑（只需要执行一次）
    reg ip_init_done;
    
    // I2C Driver Signals
    reg        i2c_req;         // 请求开始一次I2C事务
    reg        i2c_done;        // 事务完成
    reg        i2c_is_read;     // 0: Write, 1: Read
    reg [7:0]  i2c_reg_addr;    // 目标寄存器地址
    reg [7:0]  i2c_wr_data;     // 要写入的数据
    reg [7:0]  i2c_rd_data;     // 读回的数据
    reg [2:0]  drv_state;       // 底层驱动状态机
    
    // Driver FSM States
    localparam D_IDLE         = 0;
    localparam D_INIT_IP      = 1;
    localparam D_START_DEV    = 2; // Send Start + DevAddr
    localparam D_WR_REG_ADDR  = 3; // Write Register Address
    localparam D_WR_DATA      = 4; // Write Data (if write mode)
    localparam D_RESTART      = 5; // Repeated Start (if read mode)
    localparam D_RD_DATA      = 6; // Read Data
    localparam D_STOP         = 7; // Stop Condition

    //==========================================================================
    // Code
    //==========================================================================

    always @(posedge I_CLK) begin
        // 延迟两个周期以检测中断引脚变化
        i_fusb_int_n_dly1 <= i_fusb_int_n;
        i_fusb_int_n_dly2 <= i_fusb_int_n_dly1;
    end

    //--------------------------------------------------------------------------
    // 1. I2C Low-Level Driver Task FSM
    //    负责处理与 OpenCores I2C IP 的繁琐交互
    //--------------------------------------------------------------------------
    
    reg [7:0] ip_cmd; // 暂存写入CR的命令
    reg       tip_wait; // 标志：正在等待传输完成

    always @(posedge I_CLK or negedge I_RESETN) begin
        if (!I_RESETN) begin
            drv_state   <= D_IDLE;
            i2c_done    <= 0;
            I_TX_EN     <= 0; 
            I_WADDR     <= 0; 
            I_WDATA     <= 0;
            I_RX_EN     <= 0; 
            I_RADDR     <= 0;
            tip_wait    <= 0;
            error_flag  <= 0;
            cnt         <= 0;
            ip_init_done <= 0;
            addr_done_flag <= 0;
            i2c_rd_data <= 'd0;
        end else begin
            // 默认信号复位
            I_TX_EN <= 0;
            I_RX_EN <= 0;
            i2c_done <= 0;

            // TIP Check Logic: 如果正在等待传输，读取SR检查TIP位(bit 1)
            if (tip_wait) begin
                cnt <= cnt + 1;
                case(cnt)
                    0: begin
                        I_RX_EN <= 1; 
                        I_RADDR <= REG_SR; // 读状态寄存器
                    end
                    1: begin
                        I_RX_EN <= 0; 
                        // TIP位检查在下一拍进行
                    end
                    2: begin
                        
                    end
                    3: begin
                        // TIP位检查
                        if (O_RDATA[1] == 0) begin // TIP=0, 传输完成
                            tip_wait <= 0;
                            // 检查 RxACK (bit 7) - 如果是写操作且收到NACK，置错误
                            if (O_RDATA[7] && !i2c_is_read && drv_state != D_IDLE) 
                                error_flag <= 1;
                        end
                    end
                endcase
            end
            else begin
                case (drv_state)
                    D_IDLE: begin
                        if(!i2c_is_read) begin
                            addr_done_flag <= 0;
                        end
                        if(!ip_init_done) begin
                            drv_state <= D_INIT_IP;
                        end 
                        else if (i2c_req) begin
                            drv_state <= D_START_DEV;
                            error_flag <= 0;
                        end
                    end

                    // --- 初始化 OpenCores I2C IP ---
                    D_INIT_IP: begin
                        // 这里为了简单，手动写IP配置，不走通用FSM，因为是直接写IP寄存器
                        // 1. Write Prescale Low
                        I_TX_EN <= 1; 
                        I_WADDR <= REG_PRERLO; 
                        I_WDATA <= PRESCALE_L;
                        // 2. Write Prescale High (next cycle logic omitted for brevity, assumes slow state change)
                        // 3. Enable Core (CTR = 0x80)
                        // 实际应用建议增加几拍延时或分步状态
                        if (cnt == 0) begin 
                            I_TX_EN <= 1; 
                            I_WADDR <= REG_PRERLO; 
                            I_WDATA <= PRESCALE_L; 
                            cnt <= 1; 
                        end
                        else if (cnt == 1) begin 
                            I_TX_EN <= 1; 
                            I_WADDR <= REG_PRERHI; 
                            I_WDATA <= PRESCALE_H; 
                            cnt <= 2; 
                        end
                        else if (cnt == 2) begin 
                            I_TX_EN <= 1; 
                            I_WADDR <= REG_CTR;    
                            I_WDATA <= 8'h80;      
                            cnt <= 3; 
                        end
                        else begin 
                            cnt <= 0; 
                            ip_init_done <= 1; 
                            drv_state <= D_IDLE; 
                        end
                    end

                    // Step 1: Send Start + Device Address (Write)
                    D_START_DEV: begin
                        case(cnt)
                            0: begin
                                // Write TXR = {Addr, 0}
                                I_TX_EN <= 1; 
                                I_WADDR <= REG_TXR; 
                                I_WDATA <= {FUSB_ADDR, 1'b0};
                                cnt <= 1;
                            end
                            1: begin
                                I_TX_EN <= 0; 
                                cnt <= 2;
                            end
                            2: begin
                                // Write CR = START | WRITE
                                I_TX_EN <= 1; 
                                I_WADDR <= REG_CR; 
                                I_WDATA <= CMD_START | CMD_WR;
                                cnt <= 3;
                            end
                            3: begin
                                // 这里可以增加一个状态来等待传输完成，或者直接在下一状态检查TIP位
                                I_TX_EN <= 0; 
                                cnt <= 0;
                                drv_state <= D_WR_REG_ADDR;
                                tip_wait <= 1; // 等待传输完成
                            end
                            default: begin
                                I_TX_EN <= 1'b0;
                                I_WADDR <= 1'b0;
                                I_WDATA <= 0;
                                cnt <= 0;
                            end
                        endcase
                    end

                    // Step 2: Write Register Address
                    D_WR_REG_ADDR: begin
                        case(cnt)
                            0: begin
                                // Write TXR = Reg Addr
                                I_TX_EN <= 1; 
                                I_WADDR <= REG_TXR; 
                                I_WDATA <= i2c_reg_addr;
                                cnt <= 1;
                            end
                            1: begin
                                I_TX_EN <= 0; 
                                cnt <= 2;
                            end
                            2: begin
                                // Write CR = WRITE
                                I_TX_EN <= 1; 
                                I_WADDR <= REG_CR; 
                                I_WDATA <= CMD_WR;
                                cnt <= 3;
                            end
                            3: begin
                                // 这里可以增加一个状态来等待传输完成，或者直接在下一状态检查TIP位
                                I_TX_EN <= 0; 
                                cnt <= 0;
                                if(i2c_is_read) begin
                                    drv_state <= D_RESTART;
                                end
                                else begin
                                    addr_done_flag <= 1; // 标记地址写入完成
                                    drv_state <= D_WR_DATA;
                                end
                                tip_wait <= 1; // 等待传输完成
                            end
                            default: begin
                                I_TX_EN <= 1'b0;
                                I_WADDR <= 1'b0;
                                I_WDATA <= 0;
                                cnt <= 0;
                            end
                        endcase
                    end

                    // Step 3A: Write Data Value (Write Mode)
                    D_WR_DATA: begin
                        case(cnt)
                            0: begin
                                // Write TXR = Data Value
                                I_TX_EN <= 1; 
                                I_WADDR <= REG_TXR; 
                                I_WDATA <= i2c_wr_data;
                                cnt <= 1;
                            end
                            1: begin
                                I_TX_EN <= 0; 
                                cnt <= 2;
                            end
                            2: begin
                                // Write CR = WRITE
                                I_TX_EN <= 1; 
                                I_WADDR <= REG_CR; 
                                I_WDATA <= CMD_WR | CMD_STOP;
                                cnt <= 3;
                            end
                            3: begin
                                // 这里可以增加一个状态来等待传输完成，或者直接在下一状态检查TIP位
                                I_TX_EN <= 0; 
                                cnt <= 0;
                                drv_state <= D_STOP;
                                tip_wait <= 1; // 等待传输完成
                            end
                            default: begin
                                I_TX_EN <= 1'b0;
                                I_WADDR <= 1'b0;
                                I_WDATA <= 0;
                                cnt <= 0;
                            end
                        endcase
                    end

                    // Step 3B: Repeated Start (Read Mode)
                    D_RESTART: begin
                        // Write TXR = {Addr, 1 (Read)}
                        // I_TX_EN <= 1; 
                        // I_WADDR <= REG_TXR; 
                        // I_WDATA <= {FUSB_ADDR, 1'b1};
                        // if (I_TX_EN) begin
                        //     I_TX_EN <= 1; 
                        //     I_WADDR <= REG_CR; 
                        //     I_WDATA <= CMD_START | CMD_WR;
                        //     drv_state <= D_RD_DATA;
                        //     tip_wait <= 1;
                        // end
                        case(cnt)
                            0: begin
                                // Write TXR = Reg Addr
                                I_TX_EN <= 1; 
                                I_WADDR <= REG_TXR; 
                                I_WDATA <= {FUSB_ADDR, 1'b1};
                                cnt <= 1;
                            end
                            1: begin
                                I_TX_EN <= 0; 
                                cnt <= 2;
                            end
                            2: begin
                                // Write CR = WRITE
                                I_TX_EN <= 1; 
                                I_WADDR <= REG_CR; 
                                I_WDATA <= CMD_START | CMD_WR;
                                cnt <= 3;
                            end
                            3: begin
                                // 这里可以增加一个状态来等待传输完成，或者直接在下一状态检查TIP位
                                I_TX_EN <= 0; 
                                cnt <= 0;
                                drv_state <= D_RD_DATA;
                                tip_wait <= 1; // 等待传输完成
                            end
                            default: begin
                                I_TX_EN <= 1'b0;
                                I_WADDR <= 1'b0;
                                I_WDATA <= 0;
                                cnt <= 0;
                            end
                        endcase
                    end

                    // Step 4: Read Data Byte
                    D_RD_DATA: begin
                        // Write CR = READ | NACK | STOP (读一个字节就停止)
                        // I_TX_EN <= 1; 
                        // I_WADDR <= REG_CR; 
                        // I_WDATA <= CMD_RD | 8'h08 | CMD_STOP; 
                        // if (I_TX_EN) begin
                        //     drv_state <= D_STOP;
                        //     tip_wait <= 1;
                        // end
                        case(cnt)
                            0: begin
                                // Write TXR = Reg Addr
                                I_TX_EN <= 1; 
                                I_WADDR <= REG_CR; 
                                I_WDATA <= CMD_RD | 8'h08 | CMD_STOP;
                                cnt <= 1;
                            end
                            1: begin
                                // 这里可以增加一个状态来等待传输完成，或者直接在下一状态检查TIP位
                                I_TX_EN <= 0; 
                                cnt <= 0;
                                drv_state <= D_STOP;
                                tip_wait <= 1; // 等待传输完成
                            end
                            default: begin
                                I_TX_EN <= 1'b0;
                                I_WADDR <= 1'b0;
                                I_WDATA <= 0;
                                cnt <= 0;
                            end
                        endcase
                    end

                    // Step 5: Cleanup & Fetch Read Data
                    D_STOP: begin
                        if (i2c_is_read) begin
                            // I_RX_EN <= 1; 
                            // I_RADDR <= REG_RXR; // 读接收寄存器
                            // if (I_RX_EN) begin
                            //     i2c_done <= 1;
                            //     drv_state <= D_IDLE;
                            // end
                            case(cnt)
                                0: begin
                                    I_RX_EN <= 1; 
                                    I_RADDR <= REG_RXR; 
                                    cnt <= 1;
                                end
                                1: begin
                                    I_RX_EN <= 0; 
                                    cnt <= 2;
                                end
                                2: begin
                                    i2c_done <= 1;
                                    i2c_rd_data <= O_RDATA; // 捕获读回的数据
                                    cnt <= 3;
                                end
                                3: begin
                                    i2c_done <= 0;
                                    drv_state <= D_IDLE;
                                    cnt <= 0;
                                end
                                default: begin
                                    I_RX_EN <= 1'b0;
                                    I_RADDR <= REG_RXR;
                                    cnt <= 0;
                                end
                            endcase
                        end else begin
                            case(cnt)
                                0: begin
                                    i2c_done <= 1;
                                    cnt <= 1;
                                end
                                1: begin
                                    i2c_done <= 0;
                                    cnt <= 2;
                                end
                                2: begin
                                    cnt <= 3;
                                end
                                3: begin
                                    drv_state <= D_IDLE;
                                    cnt <= 0;
                                end
                            endcase
                        end
                    end
                endcase
            end
        end
    end

    //--------------------------------------------------------------------------
    // 2. Main Protocol FSM
    //    负责 FUSB302 的逻辑流程
    //--------------------------------------------------------------------------
    
    always @(posedge I_CLK or negedge I_RESETN) begin
        if(!I_RESETN) begin
            vbus_ok <= 0;
            cc_orient <= 0;
        end else begin
            if(state == S_WAIT_EVENT) begin
                if(cc_orient_latch == 2'b01 || cc_orient_latch == 2'b10) begin
                    vbus_ok <= vbus_ok_latch;
                    cc_orient <= cc_orient_latch;
                end
                else begin
                    vbus_ok <= 0;
                    cc_orient <= 0;
                end
            end
        end
    end
    
    always @(posedge I_CLK or negedge I_RESETN) begin
        if (!I_RESETN) begin
            state <= S_IDLE;
            i2c_req <= 0;
            cstate_flag <= 0;
            vbus_ok_latch <= 0;
            timer <= 0;
            cc_orient_latch <= 0;
        end else begin
            // 自动重置请求信号
            if (i2c_done) i2c_req <= 0;

            case (state)
                S_IDLE: begin
                    if (start) begin
                        if (!ip_init_done) state <= S_IDLE;
                        else state <= S_RESET_FUSB;
                    end
                end

                // --- 1. Reset FUSB302 ---
                S_RESET_FUSB: begin
                    if (!i2c_req && !i2c_done) begin
                        i2c_reg_addr <= FUSB_RESET;
                        i2c_wr_data  <= 8'h01; // SW Reset
                        i2c_is_read  <= 0;
                        i2c_req      <= 1;
                    end else if (i2c_done) begin
                        state <= S_POWER_UP;
                    end
                end

                // --- 2. Power Up (All) ---
                S_POWER_UP: begin
                    if (!i2c_req && !i2c_done) begin
                        i2c_reg_addr <= FUSB_POWER;
                        i2c_wr_data  <= 8'h0F; // PWR[0]:Bandgap and wake circuit and PWR[2]: Measure block powered
                        i2c_is_read  <= 0;
                        i2c_req      <= 1;
                    end else if (i2c_done) begin
                        state <= S_CONFIG_SINK;
                    end
                end

                // --- 3. Config as Sink (Rd/Rd) ---
                S_CONFIG_SINK: begin
                    if (!i2c_req && !i2c_done) begin
                        i2c_reg_addr <= FUSB_SWITCHES0;
                        i2c_wr_data  <= 8'h03; // PDWN1 | PDWN2 (Enable Rd)
                        i2c_is_read  <= 0;
                        i2c_req      <= 1;
                    end else if (i2c_done) begin
                        state <= S_CONFIG_MASK;
                    end
                end
                
                // --- 4. Unmask Interrupts (Enable INT pin) ---
                //S_UNMASK_INT: begin
                //     if (!i2c_req && !i2c_done) begin
                //        i2c_reg_addr <= FUSB_CONTROL0;
                //        i2c_wr_data  <= 8'h00; // Clear INT_MASK (Enable Pin)
                //        i2c_is_read  <= 0;
                //        i2c_req      <= 1;
                //    end else if (i2c_done) begin
                //        state <= S_WAIT_EVENT;
                //        cstate_flag <= 1; // 初始化完成
                //    end
                //end
                
                // --- 6. Config MASK ---
                S_CONFIG_MASK: begin
                    if (!i2c_req && !i2c_done) begin
                        i2c_reg_addr <= FUSB_MASK;
                        i2c_wr_data  <= 8'b01111111; // Enable VBUSOK interrupt
                        i2c_is_read  <= 0;
                        i2c_req      <= 1;
                    end else if (i2c_done) begin
                        // state <= S_UNMASK_INT;
                        state <= S_CONFIG_CTRL0;
                    end
                end
                
                // --- 6. Config MASK ---
                S_CONFIG_CTRL0: begin
                    if (!i2c_req && !i2c_done) begin
                        i2c_reg_addr <= FUSB_CONTROL0;
                        i2c_wr_data  <= 8'b00000100;
                        i2c_is_read  <= 0;
                        i2c_req      <= 1;
                    end else if (i2c_done) begin
                        state <= S_CONFIG_MEASURE_VBUS;
                    end
                end
                
                // --- 5. Config measure ---
                S_CONFIG_MEASURE_VBUS: begin
                    if (!i2c_req && !i2c_done) begin
                        i2c_reg_addr <= FUSB_MEASURE;
                        i2c_wr_data  <= 8'b01_001010; 
                        i2c_is_read  <= 0;
                        i2c_req      <= 1;
                    end else if (i2c_done) begin
                        state <= S_WAIT_EVENT;
                    end
                end

                // --- 7. Main Loop: Wait for Interrupt or Timeout ---
                S_WAIT_EVENT: begin
                    timer <= timer + 1;
                    // 如果中断引脚拉低(有效)，或者定时器溢出(例如每10ms轮询一次)
                    // 126MHz * 0.01s = 1.26M cycles
                    if (!i_fusb_int_n_dly2 || timer > 1250000) begin//
                        timer <= 0;
                        state <= S_READ_INT;
                    end
                end

                // --- 8. Read INT Register ---
                S_READ_INT: begin
                    if (!i2c_req && !i2c_done) begin
                        i2c_reg_addr <= FUSB_INT;
                        i2c_is_read  <= 1;
                        i2c_req      <= 1;
                    end else if (i2c_done) begin
                        state <= S_READ_STATUS_VBUS;
                    end
                end

                // --- 8. Read Status Register ---
                S_READ_STATUS_VBUS: begin
                    if (!i2c_req && !i2c_done) begin
                        i2c_reg_addr <= FUSB_STATUS0;
                        i2c_is_read  <= 1;
                        i2c_req      <= 1;
                    end else if (i2c_done) begin
                        // STATUS0 Bit 7 = VBUSOK
                        vbus_ok_latch <= i2c_rd_data[7];
                        
                        if (i2c_rd_data[7]) begin
                            state <= S_CONFIG_MEASURE_CC;
                        end
                        else begin
                            state <= S_WAIT_EVENT;
                        end
                    end
                end
                
                // --- 9. Config measure CC---
                S_CONFIG_MEASURE_CC: begin
                    if (!i2c_req && !i2c_done) begin
                        i2c_reg_addr <= FUSB_MEASURE;
                        i2c_wr_data  <= 8'b00_001010; 
                        i2c_is_read  <= 0;
                        i2c_req      <= 1;
                    end else if (i2c_done) begin
                        state <= S_CONFIG_MEASURE_CC1;
                    end
                end
                
                // --- 10. Config measure CC1---
                S_CONFIG_MEASURE_CC1: begin
                    if (!i2c_req && !i2c_done) begin
                        i2c_reg_addr <= FUSB_SWITCHES0;
                        i2c_wr_data  <= 8'b00_000111; 
                        i2c_is_read  <= 0;
                        i2c_req      <= 1;
                    end else if (i2c_done) begin
                        state <= S_READ_STATUS_CC1;
                    end
                end

                // --- 11. Read Status Register CC1---
                S_READ_STATUS_CC1: begin
                    if(timer <= 1260000) timer <= timer + 1;
                    // 126MHz * 0.01s = 1.26M cycles
                    if (timer > 1260000) begin
                        if (!i2c_req && !i2c_done) begin
                            i2c_reg_addr <= FUSB_STATUS0;
                            i2c_is_read  <= 1;
                            i2c_req      <= 1;
                        end else if (i2c_done) begin
                            timer <= 0;
                            state <= S_CONFIG_MEASURE_CC2;
                            // Check BC_LVL (Bit 1:0) for Orientation/Connection
                            if (i2c_rd_data[1:0] != 2'b00) begin
                                cc_orient_latch <= 2'b01; // CC1
                            end
                            else begin
                                cc_orient_latch <= 2'b00; // CC1
                            end
                        end
                    end
                end
                
                // --- 12. Config measure CC2---
                S_CONFIG_MEASURE_CC2: begin
                    if (!i2c_req && !i2c_done) begin
                        i2c_reg_addr <= FUSB_SWITCHES0;
                        i2c_wr_data  <= 8'b00_001011; 
                        i2c_is_read  <= 0;
                        i2c_req      <= 1;
                    end else if (i2c_done) begin
                        state <= S_READ_STATUS_CC2;
                    end
                end

                // --- 13. Read Status Register CC2---
                S_READ_STATUS_CC2: begin
                    if(timer <= 1260000) timer <= timer + 1;
                    // 126MHz * 0.01s = 1.26M cycles
                    if (timer > 1260000) begin
                        if (!i2c_req && !i2c_done) begin
                            i2c_reg_addr <= FUSB_STATUS0;
                            i2c_is_read  <= 1;
                            i2c_req      <= 1;
                        end else if (i2c_done) begin
                            timer <= 0;
                            state <= S_CONFIG_MEASURE_VBUS;
                            // Check BC_LVL (Bit 1:0) for Orientation/Connection
                            if (i2c_rd_data[1:0] != 2'b00) begin
                                cc_orient_latch[1] <= 1'b1; // CC2
                            end
                        end
                    end
                end
                
                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
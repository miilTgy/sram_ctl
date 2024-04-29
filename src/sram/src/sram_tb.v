`timescale 1ns/100ps
`include "sram.v"

module sram_tb();
// 时钟信号
reg clk;
// 复位信号
reg rst;
// 写入数据信号
reg [63:0] data_in;
// 地址信号
reg [24:0] address;
// 写使能信号
reg write_en;
// 读出数据信号
wire [63:0] data_out;


    // 时钟生成
    always #5 clk = ~clk;

    integer i;
    // 初始化测试数据
    initial begin
        clk = 0;
        rst = 1;
        address = 0;
        data_in = 64'h0123456789ABCDEF;
        write_en = 0;

        // 等待一段时间后取消复位
        #10 rst = 0;

            // 写入数据到各个单元
        for (i = 0; i < 32; i = i + 1) begin : write_data
            #10 write_en = 1;
            #10 address = {20'b0,i};
            #10 data_in = 64'h1122334455667788; // 假设每个单元写入的数据不同
            #10 write_en = 0;
        end

        // 读出数据
        for (i = 0; i < 32; i = i + 1) begin : read_data
            #10 address = {20'b0,i};
            #10 write_en = 0;
        end

        #100 $finish;
    end

    // 实例化SRAM模块
sram sram (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .address(address),
    .write_en(write_en),
    .data_out(data_out)
);

    initial begin
        // 生成波形文件
        $dumpfile("wave.vcd");
        $dumpvars(0, sram_tb);
    end
endmodule

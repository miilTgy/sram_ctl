module sram (
    input wire clk,              // 时钟
    input wire rst,              // 复位
    input wire [63:0] data_in,  // 写入数据
    input wire [24:0] address,  // 地址总线，包括片选地址和片内地址
    input wire write_en,         // 写使能
    output reg [63:0] data_out  // 读出数据
);

// 定义SRAM存储器数组，包含32个单元，每个单元有256K bit的容量
reg [63:0] memory [0:31][0:4095];

// 读写操作
always @(posedge clk) begin
    if (rst) begin
        data_out <= 64'h0; // 复位时，输出全零
    end 
    else begin
        if (write_en)memory[address[4:0]][address[24:5]] <= data_in; // 写入数据
        else data_out <= memory[address[4:0]][address[24:5]];        // 读出数据
    end
end

endmodule

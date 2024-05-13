`timescale 100ps/10ps

module chain_manager_tb();

  reg rst;
  reg clk = 1;
  reg request;
  reg [7:0] size;
  wire [48:0] test;

chain_manager ch(
  .rst(rst),
  .clk(clk),
  .request(request),
  .size(size)
);
  integer i = 0;

  always #4 clk = ~clk;

  initial begin
    $dumpfile("wave_chain.vcd");        //生成的vcd文件名称
    $dumpvars(0, chain_manager_tb);    //tb模块名称
    for(i = 0; i<=5; i=i+1) begin
        $dumpvars(0,ch.chain[i]);
    end
  end

  initial begin
    rst <= 1;
    #8;
    rst <= 0;
    #8;
    request <= 1;
    size <= 8'd16;
    #8;
    request <= 0;
    #8;
    request <= 1;
    size <= 8'd32;
    #8;
    request <= 0;
    #8;
    request <=1 ;
    size <= 8'd64;
    #8;
    request <= 0;

    #200;
    $finish;

  end


endmodule
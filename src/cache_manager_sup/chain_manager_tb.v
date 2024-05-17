`timescale 100ps/10ps

module chain_manager_tb();

  reg rst;
  reg clk = 1;

  reg wea;
  reg [7:0] size;
  reg rea;
  reg [3:0] out_port;
  reg [2:0] priority;
  reg [3:0] dest_port;

  wire [48:0] test;

chain_manager ch(
  .rst(rst),
  .clk(clk),
  .wea(wea),
  .w_size(size),
  .priority(priority),
  .dest_port(dest_port),
  .rea(rea),
  .out_port(out_port)
);

  integer i = 0;
  integer j = 0;

  always #4 clk = ~clk;

  initial begin
    $dumpfile("wave_chain.vcd");        //生成的vcd文件名称
    $dumpvars(0, chain_manager_tb);    //tb模块名称

    for(i = 0; i<=50; i=i+1) begin
        $dumpvars(0,ch.chain[i]);
    end

    for(i = 0; i<=127; i=i+1) begin
        $dumpvars(0,ch.queue_num[i]);
    end

  end

  reg [99:0] wea_in = 100'b0;
  reg [99:0] rea_in = 100'b0;
  reg [7:0] size_in [99:0];
  reg [3:0] out_port_in [99:0];
  reg [2:0] priority_in[99:0];
  reg [3:0] dest_port_in[99:0];

  initial begin 

    //initialize
    for(j=0;j<=20;j=j+2) begin
      wea_in[j] <= 1;  
      size_in[j] <= 60+j;
      size_in[j+1] <= 60+j;      
    end

    i = 0;
    for(j=0;j<=15;j=j+1) begin
      dest_port_in[i] = j;
      dest_port_in[i+1] = j;
      i = i + 2;
    end

    for(j=0;j<=99;j=j+1) priority_in[j] = 0;

    //test
    rst <= 1;
    #8;
    rst <= 0;
    #8;

    for(i=0;i<=30;i=i+1) begin
        wea <= wea_in[i];
        rea <= rea_in[i];
        size <= size_in[i];
        out_port <= out_port_in[i];
        dest_port <= dest_port_in[i];
        priority <= priority_in[i];
        #8;
    end
    #50;
    $finish;

  end


endmodule
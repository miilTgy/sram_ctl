`timescale 100ps/10ps

module chain_manager_tb();

  reg rst;
  reg clk = 1;

  reg wea;
  reg [7:0] w_size;
  reg [2:0] priority;
  reg [3:0] dest_port;

  reg [3:0] port_0_priority;
  reg port_0_rea;

  //tb输入
  reg [99:0] wea_in = 100'b0;
  reg [7:0] w_size_in [99:0];
  reg [2:0] priority_in[99:0];
  reg [3:0] dest_port_in[99:0];

  reg [3:0] port_0_priority_in[99:0];
  reg [99:0] port_0_rea_in;


chain_manager ch(
  .rst(rst),
  .clk(clk),

  .wea(wea),
  .w_size(w_size),
  .priority(priority),
  .dest_port(dest_port),

  .port_0_priority(port_0_priority),
  .port_0_rea(port_0_rea)


);

  integer i = 0;
  integer j = 0;

  always #4 clk = ~clk; //时钟

//GTKwave配置
  initial begin
    $dumpfile("wave_chain.vcd");        //生成的vcd文件名称
    $dumpvars(0, chain_manager_tb);    //tb模块名称

    for(i = 0; i<=50; i=i+1) begin
        $dumpvars(0,ch.chain[i]);
    end

    for(i = 0; i<=127; i=i+1) begin
        $dumpvars(0,ch.queue_num[i]);
    end

        $dumpvars(0,ch.queue[2]);
  end

  initial begin 

    //package_input_initialize
    for(j=0;j<=20;j=j+2) begin //输入11个数据包，长度为60+j,端口0
      wea_in[j] = 1;          

      w_size_in[j] = 60+j;
      w_size_in[j+1] = 60+j;      
    end

    for(j=0;j<=99;j=j+1) dest_port_in[j] = 0;

    //优先级为0,3,2,4,5,6,7,1,2,0,2
    priority_in[0] = 0;
    priority_in[1] = 0;
    priority_in[2] = 3;
    priority_in[3] = 3;
    priority_in[4] = 2;
    priority_in[5] = 2;
    priority_in[6] = 4;
    priority_in[7] = 4;
    priority_in[8] = 5;
    priority_in[9] = 5;
    priority_in[10] = 6;
    priority_in[11] = 6;
    priority_in[12] = 7;
    priority_in[13] = 7;
    priority_in[14] = 1;
    priority_in[15] = 1;
    priority_in[16] = 2;
    priority_in[17] = 2;
    priority_in[18] = 0;
    priority_in[19] = 0;
    priority_in[20] = 2;
    priority_in[21] = 2;


   
    //package_output_initialize
    for(j=0;j<=99;j=j+1) begin
        port_0_rea_in[j] = 0;
        port_0_priority_in[j] = 0;
    end

    for(j=22;j<=38;j=j+2) begin
        port_0_rea_in[j] = 1;
    end

    port_0_priority_in[22] = 0;
    port_0_priority_in[23] = 0;
    port_0_priority_in[24] = 1;
    port_0_priority_in[25] = 1;
    port_0_priority_in[26] = 2;
    port_0_priority_in[27] = 2;
    port_0_priority_in[28] = 3;
    port_0_priority_in[29] = 3;
    port_0_priority_in[30] = 4;
    port_0_priority_in[31] = 4;
    port_0_priority_in[32] = 5;
    port_0_priority_in[33] = 5;
    port_0_priority_in[34] = 2;
    port_0_priority_in[35] = 2;
    port_0_priority_in[36] = 6;
    port_0_priority_in[37] = 6;
    port_0_priority_in[38] = 2;
    port_0_priority_in[39] = 2;


    

    //test
    rst <= 1;
    #8;
    rst <= 0;
    #8;

    for(i=0;i<=40;i=i+1) begin
        wea <= wea_in[i];
        w_size <= w_size_in[i];
        dest_port <= dest_port_in[i];
        priority <= priority_in[i];

        port_0_priority <= port_0_priority_in[i];
        port_0_rea <= port_0_rea_in[i];

        #8;
    end
    #50;
    $finish;

  end


endmodule
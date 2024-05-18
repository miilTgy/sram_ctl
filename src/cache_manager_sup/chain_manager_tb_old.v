`timescale 100ps/10ps

module chain_manager_tb();

  reg rst;
  reg clk = 1;

  reg wea;
  reg [7:0] size;
  reg rea;
  reg [7:0] out_port;
  reg [2:0] priority;
  reg [3:0] dest_port;




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

  end

//tb输入
  reg [99:0] wea_in = 100'b0;
  reg [99:0] rea_in = 100'b0;
  reg [7:0] size_in [99:0];
  reg [7:0] out_port_in [99:0];
  reg [2:0] priority_in[99:0];
  reg [3:0] dest_port_in[99:0];

  initial begin 

    //package_input_initialize
    for(j=0;j<=20;j=j+2) begin //输入11个数据包，长度为60+j
      wea_in[j] = 1;          

      size_in[j] = 60+j;
      size_in[j+1] = 60+j;      
    end

    //端口优先级队列为: 0+0, 0+1, 1+0, 2+0, 0+2, 3+0, 3+1, 4+0, 5+0, 0+0, 0+1
    dest_port_in[0] =0;
    dest_port_in[1] =0;
    dest_port_in[2] =0;
    dest_port_in[3] =0;
    dest_port_in[4] =1;
    dest_port_in[5] =1;
    dest_port_in[6] =2;
    dest_port_in[7] =2;
    dest_port_in[8] =0;
    dest_port_in[9] =0;
    dest_port_in[10] =3; 
    dest_port_in[11] =3;
    dest_port_in[12] =3;
    dest_port_in[13] =3;
    dest_port_in[14] =4;
    dest_port_in[15] =4;
    dest_port_in[16] =5;
    dest_port_in[17] =5;
    dest_port_in[18] =0;
    dest_port_in[19] =0;
    dest_port_in[20] =0;
    dest_port_in[21] =0;

    priority_in[0] = 0;
    priority_in[1] = 0;
    priority_in[2] = 1;
    priority_in[3] = 1;
    priority_in[4] = 0;
    priority_in[5] = 0;
    priority_in[6] = 0;
    priority_in[7] = 0;
    priority_in[8] = 2;
    priority_in[9] = 2;
    priority_in[10] = 0;
    priority_in[11] = 0;
    priority_in[12] = 1;
    priority_in[13] = 1;
    priority_in[14] = 0;
    priority_in[15] = 0;
    priority_in[16] = 0;
    priority_in[17] = 0;
    priority_in[18] = 0;
    priority_in[19] = 0;
    priority_in[20] = 1;
    priority_in[21] = 1;

    //package_output_initialize
    for(j=0;j<=40;j=j+1) begin
        rea_in[j] = 0;
        out_port_in[j] = 0;
    end

    for(j=20;j<=30;j=j+2) rea_in[j] = 1; //读出六个包,分别是0+0, 0+1, 2+0, 3+1, 5+0, 0+0
    out_port_in[20] = 0;
    out_port_in[21] = 0;
    out_port_in[22] = 1;
    out_port_in[23] = 1;
    out_port_in[24] = 16;
    out_port_in[25] = 16;
    out_port_in[26] = 25;
    out_port_in[27] = 25;
    out_port_in[28] = 40;
    out_port_in[29] = 40;
    out_port_in[30] = 0;

    

    //test
    rst <= 1;
    #8;
    rst <= 0;
    #8;

    for(i=0;i<=40;i=i+1) begin
        wea <= wea_in[i];
        rea <= rea_in[i];
        size <= size_in[i];
        dest_port <= dest_port_in[i];
        priority <= priority_in[i];

        out_port <= out_port_in[i];
        #8;
    end
    #50;
    $finish;

  end


endmodule
`timescale 100ps/10ps

module sram_tb();

  reg clka; //输入端口时钟
  reg ena; //输入端口使能
  reg [0 : 0] wea; //输入端口写使能
  reg [11 : 0] addra; //输入端口地址线
  reg [63 : 0] dina; //输入端口数据线
  reg clkb; //输出端口时钟
  reg enb; //输出端口使能
  reg [11 : 0] addrb; //输出端口地址线
  wire [63 : 0] doutb; //输出端口数据线


blk_mem_gen_0 sram (
  .clka(clka),    // input wire clka
  .ena(ena),      // input wire ena
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [11 : 0] addra
  .dina(dina),    // input wire [63 : 0] dina
  .clkb(clkb),    // input wire clkb
  .enb(enb),      // input wire enb
  .addrb(addrb),  // input wire [11 : 0] addrb
  .doutb(doutb)  // output wire [63 : 0] doutb
);
  always #5 clka = ~clka;
  always #5 clkb = ~clkb;

  initial begin
    $dumpfile("wave.vcd");        //生成的vcd文件名称
    $dumpvars(0, sram_tb);    //tb模块名称

    clka <= 1; clkb <= 1; ena<= 1; enb <= 1;

    #40;
    wea <= 1;
    addra <= 0;
    dina <= 64'hABCDABCDABCDABCD;
    #40;
    addra <= 1;
    dina <= 64'hBCDABCDABCDABCDA;
    #40
    wea <= 0;
    enb <= 1;
    addrb <= 0;
    #40;
    addrb <= 1;

    #200
    $stop;
  end


endmodule
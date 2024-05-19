`timescale 1ns / 1ps

module sram
#(
  parameter addr_lines = 11
)
(
    input wire clka,
    input wire ena,
    input wire wea,
    input wire [16 : 0] addra,
    input wire [63 : 0] dina,
    input wire clkb,
    input wire enb,
    input wire [16 : 0] addrb,
    output wire [63 : 0] doutb
);
    //每个sram的写入片选信号
    reg [31:0] ena_in; 

    //输入地址，addra_in[12*n-1 -: 12]
    //reg [383:0] addra_in;
    
    //每个sram的读出片选信号
    reg [31:0] enb_in;
    //reg [383:0] addrb_in;

    integer i = 0;
    integer j = 0;

blk_mem_gen_0 sram_inst[31:0] (
  .clka(clka),    // input wire clka
  .ena(ena_in[31:0]),// input wire ena
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addra[11:0]),  // input wire [11 : 0] addra
  .dina(dina),    // input wire [63 : 0] dina
  .clkb(clkb),    // input wire clkb
  .enb(enb_in[31:0]),      // input wire enb
  .addrb(addrb[11:0]),  // input wire [11 : 0] addrb
  .doutb(doutb)  // output wire [63 : 0] doutb
);

    //管理多个sram的decoder
    always @(*) begin
        if(ena) begin
            for(i=0;i<=31;i=i+1) ena_in[i] = 0;
            ena_in[ addra[16:12] ] = 1;
        end
    end

    always @(*) begin
        if(enb) begin
            for(j=0;j<=31;j=j+1) enb_in[j] = 0;
            enb_in[ addra[16:12] ] = 1;
        end
    end


/*  //testbench

    reg [16:0] addr_test;
    reg ena_test;

    assign addra = addr_test;
    assign ena = ena_test;

    initial begin
      $dumpfile("sram.vcd");        //生成的vcd文件名称
      $dumpvars(0, sram);    //tb模块名称
      ena_test = 0;
      #4;
      addr_test = 17'hFFFFFFF;
      ena_test = 1;
      #4;
      addr_test = 17'b00001100100101011;
      #50;
      $finish;
    end
*/
endmodule

module sram(
    input wire clka
    input wire ena
    input wire [0 : 0] wea
    input wire [11 : 0] addra
    input wire [63 : 0] dina
    input wire clkb
    input wire enb
    input wire [11 : 0] addrb
    output wire [63 : 0] doutb
);

blk_mem_gen_0 sram_inst (
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
    
endmodule

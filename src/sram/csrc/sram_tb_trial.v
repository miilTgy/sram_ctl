`timescale 1ns/1ns

module sram_tb_trial();

reg         hclk;
reg         sram_clk;
reg         hresetn;
reg         hsel;
reg         hwrite;
reg         hready;
reg [2:0]   hsize;
reg [2:0]   hburst;
reg [1:0]   htrans;
reg [31:0]  hwdata;
reg [31:0]  haddr;

//signals for BIST and DFT test mode
//when signal "dft_en" or "bist_en" is high, sram controller enters into
//test mode

reg         dft_en;
reg         bist_en;

//output signals
reg         hread_resp;
reg [1:0]   hresp;
reg [31:0]  hrdata;

//when "bist_done" is high, it shows BIST test is over
reg         bist_done;

//"bist_fail" shows the results of each sram functions. There are 8
//srams in this controller.
reg [7:0]   bist_fail;

reg [31:0]  data_rt;

sramc_top u_sramc_top_tb(
          //input
          .hclk           (hclk          ), 
          .sram_clk       (sram_clk      ),
          .hresetn        (hresetn       ),
          .hsel           (hsel          ),
          .hwrite         (hwrite        ),
          .hready         (hready        ),
          .hsize          (hsize         ),
          .hburst         (hburst        ),
          .htrans         (htrans        ),
          .hwdata         (hwdata        ),
          .haddr          (haddr         ),
          .bist_done      (bist_done     ),
          .bist_fail      (bist_fail     ),
          .dft_en         (dft_en        ),
          .bist_en        (bist_en       ),

          //output
          .hready_resp    (hready_resp           ),
          .hresp          (hresp                ),
          .hrdata         (hrdata)
         );


//parameters
parameter hclk_period=20,
          IDLE=2'b00,
          BUSY=2'b01,
          NONSEQ=2'b10,
          SEQ=2'b11;

//initialization
initial begin
  hclk=0;
  hresetn=0;
  hsel=0;
  hwrite=0;
  hready=0;
  hsize=2'b00;
  htrans=IDLE;
  haddr=32'h00000;
  hwdata=32'h00000;
  #100;
  hresetn=1;
end

//clock generation
initial begin
  hclk=0;
  forever begin
    hclk=#(hclk_period/2) !hclk;
  end
end

//Test scenario
initial begin
  #100;
  write_t(32'h00001, 32'h123af);
  #200;
  read_t(32'h00099,data_rt);
  #100;
  $finish;
end

task write_t(input [31:0] addr_wt, input [31:0] data_wt);
begin
  @(posedge hclk);
  hsize=2'b10;
  htrans=NONSEQ;
  hwrite=1;
  hsel=1;
  hready=1;
  haddr=addr_wt;
  @(posedge hclk)
  hwdata=data_wt;
end
endtask

task read_t(input [31:0] addr_rt, output [31:0] data_rt);
begin
  @(posedge hclk);
  hsize=2'b10;
  htrans=NONSEQ;
  hwrite=0;
  hsel=1;
  haddr=addr_rt;
  @(posedge hclk);
  data_rt=32'h09999;
end
endtask

endmodule













             

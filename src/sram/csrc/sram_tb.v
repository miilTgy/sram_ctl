module sram_tb(); // no port

reg			    hclk;
reg			    sram_clk;
reg    	    	hresetn;
reg    	   		hsel;
reg   	   		hwrite;
reg			    hready;
reg [2:0]  	hsize ;    
reg [2:0]  	hburst;
reg [1:0]  	htrans;
reg [31:0] 	hwdata;
reg [31:0] 	haddr;		
//Signals for BIST and DFT test mode
//When signal"dft_en" or "bist_en" is high, sram controller enters into test mode.		
reg          dft_en;
reg          bist_en;

//output signals
wire         hready_resp;
wire [1:0]   hresp;
wire [31:0]  hrdata;
//When "bist_done" is high, it shows BIST test is over.
wire         bist_done;
//"bist_fail" shows the results of each sram funtions.There are 8 srams in this controller.
wire [7:0]	bist_fail;

reg [31:0] rdata;
sramc_top u_top
(
	.hclk		      (hclk),
	.sram_clk	    (sram_clk),
	.hresetn	    (hresetn),
	.hsel	  	    (hsel),
	.hwrite		    (hwrite),
	.hready		    (hready),
	.hsize		    (hsize),    
	.hburst		    (hburst),
	.htrans		    (htrans),
	.hwdata		    (hwdata),
	.haddr		    (haddr),		
	.dft_en		    (dft_en),
	.bist_en	    (bist_en),
	.hready_resp  (hready_resp),
	.hresp		    (hresp),
	.hrdata	    	(hrdata),
	.bist_done	  (bist_done),
	.bist_fail	  (bist_fail)
);

parameter period=20;
//HCLK 50M
initial begin
	hclk = 0;
	forever
	begin
		// #10 hclk = ~hclk;  // hardcode : x
		#(period/2) hclk = ~hclk;  // hardcode : x
	end
end

// always : x
initial begin
	sram_clk = 0;
	forever
	begin
		#10 sram_clk = ~sram_clk;
	end
end

initial begin
  $vcdpluson();  // vcs dump waveform
end

parameter  IDLE   = 2'b00,
           BUSY   = 2'b01,
		       NONSEQ = 2'b10,
		       SEQ    = 2'b11;
 
// testcase:
initial begin
  //... x-delay
	hresetn = 0;
	dft_en = 0;
	bist_en = 0; //work in normal mode
	htrans = IDLE;
	hsize = 2'b00;
	hwrite = 0;
	hsel = 0;
	hready = 0;
	haddr = 0;
	#200;
	hresetn = 1;
	
	//write_read bank0
	#10;
	sram_write(32'h0000_0050,32'ha0b0c0d0);
	#10;
	sram_read(32'h0000_0050,rdata);
	
	//write_read bank1
	#100;
	sram_write(32'h0000_f010,32'h0a0b0c0d);
	#10;
	sram_read(32'h0000_f010,rdata);
	#1000;
	$finish;
end

// direct test
task sram_write(input [31:0] addr,input [31:0] wdata);
begin
	@(posedge hclk); // wait(level);
	hsize  = 2'b10;
  htrans = NONSEQ;
  hwrite = 1;
	hsel = 1;
	hready = 1;
	haddr = addr;
	@(posedge hclk);
	hwdata = wdata;
end
endtask

task sram_read(input [31:0] addr,output [31:0] rdata);
begin
	@(posedge hclk);
	haddr = addr;
	hsize  = 2'b10;
    htrans = NONSEQ;
    hwrite = 0;
	hsel = 1;
	@(posedge hclk);
	rdata = hrdata;
end
endtask

endmodule


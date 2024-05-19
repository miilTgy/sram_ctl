module top_tb ();
    
    // parameters
    parameter num_of_ports = 16;
    parameter arbiter_data_width = 64;
    parameter priority_width = 3;
    parameter fifo_data_width = 64;
    parameter fifo_num_of_priority = 8;
    parameter fifo_length = 32;
    parameter des_port_width = 7;
    parameter address_width = 12;
    parameter num_of_priority = 8;
    parameter data_width = 64;
    parameter num_of_priorities = 8;

reg clk, in_clk, rst;

// ports
    reg sp0_wrr1;
    reg [num_of_ports-1:0] wr_sop, wr_eop, wr_vld;
    reg [data_width*num_of_ports-1:0] wr_data;
    reg [num_of_ports-1:0] ready;

    wire [num_of_ports-1:0] rd_sop, rd_eop, rd_vld;
    wire [num_of_ports*data_width-1:0] rd_data;
    wire full, almost_full;

// instance
    top top_in (
        .clk        (clk),
        .in_clk     (in_clk),
        .rst        (rst),
        .sp0_wrr1   (sp0_wrr1),
        .wr_sop     (wr_sop),
        .wr_eop     (wr_eop),
        .wr_vld     (wr_vld),
        .wr_data    (wr_data),
        .ready      (ready),
        .rd_sop     (rd_sop),
        .rd_eop     (rd_eop),
        .rd_vld     (rd_vld),
        .rd_data    (rd_data),
        .full       (full),
        .almost_full(almost_full)
    );

    always #1 clk = ~clk;
    always #16 in_clk = ~in_clk;
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    initial begin
        clk <= 1; in_clk <= 1; sp0_wrr1 <= 0;
        rst <= 0; wr_sop <= 0; wr_eop <= 0;
        wr_vld <= 0; wr_data <= 0; 
        #2;
        rst <= 1;
        #2;
        rst <= 0;
        #4;
        wr_sop[0] <= 1;
        #32;
        wr_sop[0] <= 0;
        wr_vld[0] <= 1;
        wr_data[3:0] <= 0;
        wr_data[6:4] <= 0;
        wr_data[14:7] <= 4;
        #32;
        wr_data[63:0] <= {$random, $random};
        #32;
        wr_data[63:0] <= {$random, $random};
        #32;
        wr_data[63:0] <= {$random, $random};
        #32;
        wr_data[63:0] <= {$random, $random};
        #32;
        wr_eop[63:0] <= 1;
        wr_vld[63:0] <= 0;
        #512;
        $finish;
    end

endmodule
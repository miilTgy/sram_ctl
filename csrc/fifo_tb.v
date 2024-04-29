module fifo_tb ();
    parameter fifo_data_width = 16;
    parameter fifo_num_of_priority = 8;
    parameter fifo_length = 32;

    reg                         rst;
    reg                         clk;
    reg                         in_clk;
    reg                         next_data;
    reg                         wr_sop;
    reg                         wr_eop;
    reg                         wr_vld;
    reg [fifo_data_width-1:0]   wr_data;
    wire                        ready;
    wire                        overflow;
    wire                        sop;
    wire                        eop;
    wire                        vld;
    wire[fifo_data_width-1:0]   out_data;

    fifo fifo_tt (
        .rst            (rst        ),
        .in_clk         (in_clk     ),
        .clk            (clk        ),
        .next_data      (next_data  ),
        .wr_sop         (wr_sop     ),
        .wr_eop         (wr_eop     ),
        .wr_vld         (wr_vld     ),
        .wr_data        (wr_data    ),
        .ready          (ready      ),
        .overflow       (overflow   ),
        .sop            (sop        ),
        .eop            (eop        ),
        .vld            (vld        ),
        .out_data       (out_data   )
    );

    always #1 clk = ~clk;
    always #16 in_clk = ~in_clk;
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    integer i;
    initial begin
        clk <=1; rst <= 0; next_data <= 0; in_clk <= 1;
        wr_sop <= 0; wr_eop <= 0; wr_vld <= 0;
        wr_data <= 0;
        #32;
        rst <= 1;
        #32;
        rst <= 0;
        #320;
        wr_sop <=1;
        #32;
        wr_sop <= 0;
        wr_vld <= 1;
        for (i=0; i<fifo_length-1; i=i+1) begin
            wr_data <= $random;
            #2;
            next_data <= 1;
            #2;
            next_data <= 0;
            #28;
        end
        wr_data <= 0;
        wr_eop <= 1;
        #32;
        wr_eop <= 0;
        wr_vld <= 0;
        #320;
        next_data <= 1;
        #640;
        next_data <= 0;
        #160;
        $finish;
    end

endmodule
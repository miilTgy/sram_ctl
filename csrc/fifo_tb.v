module fifo_tb ();
    parameter fifo_data_width = 16;
    parameter fifo_num_of_priority = 8;
    parameter fifo_length = 32;

    reg                         rst;
    reg                         clk;
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
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    integer i;
    initial begin
        clk <=1; rst <= 0; next_data <= 0;
        wr_sop <= 0; wr_eop <= 0; wr_vld <= 0;
        wr_data <= 0;
        #2;
        rst <= 1;
        #2;
        rst <= 0;
        #20;
        wr_sop <=1;
        #2;
        wr_sop <= 0;
        wr_vld <= 1;
        for (i=0; i<fifo_length-1; i=i+1) begin
            if (ready) begin
                next_data <= 1'b1;
            end
            wr_data <= $random;
            #2;
        end
        wr_eop <= 1;
        #2;
        wr_eop <= 0;
        wr_vld <= 0;
        #20;
        next_data <= 1;
        #64;
        next_data <= 0;
        #10;
        $finish;
    end

endmodule
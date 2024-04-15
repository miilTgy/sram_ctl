module arbiter_tb ();

    parameter arbiter_data_width = 256;
    reg clk, rst, sp0_wrr1;
    reg [arbiter_data_width-1:0] data_in;
    wire [arbiter_data_width-1:0] data_out;

    arbiter arbiter_test (
        .rst        (rst        ),
        .clk        (clk        ),
        .sp0_wrr1   (sp0_wrr1   ),
        .data_in    (data_in    ),
        .data_out   (data_out   )
    );

    always #1 clk = ~clk;
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end
    initial begin
        rst <= 0; sp0_wrr1 <= 0; clk <= 1'b1;
        #10
        rst <= 1;
        #2
        rst <= 0;
        #10
        $finish;
    end
    
endmodule

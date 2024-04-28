module write_arbiter_tb ();

    // parameters
    parameter arbiter_data_width = 256;
    parameter num_of_ports = 16;
    
    // ports
    reg clk, rst, sp0_wrr1;
    wire busy;
    reg [num_of_ports-1:0] ready, sop, eop, vld;
    wire [num_of_ports-1:0] next_data;
    reg [(arbiter_data_width * num_of_ports)-1:0] data_in_p;
    wire [arbiter_data_width-1:0] selected_data_out;

    // unpacked ports
    wire [arbiter_data_width-1:0] data_in [num_of_ports-1:0];

    // unpack ports
    genvar j;
    generate
        for (j=0; j<num_of_ports; j=j+1) begin
            assign data_in[j] = data_in_p[(j+1)*arbiter_data_width-1:j*arbiter_data_width];
        end
    endgenerate

    // instance
    write_arbiter arbiter_tt (
        .rst                        (rst                ),
        .clk                        (clk                ),
        .sp0_wrr1                   (sp0_wrr1           ),
        .ready                      (ready              ),
        .sop                        (sop                ),
        .eop                        (eop                ),
        .vld                        (vld                ),
        .data_in_p                  (data_in_p          ),
        .busy                       (busy               ),
        .selected_data_out          (selected_data_out  ),
        .next_data                  (next_data          )
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

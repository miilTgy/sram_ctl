module write_arbiter_tb ();

    // parameters
    parameter arbiter_data_width = 256;
    parameter num_of_ports = 16;
    
    // ports
    reg clk, rst, sp0_wrr1;
    wire busy;
    reg [num_of_ports-1:0] ready, sop, eop, vld;
    wire [num_of_ports-1:0] next_data;
    wire [(arbiter_data_width * num_of_ports)-1:0] data_in_p;
    wire [arbiter_data_width-1:0] selected_data_out;

    // unpacked ports
    reg [arbiter_data_width-1:0] data_in [num_of_ports-1:0];

    // unpack ports
    genvar j;
    generate
        for (j=0; j<num_of_ports; j=j+1) begin
            assign data_in_p[(j+1)*arbiter_data_width-1:j*arbiter_data_width] = data_in[j];
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
    reg randomselect;
    integer i, k;
    initial begin
        rst <= 0; sp0_wrr1 <= 0; clk <= 1'b1;
        ready <= 0; sop <= 0; eop <= 0; vld <= 0;
        for (i=0; i<num_of_ports; i=i+1) begin
            data_in[i] <= 0;
        end
        #2;
        rst <= 1;
        #2;
        rst <= 0;
        #2;
        for (i=0; i<num_of_ports; i=i+1) begin
            if ({$random}%2) begin
                vld[i] <= 1;
                ready[i] <= 1;
                sop[i] <= 0;
                eop[i] <= 0;
                for (k=0; k<arbiter_data_width; k=k+1) begin
                    data_in[i][k] <= $random;
                end
            end
        end
        #10;
        $finish;
    end
    
endmodule

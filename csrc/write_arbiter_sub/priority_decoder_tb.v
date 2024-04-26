module ();
    // parameters
    parameter arbiter_data_width = 256;
    parameter num_of_ports       = 16;
    parameter priority_width     = 3;

    // ports
    reg clk;
    reg [arbiter_data_width*num_of_ports-1:0] priority_decoder_in;
    reg [num_of_ports-1:0] ready;
    wire [num_of_ports*priority_width-1:0] priority_out;

    //unpacked ports
    wire [arbiter_data_width-1:0] unpack_priority_decoder_in [num_of_ports-1:0];
    wire [priority_width-1:0] unpack_priority_out [num_of_ports-1:0];

    // unpack ports
    genvar j;
    generate
        for (j=0; j<num_of_ports; j=j+1) begin
            assign unpack_priority_decoder_in[j] = priority_decoder_in[(j+1)*arbiter_data_width-1:j*arbiter_data_width];
            assign unpack_priority_out[j] = priority_out[(j+1)*priority_width-1:j*priority_width];
        end
    endgenerate

    // instance
    priority_decoder priority_decoder_tt (
        .clk                    (clk                ),
        .priority_decoder_in    (priority_decoder_in),
        .ready                  (ready              ),
        .priority_out           (priority_out       )
    );

    always #1 clk = ~clk;
    integer i;
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
        for (i=0; i<num_of_ports; i=i+1) begin
            $dumpvars(0, unpack_priority_decoder_in[i]);
            $dumpvars(0, unpack_priority_out);
        end
    end
    initial begin
        clk <= 1;  priority_decoder_in <= 0;
        #10;
        $finish;
    end
endmodule
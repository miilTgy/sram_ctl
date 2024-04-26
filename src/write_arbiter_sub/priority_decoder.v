module priority_decoder #(
    // parameters
    parameter arbiter_data_width = 256,
    parameter num_of_ports       = 16,
    parameter priority_width     = 3
) (
    // ports
    input       [arbiter_data_width*num_of_ports-1:0]   priority_decoder_in,
    input       [num_of_ports-1:0]                      ready,
    output  reg [num_of_ports*priority_width-1:0]       priority_out
);
    
endmodule
// `define num_of_ports 16
module write_arbiter #(
    // parameters
    parameter num_of_ports = 16,
    parameter arbiter_data_width = 256
) (
    // ports
    input                                                       rst,
    input                                                       clk,
    input                                                       sp0_wrr1,
    input           [num_of_ports-1:0]                          ready,
    input           [num_of_ports-1:0]                          sop,
    input           [num_of_ports-1:0]                          eop,
    input           [num_of_ports-1:0]                          vld,
    input   wire    [(num_of_ports*sarbiter_data_width)-1:0]    data_in_p,
    output  wire                                                busy,
    output  reg     [(arbiter_data_width)-1:0]                  selected_data_out,
    output  reg     [num_of_ports-1:0]                          next_data
);

    wire    [arbiter_data_width-1:0]    selected_data_in    [num_of_ports-1:0];

    // 压缩data_in_p端口
    genvar i;
    generate
        for (i = 0; i < num_of_ports; i = i + 1) begin
            assign data_in[i] = data_in_p[(i+1)*arbiter_data_width-1:i*arbiter_data_width];
        end
    endgenerate

    
endmodule

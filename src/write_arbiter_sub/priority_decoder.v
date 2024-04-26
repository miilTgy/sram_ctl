module priority_decoder #(
    // parameters
    parameter arbiter_data_width = 256,
    parameter num_of_ports       = 16,
    parameter priority_width     = 3
) (
    // ports
    input                                               clk,
    input       [arbiter_data_width*num_of_ports-1:0]   priority_decoder_in,
    input       [num_of_ports-1:0]                      ready,
    output  reg [num_of_ports*priority_width-1:0]       priority_out
);
    wire [arbiter_data_width-1:0] priorities_tmp [num_of_ports-1:0];
    wire [priority_width-1:0] priorities [num_of_ports-1:0];

    genvar j;
    generate
        for (j=0; j<num_of_ports; j=j+1) begin
            assign priorities_tmp[j] = priority_decoder_in[(j+1)*arbiter_data_width-1:j*arbiter_data_width];
            assign priorities[j] = priorities_tmp[j][6:4];
        end
    endgenerate

    integer i;
    always @(posedge clk ) begin
        if (| ready) begin
            for (i=0; i<num_of_ports; i=i+1) begin
                // 这里运用了一个新语法：signal[i+:n]表示从i位开始往上取n位。
                priority_out[i*priority_width+:priority_width] <= priorities[i];
            end
        end
    end

endmodule
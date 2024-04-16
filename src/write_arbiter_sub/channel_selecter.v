module channel_selecter #(
    // parameters
    parameter num_of_ports = 16,
    parameter arbiter_data_width = 256
) (
    // ports
    input                                                   clk,
    input       [num_of_ports-1:0]                          select,
    input       [(arbiter_data_width * num_of_ports)-1:0]   selected_data_in,
    output      [arbiter_data_width-1:0]                    selected_data_out,
    output  reg [num_of_ports-1:0]                          enabled
);

    wire    [arbiter_data_width-1:0]    datas   [num_of_ports-1:0];

    genvar i;
    generate
        for (i = 0; i < num_of_ports; i = i + 1) begin
            assign datas[i] = selected_data_in[(i + 1) * arbiter_data_width - 1 : i * arbiter_data_width];
        end
    endgenerate

    always @(posedge clk ) begin
        
    end
    
endmodule
module channel_selecter #(
    // parameters
    parameter num_of_ports = 16,
    parameter arbiter_data_width = 256
) (
    // ports
    input       [num_of_ports-1:0]          select,
    input       [arbiter_data_width-1:0]    selected_data_in,
    output      [arbiter_data_width-1:0]    selected_data_out,
    output  reg [num_of_ports-1:0]          enabled
);

    always @(posedge clk ) begin
        
    end
    
endmodule
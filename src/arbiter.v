module arbiter #(
    // parameters
    parameter arbiter_data_width = 256
) (
    // ports
    input rst,
    input clk,
    input sp0_wrr1,
    input [arbiter_data_width-1:0] data_in,
    output reg [arbiter_data_width-1:0] data_out
);

    always @(posedge clk ) begin
        if (rst) begin
            data_out <= {arbiter_data_width{1'b0}};
        end
    end
    
endmodule

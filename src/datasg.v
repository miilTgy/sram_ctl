module datasg #(
    // parameters
    // [x] Make parameters
    parameter sg_data_width = 64,
    parameter sg_address_width = 12,
    parameter sg_des_width = 4,
    parameter sg_priority_width = 3
) (
    // ports
    // [.] Make ports
    input                               rst,
    input   [sg_data_width-1:0]         data_in,
    output                              request,
    output  [sg_priority_width-1:0]     wr_priority,
    output  [sg_des_width-1:0]          des_port,
    output  [sg_address_width-1:0]      address_write,
    output  [sg_data_width-1:0]         data_write
);
    // [.] Complete this
    always @(posedge clk ) begin
        if (rst) begin
            
        end
    end
endmodule
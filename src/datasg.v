module datasg #(
    // parameters
    // [x] Make parameters
    parameter sg_data_width = 64,
    parameter sg_address_width = 12,
    parameter sg_des_width = 4,
    parameter sg_priority_width = 3
) (
    // ports
    // [x] Make ports
    input                                   rst,
    input                                   clk,
    input                                   transfering,
    input                                   busy,
    input       [sg_data_width-1:0]         data_in,
    input       [sg_address_width-1:0]      priority_in,
    input       [sg_des_width-1:0]          des_port_in,
    output  reg                             request,
    output  reg [sg_priority_width-1:0]     wr_priority,
    output  reg [sg_des_width-1:0]          des_port,
    output  reg [sg_address_width-1:0]      address_write,
    output  reg [sg_data_width-1:0]         data_write
);
    // [.] Complete this
    always @(posedge clk ) begin
        if (rst) begin
            request <= 1'b0; wr_priority <= {sg_priority_width{1'b0}};
            des_port <= {sg_des_width{1'b0}};
            address_write <= {sg_address_width{1'b0}};
            data_write <= {sg_data_width{1'b0}};
        end
    end
endmodule
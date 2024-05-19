module datasg #(
    // parameters
    // [x] Make parameters
    parameter num_of_ports = 16,
    parameter sg_data_width = 64,
    parameter sg_address_width = 16,
    parameter sg_des_width = 4,
    parameter sg_priority_width = 3,
    parameter sg_pack_length_width = 7
) (
    // ports
    // [x] Make ports
    input                                       rst,
    input                                       clk,
    input                                       transfering,
    input                                       busy,
    input           [num_of_ports-1:0]          eop,
    input           [sg_data_width-1:0]         data_in,
    input           [sg_address_width-1:0]      address_in,
    input           [sg_address_width-1:0]      priority_in,
    input           [sg_des_width-1:0]          des_port_in,
    input           [sg_pack_length_width-1:0]  pack_length_in,
    output  reg                                 request,
    output  reg                                 request2,
    output  wire    [sg_priority_width-1:0]     wr_priority,
    output  wire    [sg_des_width-1:0]          des_port,
    output  reg     [sg_address_width-1:0]      address_write,
    output  reg     [sg_data_width-1:0]         data_write,
    output  wire                                write_enable1,
    output  wire                                write_enable2,
    output  wire                                write_enable3,
    output  wire                                write_enable4,
    output  wire    [ab_pack_length_out-1:0]    pack_length
);
    // [x] Complete this
    reg writting;

    // assign data_write = data_in;
    assign des_port = des_port_in;
    assign wr_priority = priority_in;
    assign pack_length = pack_length_in;
    assign write_enable1 = transfering;
    assign write_enable2 = request;
    assign write_enable3 = writting;
    assign write_enable4 = request2;

    always @(posedge clk ) begin
        if (rst) begin
            request <= 1'b0; writting <= 1'b0;
            address_write <= {sg_address_width{1'b0}};
            data_write <= {sg_data_width{1'b0}};
        end else begin
            if (transfering && (!writting)) begin
                // transfering拉高后的第一拍进来这里
                $display("writting start");
                writting <= 1'b1;
            end else if (|eop) begin
                // eop拉高后的一拍进来这里
                $display("writting stop");
                writting <= 1'b0;
                data_write <= 0;
                address_write <= 0;
            end
        end 
    end

    always @(* ) begin
        if (writting) begin
            data_write <= data_in;
            address_write <= address_in;
        end else begin
            data_write <= 0;
            address_write <= 0;
        end
    end

    always @(* ) begin
        request = (transfering & (!(|eop)));
        request2 = (busy & (!(|eop)));
    end
endmodule
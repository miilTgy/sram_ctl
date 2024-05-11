// `define num_of_ports 16
module read_arbiter #(
    // parameters
    parameter num_of_ports = 16,
    parameter arbiter_data_width = 256
) (
    // ports
    input                                                       rst,
    input                                                       clk,
    input                                                       sp0_wrr1,
    input           [num_of_ports-1:0]                          ready,

    output          [num_of_ports-1:0]                          rd_sop,
    output          [num_of_ports-1:0]                          rd_eop,
    output          [num_of_ports-1:0]                          rd_vld,
    output          [(arbiter_data_width)-1:0]                  rd_data,

    input           [num_of_ports-1:0]                          rd_port,
    input           [num_of_ports-1:0]                          rd_address_offset,
    output          [num_of_ports-1:0]                          rd_priority,
    output          [num_of_ports-1:0]                          rd_enable,


    input           [(arbiter_data_width)-1:0]                  data_read, 
    output  reg     [num_of_ports-1:0]                          address_read
);

    wire    [arbiter_data_width-1:0]    data_out     [num_of_ports-1:0];

    // 解压缩data_read端口
    genvar i;
    generate
        for (i = 0; i < num_of_ports; i = i + 1) begin
            assign data_out[(i + 1) * arbiter_data_width - 1 : i * arbiter_data_width] = data_read[i];
        end
    endgenerate

    always @(posedge clk ) begin
        if (rst) begin
            data_out <= {arbiter_data_width{1'b0}};
        end else begin
            case (sp0_wrr1)
                1'b0: begin // *SP严格优先级
                    data_out <= data_read[1];
                    // TODO
                end
                1'b1: begin // *WRR加权轮询调度
                    // TODO
                end
                default: data_out <= data_out;
            endcase
        end
        rd_data <= data_out[rd_port];
    end
    
endmodule

module channel_selecter #(
    // parameters
    parameter num_of_ports = 16,
    parameter arbiter_data_width = 256
) (
    // ports
    input                                                   clk,
    input                                                   rst,
    input                                                   enable,
    input       [3:0]                                       select,
    input       [(arbiter_data_width * num_of_ports)-1:0]   selected_data_in,
    output  reg [arbiter_data_width-1:0]                    selected_data_out,
    output  reg [3:0]                                       enabled
);

    wire    [arbiter_data_width-1:0]    datas   [num_of_ports-1:0];

    // 解压缩selected_data_in端口
    genvar i;
    generate
        for (i = 0; i < num_of_ports; i = i + 1) begin
            assign datas[i] = selected_data_in[(i + 1) * arbiter_data_width - 1 : i * arbiter_data_width];
        end
    endgenerate

    always @(* ) begin
        if (rst) begin
            selected_data_out = 0; enabled = 0;
        end else begin
            if (enable) begin
                selected_data_out = datas[select];
                enabled = select;
            end else begin
                selected_data_out = {256{1'b0}};
                // enabled = enabled;
            end
        end
    end
    
endmodule

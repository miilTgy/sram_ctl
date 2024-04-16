module channel_selecter #(
    // parameters
    parameter num_of_ports = 16,
    parameter arbiter_data_width = 256
) (
    // ports
    input                                                   clk,
    input                                                   enable,
    input       [3:0]                                       select,
    input       [(arbiter_data_width * num_of_ports)-1:0]   selected_data_in,
    output  reg [arbiter_data_width-1:0]                    selected_data_out,
    output  reg [num_of_ports-1:0]                          enabled
);

    wire    [arbiter_data_width-1:0]    datas   [num_of_ports-1:0];

    // 压缩selected_data_in端口
    genvar i;
    generate
        for (i = 0; i < num_of_ports; i = i + 1) begin
            assign datas[i] = selected_data_in[(i + 1) * arbiter_data_width - 1 : i * arbiter_data_width];
        end
    endgenerate

    always @(posedge clk ) begin
        // case (select)
        //     4'd0:   selected_data_out <= datas[0];
        //     4'd1:   selected_data_out <= datas[1];
        //     4'd2:   selected_data_out <= datas[2];
        //     4'd3:   selected_data_out <= datas[3];
        //     4'd4:   selected_data_out <= datas[4];
        //     4'd5:   selected_data_out <= datas[5];
        //     4'd6:   selected_data_out <= datas[6];
        //     4'd7:   selected_data_out <= datas[7];
        //     4'd8:   selected_data_out <= datas[8];
        //     4'd9:   selected_data_out <= datas[9];
        //     4'd10:  selected_data_out <= datas[10];
        //     4'd11:  selected_data_out <= datas[11];
        //     4'd12:  selected_data_out <= datas[12];
        //     4'd13:  selected_data_out <= datas[13];
        //     4'd14:  selected_data_out <= datas[14];
        //     4'd15:  selected_data_out <= datas[15];
        //     default:selected_data_out <= selected_data_out;
        // endcase
        if (enable) begin
            selected_data_out <= datas[select];
        end
    end
    
endmodule

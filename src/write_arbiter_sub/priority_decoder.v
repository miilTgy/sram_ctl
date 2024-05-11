module priority_decoder #(
    // parameters
    parameter arbiter_data_width = 64,
    parameter num_of_ports       = 16,
    parameter priority_width     = 3,
    parameter des_port_width     = 4
) (
    // ports
    input                                               clk,
    input                                               rst,
    input       [arbiter_data_width*num_of_ports-1:0]   priority_decoder_in,
    input       [num_of_ports-1:0]                      ready,
    input       [num_of_ports-1:0]                      eop,
    input       [3:0]                                   select,
    input       [3:0]                                   pre_selected,
    output  reg [num_of_ports*priority_width-1:0]       priority_out,
    output  reg [num_of_ports*priority_width-1:0]       pre_priority_out,
    output  reg [num_of_ports*des_port_width-1:0]       des_port_out
);

    wire [arbiter_data_width-1:0] priorities_tmp [num_of_ports-1:0];
    wire [priority_width-1:0] priorities [num_of_ports-1:0];
    wire [arbiter_data_width-1:0] des_port_tmp [num_of_ports-1:0];
    wire [des_port_width-1:0] des_ports [num_of_ports-1:0];

    reg holding;

    genvar j;
    generate
        for (j=0; j<num_of_ports; j=j+1) begin
            assign priorities_tmp[j] = priority_decoder_in[(j+1)*arbiter_data_width-1:j*arbiter_data_width];
            assign priorities[j] = priorities_tmp[j][6:4];
            assign des_port_tmp[j] = priority_decoder_in[(j+1)*arbiter_data_width-1:j*arbiter_data_width];
            assign des_ports[j] = des_port_tmp[j][3:0];
            // assign des_port_out[(j+1)*des_port_width-1:j*des_port_width] = des_ports[j];
        end
    endgenerate

    // assign select_reg = select;

    integer i;
    always @(posedge clk ) begin
        if (rst) begin
            holding <= 1'b0;
        end else begin
            if ((| ready) && (! holding)) begin
                for (i=0; i<num_of_ports; i=i+1) begin
                    // 这里运用了一个新语法：signal[i+:n]表示从i位开始往上取n位。
                    priority_out[i*priority_width +: priority_width] <= priorities[i];
                    des_port_out[i*des_port_width +: des_port_width] <= des_ports[i];
                    holding <= 1'b1;
                end
            end else if (holding && eop[select]) begin
                holding <= 1'b0;
                priority_out <= {num_of_ports*priority_width{1'b0}};
            end
        end
    end

    always @(* ) begin
        for (i=0; i<num_of_ports; i=i+1) begin
            pre_priority_out[i*priority_width +: priority_width] <= priorities[i];
        end
    end

endmodule
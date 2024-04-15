// `define num_of_ports 16
module arbiter #(
    parameter num_of_ports = 16
)
(
    // ports
    input                               rst,
    input                               clk,
    input                               sp0_wrr1,
    input   wire    [num_of_ports-1:0]  ready_in,
    output  reg     [num_of_ports-1:0]  select_out
);

    always @(posedge clk ) begin
        if (rst) begin
            select_out <= 1'b0;
        end else begin
            case (sp0_wrr1)
                1'b0: begin // *SP严格优先级
                    select_out <= ready_in[1];
                    // TODO
                end
                1'b1: begin // *WRR加权轮询调度
                    // TODO
                end
                default: select_out <= select_out;
            endcase
        end
    end
    
endmodule

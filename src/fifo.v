module fifo #(
        // parameters
        fifo_data_width = 256,
        fifo_num_of_priority = 8
    ) (
        // ports
        input                               rst,
        input                               clk,
        input                               read,
        input                               wr_sop,
        input                               wr_eop,
        input                               wr_vld,
        input       [fifo_data_width-1:0]   wr_data,
        output  reg                         sop,
        output  reg                         eop,
        output  reg                         vld,
        output  reg [fifo_data_width-1:0]   out_data
    );

    reg [fifo_data_width-1+3:0] fifo [7:0];
    integer i=32'b0;

    always @(posedge clk ) begin
        if (rst) begin
            sop <= 1'b0; eop <= 1'b0; vld <= 1'b0;
            for (i = 32'b0; i < 32'd8; i++) begin
                fifo[i] <= fifo[i] ^ fifo[i];
            end
        end
    end

endmodule

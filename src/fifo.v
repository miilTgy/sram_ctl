module fifo #(
        // parameters
        parameter fifo_data_width      = 64,   // should be 256
        parameter fifo_num_of_priority = 8,
        parameter fifo_length = 32,
        parameter fifo_pointer_width = 5
    ) (
        // ports
        input                               rst,
        input                               in_clk,
        input                               clk,
        input                               next_data,
        input                               wr_sop,
        input                               wr_eop,
        input                               wr_vld,
        input       [fifo_data_width-1:0]   wr_data,
        output  reg                         ready, // ready=1 means there is data to be readed in fifo_buf.
        output  reg                         overflow,
        output  wire                        sop, // 这里用wire是因为这条线直接接在fifo_buf上，
        output  wire                        eop, // 而fifo_buf是reg类型，所以没必要再套一层reg了。
        output  wire                        vld,
        output  wire[fifo_data_width-1:0]   out_data
    );

    reg [fifo_data_width-1+3:0] fifo_buf [fifo_length-1:0];
    reg [fifo_pointer_width-1:0] wptr, rptr;
    reg working;
    integer i=32'b0;

    // reg [2:0] clk_sync;
    // wire sampling;

    // assign sampling = (!clk_sync[2] & clk_sync[1]); // detact posedge of input clock;

    // always @(posedge clk ) begin
    //     clk_sync <= {clk_sync[1:0], in_clk};
    // end

    always @(posedge clk ) begin
        if (rst) begin
            wptr <= 0; rptr <= 0; working <= 1'b0; ready <= 1'b0;
            for (i = 32'b0; i < fifo_num_of_priority; i++) begin
                fifo_buf[i] <= 0;
            end
        end else begin
            // read out
            if (ready) begin
                if (next_data) begin
                    rptr <= rptr + {{(fifo_pointer_width-1){1'b0}}, 1'b1};
                    if (wptr == rptr+{{(fifo_pointer_width-1){1'b0}}, 1'b1}) begin // if fifo_buf empty
                        ready <= 1'b0; // reset ready
                    end
                end
            end
            // //write in
            // if (wr_sop) begin
            //     working <= 1'b1;
            // end
            // if (wr_eop) begin
            //     working <= 1'b0;
            //     fifo_buf[wptr] <= {wr_sop, wr_eop, wr_vld, {fifo_data_width{1'b0}}};
            // end
            // if (working && wr_vld) begin
            //     fifo_buf[wptr] <= {wr_sop, wr_eop, wr_vld, wr_data};
            //     wptr <= wptr + 5'b1;
            //     ready <= 1'b1;
            //     overflow <= overflow | (rptr == (wptr+5'b1)); // if wptr catch up with rptr, overflow
            // end
        end
    end

    always @(posedge in_clk ) begin
        //write in
        if (wr_sop) begin
            working <= 1'b1;
        end
        if (wr_eop) begin
            working <= 1'b0;
            ready <= 1'b1;
            fifo_buf[wptr] <= {wr_sop, wr_eop, wr_vld, {fifo_data_width{1'b0}}};
        end
        if (working && wr_vld) begin
            fifo_buf[wptr] <= {wr_sop, wr_eop, wr_vld, wr_data};
            wptr <= wptr + {{(fifo_pointer_width-1){1'b0}}, 1'b1};
            overflow <= overflow | (rptr == (wptr+{{(fifo_pointer_width-1){1'b0}}, 1'b1})); // if wptr catch up with rptr, overflow
        end
    end

    assign {sop, eop, vld, out_data} = fifo_buf[rptr];

endmodule

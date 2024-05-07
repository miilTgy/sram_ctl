module fifo_write_arbiter ();
    
    // parameters
    parameter num_of_ports = 16;
    parameter arbiter_data_width = 64;
    parameter priority_width = 3;
    parameter fifo_data_width = 64;
    parameter fifo_num_of_priority = 8;
    parameter fifo_length = 32;

    // ports for fifo
    reg rst;
    reg in_clk, clk;
    reg [num_of_ports-1:0] wr_sop, wr_eop, wr_wld;
    reg [fifo_data_width-1:0] wr_data_unpack [num_of_ports-1:0];
    reg [fifo_data_width*num_of_ports-1:0] wr_data;
    wire [fifo_data_width*num_of_ports-1:0] out_data;

    // ports for all
    wire [num_of_ports-1:0] next_data;
    wire [num_of_ports-1:0] ready;
    wire overflow [num_of_ports-1:0];
    wire [num_of_ports-1:0] sop, eop, vld;
    wire [fifo_data_width-1:0] between_data_unpack [num_of_ports-1:0]; // 接到fifo的out_data

    // ports for write_arbiter
    reg sp0_wrr1;
    wire busy;
    wire [arbiter_data_width-1:0] data_out_unpack [num_of_ports-1:0];
    wire [arbiter_data_width*num_of_ports-1:0] data_out;
    wire [fifo_data_width*num_of_ports-1:0] data_in_p;

endmodule
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
    reg [fifo_data_width-1:0] wr_data [num_of_ports-1:0];

    wire [num_of_ports-1:0] next_data;
    wire [num_of_ports-1:0] ready;
    wire overflow [num_of_ports-1:0];
    wire [num_of_ports-1:0] sop, eop, vld;
    wire [fifo_data_width-1:0] out_data [num_of_ports-1:0];

endmodule
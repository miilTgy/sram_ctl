module top_tb ();
    
    // parameters
    parameter num_of_ports = 16;
    parameter arbiter_data_width = 64;
    parameter priority_width = 3;
    parameter fifo_data_width = 64;
    parameter fifo_num_of_priority = 8;
    parameter fifo_length = 32;
    parameter des_port_width = 7;
    parameter address_width = 12;
    parameter num_of_priority = 8;
    parameter data_width = 64;
    parameter num_of_priorities = 8;


// ports
    reg sp0_wrr1;
    reg [num_of_ports-1:0] wr_sop, wr_eop, wr_vld;
    reg [data_width*num_of_ports-1:0] wr_data;
    reg [num_of_ports-1:0] ready;

    wire [num_of_ports-1:0] rd_sop, rd_eop, rd_vld;
    wire [num_of_ports*data_width-1:0] rd_data;
    wire full, almost_full;

// instance
    top top_in (
        .sp0_wrr1   (sp0_wrr1),
        .wr_sop     (wr_sop),
        .wr_eop     (wr_eop),
        .wr_vld     (wr_vld),
        .wr_data    (wr_data),
        .ready      (ready),
        .rd_sop     (rd_sop),
        .rd_eop     (rd_eop),
        .rd_vld     (rd_vld),
        .rd_data    (rd_data),
        .full       (full),
        .almost_full(almost_full)
    );


endmodule
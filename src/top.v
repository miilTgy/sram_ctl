module top #(
        // parameters
        parameter num_of_ports    = 16,
        parameter data_width      = 256,
        parameter num_of_priority = 8
    ) (
        // ports
        input                           wr_sop      [num_of_ports-1:0],
        input                           wr_eop      [num_of_ports-1:0],
        input                           wr_vld      [num_of_ports-1:0],
        input   [data_width-1:0]        wr_data     [num_of_ports-1:0],
        input   [num_of_priority-1:0]   ready       [num_of_ports-1:0],
        output                          rd_sop      [num_of_ports-1:0],
        output                          rd_eop      [num_of_ports-1:0],
        output                          rd_vld      [num_of_ports-1:0],
        output  [data_width-1:0]        rd_data     [num_of_ports-1:0],
        output  [num_of_priority-1:0]   full        [num_of_ports-1:0],
        output  [num_of_priority-1:0]   almost_full [num_of_ports-1:0]
    );

endmodule

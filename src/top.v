/*
2024年4月3日创建。
Created in April, 3rd, 2024.
此模块是顶层模块。
This is a top module.
请不要在此模块中完成任何逻辑过程。
Please do not write ant logical code in this module.
此模块中只能例化和拉线。
You can only instantiate modules or creat wire/regs in this module.
*/

module top #(
        // parameters
        parameter num_of_ports    = 16,
        parameter data_width      = 256,
        parameter num_of_priority = 8
    ) (
        // ports
        input                               wr_sop      [num_of_ports-1:0],
        input                               wr_eop      [num_of_ports-1:0],
        input                               wr_vld      [num_of_ports-1:0],
        input       [data_width-1:0]        wr_data     [num_of_ports-1:0],
        input       [num_of_priority-1:0]   ready       [num_of_ports-1:0],
        output  reg                         rd_sop      [num_of_ports-1:0],
        output  reg                         rd_eop      [num_of_ports-1:0],
        output  reg                         rd_vld      [num_of_ports-1:0],
        output  reg [data_width-1:0]        rd_data     [num_of_ports-1:0],
        output  reg [num_of_priority-1:0]   full        [num_of_ports-1:0],
        output  reg [num_of_priority-1:0]   almost_full [num_of_ports-1:0]
    );

endmodule

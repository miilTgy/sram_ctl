// 2024年4月3日创建。
// Created in April, 3rd, 2024.
// 此模块是顶层模块。
// This is a top module.
// 请不要在此模块中完成任何逻辑过程。
// Please do not write ant logical code in this module.
// 此模块中只能例化和拉线。
// You can only instantiate modules or creat wire/regs in this module.

module top #(
        // parameters
        parameter num_of_ports    = 16,
        parameter data_width      = 64,
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

//cache_manager_inst

    reg rst;
    reg clk;

    //package_input_related_declaration

    reg wea; //write_enable
    reg [7:0] w_size; //写入包长度
    reg [2:0] priority; //该数据包的优先级，0~7
    reg [3:0] dest_port; //该数据包的目标端口;0~15
    reg [11:0] write_address = 0; //写入地址
    reg writing = 0; //正在传输写入地址时拉高

    //package_output_related_declaration

    //port_n_addr为输出地址线； port_n_priority为需求优先级； port_n_rea为n端口读出请求； port_n_reading为n端口输出有效；
    reg [11:0] port_0_addr = 0; reg [3:0] port_0_priority; reg port_0_rea;  reg port_0_reading = 0;
    reg [11:0] port_1_addr = 0; reg [3:0] port_1_priority; reg port_1_rea;  reg port_1_reading = 0;
    reg [11:0] port_2_addr = 0; reg [3:0] port_2_priority; reg port_2_rea;  reg port_2_reading = 0;
    reg [11:0] port_3_addr = 0; reg [3:0] port_3_priority; reg port_3_rea;  reg port_3_reading = 0;
    reg [11:0] port_4_addr = 0; reg [3:0] port_4_priority; reg port_4_rea;  reg port_4_reading = 0;
    reg [11:0] port_5_addr = 0; reg [3:0] port_5_priority; reg port_5_rea;  reg port_5_reading = 0;
    reg [11:0] port_6_addr = 0; reg [3:0] port_6_priority; reg port_6_rea;  reg port_6_reading = 0;
    reg [11:0] port_7_addr = 0; reg [3:0] port_7_priority; reg port_7_rea;  reg port_7_reading = 0;
    reg [11:0] port_8_addr = 0; reg [3:0] port_8_priority; reg port_8_rea;  reg port_8_reading = 0;
    reg [11:0] port_9_addr = 0; reg [3:0] port_9_priority; reg port_9_rea;  reg port_9_reading = 0;
    reg [11:0] port_10_addr = 0; reg [3:0] port_10_priority; reg port_10_rea;  reg port_10_reading = 0;
    reg [11:0] port_11_addr = 0; reg [3:0] port_11_priority; reg port_11_rea;  reg port_11_reading = 0;
    reg [11:0] port_12_addr = 0; reg [3:0] port_12_priority; reg port_12_rea;  reg port_12_reading = 0;
    reg [11:0] port_13_addr = 0; reg [3:0] port_13_priority; reg port_13_rea;  reg port_13_reading = 0;
    reg [11:0] port_14_addr = 0; reg [3:0] port_14_priority; reg port_14_rea;  reg port_14_reading = 0;
    reg [11:0] port_15_addr = 0; reg [3:0] port_15_priority; reg port_15_rea;  reg port_15_reading = 0;

    cache_manager u_cache_manager(
        .rst(rst),
        .clk(clk),
        .wea(wea),
        .w_size(w_size),
        .priority(priority),
        .dest_port(dest_port),
        .write_address(write_address),
        .writing(writing),
        .port_0_addr(port_0_addr), .port_0_priority(port_0_priority), .port_0_rea(port_0_rea), .port_0_reading(port_0_reading),
        .port_1_addr(port_1_addr), .port_1_priority(port_1_priority), .port_1_rea(port_1_rea), .port_1_reading(port_1_reading),
        .port_2_addr(port_2_addr), .port_2_priority(port_2_priority), .port_2_rea(port_2_rea), .port_2_reading(port_2_reading),
        .port_3_addr(port_3_addr), .port_3_priority(port_3_priority), .port_3_rea(port_3_rea), .port_3_reading(port_3_reading),
        .port_4_addr(port_4_addr), .port_4_priority(port_4_priority), .port_4_rea(port_4_rea), .port_4_reading(port_4_reading),
        .port_5_addr(port_5_addr), .port_5_priority(port_5_priority), .port_5_rea(port_5_rea), .port_5_reading(port_5_reading),
        .port_6_addr(port_6_addr), .port_6_priority(port_6_priority), .port_6_rea(port_6_rea), .port_6_reading(port_6_reading),
        .port_7_addr(port_7_addr), .port_7_priority(port_7_priority), .port_7_rea(port_7_rea), .port_7_reading(port_7_reading),
        .port_8_addr(port_8_addr), .port_8_priority(port_8_priority), .port_8_rea(port_8_rea), .port_8_reading(port_8_reading),
        .port_9_addr(port_9_addr), .port_9_priority(port_9_priority), .port_9_rea(port_9_rea), .port_9_reading(port_9_reading),
        .port_10_addr(port_10_addr), .port_10_priority(port_10_priority), .port_10_rea(port_10_rea), .port_10_reading(port_10_reading),
        .port_11_addr(port_11_addr), .port_11_priority(port_11_priority), .port_11_rea(port_11_rea), .port_11_reading(port_11_reading),
        .port_12_addr(port_12_addr), .port_12_priority(port_12_priority), .port_12_rea(port_12_rea), .port_12_reading(port_12_reading),
        .port_13_addr(port_13_addr), .port_13_priority(port_13_priority), .port_13_rea(port_13_rea), .port_13_reading(port_13_reading),
        .port_14_addr(port_14_addr), .port_14_priority(port_14_priority), .port_14_rea(port_14_rea), .port_14_reading(port_14_reading),
        .port_15_addr(port_15_addr), .port_15_priority(port_15_priority), .port_15_rea(port_15_rea), .port_15_reading(port_15_reading)


    );

endmodule

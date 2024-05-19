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
        parameter num_of_priority = 8,
        parameter priority_width  = 3,
        parameter num_of_priorities=8,
        parameter des_port_width  = 7,
        parameter address_width   = 12
    ) (
        // ports
        input                                           sp0_wrr1,
        input       [num_of_ports-1:0]                  wr_sop,
        input       [num_of_ports-1:0]                  wr_eop,
        input       [num_of_ports-1:0]                  wr_vld,
        input       [data_width*num_of_ports-1:0]       wr_data,
        input       [num_of_priority*num_of_ports-1:0]  ready,
        output  reg [num_of_ports-1:0]                  rd_sop,
        output  reg [num_of_ports-1:0]                  rd_eop,
        output  reg [num_of_ports-1:0]                  rd_vld,
        output  reg [data_width*num_of_ports-1:0]       rd_data,
        output  reg [num_of_priority*num_of_ports-1:0]  full,
        output  reg [num_of_priority*num_of_ports-1:0]  almost_full
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

    // ports for fifo
    reg in_clk;
    wire [fifo_data_width-1:0] wr_data_unpack [num_of_ports-1:0]; // packed
    wire [fifo_data_width*num_of_ports-1:0] out_data;

    // ports for between fifo and write_arbiter
    wire [num_of_ports-1:0] sop, eop, vld;
    wire [num_of_ports-1:0] overflow;
    wire [num_of_ports-1:0] ready_between;
    wire [num_of_ports-1:0] next_data;
    wire [fifo_data_width-1:0] between_data_unpack [num_of_ports-1:0]; // 接到fifo的out_data

    // ports for write_arbiter
    wire busy;
    wire [arbiter_data_width-1:0] data_out; // packed
    wire [fifo_data_width*num_of_ports-1:0] data_in_p; // packed
    wire [3:0] arbiter_des_port_out, pre_des_port_out;
    wire [3:0] pre_selected;
    wire [priority_width-1:0] priority_out;
    wire [des_port_width-1:0] ab_pack_length_out, pre_pack_length_out;
    reg  [address_width-1:0] address_in;

    // ports for rd_arbiter
    wire [num_of_priorities-1:0] prepared; // TODO
    reg [wrr_weight_width-1:0] wrr_weight;
    wire [num_of_priorities-1:0] next_data2;

    reg [arbiter_data_width-1:0] data_read;
    reg last1, last2;
    reg [address_width-1:0] address_to_read1, address_to_read2;
    wire [address_width-1:0] address_read1, address_read2;
    wire rd_request1, rd_request2;
    wire enb;


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
    fifo u_fifo[num_of_ports-1:0] (
        .rst                        (rst),
        .in_clk                     (in_clk),
        .clk                        (clk),
        .next_data                  (next_data),
        .wr_sop                     (wr_sop),
        .wr_eop                     (wr_eop),
        .wr_vld                     (wr_vld),
        .wr_data                    (wr_data),
        .ready                      (ready_between),
        .overflow                   (overflow),
        .sop                        (sop),
        .eop                        (eop),
        .vld                        (vld),
        .out_data                   (out_data)
    );

    write_arbiter write_arbiter_tt1 (
        .rst                        (rst),
        .clk                        (clk),
        .sp0_wrr1                   (sp0_wrr1),
        .ready                      (ready_between),
        .sop                        (sop),
        .eop                        (eop),
        .vld                        (vld),
        .data_in_p                  (data_in_p),
        .busy                       (busy),
        .selected_data_out          (data_out),
        .arbiter_des_port_out       (arbiter_des_port_out),
        .ab_pack_length_out         (ab_pack_length_out),
        .next_data                  (next_data),
        .pre_selected               (pre_selected),
        .pre_des_port_out           (pre_des_port_out),
        .pre_pack_length_out        (pre_pack_length_out),
        .transfering                (transfering),
        .priority_out               (priority_out)
    );

    datasg datasg_ttt (
        .rst                        (rst),
        .clk                        (clk),
        .transfering                (transfering),
        .busy                       (busy),
        .eop                        (eop),
        .data_in                    (data_out),
        .address_in                 (address_in),
        .priority_in                (priority_out),
        .des_port_in                (pre_des_port_out),
        .pack_length_in             (pre_pack_length_out)
    );

    read_arbiter read_arbiter_tt[num_of_ports-1:0] (
        .rst                        (rst),
        .clk                        (clk),
        .sp0_wrr1                   (sp0_wrr1),
        .ready                      (ready),
        .prepared                   (prepared),
        .wrr_weight                 (wrr_weight),
        .rd_data                    (rd_data),
        .rd_sop                     (rd_sop),
        .rd_vld                     (rd_vld),
        .rd_eop                     (rd_eop),
        .next_data                  ( ),
        .next_data2                 (next_data2),
        .data_read                  (data_read),
        .last1                      (last1),
        .address_to_read1           (address_to_read1),
        .address_read1              (address_read1),
        .last2                      (last2),
        .address_to_read2           (address_to_read2),
        .address_read2              (address_read2),
        .rd_request1                (rd_request1),
        .rd_request2                (rd_request2),
        .enb                        (enb)
    );


endmodule

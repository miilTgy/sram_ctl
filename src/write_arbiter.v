// `define num_of_ports 16
module write_arbiter #(
    // parameters
    parameter num_of_ports       = 16,
    parameter arbiter_data_width = 64,
    parameter priority_width     = 3,
    parameter des_port_width     = 4
) (
    // ports
    input                                                       rst,
    input                                                       clk,
    input                                                       sp0_wrr1,
    input           [num_of_ports-1:0]                          ready,
    input           [num_of_ports-1:0]                          sop,
    input           [num_of_ports-1:0]                          eop,
    input           [num_of_ports-1:0]                          vld,
    input   wire    [(num_of_ports*arbiter_data_width)-1:0]     data_in_p,
    output  wire                                                busy,
    output  wire    [(arbiter_data_width)-1:0]                  selected_data_out,
    output  wire    [des_port_width-1:0]                        arbiter_des_port_out,
    output  wire    [num_of_ports-1:0]                          next_data,
    output  wire    [3:0]                                       pre_selected,
    output  reg     [des_port_width-1:0]                        pre_des_port_out,
    output  wire                                                transfering
);

    wire    [arbiter_data_width-1:0]            data_in             [num_of_ports-1:0];
    wire    [num_of_ports*priority_width-1:0]   priority_in;
    wire    [num_of_ports*priority_width-1:0]   pre_priority_in;
    wire    [3:0]                               select;
    wire    [num_of_ports*des_port_width-1:0]   des_port_between;

    // 压缩data_in_p端口
    genvar i;
    generate
        for (i = 0; i < num_of_ports; i = i + 1) begin
            assign data_in[i] = data_in_p[(i+1)*arbiter_data_width-1:i*arbiter_data_width];
        end
    endgenerate

    // instance
    arbiter_core arbiter_core_write (
        .clk                        (clk                ),
        .rst                        (rst                ),
        .sp0_wrr1                   (sp0_wrr1           ),
        .ready                      (ready              ),
        .eop                        (eop                ),
        .priority_in                (priority_in        ),
        .pre_priority_in            (pre_priority_in    ),
        .select                     (select             ),
        .next_data                  (next_data          ),
        .pre_selected               (pre_selected       ),
        .transfering                (transfering        ),
        .busy                       (busy               )
    );
    
    priority_decoder priority_decoder_write (
        .clk                        (clk                ),
        .rst                        (rst                ),
        .priority_decoder_in        (data_in_p          ),
        .ready                      (ready              ),
        .eop                        (eop                ),
        .select                     (select             ),
        .priority_out               (priority_in        ),
        .pre_priority_out           (pre_priority_in    ),
        .des_port_out               (des_port_between   )
    );

    channel_selecter channel_selecter_write (
        .clk                        (clk                ),
        .rst                        (rst                ),
        .enable                     (transfering        ),
        .busy                       (busy               ),
        .select                     (select             ),
        .pre_selected               (pre_selected       ),
        .selected_data_in           (data_in_p          ),
        .des_port_in                (des_port_between   ),
        .selected_data_out          (selected_data_out  ),
        .des_port_out               (arbiter_des_port_out),
        .pre_des_port_out           (pre_des_port_out   ),
        .enabled                    (                   )
    );

endmodule

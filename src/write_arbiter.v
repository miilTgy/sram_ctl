// `define num_of_ports 16
module write_arbiter #(
    // parameters
    parameter num_of_ports       = 16,
    parameter arbiter_data_width = 256,
    parameter priority_width     = 3
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
    output  wire    [num_of_ports-1:0]                          next_data
);

    wire    [arbiter_data_width-1:0]            data_in             [num_of_ports-1:0];
    wire    [num_of_ports*priority_width-1:0]   priority_in;
    wire    [num_of_ports*priority_width-1:0]   pre_priority_in;
    wire    [3:0]                               select;

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
        .pre_priority_out           (pre_priority_in    )
    );

    channel_selecter channel_selecter_write (
        .clk                        (clk                ),
        .rst                        (rst                ),
        .enable                     (transfering        ),
        .select                     (select             ),
        .selected_data_in           (data_in_p          ),
        .selected_data_out          (selected_data_out  ),
        .enabled                    (                   )
    );

endmodule

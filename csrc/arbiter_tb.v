module arbiter_tb ();

    parameter arbiter_data_width = 256;
    reg clk, rst, sp0_wrr1;
    reg [arbiter_data_width-1:0] data_in;

    arbiter arbiter_test (
        .rst        (rst        ),
        .clk        (clk        ),
        .sp0_wrr1   (sp0_wrr1   ),
        .data_in    (data_in    ),
        .data_out   (data_out   )
    )
    
endmodule
module channel_selecter_tb ();
    parameter arbiter_data_width = 256;
    parameter num_of_ports = 16;
    reg clk, rst, enable;
    reg [arbiter_data_width-1:0] selected_data_in [num_of_ports-1:0];
    wire [arbiter_data_width-1:0] selected_data_out;
    wire enabled;
    integer i;

    always #1 clk = ~clk;
    initial begin
        clk <= 1; rst <= 0; enable <= 0;
        for (i = 0; i < num_of_ports; i = i + 1) begin
            selected_data_in[i] <= 0;
        end
        #10;
    end
endmodule
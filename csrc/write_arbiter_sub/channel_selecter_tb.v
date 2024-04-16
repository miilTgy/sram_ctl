module channel_selecter_tb ();
    parameter arbiter_data_width = 256;
    parameter num_of_ports = 16;
    reg clk, rst, enable;
    reg [arbiter_data_width-1:0] selected_data_in [num_of_ports];
    wire [arbiter_data_width-1:0] selected_data_out;
    wire enabled;

    always clk = ~clk;
    initial begin
        clk = 1; rst = 0; enable = 0; selected_data_in = 0; 
        #10
    end
endmodule
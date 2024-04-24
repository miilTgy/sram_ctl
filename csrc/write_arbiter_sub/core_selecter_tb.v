module core_selecter_tb ();
    //parameters
    parameter num_of_ports = 16;
    parameter arbiter_data_width = 256;
    
    // ports for all
    reg clk, rst;

    // ports for core
    reg sp0_wrr1;
    reg [num_of_ports-1:0] ready;
    reg [num_of_ports-1:0] eop;
    reg [num_of_ports*3-1:0] priority_in;
    wire [3:0] select;
    wire transfering;

    //ports for selecter
    reg enable;
    reg [3:0] select;
    reg [(arbiter_data_width*num_of_ports)-1:0] selected_data_in;
    wire [arbiter_data_width-1:0] selected_data_out;
    wire enabled;

endmodule
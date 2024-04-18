module arbiter_core_tb ();
    parameter num_of_ports = 16;

    reg clk, sp0_wrr1;
    reg [num_of_ports-1:0] sop;
    reg [2:0] priorities [num_of_ports-1:0];
    wire [num_of_ports*3-1:0] priority_in;
    wire [3:0] select;

    // packup priorities
    genvar i;
    generate
        for (i = 0; i<num_of_ports; i=i+1) begin
            assign priority_in[(i+1)*3-1:i*3] = priorities[i];
        end
    endgenerate
    
endmodule
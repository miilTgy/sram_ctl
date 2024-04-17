module arbiter_core # (
    // parameters
    parameter num_of_ports = 16
) (
    // port
    input                                   sp0_wrr1,
    input           [num_of_ports-1:0]      sop,
    input           [num_of_ports*3-1:0]    priority_in,
    output  reg     [3:0]                   select
);
            wire    [2:0]                   priority        [num_of_ports-1:0];
    genvar i;
    generate
        for (i = 0; i < num_of_ports; i = i + 1) begin
            assign priority[i] = priority_in[(i+1)*3-1:i*3];
        end
    endgenerate

    always @(posedge clk ) begin
        if (sp0_wrr1) begin // wrr
            
        end else begin      // sp
            
        end
    end
    
endmodule
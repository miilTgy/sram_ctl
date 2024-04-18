module arbiter_core # (
    // parameters
    parameter num_of_ports = 16
) (
    // port
    input                                   clk,
    input                                   rst,
    input                                   sp0_wrr1,
    input           [num_of_ports-1:0]      sop,
    input           [num_of_ports*3-1:0]    priority_in,
    output  reg     [3:0]                   select
);

    wire [2:0] priorities [num_of_ports-1:0];
    reg [2:0] bigger;
    reg [3:0] select_tmp;
    wire busy;
    integer j;

    // unzip priority_in
    genvar i;
    generate
        for (i = 0; i < num_of_ports; i = i + 1) begin
            assign priorities[i] = priority_in[(i+1)*3-1:i*3];
        end
    endgenerate

    assign busy = |sop;

    always @(posedge clk ) begin
        if (rst) begin
            select = 4'b0000; select_tmp = 4'b0000;
        end else if (busy) begin
            if (sp0_wrr1) begin // wrr
                bigger <= bigger;
            end else begin      // sp
                select_tmp = 4'b0;
                bigger = 3'b0;
                for (j = 0; j<num_of_ports; j = j + 1) begin
                    if (sop[j]) begin
                        if (priorities[j] > bigger) begin
                            bigger = priorities[j];
                            select_tmp = j[3:0];
                        end
                    end
                end
                select = select_tmp;
            end
        end else begin
            bigger = bigger;
        end
    end
    
endmodule
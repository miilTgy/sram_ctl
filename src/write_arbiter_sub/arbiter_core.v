module arbiter_core # (
    // parameters
    parameter num_of_ports = 16,
    parameter priority_width = 3
) (
    // port
    input                                           clk,
    input                                           rst,
    input                                           sp0_wrr1,
    input       [num_of_ports-1:0]                  ready,
    input       [num_of_ports-1:0]                  eop,
    input       [num_of_ports*priority_width-1:0]   priority_in,
    output  reg [3:0]                               select,
    output  reg                                     transfering,
    output  reg                                     busy
);

    wire [2:0] priorities [num_of_ports-1:0];
    reg [2:0] bigger;
    reg [3:0] select_tmp;
    integer j;

    // unzip priority_in
    genvar i;
    generate
        for (i = 0; i < num_of_ports; i = i + 1) begin
            assign priorities[i] = priority_in[(i+1)*3-1:i*3];
        end
    endgenerate

    always @(posedge clk ) begin
        if (rst) begin
            select = 4'b0000; select_tmp = 4'b0000; transfering = 1'b0;
            busy = 1'b0;
        end else if (busy && (!transfering)) begin
            if (sp0_wrr1) begin // wrr
                bigger = bigger;
            end else begin      // sp
                select_tmp = 4'b0;
                bigger = 3'b0;
                for (j = 0; j<num_of_ports; j = j + 1) begin
                    if (ready[j]) begin
                        if (priorities[j] > bigger) begin
                            bigger = priorities[j];
                            select_tmp = j[3:0];
                        end
                    end
                end
                select = select_tmp;
                transfering = 1'b1;
            end
        end else if (transfering && eop[select]) begin
            transfering = 1'b0;
        end else if (!busy) begin
            busy = | ready;
        end
        if (busy && (| eop)) begin
            busy = 1'b0;
        end
    end
    
endmodule
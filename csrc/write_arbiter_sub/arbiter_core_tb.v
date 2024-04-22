module arbiter_core_tb ();
    parameter num_of_ports = 16;

    reg clk, sp0_wrr1, rst;
    reg [num_of_ports-1:0] ready;
    reg [num_of_ports-1:0] eop;
    reg [2:0] priorities [num_of_ports-1:0];
    wire [num_of_ports*3-1:0] priority_in;
    wire [3:0] select;
    wire transfering;

    // packup priorities
    genvar i;
    generate
        for (i = 0; i<num_of_ports; i=i+1) begin
            assign priority_in[(i+1)*3-1:i*3] = priorities[i];
        end
    endgenerate

    arbiter_core arbiter_core_tt (
        .clk                (clk            ),
        .rst                (rst            ),
        .sp0_wrr1           (sp0_wrr1       ),
        .ready              (ready          ),
        .eop                (eop            ),
        .priority_in        (priority_in    ),
        .select             (select         ),
        .transfering        (transfering    )
    );

    integer ii;
    always #1 clk = ~clk;
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
        for (ii = 0; ii<num_of_ports; ii=ii+1) begin
            $dumpvars(0, priorities[ii]);
        end
    end
    integer j;
    initial begin
        clk <= 1; rst <= 0; sp0_wrr1 <= 0;
        ready <= {num_of_ports{1'b0}};
        eop <= {num_of_ports{1'b0}};
        for (j=0; j<num_of_ports; j=j+1) begin
            priorities[j] <= 3'b000;
        end
        #2;
        rst <= 1'b1;
        #2;
        rst <= 1'b0;
        #20;
        for (ii=0; ii<num_of_ports; ii=ii+1) begin
            ready[ii] <= $random;
            priorities[ii] <= {$random}%8;
        end
        #4
        ready[select] <= 1'b0;
        #20;
        eop[select] <= 1'b1;
        #2;
        eop[select] <= 1'b0;
        #10;
        $finish;
    end
    
endmodule
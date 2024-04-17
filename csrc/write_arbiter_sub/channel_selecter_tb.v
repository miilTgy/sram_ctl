module channel_selecter_tb ();
    parameter arbiter_data_width = 256;
    parameter num_of_ports = 16;
    reg clk, rst, enable;
    reg [3:0] select;
    wire [arbiter_data_width-1:0] selected_data_in [num_of_ports-1:0];
    wire [arbiter_data_width-1:0] selected_data_out;
    wire [3:0] enabled;
    integer i;

    reg [(arbiter_data_width*num_of_ports)-1:0] data_in;
    reg [(arbiter_data_width*num_of_ports)-1:0] reg_data_in;

    reg [(num_of_ports*arbiter_data_width)-1:0] k;

    // 压缩data_in
    genvar j;
    generate
        for (j = 0; j < num_of_ports; j = j + 1) begin
            assign selected_data_in[j] = data_in[(j+1)*arbiter_data_width-1:j*arbiter_data_width];
        end
    endgenerate

    channel_selecter channel_selecter_tt (
        .clk                (clk                ),
        .rst                (rst                ),
        .enable             (enable             ),
        .select             (select             ),
        .selected_data_in   (data_in            ),
        .selected_data_out  (selected_data_out  ),
        .enabled            (                   )
    );

    integer ii;
    always #1 clk = ~clk;
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
        for (ii = 0; ii<num_of_ports; ii = ii+1) begin
            $dumpvars(0, selected_data_in[ii]);
        end
    end
    initial begin
        clk <= 1; rst <= 0; enable <= 0; data_in <= 4096'b0;
        #2;
        rst <= 1;
        #2;
        rst <= 0;
        #10;
        for (i=0; i<100; i=i+1) begin
            enable <= 1;
            select <= $random;
            for (k = 0; k<4096; k=k+1) begin
                data_in[k] <= $random;
            end
            #2;
        end
        enable <= 0;
        for (k = 0; k<4096; k=k+1) begin
            data_in[k] <= $random;
        end
        #50;
        $finish;
    end

endmodule

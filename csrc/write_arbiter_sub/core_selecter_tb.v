module core_selecter_tb ();
    //parameters
    parameter num_of_ports = 16;
    parameter arbiter_data_width = 256;
    
    // ports for all
    reg clk, rst;
    wire [3:0] select;

    // ports for core
    reg sp0_wrr1;
    reg [num_of_ports-1:0] ready;
    reg [num_of_ports-1:0] eop;
    wire [num_of_ports*3-1:0] priority_in;
    // wire [3:0] select;
    wire transfering;
    // unpacked priority_in
    reg [2:0] priorities [num_of_ports-1:0];

    //ports for selecter
    reg enable;
    // reg [3:0] select;
    wire [(arbiter_data_width*num_of_ports)-1:0] selected_data_in;
    wire [arbiter_data_width-1:0] selected_data_out;
    wire enabled;
    // unpacked selected_data_in
    reg [arbiter_data_width-1:0] datas [num_of_ports-1:0];

    // 解压缩selected_data_in和priority_in
    genvar j;
    generate
        for (j=0; j<num_of_ports; j=j+1) begin
            assign selected_data_in[(j+1)*arbiter_data_width-1:j*arbiter_data_width] = datas[j];
            assign priority_in[(j+1)*3-1:j*3] = priorities[j];
        end
    endgenerate

    // instance
    arbiter_core arbiter_core_tt1 (
        .clk                    (clk                ),
        .rst                    (rst                ),
        .sp0_wrr1               (sp0_wrr1           ),
        .ready                  (ready              ),
        .eop                    (eop                ),
        .priority_in            (priority_in        ),
        .select                 (select             ),
        .transfering            (transfering        )
    );

    channel_selecter channel_selecter_tt1 (
        .clk                    (clk                ),
        .rst                    (rst                ),
        .enable                 (enable             ),
        .select                 (select             ),
        .selected_data_in       (selected_data_in   ),
        .selected_data_out      (selected_data_out  ),
        .enabled                (enabled            )
    );

    always #1 clk = ~clk;
    integer i;
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
        for (i=0; i<num_of_ports; i=i+1) begin
            $dumpvars(1, datas[i]);
        end
    end
    initial begin
        clk <= 1; rst <= 0; enable <= 0;
        for (i=0; i<num_of_ports; i=i+1) begin
            datas[i] <= 0;
            priorities[i] <= 0;
        end
        #10;
    end

endmodule
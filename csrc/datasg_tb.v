module datasg_tb ();
    // parameters
    parameter num_of_ports = 16;
    parameter sg_data_width = 64;
    parameter sg_address_width = 12;
    parameter sg_des_width = 4;
    parameter sg_priority_width = 3;

    // ports
    reg rst, transfering, busy, clk;
    reg [sg_data_width-1:0] data_in;
    reg [sg_address_width-1:0] address_in;
    reg [num_of_ports-1:0]  eop;
    reg [sg_address_width-1:0] priority_in;
    reg [sg_des_width-1:0] des_port_in;

    wire request;
    wire [sg_priority_width-1:0] wr_priority;
    wire [sg_des_width-1:0] des_port;
    wire [sg_address_width-1:0] address_write;
    wire [sg_data_width-1:0] data_write;

    // instance
    datasg datasg_tt (
        .rst                    (rst),
        .clk                    (clk),
        .transfering            (transfering),
        .busy                   (busy),
        .eop                    (eop),
        .data_in                (data_in),
        .address_in             (address_in),
        .priority_in            (priority_in),
        .des_port_in            (des_port_in),
        .request                (request),
        .wr_priority            (wr_priority),
        .des_port               (des_port),
        .address_write          (address_write),
        .data_write             (data_write)
    );

    integer i;

    // clk
    always #1 clk = ~clk;
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    initial begin
        clk <= 1; rst <= 0; busy <= 0;
        transfering <= 0; data_in <= 0;
        priority_in <= 0; des_port_in <= 0;
        eop <= 0; address_in <= 0;
        #2;
        rst <= 1;
        #2;
        rst <= 0;
        #2;
        busy <= 1;
        priority_in <= 6;
        #2;
        transfering <= 1;
        des_port_in <= 9;
        #2;
        address_in <= $random;
        for (i=0; i<5; i=i+1) begin
            data_in <= {$random, $random};
            if (i == 4) begin
                eop[5] <= 1;
            end
            #2;
        end
        transfering <= 0;
        busy <= 0;
        eop <= 0;
        data_in <= 0;
        address_in <= 0;
        #4;
        $finish;
    end
endmodule
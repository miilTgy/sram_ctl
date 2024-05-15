module cache_manager_zgy_tb ();
    // parameters
    parameter chain_length = 16; // TODO 最后要改4096
    parameter chain_width = 1; // [ ] TODO: chain width
    parameter num_of_ports = 16;
    parameter address_width = 4; // TODO 最后要改12
    parameter des_width = 4;
    parameter priority_width = 3;
    parameter num_of_priorities = 8;

    // ports
    reg clk;
    reg rst;
    reg request;
    reg eop;

    reg [num_of_priorities-1:0] next_data_0;
    reg [num_of_priorities-1:0] next_data_1;
;    reg [num_of_priorities-1:0] next_data_2;
;    reg [num_of_priorities-1:0] next_data_3;
;    reg [num_of_priorities-1:0] next_data_4;
;    reg [num_of_priorities-1:0] next_data_5;
;    reg [num_of_priorities-1:0] next_data_6;
;    reg [num_of_priorities-1:0] next_data_7;
;    reg [num_of_priorities-1:0] next_data_8;
;    reg [num_of_priorities-1:0] next_data_9;
;    reg [num_of_priorities-1:0] next_data_10;
;    reg [num_of_priorities-1:0] next_data_11;
;    reg [num_of_priorities-1:0] next_data_12;
;    reg [num_of_priorities-1:0] next_data_13;
;    reg [num_of_priorities-1:0] next_data_14;
;    reg [num_of_priorities-1:0] next_data_15;

    reg [priority_width-1:0]    priority_from_rd_ar_0;
    reg [priority_width-1:0]    priority_from_rd_ar_1;
    reg [priority_width-1:0]    priority_from_rd_ar_2;
    reg [priority_width-1:0]    priority_from_rd_ar_3;
    reg [priority_width-1:0]    priority_from_rd_ar_4;
    reg [priority_width-1:0]    priority_from_rd_ar_5;
    reg [priority_width-1:0]    priority_from_rd_ar_6;
    reg [priority_width-1:0]    priority_from_rd_ar_7;
    reg [priority_width-1:0]    priority_from_rd_ar_8;
    reg [priority_width-1:0]    priority_from_rd_ar_9;
    reg [priority_width-1:0]    priority_from_rd_ar_10;
    reg [priority_width-1:0]    priority_from_rd_ar_11;
    reg [priority_width-1:0]    priority_from_rd_ar_12;
    reg [priority_width-1:0]    priority_from_rd_ar_13;
    reg [priority_width-1:0]    priority_from_rd_ar_14;
    reg [priority_width-1:0]    priority_from_rd_ar_15;

    reg [priority_width-1:0]    priority_in;
    reg [des_width-1:0]         des_port_in;

    wire [address_width-1:0] address_out;

    // instance
    cache_manager_zgy c_tb (
        .clk                            (clk),
        .rst                            (rst),
        .request                        (request),
        .eop                            (eop),
        .next_data_0                    (next_data_0),
        .next_data_1                    (next_data_1),
        .next_data_2                    (next_data_2),
        .next_data_3                    (next_data_3),
        .next_data_4                    (next_data_4),
        .next_data_5                    (next_data_5),
        .next_data_6                    (next_data_6),
        .next_data_7                    (next_data_7),
        .next_data_8                    (next_data_8),
        .next_data_9                    (next_data_9),
        .next_data_10                    (next_data_10),
        .next_data_11                    (next_data_11),
        .next_data_12                    (next_data_12),
        .next_data_13                    (next_data_13),
        .next_data_14                    (next_data_14),
        .next_data_15                    (next_data_15),

        .priority_from_rd_ar_0           (priority_from_rd_ar_0),
        .priority_from_rd_ar_1           (priority_from_rd_ar_1),
        .priority_from_rd_ar_2           (priority_from_rd_ar_2),
        .priority_from_rd_ar_3           (priority_from_rd_ar_3),
        .priority_from_rd_ar_4           (priority_from_rd_ar_4),
        .priority_from_rd_ar_5           (priority_from_rd_ar_5),
        .priority_from_rd_ar_6           (priority_from_rd_ar_6),
        .priority_from_rd_ar_7           (priority_from_rd_ar_7),
        .priority_from_rd_ar_8           (priority_from_rd_ar_8),
        .priority_from_rd_ar_9           (priority_from_rd_ar_9),
        .priority_from_rd_ar_10          (priority_from_rd_ar_10),
        .priority_from_rd_ar_11          (priority_from_rd_ar_11),
        .priority_from_rd_ar_12          (priority_from_rd_ar_12),
        .priority_from_rd_ar_13          (priority_from_rd_ar_13),
        .priority_from_rd_ar_14          (priority_from_rd_ar_14),
        .priority_from_rd_ar_15          (priority_from_rd_ar_15),

        .priority_in                    (priority_in),
        .des_port_in                    (des_port_in),
        .address_out                    (address_out)
    );

    // clk
    always #1 clk = ~clk;
    integer j, j2;
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
        for (j=0; j<chain_length; j=j+1) begin
            $dumpvars(0, c_tb.next_unused_addr_rd[j]);
        end
    end

    task write_data;
    begin
        request <= 1;
        #10;
        request <= 0;
        // $display("%d", c_tb.wr_ptr0[0]);
        eop <= 1;
        #2;
        eop <= 0;
        #2;
    end
    endtask

    task read_data;
    begin
        #1;
        // 到达时钟下降沿
        next_data_0[0] <= 1;
        priority_from_rd_ar_0 <= 0;
        #1;
        // 到达时钟上升延
        #10;
        #1;
        next_data_0[0] <= 0;
        #2;   
    end
    endtask

    initial begin
        clk <= 1; rst <= 0; request <= 0; eop <= 0;
        des_port_in <= 0; priority_in <= 0;
        next_data_0 <= 0;
        // $display("%d", c_tb.rd_ptr11[0]);
        #2;
        rst <= 1;
        #2;
        rst <= 0;
        #1;
        // c_tb.used_wr[2] <= 1;
        // c_tb.last_one_used_wr[2-1] <= 1;
        // c_tb.next_unused_addr_wr[2-1] <= 4'd3;
        #3;
        write_data;
        priority_in <= 1;
        write_data;
        // priority_in <= 1;
        // write_data;
        #6;
        read_data;
        $display("next unused: %d", c_tb.next_unused_addr_wr[4]);
        #6;
        $finish;
    end

endmodule
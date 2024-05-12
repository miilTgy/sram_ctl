module read_arbiter_tb ();
    // parameters
    parameter num_of_priorities = 8;
    parameter num_of_ports = 16;
    parameter address_width = 12;
    parameter arbiter_data_width = 64;
    parameter wrr_weight_width = 5;
    
    // ports
    reg rst, clk, sp0_wrr1, ready;
    reg [num_of_priorities-1:0] prepared;
    reg [wrr_weight_width-1:0] wrr_weight;
    wire [arbiter_data_width-1:0] rd_data;
    wire rd_sop, rd_vld, rd_eop;
    wire [num_of_priorities-1:0] next_data;
    wire [num_of_priorities-1:0] next_data2;

    reg [arbiter_data_width-1:0] data_read;
    reg last1, last2;
    reg [address_width-1:0] address_to_read1, address_to_read2;
    wire [address_width-1:0] address_read1, address_read2;
    wire rd_request1, rd_request2;
    wire enb;

    // instance
    read_arbiter read_arbiter_tt (
        .rst                        (rst),
        .clk                        (clk),
        .sp0_wrr1                   (sp0_wrr1),
        .ready                      (ready),
        .prepared                   (prepared),
        .wrr_weight                 (wrr_weight),
        .rd_data                    (rd_data),
        .rd_sop                     (rd_sop),
        .rd_vld                     (rd_vld),
        .rd_eop                     (rd_eop),
        .next_data                  (next_data),
        .next_data2                 (next_data2),
        .data_read                  (data_read),
        .last1                      (last1),
        .address_to_read1           (address_to_read1),
        .address_read1              (address_read1),
        .last2                      (last2),
        .address_to_read2           (address_to_read2),
        .address_read2              (address_read2),
        .rd_request1                (rd_request1),
        .rd_request2                (rd_request2),
        .enb                        (enb)
    );

    integer i;
    // clk
    always #1 clk = ~clk;
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    reg tmpvar;
    task ready_go;
        begin
            ready <= 1;
            #2;
            ready <= 0;
            address_to_read2 <= $random;
            #2;
            address_to_read2 <= $random;
            data_read <= {$random, $random};
            #2;
            address_to_read2 <= $random;
            data_read <= {$random, $random};
            #2;
            address_to_read2 <= $random;
            data_read <= {$random, $random};
            #2;
            address_to_read2 <= $random;
            data_read <= {$random, $random};
            #2;
            address_to_read2 <= $random;
            last2 <= 1'b1;
            data_read <= {$random, $random};
            #1;
            // if (tmpvar) begin
            //     prepared[read_arbiter_tt.select_tmp] = 0;
            // end
            #1;
            last2 <= 1'b0;
            data_read <= {$random, $random};
            tmpvar = ~tmpvar;
            #6;
        end
    endtask

    initial begin
        tmpvar <= 0;
        clk <= 1; rst <= 0; sp0_wrr1 <= 1;
        ready <= 0; prepared <= 0;
        data_read <= 0; last1 <= 0;
        address_to_read1 <= 0; wrr_weight <= 5;
        last2 <= 0; address_to_read2 <= 0;
        for (i=0; i<num_of_priorities; i=i+1) begin
            // prepared <= $random;
            prepared[i] <= 1'b1;
        end
        #2;
        rst <= 1;
        #2;
        rst <= 0;
        #6;
        for (i=0; i<32; i=i+1) begin
            ready_go();
        end
        #6;
        $finish;
    end
endmodule

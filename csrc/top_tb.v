module top_tb ();
    
    // parameters
    parameter num_of_ports = 16;
    parameter arbiter_data_width = 64;
    parameter priority_width = 3;
    parameter fifo_data_width = 64;
    parameter fifo_num_of_priority = 8;
    parameter fifo_length = 32;
    parameter des_port_width = 7;
    parameter address_width = 12;


    always #1 clk = ~clk;
    always #16 in_clk = ~in_clk;
    integer iii;
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
        for (iii = 0; iii<num_of_ports; iii=iii+1) begin
            $dumpvars(0, wr_data_unpack[iii]);
        end
    end

    integer i, k, jk;
    initial begin
        clk <= 1; sp0_wrr1 <= 0; rst <= 0;
        in_clk <= 1; wr_sop <= 0; wr_eop <= 0;
        wr_vld <= 0; address_in <= 0;
        for (i=0; i<num_of_ports; i=i+1) begin
            wr_data_unpack[i] <= 0;
        end
        #2;
        rst <= 1;
        #2;
        rst <= 0;
        #28;
        wr_sop <= {(num_of_ports){1'b1}}; // 这是第32秒
        #32;
        wr_sop <= 0;
        wr_vld <= {(num_of_ports){1'b1}};
        for (i=0; i<num_of_ports; i=i+1) begin
            for (k=4; k<14; k=k+1) begin
                wr_data_unpack[i][k] = $random;
            end
            wr_data_unpack[i][13:7] = 7'd4;
        end
        for (i=0; i<num_of_ports; i=i+1) begin
            wr_data_unpack[i][3:0] = i[3:0];
        end
        #32;
        for (jk=0; jk<4; jk=jk+1) begin
            for (i=0; i<num_of_ports; i=i+1) begin
                for (k=0; k<fifo_data_width; k=k+1) begin
                    wr_data_unpack[i][k] <= $random;
                end
            end
            #32;
        end
        for (i=0; i<num_of_ports; i=i+1) begin
            wr_data_unpack[i] <= 0;
        end
        wr_eop <= {(num_of_ports){1'b1}};
        #32;
        wr_eop <= 0;
        wr_vld <= 0;
        #1280;
        $finish;
    end

endmodule
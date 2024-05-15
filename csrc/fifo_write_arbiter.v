module fifo_write_arbiter ();
    
    // parameters
    parameter num_of_ports = 16;
    parameter arbiter_data_width = 64;
    parameter priority_width = 3;
    parameter fifo_data_width = 64;
    parameter fifo_num_of_priority = 8;
    parameter fifo_length = 32;
    parameter des_port_width = 7;
    parameter address_width = 12;

    // ports for fifo
    reg rst;
    reg in_clk, clk;
    reg [num_of_ports-1:0] wr_sop, wr_eop, wr_vld;
    reg [fifo_data_width-1:0] wr_data_unpack [num_of_ports-1:0]; // packed
    wire [fifo_data_width*num_of_ports-1:0] wr_data;
    wire [fifo_data_width*num_of_ports-1:0] out_data;

    // ports for all
    wire [num_of_ports-1:0] next_data;
    wire [num_of_ports-1:0] ready;
    wire [num_of_ports-1:0] overflow;
    wire [num_of_ports-1:0] sop, eop, vld;
    wire [fifo_data_width-1:0] between_data_unpack [num_of_ports-1:0]; // 接到fifo的out_data

    // ports for write_arbiter
    reg sp0_wrr1;
    wire busy;
    wire [arbiter_data_width-1:0] data_out; // packed
    wire [fifo_data_width*num_of_ports-1:0] data_in_p; // packed
    wire [3:0] arbiter_des_port_out, pre_des_port_out;
    wire [3:0] pre_selected;
    wire [priority_width-1:0] priority_out;
    wire [des_port_width-1:0] ab_pack_length_out, pre_pack_length_out;
    reg  [address_width-1:0] address_in;


    // unpack ports
    genvar j;
    generate
        for (j=0; j<num_of_ports; j=j+1) begin
            assign wr_data[(j+1)*fifo_data_width-1:j*fifo_data_width] = wr_data_unpack[j];
            assign between_data_unpack[j] = out_data[(j+1)*fifo_data_width-1:j*fifo_data_width];
            assign data_in_p[(j+1)*fifo_data_width-1:j*fifo_data_width] = between_data_unpack[j];
        end
    endgenerate

    // instance
    fifo fifo_tt[num_of_ports-1:0] (
        .rst                        (rst),
        .in_clk                     (in_clk),
        .clk                        (clk),
        .next_data                  (next_data),
        .wr_sop                     (wr_sop),
        .wr_eop                     (wr_eop),
        .wr_vld                     (wr_vld),
        .wr_data                    (wr_data),
        .ready                      (ready),
        .overflow                   (overflow),
        .sop                        (sop),
        .eop                        (eop),
        .vld                        (vld),
        .out_data                   (out_data)
    );

    write_arbiter write_arbiter_tt1 (
        .rst                        (rst),
        .clk                        (clk),
        .sp0_wrr1                   (sp0_wrr1),
        .ready                      (ready),
        .sop                        (sop),
        .eop                        (eop),
        .vld                        (vld),
        .data_in_p                  (data_in_p),
        .busy                       (busy),
        .selected_data_out          (data_out),
        .arbiter_des_port_out       (arbiter_des_port_out),
        .ab_pack_length_out         (ab_pack_length_out),
        .next_data                  (next_data),
        .pre_selected               (pre_selected),
        .pre_des_port_out           (pre_des_port_out),
        .pre_pack_length_out        (pre_pack_length_out),
        .transfering                (transfering),
        .priority_out               (priority_out)
    );

    datasg datasg_ttt (
        .rst                        (rst),
        .clk                        (clk),
        .transfering                (transfering),
        .busy                       (busy),
        .eop                        (eop),
        .data_in                    (data_out),
        .address_in                 (address_in),
        .priority_in                (priority_out),
        .des_port_in                (pre_des_port_out),
        .pack_length_in             (pre_pack_length_out)
    );

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
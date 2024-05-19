// `define num_of_ports 16
module read_arbiter #(
    // parameters
    parameter num_of_priorities = 8,
    parameter priority_width = 3,
    parameter num_of_ports = 16,
    parameter address_width = 17,
    parameter arbiter_data_width = 64,
    parameter wrr_weight_width = 5
) (
    // ports
    input                                                       rst,
    input                                                       clk,
    input                                                       sp0_wrr1,
    input                                                       ready,    // 由外部驱动，拉高代表按照调度顺序取出数据
    input           [num_of_priorities-1:0]                     prepared, // 每一个prepared代表相应的优先级存有可被读出的数据
    input           [wrr_weight_width-1:0]                      wrr_weight,

    output  wire    [(arbiter_data_width)-1:0]                  rd_data,
    output  reg                                                 rd_sop,
    output  reg                                                 rd_vld,
    output  reg                                                 rd_eop,
    output  reg     [num_of_priorities-1:0]                     next_data, // 告诉manager提供相应优先级的数据的下一位地址
    output  reg     [num_of_priorities-1:0]                     next_data2, // 用这个
    output  reg     [priority_width-1:0]                        priority_to_man,

    input           [(arbiter_data_width)-1:0]                  data_read, 
    input                                                       last1,
    input           [address_width-1:0]                         address_to_read1,
    output  wire    [address_width-1:0]                         address_read1,
    input                                                       last2,
    input           [address_width-1:0]                         address_to_read2, // 用这个
    output  wire    [address_width-1:0]                         address_read2,
    output  reg                                                 rd_request1,
    output  wire                                                rd_request2, // 用这个

    output  reg                                                 enb
);

    reg useless, useless2, last2_delay;
    reg [wrr_weight_width-1:0] wrr_count;
    reg [priority_width-1:0] priority_offset;

    assign rd_data = data_read;
    assign address_read1 = address_to_read1;
    assign address_read2 = address_to_read2;
    assign rd_request2 = ready;

    // 这里产生输出时序
    always @(posedge clk ) begin
        if (rst) begin
            rd_sop <= 0; rd_vld <= 0; rd_eop <= 0;
            rd_request1 <= 0; useless <= 0;
            useless2 <= 0; next_data <= 0;
            last2_delay <= 0;
        end else begin
            if (ready && (!rd_sop) && (!rd_vld)) begin
                // ready拉高后第一拍进来这里
                rd_sop <= 1'b1; // 产生rd_sop信号
                rd_request1 <= 1'b1; // 跟manager请求地址
            end else if (rd_sop && (!rd_vld)) begin
                // ready拉高后第二拍进来这里
                // 也是rd_sop拉高后第一拍
                // 也是开始传数据的地方
                rd_sop <= 1'b0;
                rd_vld <= 1'b1;
            end else if (rd_vld && last2) begin
                // 倒数据的最后一拍进来这里
                last2_delay <= 1'b1;
            end else if (last2_delay) begin
                // eop从这里产生，也是输出时序的最后一拍
                rd_eop <= 1'b1;
                rd_vld <= 1'b0;
                rd_request1 <= 1'b0;
                last2_delay <= 1'b0;
            end else if (rd_eop) begin
                rd_eop <= 1'b0;
            end else begin
                useless <= useless;
            end
        end
    end

    // 产生enb信号
    always @(posedge clk ) begin
        if (rst) begin
            enb <= 1'b0;
        end
        if (ready && (!rd_sop) && (!rd_vld)) begin
            // ready进来后的第一拍
            enb <= 1'b1;
        end else if (last2) begin
            enb <= 1'b0;
        end else begin
            useless2 <= useless2;
        end
    end

    // 调度这里
    integer j;
    reg arbi_lock, biggest_lock;
    reg [priority_width-1:0] prio_now;
    reg [priority_width-1:0] select_tmp;
    reg [priority_width-1:0] wrr_now_biggest;
    reg [priority_width-1:0] smallest_select_tmp;

    always @(negedge clk ) begin
        if (rst) begin
            next_data2 = 0;
            wrr_count = 0; priority_offset = 0;
        end
        if (sp0_wrr1) begin
            // wrr here
            if (ready && (|prepared)) begin
                if (!prepared[select_tmp]) begin // 代表上一次读的端口已经被读完了，重新开启wrr仲裁
                    // $display("last select out");
                    priority_offset = 0;
                    wrr_count = 0;
                end
                arbi_lock = 1'b0;
                prio_now = 0;
                select_tmp = 0;
                biggest_lock = 0;
                priority_to_man = 0;
                // $display("enter here 1");
                for (j=(num_of_priorities-1); j>=0; j=j-1) begin // [.] Change it from sp to wrr use offset
                    if (prepared[j] && (!arbi_lock) && (priority_offset == prio_now)) begin
                        // $display("got priority %d", j);
                        arbi_lock = 1'b1;
                        select_tmp = j[priority_width-1:0];
                    end else if (prepared[j] && (!arbi_lock) && (priority_offset != prio_now)) begin
                        // [x] 这里不是do nothing了，要改一下。
                        // wrr_now_biggest = j;
                        prio_now = prio_now + 1;
                    end
                    if (prepared[j] && (!biggest_lock)) begin
                        biggest_lock = 1'b1;
                        wrr_now_biggest = j[priority_width-1:0];
                    end
                end
                if (select_tmp < smallest_select_tmp) begin
                    select_tmp = wrr_now_biggest;
                    priority_offset = 0;
                end
                if ((wrr_count+1)<wrr_weight) begin
                    // if (wrr_count == 0) begin
                    // end
                    // $display("heer 2");
                    wrr_count = wrr_count + 1;
                end else begin
                    // $display("heer 3");
                    wrr_count = 0; 
                    priority_offset = priority_offset + 1;
                    // if (priority_offset) begin
                    
                    // end
                end
                next_data2[select_tmp] = 1'b1;
                priority_to_man = select_tmp;
            end
        end else begin
            //sp here
            if (ready && (|prepared)) begin
                select_tmp = 0;
                for (j=0; j<num_of_priorities; j=j+1) begin
                    if (prepared[j]) begin
                        select_tmp = j[priority_width-1:0];
                    end else begin
                        next_data2 = next_data2;
                    end
                end
                next_data2[select_tmp] = 1'b1;
                priority_to_man = select_tmp;
            end
        end
        if (last2) begin
            next_data2 = 1'b0;
            priority_to_man = 0;
        end else begin
            next_data2 = next_data2;
            priority_to_man = priority_to_man;
        end
    end

    always @(prepared ) begin
        for (j=(num_of_priorities-1); j>=0; j=j-1) begin
            if (prepared[j]) begin
                smallest_select_tmp = j[priority_width-1:0];
            end else begin
                next_data2 = next_data2;
                priority_to_man = priority_to_man;
            end
        end
    end
    
endmodule

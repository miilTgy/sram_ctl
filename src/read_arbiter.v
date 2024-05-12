// `define num_of_ports 16
module read_arbiter #(
    // parameters
    parameter num_of_priorities = 8,
    parameter priority_width = 3,
    parameter num_of_ports = 16,
    parameter address_width = 12,
    parameter arbiter_data_width = 64
) (
    // ports
    input                                                       rst,
    input                                                       clk,
    input                                                       sp0_wrr1,
    input                                                       ready,    // 由外部驱动，拉高代表按照调度顺序取出数据
    input           [num_of_priorities-1:0]                     prepared, // 每一个prepared代表相应的优先级存有可被读出的数据

    output  wire    [(arbiter_data_width)-1:0]                  rd_data,
    output  reg                                                 rd_sop,
    output  reg                                                 rd_vld,
    output  reg                                                 rd_eop,
    output  reg     [num_of_priorities-1:0]                     next_data, // 告诉manager提供相应优先级的数据的下一位地址
    output  reg     [num_of_priorities-1:0]                     next_data2, // 用这个

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

    assign rd_data = data_read;
    assign address_read1 = address_to_read1;
    assign address_read2 = address_to_read2;
    assign rd_request2 = ready;

    // 这里产生输出时序
    always @(posedge clk ) begin
        if (rst) begin
            rd_sop <= 0; rd_vld <= 0; rd_eop <= 0;
            rd_request1 <= 0; useless <= 0;
            useless2 <= 0; enb <= 0; next_data <= 0;
            last2_delay <= 0; next_data2 <= 0;
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
    reg [priority_width-1:0] wrr_select_tmp, sp_select_tmp;
    always @(negedge clk ) begin
        if (sp0_wrr1) begin
            // wrr here
        end else begin
            //sp here
            if (ready) begin
                for (j=0; j<num_of_priorities; j=j+1) begin
                    if (prepared[j]) begin
                        sp_select_tmp = j;
                    end else begin
                        next_data2 = next_data2;
                    end
                end
                next_data2[sp_select_tmp] = 1'b1;
            end
        end
        if (last2) begin
            next_data2 = 1'b0;
        end else begin
            next_data2 = next_data2;
        end
    end
    
endmodule

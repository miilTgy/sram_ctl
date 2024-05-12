// `define num_of_ports 16
module read_arbiter #(
    // parameters
    parameter num_of_priorities = 8,
    parameter num_of_ports = 16,
    parameter address_width = 12,
    parameter arbiter_data_width = 256
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

    // input           [num_of_ports-1:0]                          rd_address_offset,
    // output          [num_of_ports-1:0]                          rd_priority,
    input           [(arbiter_data_width)-1:0]                  data_read, 
    input                                                       last1,
    input           [address_width-1:0]                         address_to_read1,
    output  wire    [address_width-1:0]                         address_read1,
    input                                                       last2,
    input           [address_width-1:0]                         address_to_read2,
    output  wire    [address_width-1:0]                         address_read2,
    output  reg                                                 rd_request1,
    output  wire                                                rd_request2
);

    assign rd_data = data_read;
    assign address_read1 = address_to_read1;
    assign address_read2 = address_to_read2;
    assign rd_request2 = ready;

    always @(posedge clk ) begin
        if (rst) begin
            rd_data <= {arbiter_data_width{1'b0}};
            rd_sop <= 0; rd_vld <= 0; rd_eop <= 0;
            address_read1 <= 0; rd_request1 <= 0;
        end else begin
            case (sp0_wrr1)
                1'b0: begin // *SP严格优先级
                    if (ready || (!rd_sop)) begin
                        // ready拉高后第一拍进来这里
                        rd_sop <= 1; // 产生rd_sop信号
                        rd_request1 <= 1; // 跟manager请求地址
                        address_read2 <= address_to_read2; // 传地址
                    end else if (rd_sop) begin
                        // ready拉高后第二拍进来这里
                        // 也是rd_sop拉高后第一拍
                        // 也是开始传数据的地方
                        rd_sop <= 0;
                        rd_vld <= 1;
                        address_read1 <= address_to_read1; // 传地址
                    end
                    // [ ] sp here
                end
                1'b1: begin // *WRR加权轮询调度
                    // [ ] wrr here
                end
                default: data_out <= data_out;
            endcase
        end
        rd_data <= data_out[rd_port];
    end
    
endmodule

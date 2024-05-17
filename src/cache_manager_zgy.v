// 还差request信号没做
`define DES_WID 4
module cache_manager_zgy #(
    // parameters
    parameter chain_length = 16, // TODO 最后要改：4096
    parameter chain_ptr_width = 4,
    parameter num_of_ports = 16, //
    parameter port_ptr_width = 4,
    parameter num_of_priorities = 8, //
    parameter priority_ptr_width = 3,
    parameter address_width = 4, // TODO 最后要改：12
    parameter des_width = 4,
    parameter priority_width = 3,
    parameter chain_width = 1+1+address_width+1 // [.] TODO: chain width
) (
    // ports
    input                                   clk,
    input                                   rst,
    input                                   request,
    input                                   eop,

    input           [num_of_priorities-1:0] next_data_0,
    input           [num_of_priorities-1:0] next_data_1,
    input           [num_of_priorities-1:0] next_data_2,
    input           [num_of_priorities-1:0] next_data_3,
    input           [num_of_priorities-1:0] next_data_4,
    input           [num_of_priorities-1:0] next_data_5,
    input           [num_of_priorities-1:0] next_data_6,
    input           [num_of_priorities-1:0] next_data_7,
    input           [num_of_priorities-1:0] next_data_8,
    input           [num_of_priorities-1:0] next_data_9,
    input           [num_of_priorities-1:0] next_data_10,
    input           [num_of_priorities-1:0] next_data_11,
    input           [num_of_priorities-1:0] next_data_12,
    input           [num_of_priorities-1:0] next_data_13,
    input           [num_of_priorities-1:0] next_data_14,
    input           [num_of_priorities-1:0] next_data_15,

    input           [priority_width-1:0]    priority_from_rd_ar_0,
    input           [priority_width-1:0]    priority_from_rd_ar_1,
    input           [priority_width-1:0]    priority_from_rd_ar_2,
    input           [priority_width-1:0]    priority_from_rd_ar_3,
    input           [priority_width-1:0]    priority_from_rd_ar_4,
    input           [priority_width-1:0]    priority_from_rd_ar_5,
    input           [priority_width-1:0]    priority_from_rd_ar_6,
    input           [priority_width-1:0]    priority_from_rd_ar_7,
    input           [priority_width-1:0]    priority_from_rd_ar_8,
    input           [priority_width-1:0]    priority_from_rd_ar_9,
    input           [priority_width-1:0]    priority_from_rd_ar_10,
    input           [priority_width-1:0]    priority_from_rd_ar_11,
    input           [priority_width-1:0]    priority_from_rd_ar_12,
    input           [priority_width-1:0]    priority_from_rd_ar_13,
    input           [priority_width-1:0]    priority_from_rd_ar_14,
    input           [priority_width-1:0]    priority_from_rd_ar_15,


    input           [priority_width-1:0]    priority_in,
    input           [des_width-1:0]         des_port_in,
    output  reg                             last, // 用于读出时指定最后一帧地址
    output  reg     [address_width-1:0]     address_out,
    output  reg     [address_width-1:0]     address_to_read

);
    reg nothing;
    // pointers
    reg [address_width-1:0] first_addr; // 永远指向第一个空闲格子，也指向当前格子
    reg [address_width-1:0] last_write_addr; // 存上一个写入数据的地址
    reg [address_width-1:0] last_read_addr; // 存上一个读出数据的地址
    reg lock_first_read_addr; // 用于从第3帧锁住first_read_addr
    reg enable_first_read_addr; // 用于从第2帧开始记录第一帧输出的地址
    reg [address_width-1:0] first_read_addr; // 用于读出第一帧时保存第一帧的地址

    // flags per chain_block
    // [x] all "*_rd" flags ignore
    reg [chain_length-1:0] used_wr;
    wire [chain_length-1:0] used_rd; // 1本格占用，0本格空闲
    reg [chain_length-1:0] last_one_used_wr;
    wire [chain_length-1:0] last_one_used_rd; // 1下格占用，0下格空闲
    reg [address_width-1:0] next_unused_addr_wr [chain_length-1:0];
    wire [address_width-1:0] next_unused_addr_rd [chain_length-1:0]; // 存下一个空闲格的地址
    reg [chain_length-1:0] last_wr;
    wire [chain_length-1:0] last_rd;
    
    // chain
    wire [chain_width-1:0] chain [chain_length-1:0];
    // 0位：            used
    // 1位：            last_one_used
    // 2-13位：         next_unused_addr

    // port fifo and its ptr, 16 channel in total
    // useage addr_fifo_(port)[priority][addr][位]
    // 最高位(addr_fifo_n[prio][rwptr][address_width])为1表示此为eop
    reg [address_width-1:0] addr_fifo_0 [num_of_priorities-1:0][chain_length-1:0];
    reg [address_width-1:0] addr_fifo_1 [num_of_priorities-1:0][chain_length-1:0];
    reg [address_width-1:0] addr_fifo_2 [num_of_priorities-1:0][chain_length-1:0];
    reg [address_width-1:0] addr_fifo_3 [num_of_priorities-1:0][chain_length-1:0];
    reg [address_width-1:0] addr_fifo_4 [num_of_priorities-1:0][chain_length-1:0];
    reg [address_width-1:0] addr_fifo_5 [num_of_priorities-1:0][chain_length-1:0];
    reg [address_width-1:0] addr_fifo_6 [num_of_priorities-1:0][chain_length-1:0];
    reg [address_width-1:0] addr_fifo_7 [num_of_priorities-1:0][chain_length-1:0];
    reg [address_width-1:0] addr_fifo_8 [num_of_priorities-1:0][chain_length-1:0];
    reg [address_width-1:0] addr_fifo_9 [num_of_priorities-1:0][chain_length-1:0];
    reg [address_width-1:0] addr_fifo_10 [num_of_priorities-1:0][chain_length-1:0];
    reg [address_width-1:0] addr_fifo_11 [num_of_priorities-1:0][chain_length-1:0];
    reg [address_width-1:0] addr_fifo_12 [num_of_priorities-1:0][chain_length-1:0];
    reg [address_width-1:0] addr_fifo_13 [num_of_priorities-1:0][chain_length-1:0];
    reg [address_width-1:0] addr_fifo_14 [num_of_priorities-1:0][chain_length-1:0];
    reg [address_width-1:0] addr_fifo_15 [num_of_priorities-1:0][chain_length-1:0];
        // its ptrs
    reg [address_width-1:0] rd_ptr0[num_of_priorities-1:0];
    reg [address_width-1:0] rd_ptr1[num_of_priorities-1:0];
    reg [address_width-1:0] rd_ptr2[num_of_priorities-1:0];
    reg [address_width-1:0] rd_ptr3[num_of_priorities-1:0];
    reg [address_width-1:0] rd_ptr4[num_of_priorities-1:0];
    reg [address_width-1:0] rd_ptr5[num_of_priorities-1:0];
    reg [address_width-1:0] rd_ptr6[num_of_priorities-1:0];
    reg [address_width-1:0] rd_ptr7[num_of_priorities-1:0];
    reg [address_width-1:0] rd_ptr8[num_of_priorities-1:0];
    reg [address_width-1:0] rd_ptr9[num_of_priorities-1:0];
    reg [address_width-1:0] rd_ptr10[num_of_priorities-1:0];
    reg [address_width-1:0] rd_ptr11[num_of_priorities-1:0];
    reg [address_width-1:0] rd_ptr12[num_of_priorities-1:0];
    reg [address_width-1:0] rd_ptr13[num_of_priorities-1:0];
    reg [address_width-1:0] rd_ptr14[num_of_priorities-1:0];
    reg [address_width-1:0] rd_ptr15[num_of_priorities-1:0];

    reg [address_width-1:0] wr_ptr0[num_of_priorities-1:0];
    reg [address_width-1:0] wr_ptr1[num_of_priorities-1:0];
    reg [address_width-1:0] wr_ptr2[num_of_priorities-1:0];
    reg [address_width-1:0] wr_ptr3[num_of_priorities-1:0];
    reg [address_width-1:0] wr_ptr4[num_of_priorities-1:0];
    reg [address_width-1:0] wr_ptr5[num_of_priorities-1:0];
    reg [address_width-1:0] wr_ptr6[num_of_priorities-1:0];
    reg [address_width-1:0] wr_ptr7[num_of_priorities-1:0];
    reg [address_width-1:0] wr_ptr8[num_of_priorities-1:0];
    reg [address_width-1:0] wr_ptr9[num_of_priorities-1:0];
    reg [address_width-1:0] wr_ptr10[num_of_priorities-1:0];
    reg [address_width-1:0] wr_ptr11[num_of_priorities-1:0];
    reg [address_width-1:0] wr_ptr12[num_of_priorities-1:0];
    reg [address_width-1:0] wr_ptr13[num_of_priorities-1:0];
    reg [address_width-1:0] wr_ptr14[num_of_priorities-1:0];
    reg [address_width-1:0] wr_ptr15[num_of_priorities-1:0];

    // bind flags to chain
    genvar b;
    for (b = 0; b<chain_length; b=b+1) begin
        // 第1位，1本格占用，0本格空闲
        assign chain[b][0] = used_wr[b]; 
        // 第2位，1下格占用，0下格空闲
        assign chain[b][1] = last_one_used_wr[b];
        // 第3位，代表是否为一个last信号
        assign chain[b][3] = last_wr;
        // 第3～(2+address_width-1)位，存下一个空闲格的地址
        assign chain[b][(3+address_width-1):3] = next_unused_addr_wr[b];
    end

    integer j, j2, j3;
    always @(posedge clk ) begin
        if (rst) begin
            // reset
            nothing <= 0;
            first_addr <= 0;
            last_write_addr <= 0;
            address_out <= 0;
            address_to_read <= 0;
            last <= 0;
            first_read_addr <= 0;
            lock_first_read_addr <= 0;
            enable_first_read_addr <= 0;
            for (j=0; j<chain_length; j=j+1) begin
                used_wr[j] <= 0;
                last_one_used_wr[j] <= 0;
                last_wr[j] <= 0;
                // next_unused_addr_wr[j] <= 0; // TODO 有点问题这里
                next_unused_addr_wr[j] <= j+1;
            end
            for (j2=0; j2<num_of_priorities; j2=j2+1) begin
                rd_ptr0[j2] <= 0; wr_ptr0[j2] <= 0;
                rd_ptr1[j2] <= 0; wr_ptr1[j2] <= 0;
                rd_ptr2[j2] <= 0; wr_ptr2[j2] <= 0;
                rd_ptr3[j2] <= 0; wr_ptr3[j2] <= 0;
                rd_ptr4[j2] <= 0; wr_ptr4[j2] <= 0;
                rd_ptr5[j2] <= 0; wr_ptr5[j2] <= 0;
                rd_ptr6[j2] <= 0; wr_ptr6[j2] <= 0;
                rd_ptr7[j2] <= 0; wr_ptr7[j2] <= 0;
                rd_ptr8[j2] <= 0; wr_ptr8[j2] <= 0;
                rd_ptr9[j2] <= 0; wr_ptr9[j2] <= 0;
                rd_ptr10[j2] <= 0; wr_ptr10[j2] <= 0;
                rd_ptr11[j2] <= 0; wr_ptr11[j2] <= 0;
                rd_ptr12[j2] <= 0; wr_ptr12[j2] <= 0;
                rd_ptr13[j2] <= 0; wr_ptr13[j2] <= 0;
                rd_ptr14[j2] <= 0; wr_ptr14[j2] <= 0;
                rd_ptr15[j2] <= 0; wr_ptr15[j2] <= 0;
            end
        end else begin
            // [.] chain management
            if (request && (!eop)) begin // 有写入请求，且不是最后一拍，返回地址
                // 请求写入
                address_out <= first_addr; // 将(本格地址)输出
                last_write_addr <= first_addr; // 将(本格地址)保存为(上一次存的地址)
                used_wr[first_addr] <= 1; // 将本格标记为used
                case (des_port_in) // useage addr_fifo_(port)[priority][addr][位]
                // 将将要存入sram的地址同步写入addr_fifo_n[prio][wr指向的地址]中。
                    `DES_WID'd0: begin 
                                    wr_ptr0[priority_in] <= wr_ptr0[priority_in] + 1;
                                    addr_fifo_0[priority_in][wr_ptr0[priority_in]] <= {first_addr};
                                 end
                    `DES_WID'd1: begin
                                    wr_ptr1[priority_in] <= wr_ptr1[priority_in] + 1;
                                    addr_fifo_1[priority_in][wr_ptr1[priority_in]] <= {first_addr};
                                 end
                    `DES_WID'd2: begin
                                    wr_ptr2[priority_in] <= wr_ptr2[priority_in] + 1;
                                    addr_fifo_2[priority_in][wr_ptr2[priority_in]] <= {first_addr};
                                 end
                    `DES_WID'd3: begin
                                    wr_ptr3[priority_in] <= wr_ptr3[priority_in] + 1;
                                    addr_fifo_3[priority_in][wr_ptr3[priority_in]] <= {first_addr};
                                 end
                    `DES_WID'd4: begin
                                    wr_ptr4[priority_in] <= wr_ptr4[priority_in] + 1;
                                    addr_fifo_4[priority_in][wr_ptr4[priority_in]] <= {first_addr};
                                 end
                    `DES_WID'd5: begin
                                    wr_ptr5[priority_in] <= wr_ptr5[priority_in] + 1;
                                    addr_fifo_5[priority_in][wr_ptr5[priority_in]] <= {first_addr};
                                 end
                    `DES_WID'd6: begin
                                    wr_ptr6[priority_in] <= wr_ptr6[priority_in] + 1;
                                    addr_fifo_6[priority_in][wr_ptr6[priority_in]] <= {first_addr};
                                 end
                    `DES_WID'd7: begin
                                    wr_ptr7[priority_in] <= wr_ptr7[priority_in] + 1;
                                    addr_fifo_7[priority_in][wr_ptr7[priority_in]] <= {first_addr};
                                 end
                    `DES_WID'd8: begin
                                    wr_ptr8[priority_in] <= wr_ptr8[priority_in] + 1;
                                    addr_fifo_8[priority_in][wr_ptr8[priority_in]] <= {first_addr};
                                 end
                    `DES_WID'd9: begin
                                    wr_ptr9[priority_in] <= wr_ptr9[priority_in] + 1;
                                    addr_fifo_9[priority_in][wr_ptr9[priority_in]] <= {first_addr};
                                 end
                    `DES_WID'd10: begin
                                    wr_ptr10[priority_in] <= wr_ptr10[priority_in] + 1;
                                    addr_fifo_10[priority_in][wr_ptr10[priority_in]] <= {first_addr};
                                 end
                    `DES_WID'd11: begin
                                    wr_ptr11[priority_in] <= wr_ptr11[priority_in] + 1;
                                    addr_fifo_11[priority_in][wr_ptr11[priority_in]] <= {first_addr};
                                 end
                    `DES_WID'd12: begin
                                    wr_ptr12[priority_in] <= wr_ptr12[priority_in] + 1;
                                    addr_fifo_12[priority_in][wr_ptr12[priority_in]] <= {first_addr};
                                 end
                    `DES_WID'd13: begin
                                    wr_ptr13[priority_in] <= wr_ptr13[priority_in] + 1;
                                    addr_fifo_13[priority_in][wr_ptr13[priority_in]] <= {first_addr};
                                 end
                    `DES_WID'd14: begin
                                    wr_ptr14[priority_in] <= wr_ptr14[priority_in] + 1;
                                    addr_fifo_14[priority_in][wr_ptr14[priority_in]] <= {first_addr};
                                 end
                    `DES_WID'd15: begin
                                    wr_ptr15[priority_in] <= wr_ptr15[priority_in] + 1;
                                    addr_fifo_15[priority_in][wr_ptr15[priority_in]] <= {first_addr};
                                 end
                    default: begin nothing <= nothing; end
                endcase
                if (used_wr[first_addr+1]) begin
                    // [ ] 如果下一格不是空闲(下一格被占用)
                    first_addr <= next_unused_addr_wr[first_addr]; // 将本格中存放的下一个空闲地址给到first_addr指针
                end else begin
                    // 如果下一格是空闲地址，直接设成下一格
                    first_addr <= first_addr + 1;
                end
            end else if (eop) begin // 写入请求的最后一拍
                // 这个时候不放地址，主要做收尾工作。
                last_wr[last_write_addr] <= 1; // 将上一次保存的格标记为末拍数据
            end
            // 读出部分
            if ((|next_data_0)) begin // 如果port有写入请求且fifo中有数据可读
                $display("priority: %d", priority_from_rd_ar_0);
                $display("rd_ptr: %d; addr: %d", rd_ptr0[priority_from_rd_ar_0], addr_fifo_0[priority_from_rd_ar_0][rd_ptr0[priority_from_rd_ar_0]]);
                enable_first_read_addr <= 1'b1;
                if (enable_first_read_addr & (!lock_first_read_addr)) begin //保存第一个读出的地址
                    first_read_addr <= address_to_read;
                    lock_first_read_addr <= 1'b1;
                    enable_first_read_addr <= 1'b0;
                end
                address_to_read <= addr_fifo_0[priority_from_rd_ar_0][rd_ptr0[priority_from_rd_ar_0]]; // 输出fifo中存的当前帧地址
                last <= last_wr[addr_fifo_0[priority_from_rd_ar_0][rd_ptr0[priority_from_rd_ar_0]]]; // 若为last帧，last的输出会高，否则低
                rd_ptr0[priority_from_rd_ar_0] <= rd_ptr0[priority_from_rd_ar_0] + 1; // fifo读指针，相应优先级的rd_ptr自增1
                used_wr[addr_fifo_0[priority_from_rd_ar_0][rd_ptr0[priority_from_rd_ar_0]]] <= 0; // 相应地址的chain中used标记为0
                last_wr[addr_fifo_0[priority_from_rd_ar_0][rd_ptr0[priority_from_rd_ar_0]]] <= 1'b0; // 最后一帧标志拉低
                // next_unused_addr设成下一个格子
                next_unused_addr_wr[addr_fifo_0[priority_from_rd_ar_0][rd_ptr0[priority_from_rd_ar_0]]] <= (addr_fifo_0[priority_from_rd_ar_0][rd_ptr0[priority_from_rd_ar_0]] + 1);
                last_read_addr <= addr_fifo_0[priority_from_rd_ar_0][rd_ptr0[priority_from_rd_ar_0]]; // 储存上一个读出数据的地址
            end // TODO 剩下15个情况 else
            if (last) begin // 读出最后一帧之后
                last <= 1'b0; //last 拉低
                // 最后一帧还需要啥操作一时间想不起来
                // 还要更新first_addr为刚刚读出来的第一帧的地址
                // 更新first_addr前需要判断：first_read_addr是否在first_addr前面，是的话才更新first_addr
                lock_first_read_addr <= 1'b0;
                next_unused_addr_wr[last_read_addr] <= first_addr;
                if (first_read_addr < first_addr) begin
                    first_addr <= first_read_addr;
                end else begin
                    first_addr <= first_addr;
                end
            end
        end
    end

endmodule
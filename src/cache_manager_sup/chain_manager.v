//用于记录内存空间的链表，寻找内存可用空间和内存回收
//author: Dreams Zhou

module chain_manager
#(
    parameter units = 512, //链表单元数量,sram为4096*8Bytes，数据包最小为64Bytes
    parameter next = 48, //[48:37]为next
    parameter prev = 36, //[36:25]为prev
    parameter state = 24,//[24]为state
    parameter size = 23, //[23:12]为size
    parameter sa = 11, //[11:0]为start_address

    //端口优先级对应编号
    parameter q0 = 0, //端口0为 [q0 +: 1] ～ [q0 +: 8]，以此类推 
    parameter q1 = 8, //这样一来端口N的优先级M队列就是queue[N*8+M]，很文明
    parameter q2 = 16,
    parameter q3 = 24,
    parameter q4 = 32,
    parameter q5 = 40,
    parameter q6 = 48,
    parameter q7 = 56,
    parameter q8 = 64,
    parameter q9 = 72,
    parameter q10 = 80,
    parameter q11 = 88,
    parameter q12 = 96,
    parameter q13 = 104,
    parameter q14 = 112,
    parameter q15 = 120
)
(
    input rst,
    input clk,

    //package_input_related_declaration

    input wea, //write_enable
    input [7:0] w_size, //写入包长度
    input [2:0] priority, //该数据包的优先级，0~7
    input [3:0] dest_port, //该数据包的目标端口,0~15
    output reg [11:0] write_address = 0, //写入地址
    output reg writing = 0, //正在传输写入地址时拉高

    //package_output_related_declaration

    //port_n_addr为输出地址线； port_n_priority为需求优先级； port_n_rea为n端口读出请求； port_n_reading为n端口输出有效；
    output reg [11:0] port_0_addr = 0, input [3:0] port_0_priority, input port_0_rea, output reg port_0_reading = 0,
    output reg [11:0] port_1_addr = 0, input [3:0] port_1_priority, input port_1_rea, output reg port_1_reading = 0,
    output reg [11:0] port_2_addr = 0, input [3:0] port_2_priority, input port_2_rea, output reg port_2_reading = 0,
    output reg [11:0] port_3_addr = 0, input [3:0] port_3_priority, input port_3_rea, output reg port_3_reading = 0,
    output reg [11:0] port_4_addr = 0, input [3:0] port_4_priority, input port_4_rea, output reg port_4_reading = 0,
    output reg [11:0] port_5_addr = 0, input [3:0] port_5_priority, input port_5_rea, output reg port_5_reading = 0,
    output reg [11:0] port_6_addr = 0, input [3:0] port_6_priority, input port_6_rea, output reg port_6_reading = 0,
    output reg [11:0] port_7_addr = 0, input [3:0] port_7_priority, input port_7_rea, output reg port_7_reading = 0,
    output reg [11:0] port_8_addr = 0, input [3:0] port_8_priority, input port_8_rea, output reg port_8_reading = 0,
    output reg [11:0] port_9_addr = 0, input [3:0] port_9_priority, input port_9_rea, output reg port_9_reading = 0,
    output reg [11:0] port_10_addr = 0, input [3:0] port_10_priority, input port_10_rea, output reg port_10_reading = 0,
    output reg [11:0] port_11_addr = 0, input [3:0] port_11_priority, input port_11_rea, output reg port_11_reading = 0,
    output reg [11:0] port_12_addr = 0, input [3:0] port_12_priority, input port_12_rea, output reg port_12_reading = 0,
    output reg [11:0] port_13_addr = 0, input [3:0] port_13_priority, input port_13_rea, output reg port_13_reading = 0,
    output reg [11:0] port_14_addr = 0, input [3:0] port_14_priority, input port_14_rea, output reg port_14_reading = 0,
    output reg [11:0] port_15_addr = 0, input [3:0] port_15_priority, input port_15_rea, output reg port_15_reading = 0

);

//----------inner_declaration----------
    reg [48:0] chain[units:0]; //双向链表，每个单元的数据定义参考parameter处注释
    reg [units:0] available;  //用于记录链表中某节点序号项是否被使用
    integer new_block; //指示新链表节点序号
    integer write_done = 0; 
    integer found_new_block = 0;

    //用于记录数据包输出顺序的队列，16个端口，每个端口8个优先级，每个优先级16个座位，每个座位记录一个chain_id
    reg [8:0][15:0] queue[127:0]; //queue[端口*8+优先级][第几项]
    reg      [3:0] queue_num[127:0]; //queue[端口*8+优先级]中目前项目数量

    //循环变量
    integer initial_loop; //rst过程的循环变量
    integer write_loop; //写入过程的循环变量
    integer find_block_loop;
    integer write_pointer; //写入过程的当前链表节点指针
    integer addr_left; //地址传输过程中剩余的位数
    integer deallocate_loop; //内存回收过程的循环变量
    integer deallocate_pointer; //内存回收过程的当前链表节点指针
    integer out_loop_0;
    integer out_loop_1;
    integer out_loop_2;
    integer out_loop_3;
    integer out_loop_4;
    integer out_loop_5;
    integer out_loop_6;
    integer out_loop_7;
    integer out_loop_8;
    integer out_loop_9;
    integer out_loop_10;
    integer out_loop_11;
    integer out_loop_12;
    integer out_loop_13;
    integer out_loop_14;
    integer out_loop_15;


    //输出端口剩余位数
    integer port_0_addr_left = 0;
    integer port_1_addr_left = 0;
    integer port_2_addr_left = 0;
    integer port_3_addr_left = 0;
    integer port_4_addr_left = 0;
    integer port_5_addr_left = 0;
    integer port_6_addr_left = 0;
    integer port_7_addr_left = 0;
    integer port_8_addr_left = 0;
    integer port_9_addr_left = 0;
    integer port_10_addr_left = 0;
    integer port_11_addr_left = 0;
    integer port_12_addr_left = 0;
    integer port_13_addr_left = 0;
    integer port_14_addr_left = 0;
    integer port_15_addr_left = 0;

//----------initialization----------
    always @(posedge clk) begin
        if(rst) begin
            for (initial_loop=0;initial_loop<=units;initial_loop=initial_loop+1)
                chain[initial_loop] = 49'b0; //初始化整个链表
            for (initial_loop=0;initial_loop<=units;initial_loop=initial_loop+1)
                available[initial_loop] = 1; //初始化available
            for (initial_loop=0;initial_loop<=127;initial_loop=initial_loop+1)
                    queue_num[initial_loop] = 4'b0; //初始化queue_num

            //初始化链表头chain[0]
            chain[0][sa-:12] = 1'b0; //start_address = 0
            chain[0][size-:12] = 12'hFFF; //size = 4096
            chain[0][state] = 1'b0;  // state = 0
            chain[0][prev-:12] = 12'hFFF; // prev = null
            chain[0][next-:12] = 12'hFFF; //next = null
            available[0] = 0; //链表头已使用
            new_block = 1; //从chain[1]开始添加节点

        end
    end    

//----------allocate-new-space----------
    always @(posedge clk) begin //正在传输地址
        if(writing && addr_left > 0) begin
            write_address = write_address + 1;
            addr_left = addr_left - 1;
        end
        else writing = 0;
    end

    always @(posedge clk) begin //开始传输新包的地址
        if (wea && writing == 0) begin
            $display("wea is posedge");
            write_loop = 0;
            write_done = 0;
            write_pointer = 0; //当前遍历到的链表节点编号

            for(write_loop=0;write_loop<units;write_loop=write_loop+1) begin //开始寻找可用内存块

                $display("record loop = %d, pointer = %d, state = %d, size = %d, done = %d",write_loop,write_pointer,chain[write_pointer][state],chain[write_pointer][size-:12],write_done);
                if(write_done == 0) begin
                    $display("available loop");
                    if(chain[write_pointer][state] == 0 && chain[write_pointer][size-:12] >= w_size) begin //如果发现state为0且长度大于等于需要长度的块就开始分配
                    
                        $display("found");

                        if(chain[write_pointer][size-:12] == w_size) begin 
                            chain[write_pointer][state] = 1; //如果需要分配的长度与内存块相同，则直接把state改为1
                            write_address = chain[write_pointer][sa-:12]; //输出起始地址
                            addr_left = w_size - 1;
                            writing = 1;

                            queue[dest_port*8+priority][ queue_num[dest_port*8+priority] ] = write_pointer; //在当前队尾处写入该链表节点id
                            queue_num[dest_port*8+priority] = queue_num[dest_port*8+priority] + 1; //该队列项目数量+1

                            write_done = 1;
                        end
                        else begin  //如果内存块长度大于分配长度，则将该块一分为二
                            chain[new_block][prev-:12] = write_pointer; //新块的prev指向旧块节点序号
                            chain[new_block][next-:12] = chain[write_pointer][next-:12]; //新块的next指向旧块的next
                            chain[new_block][sa-:12] = chain[write_pointer][sa-:12]; //新块的start_address等于旧块的start_address
                            chain[new_block][size-:12] = w_size; //新块的size等于新分配的size
                            chain[new_block][state] = 1; //新块的state等于1

                            chain[write_pointer][next-:12] = new_block; //旧块的prev不变，next指向新块节点序号
                            chain[write_pointer][size-:12] = chain[write_pointer][size-:12] - w_size; //旧块的size等于原size减去被切割的长度
                            chain[write_pointer][sa-:12] = chain[new_block][sa-:12] + w_size; //旧块的start_address等于新块start_address+size 

                            write_address = chain[new_block][sa-:12]; //输出起始地址
                            addr_left = w_size - 1; //记录剩余输入地址位数
                            writing = 1; //标记开始写入

                            queue[dest_port*8+priority][ queue_num[dest_port*8+priority] ] = new_block; //在当前队尾处写入新链表节点id
                            queue_num[dest_port*8+priority] = queue_num[dest_port*8+priority] + 1; //该队列项目数量+1
                            available[new_block] = 0; //新块已被占用

                            //刷新new_block
                            new_block = 0; found_new_block = 0;
                            for(find_block_loop = 0;find_block_loop<units;find_block_loop=find_block_loop+1) begin //从0开始寻找编号最小的未使用节点
                                if(found_new_block == 0)
                                    if(available[find_block_loop]==1)begin
                                        new_block = find_block_loop;
                                        found_new_block = 1;
                                    end
                            end 

                            $display("entered an end");

                            write_done = 1;
                        end
                    
                    end
                    else begin
                        write_pointer = chain[write_pointer][next-:12]; //寻找下一个内存块
                    end
                end
                else write_done = write_done;
            end
        end
    end

//----------read-out-package----------
    always @(posedge clk) begin //正在传输地址
        if(port_0_reading && port_0_addr_left > 0 ) begin //如果正在读取且还有剩余位未传输
            port_0_addr = port_0_addr + 1;
            port_0_addr_left = port_0_addr_left - 1;
        end
        else port_0_reading = 0; //读取完毕
    end
    always @(posedge clk) begin
        if (port_0_rea && port_0_reading == 0) begin
            if( queue_num[ port_0_priority ] > 0 ) //如果请求读取的优先级队列有东西可以读
                port_0_addr = chain[ queue[ port_0_priority ][0] ][sa-:12]; //输出队列头项的起始地址
                port_0_addr_left = chain[ queue[ port_0_priority ][0] ][size-:12] - 1;
                port_0_reading = 1; //允许读出
                
                chain[ queue[ port_0_priority ][0] ][state] = 0; //该链表节点state设为0
                queue_num[ port_0_priority ] = queue_num[ port_0_priority ] - 1; //该队列长度减1

                for(out_loop_0=0;out_loop_0<15;out_loop_0=out_loop_0+1)
                    queue[ port_0_priority ][out_loop_0] = queue[ port_0_priority ][out_loop_0+1];//队列内所有项目往前挪一位
        end
        else out_loop_0 = 0;
           
    end

//----------deallocate-nearby-free-space----------
    always @(negedge clk) begin
        deallocate_loop = 0;
        deallocate_pointer = 0;
        for(deallocate_loop=0;deallocate_loop<units;deallocate_loop=deallocate_loop+1) begin  //当chain[k]的next不等于null时继续
            
            if(chain[deallocate_pointer][24] == 0 && chain[ chain[deallocate_pointer][48:37] ][24] == 0 && available[deallocate_pointer] == 0 && available[ chain[deallocate_pointer][48:37] ] == 0) begin //当发现当前内存块和下一个内存块的state都为0，且两个块都正在被使用时，开始吞并
                
                available[ chain[deallocate_pointer][48:37] ] = 1; //下一个内存块的链表位置空出
                chain[deallocate_pointer][23:12] = chain[deallocate_pointer][23:12] + chain[ chain[deallocate_pointer][48:37] ][23:12]; //当前块的size加上下一个块的size
                chain[deallocate_pointer][48:37] = chain[ chain[deallocate_pointer][48:37] ][48:37]; //当前块的next等于下一个块的next
                
            end
            else if( chain[deallocate_pointer][48:37] == 12'hFFF ) deallocate_loop = units+1; //如果next为null则停止循环
            deallocate_pointer = chain[deallocate_pointer][48:37]; //寻找下一个内存块节点序号
        end
    end

    
endmodule

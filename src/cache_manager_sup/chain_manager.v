//用于记录内存空间的链表，寻找内存可用空间和内存回收

module chain_manager
#(
    parameter units = 512, //链表单元数量,sram为4096*8Bytes，数据包最小为64Bytes
    parameter next = 48, //[48:37]为next
    parameter prev = 36, //[36:25]为prev
    parameter state = 24,//[24]为state
    parameter size = 23, //[23:12]为size
    parameter sa = 11 //[11:0]为start_address
)
(
    input rst,
    input clk,

    input wea, //write_enable
    input [7:0] w_size, //写入包长度
    output reg [11:0] start_write_address, //写入起始地址

    input rea, //read_enable
    input [11:0] chain_id, //读出包对应的链表节点序号
    output reg [11:0] start_read_address //读取起始地址


);

//----------declaration----------
    reg [48:0] chain[units:0]; //双向链表，4096个单元，每个单元[11:0]为start_address，
                                //[23:12]为size，[24]为state,[36:25]为prev,[48:37]为next

    reg [units:0] available;  //用于记录链表中某节点序号项是否被使用
    integer new_block; //指示新链表节点序号
    //循环变量
    integer initial_loop;
    integer write_loop;
    integer write_pointer;
    integer deallocate_loop;
    integer deallocate_pointer;

//----------initialization----------
    always @(posedge clk) begin
        if(rst) begin
            for (initial_loop=0;initial_loop<=units;initial_loop=initial_loop+1)
                chain[initial_loop] = 49'b0; //初始化整个链表
            for (initial_loop=0;initial_loop<=units;initial_loop=initial_loop+1)
                available[initial_loop] = 1; //初始化available

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

//----------recording-new-package----------
    always @(posedge clk) begin
        if (wea) begin
            $display("wea is posedge");
            write_loop = 0;
            write_pointer = 0; //i为当前遍历到的链表节点编号

            for(write_loop=0;write_loop<=units;write_loop=write_loop+1) begin //开始寻找可用内存块

                $display("record loop = %d, pointer = %d, state = %d, size = %d",write_loop,write_pointer,chain[write_pointer][state],chain[write_pointer][size-:12]);
                
                if(chain[write_pointer][state] == 0 && chain[write_pointer][size-:12] >= w_size) begin //如果发现state为0且长度大于等于需要长度的块就开始分配
                    
                    $display("found");

                    if(chain[write_pointer][size-:12] == w_size) begin 
                        chain[write_pointer][state] = 1; //如果需要分配的长度与内存块相同，则直接把state改为1
                        start_write_address = chain[write_pointer][sa-:12]; //输出起始地址

                        write_loop = units+1;
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

                        start_write_address = chain[new_block][sa-:12]; //输出起始地址

                        available[new_block] = 0; //刷新new_block
                        for(new_block = 0;available[new_block]==0;new_block=new_block+1); //从0开始寻找编号最小的未使用节点

                        $display("entered an end");

                        write_loop = units+1;
                    end
                
                end
                else begin
                    write_pointer = chain[write_pointer][next-:12]; //寻找下一个内存块
                end
            end
        end
    end

//----------read-out-package----------
    always @(posedge clk) begin
        if (rea) begin
            chain[ chain_id ][24] = 0;
            start_read_address = chain[ chain_id ][11:0];
        end
    end

//----------deallocate-memory----------
    always @(negedge clk) begin
        deallocate_loop = 0;
        deallocate_pointer = 0;
        for(deallocate_loop=0;deallocate_loop<=units;deallocate_loop=deallocate_loop+1) begin  //当chain[k]的next不等于null时继续
            
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

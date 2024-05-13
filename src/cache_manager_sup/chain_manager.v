//用于记录内存空间的链表，寻找内存可用空间和内存回收

module chain_manager(
    input rst,
    input clk,
    input request, //request上升沿时触发链表活动
    input [7:0] size //包长度

);

//----------declaration----------
    reg [48:0] chain[4095:0]; //双向链表，4096个单元，每个单元[11:0]为start_address，
                                //[23:12]为size，[24]为state,[36:25]为prev,[48:37]为next

    reg [4095:0] available;  //用于记录链表中某一项是否被使用
    integer new_block; //指示新链表位置
    integer i = 0;
    integer j = 0;
    integer k = 0;
    reg b;

//----------initialization----------
    always @(posedge clk) begin
        if(rst) begin
            for (i=0;i<=4095;i=i+1) chain[i] <= 49'b0; //初始化整个链表
            for (i=0;i<=4095;i=i+1) available[i] <= 1; //初始化available

            //初始化链表头chain[0]
            chain[0][11:0] <= 1'b0; //start_address = 0
            chain[0][23:12] <= 12'hFFF; //size = 4096
            chain[0][24] <= 1'b0;  // state = 0
            chain[0][36:25] <= 12'hFFF; // prev = null
            chain[0][48:37] <= 12'hFFF; //next = null
            available[0] <= 0; //链表头已使用
            new_block <= 1; //从chain[1]开始添加节点
        end
    end    

//----------recording-new-package----------
    always @(posedge clk) begin
        if(request) allocate;
    end

//----------deallocate-memory----------
    always @(negedge clk) begin
        deallocate;
    end

//----------task----------
task automatic allocate; //分配内存空间
    begin
        b = 1;
        i = 0; //i为当前遍历到的链表节点编号
        while (b) begin:finding
            $display("while");
            if(chain[i][24] == 0 && chain[i][23:12] >= size) begin //发现可用内存块，开始分配

                if(chain[i][23:12] == size) begin //如果需要分配的长度与内存块相同，则直接把state改为1
                    chain[i][24] = 1; 
                    b = 0;
                end
                else begin  //如果内存块长度大于分配长度，则将该块一分为二
                    chain[new_block][36:25] = i; //新块的prev指向旧块
                    chain[new_block][48:37] = chain[i][48:37]; //新块的next指向旧块的next
                    chain[new_block][11:0] = chain[i][11:0]; //新块的start_address等于旧块的start_address
                    chain[new_block][23:12] = size; //新块的size等于新分配的size
                    chain[new_block][24] = 1; //新块的state等于1

                    chain[i][48:37] = new_block; //旧块的prev不变，next指向新块
                    chain[i][23:12] = chain[i][23:12] - size; //旧块的size等于原size减去被切割的长度
                    chain[i][11:0] = chain[new_block][11:0] + size; //旧块的start_address等于新块start_address+size 

                    available[new_block] = 0; //刷新new_block
                    j = 0;
                    while(available[j] == 0) j = j+1;
                    new_block = j;

                    b = 0;
                end
                
            end
            else begin
                i = chain[i][48:37]; //寻找下一个内存块
            end
        end
        
    end
    endtask 

task automatic deallocate; //内存回收
    begin
        k = 0;
        while( chain[k][48:37] != 12'hFFF ) begin  //当chain[k]的next不等于null时继续
            if(chain[k][24] == 0 && chain[ chain[k][48:37] ][24] == 0) begin //当发现当前内存块和下一个内存块的state都为0时，开始吞并
                available[ chain[k][48:37] ] = 1; //下一个内存块的链表位置空出
                chain[k][23:12] = chain[k][23:12] + chain[ chain[k][48:37] ][23:12]; //当前块的size加上下一个块的size
                chain[k][48:37] = chain[ chain[k][48:37] ][48:37]; //当前块的next等于下一个块的next
            end
        k = chain[k][48:37]; //寻找下一个内存块
        end
    end
    
endtask

endmodule

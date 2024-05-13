//用于记录内存空间的链表，寻找内存可用空间和内存回收

module chain_manager(
    input request, //request上升沿时触发链表活动
    input [7:0] size //包长度

);

//----------declaration----------
    reg [4095:0] chain [0:48]; //双向链表，4096个单元，每个单元[11:0]为start_address，
                                //[23:12]为size，[24]为state,[36:25]为prev,[48:37]为next

    reg [4095:0] available;  //用于记录链表中某一项是否被使用
    integer new_block; //指示新链表位置
    integer i = 0;

//----------initialization----------
    initial begin
        
        for (i=0;i<=4095;i=i+1) chain[i] = 49'b0; //初始化整个链表
        for (i=0;i<=4095;i=i+1) available[i] = 0; //初始化available
        //初始化链表头chain[0]
        chain[0][11:0] = 1'b0; //start_address = 0
        chain[0][23:12] = 12'hFFF; //size = 4096
        chain[0][24] = 1'b0;  // state = 0
        chain[0][36:25] = 1'b0; // prev = 0
        chain[0][48:37] = 1'b0; //next = 0
        available[0] = 1; //链表头已使用
        new_block = 1; //从chain[1]开始添加节点
    end    

//----------recording-new-package----------
    always @(posedge request) begin
        
        allocate;
    end

//----------task----------
task automatic allocate; //分配内存空间
    begin
        i = 0; //i为当前遍历到的链表节点编号
        while (1) begin:finding
            if(chain[i][24] == 0 && chain[i][23:12] >= size) begin //发现可用内存块，开始分配

                if(chain[i][23:12] == size) begin
                    chain[i][24] = 1; //如果需要分配的长度与内存块相同，则直接把state改为1
                    disable finding;
                end
                else begin
                    chain[new_block][36:25] = chain[i][36:25]; //新块的prev指向旧块的prev
                    chain[new_block][48:37] = i; //新块的next指向旧块
                    chain[new_block][11:0] = chain[i][11:0]; //新块的start_address等于旧块的start_address
                    chain[new_block][23:12] = size; //新块的size等于新分配的size
                    chain[new_block][24] = 1; //新块的state等于1

                    chain[i][48:37] = new_block; //旧块的prev指向新块，next不变
                    chain[i][23:12] = chain[i][23:12] - size; //旧块的size等于原size减去被切割的长度
                    chain[i][11:0] = chain[new_block][11:0] + size; //旧块的start_address等于新块start_address+size 
                    new_block = new_block+1; //
                    disable finding;
                end
                
            end
            else begin
                i = chain[i][48:37]; //寻找下一个内存块
            end
        end
        
    end
    endtask 

endmodule

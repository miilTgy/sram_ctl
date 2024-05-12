//用于记录内存空间的链表，寻找内存可用空间和内存回收

module chain_manager(
    input request;
    input size;

);

    task automatic allocate(input [7:0] size); //分配内存空间
        integer i = 0;
        while (1) begin
            if(chain[i][24] == 0 && chain[i][12:23] >= size) begin //发现可用内存块，开始分配

                if(chain[i][12:23] == size) begin
                    chain[i][24] = 1; //如果需要分配的长度与内存块相同，则直接把state改为1
                    break;
                end
                else begin
                    chain[new_block][25:36] = chain[i][25:36]; //新块的prev指向旧块的prev
                    chain[new_block][36:47] = i; //新块的next指向旧块
                    chain[new_block][0:11] = chain[i][0:11]; //新块的start_address等于旧块的start_address
                    chain[new_block][12:23] = size; //新块的size等于新分配的size
                    chain[new_block][24] = 1; //新块的state等于1

                    chain[i][36:47] = new_block; //旧块的prev指向新块，next不变
                    chain[i][12:23] = chain[i][12:23] - size; //旧块的size等于原size减去被切割的长度
                    chain[i][0:11] = chain[new_block][0:11] + size; //旧块的start_address等于新块start_address+size 
                    new_block = new_block+1; //
                    break;
                end
                
            end
            else begin
                i = chain[i][36:47]; //寻找下一个内存块
            end
        end
        
        
    endtask 


    //此处要例化一个SRAM，过会儿再说，名字叫chain
    //该SRAM用于存储链表，或者说用reg？
    
    reg [4095:0] chain [43]; //双向链表，4096个单元，每个单元[0:11]为start_address，
                                //[12:23]为size，[24]为state,[25:36]为prev,[36:47]为next,
    integer new_block = 1; //指示

    initial begin
        integer i;
        for (i=0;i<=4095;i=i+1) chain[i] = 43'b0; //初始化整个链表

        //初始化链表头chain[0]
        chain[0][0:11] = 1'b0; //start_address = 0
        chain[0][12:23] = 12'hFFF; //size = 4096
        chain[0][24] = 1'b0;  // state = 0
        chain[0][25:36] = 1'b0; // prev = 0
        chain[0][36:47] = 1'b0; //next = 0
    end    

    always @posedge(request) begin
        
        
    end
endmodule

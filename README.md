# 集创赛仓库
activated 曾广翼  
activated 周俊熹  
activated 陈光鉴  

## 使用方法
本项目默认使用[**`verilator`**](https://github.com/verilator/verilator.git)进行仿真，  
但也提供了[**`iverilog`**](https://github.com/steveicarus/iverilog.git)的仿真方式。
- ### **verilator**
    - #### 使用以下命令来生成可执行文件(依赖于`.v`文件和`C++ testbench`)  
        ```
        make ["MOD_NAME=<module name(default: fifo)>"]
        ```
        注：方括号中的命令`[selective instructions]`代表可选命令，缺省也无伤大雅。  
    - #### 使用以下命令来检查语法错误
        ```
        make check ["MOD_NAME=<module name(default: fifo)>"]
        ```
    - #### 使用以下命令来编译，运行并查看仿真波形
        ```
        make wave
        ``` 
    - #### 若为第一次编译(项目主目录下不含有`build`文件夹)
        1. 使用以下命令来生成`V<module name>.h(default Vfifo.h)`文件(用于`C++ testbench`中)  
            ```
            make build
            ```
            然后去写`C++ testbench`  

        3. 使用以下命令来生成可执行文件
            ```
            make all
            ```
        4. 使用以下命令来执行可执行文件
            ```
            make run
            ```
        7. 使用以下命令来显示波形(需要[**`gtkwave`**](https://github.com/gtkwave/gtkwave.git))
           ```
           make show
           ``` 
- ### **iverilog**
    - #### 使用以下命令来检查语法错误(只依赖于`.v`文件)
        ```
        make ibuild
        ```
    - #### 使用以下命令来生成仿真可执行文件(依赖于`.v`与`_tb.v`文件)
        ```
        make itest
        ```
    - #### 使用以下命令来编译，运行并查看仿真波形
        ```
        make iwave
        ``` 
    - #### 若为第一次编译(项目主目录下不含有`a.out`文件)
        1. 使用以下命令来生成`a.out`可执行文件
            ```
            make itest
            ```
        2. 使用以下命令来执行仿真
            ```
            make irun
            ```
        3. 使用以下命令来查看仿真波形
            ```
            make ishow
            ```
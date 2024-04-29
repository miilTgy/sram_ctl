# 集创赛仓库
activated 曾广翼  
activated 周俊熹  
activated 陈光鉴  

## 使用方法
本项目默认使用[**`verilator`**](https://github.com/verilator/verilator.git)进行仿真，  
但也提供了[**`iverilog`**](https://github.com/steveicarus/iverilog.git)的仿真方式。  
同时，本项目依赖于[**`gtkwave`**](https://github.com/gtkwave/gtkwave.git)来查看仿真波形  

<font size=2>(可选)注：以下所有命令都可后接(不接也没问题，那就默认作用对象为fifo)：</font>
```
"MOD_NAME=<module name(default: fifo)>"
``` 
<font size=2>来测试你想要测试的模块  
例如：</font>
```
make check "MOD_NAME=arbiter_core"
```
### 测试单个模块  
------------------------

- ### **使用verilator**
    - #### 使用以下命令来生成可执行文件(依赖于`.v`文件和`C++ testbench`)  
        ```
        make
        ```
    - #### 使用以下命令来检查语法错误
        ```
        make check
        ```
    - #### 使用以下命令来编译，运行并查看仿真波形(需要[**`gtkwave`**](https://github.com/gtkwave/gtkwave.git))
        ```
        make wave
        ``` 
    - #### 若为第一次编译(项目主目录下不含有`build`文件夹)
        1. 使用以下命令来生成`V<module name>.h`(默认为`Vfifo.h`)文件(用于`C++ testbench`中)  
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
- ### **使用iverilog**
    - #### 使用以下命令来检查语法错误(只依赖于`.v`文件)
        ```
        make ibuild
        ```
    - #### 使用以下命令来生成仿真可执行文件(依赖于`.v`与`_tb.v`文件)
        ```
        make itest
        ```
    - #### 使用以下命令来编译，运行并查看仿真波形(需要[**`gtkwave`**](https://github.com/gtkwave/gtkwave.git))
        ```
        make iwave
        ``` 
    - #### 若为第一次编译(项目主目录下不含有`a.out`文件)
        1. 使用以下命令来生成`a.out`可执行文件
            ```
            make itest
            ```
        8. 使用以下命令来执行仿真
            ```
            make irun
            ```
        7. 使用以下命令来查看仿真波形(需要[**`gtkwave`**](https://github.com/gtkwave/gtkwave.git))
            ```
            make ishow
            ```
### 测试多个模块
----------------------

- ### **仅支持使用iverilog**
    - #### 使用以下命令来为所有包含的模块检查语法错误
        ```
        make sbuild
        ```
    - #### 使用以下命令来为所有模块和testbench生成可知性文件`a.out`
        ```
        make stest
        ```
    - #### 使用以下命令来编译，运行并查看仿真波形(需要[**`gtkwave`**](https://github.com/gtkwave/gtkwave.git))
        ```
        make swave
        ```
    - #### 若为第一次编译(项目主目录下不含有`a.out`文件)
        1. 使用以下命令来生成`a.out`可执行文件
            ```
            make stest
            ```
        9. 使用以下命令来执行仿真
            ```
            make srun
            ```
        6. 使用以下命令来查看仿真波形(需要[**`gtkwave`**](https://github.com/gtkwave/gtkwave.git))
            ```
            make sshow
            ```

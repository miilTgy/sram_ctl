# 集创赛仓库
activated 曾广翼  
activated 周俊熹  
activated 陈光鉴  

## 使用方法
本项目默认使用[**`verilator`**](https://github.com/verilator/verilator.git)进行仿真，  
但也提供了[**`iverilog`**](https://github.com/steveicarus/iverilog.git)的仿真方式。
- ### **verilator**
    - 使用以下命令来生成可执行文件(只有当`.v`文件和`C++ testbench`都存在时才能使用):  
  
        ```
        make ["MOD_NAME=<the name you want(default: fifo)>"]
        ```
        注：方括号中的命令`[selective instructions]`代表可选命令，缺省也无伤大雅。
    - 使用以下命令来

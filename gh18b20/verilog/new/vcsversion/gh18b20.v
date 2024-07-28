module gh18b20
(
input wire sys_clk , //系统时钟，频率50MHz
input wire sys_rst_n , //复位信号，低电平有效

inout wire dq  //数据总线

);

////
//\* Parameter and Internal Signal \//
////

//wire define
wire [19:0] data_out ;
wire sign ;

////
//\* Instantiation \//
////

//-------------gh18b20_ctrl_inst--------------
gh18b20_ctrl gh18b20_ctrl_inst
(
.sys_clk (sys_clk ), //系统时钟，频率50MHz
.sys_rst_n (sys_rst_n), //复位信号，低电平有效

.dq (dq ), //数据总线

.data_out (data_out ), //输出温度
.sign (sign ) //输出温度符号位

);



endmodule
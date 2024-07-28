module gh18b20
(
input wire sys_clk , //系统时钟，频率50MHz
input wire sys_rst_n , //复位信号，低电平有效

inout wire dq , //数据总线

output wire stcp , //输出数据存储寄时钟
output wire shcp , //移位寄存器的时钟输入
output wire ds , //串行数据输入
output wire oe

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

//-------------seg7_dynamic_inst--------------
seg_595_dynamic
(
.sys_clk (sys_clk ), //系统时钟，频率50MHz
.sys_rst_n (sys_rst_n), //复位信号，低有效
.data (data_out ), //数码管要显示的值
.point (6'b001000), //小数点显示,高电平有效
.seg_en (1'b1 ), //数码管使能信号，高电平有效
.sign (sign ), //符号位，高电平显示负号

.stcp (stcp ), //输出数据存储寄时钟
.shcp (shcp ), //移位寄存器的时钟输入
.ds (ds ), //串行数据输入
.oe (oe ) //输出使能信号

);

endmodule
module gh18b20
(
input wire sys_clk , //ϵͳʱ�ӣ�Ƶ��50MHz
input wire sys_rst_n , //��λ�źţ��͵�ƽ��Ч

inout wire dq  //��������

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
.sys_clk (sys_clk ), //ϵͳʱ�ӣ�Ƶ��50MHz
.sys_rst_n (sys_rst_n), //��λ�źţ��͵�ƽ��Ч

.dq (dq ), //��������

.data_out (data_out ), //����¶�
.sign (sign ) //����¶ȷ���λ

);



endmodule
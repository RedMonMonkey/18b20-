module seg_595_dynamic
(
input wire sys_clk , //ϵͳʱ�ӣ�Ƶ��50MHz
input wire sys_rst_n , //��λ�źţ�����Ч
input wire [19:0] data , //�����Ҫ��ʾ��ֵ
input wire [5:0] point , //С������ʾ,�ߵ�ƽ��Ч
input wire seg_en , //�����ʹ���źţ��ߵ�ƽ��Ч
input wire sign , //����λ���ߵ�ƽ��ʾ����

output wire stcp , //������ݴ洢��ʱ��
output wire shcp , //��λ�Ĵ�����ʱ������
output wire ds , //������������
output wire oe //���ʹ���ź�

);

////
//\* Parameter And Internal Signal \//
////

//wire define
wire [5:0] sel; //�����λѡ�ź�
wire [7:0] seg; //����ܶ�ѡ�ź�

////
//\* Main Code \//
////

seg_dynamic seg_dynamic_inst
(
.sys_clk (sys_clk ), //ϵͳʱ�ӣ�Ƶ��50MHz
.sys_rst_n (sys_rst_n), //��λ�źţ�����Ч
.data (data ), //�����Ҫ��ʾ��ֵ
.point (point ), //С������ʾ,�ߵ�ƽ��Ч
.seg_en (seg_en ), //�����ʹ���źţ��ߵ�ƽ��Ч
.sign (sign ), //����λ���ߵ�ƽ��ʾ����

.sel (sel ), //�����λѡ�ź�
.seg (seg ) //����ܶ�ѡ�ź�

);

hc595_ctrl hc595_ctrl_inst
(
.sys_clk (sys_clk ), //ϵͳʱ�ӣ�Ƶ��50MHz
.sys_rst_n (sys_rst_n), //��λ�źţ�����Ч
.sel (sel ), //�����λѡ�ź�
.seg (seg ), //����ܶ�ѡ�ź�

.stcp (stcp ), //������ݴ洢��ʱ��
.shcp (shcp ), //��λ�Ĵ�����ʱ������
.ds (ds ), //������������
.oe (oe )

);

endmodule
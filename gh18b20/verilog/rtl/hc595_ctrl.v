module hc595_ctrl
(
input wire sys_clk , //ϵͳʱ�ӣ�Ƶ��50MHz
input wire sys_rst_n , //��λ�źţ�����Ч
input wire [5:0] sel , //�����λѡ�ź�
input wire [7:0] seg , //����ܶ�ѡ�ź�

output reg stcp , //���ݴ洢��ʱ��
output reg shcp , //��λ�Ĵ���ʱ��
output reg ds , //������������
output wire oe //ʹ���źţ�����Ч
);

////
//\* Parameter and Internal Signal \//
////
//reg define
reg [1:0] cnt_4 ; //��Ƶ������
reg [3:0] cnt_bit ; //����λ��������

//wire define
wire [13:0] data ; //������źżĴ�

////
//\* Main Code \//
////

//��������źżĴ�
assign data={seg[0],seg[1],seg[2],seg[3],seg[4],seg[5],seg[6],seg[7],sel};

//����λȡ����ֵ���伴��
assign oe = ~sys_rst_n;

//��Ƶ������:0~3ѭ������
always@(posedge sys_clk or negedge sys_rst_n)
if(sys_rst_n == 1'b0)
cnt_4 <= 2'd0;
else if(cnt_4 == 2'd3)
cnt_4 <= 2'd0;
else
cnt_4 <= cnt_4 + 1'b1;

//cnt_bit:ÿ����һλ���ݼ�һ
always@(posedge sys_clk or negedge sys_rst_n)
if(sys_rst_n == 1'b0)
cnt_bit <= 4'd0;
else if(cnt_4 == 2'd3 && cnt_bit == 4'd13)
cnt_bit <= 4'd0;
else if(cnt_4 == 2'd3)
cnt_bit <= cnt_bit + 1'b1;
else
cnt_bit <= cnt_bit;

//stcp:14���źŴ������֮�����һ��������
always@(posedge sys_clk or negedge sys_rst_n)
if(sys_rst_n == 1'b0)
stcp <= 1'b0;
else if(cnt_bit == 4'd13 && cnt_4 == 2'd3)
stcp <= 1'b1;
else
stcp <= 1'b0;

//shcp:�����ķ�Ƶ��λʱ��
always@(posedge sys_clk or negedge sys_rst_n)
if(sys_rst_n == 1'b0)
shcp <= 1'b0;
else if(cnt_4 >= 4'd2)
shcp <= 1'b1;
else
shcp <= 1'b0;

//ds:���Ĵ�����洢��������ź����뼴
always@(posedge sys_clk or negedge sys_rst_n)
if(sys_rst_n == 1'b0)
ds <= 1'b0;
else if(cnt_4 == 2'd0)
ds <= data[cnt_bit];
else
ds <= ds;

endmodule

module gh18b20 #(
    parameter                                   p_1us_cnt                 = 5'd24 , //������������̷�������
    parameter                                   S_WAIT_MAX                = 750000//750ms
)
(
    input  wire                                 sys_clk                    ,//ϵͳʱ�ӣ�Ƶ��50MHz
    input  wire                                 sys_rst_n                  ,//��λ�źţ��͵�ƽ��Ч

    inout  wire                                 dq                         ,//��������

    output wire                                 stcp                       ,//������ݴ洢��ʱ��
    output wire                                 shcp                       ,//��λ�Ĵ�����ʱ������
    output wire                                 ds                         ,//������������
    output wire                                 oe                          

);

////
//\* Parameter and Internal Signal \//
////

//wire define
    wire               [  19: 0]                data_out                   ;
    wire                                        sign                       ;

////
//\* Instantiation \//
////

//-------------gh18b20_ctrl_inst--------------
gh18b20_ctrl #(p_1us_cnt) gh18b20_ctrl_inst
(
    .sys_clk                                    (sys_clk                   ),//ϵͳʱ�ӣ�Ƶ��50MHz
    .sys_rst_n                                  (sys_rst_n                 ),//��λ�źţ��͵�ƽ��Ч

    .dq                                         (dq                        ),//��������

    .data_out                                   (data_out                  ),//����¶�
    .sign                                       (sign                      ) //����¶ȷ���λ

);

//-------------seg7_dynamic_inst--------------
seg_595_dynamic
(
    .sys_clk                                    (sys_clk                   ),//ϵͳʱ�ӣ�Ƶ��50MHz
    .sys_rst_n                                  (sys_rst_n                 ),//��λ�źţ�����Ч
    .data                                       (data_out                  ),//�����Ҫ��ʾ��ֵ
    .point                                      (6'b001000                 ),//С������ʾ,�ߵ�ƽ��Ч
    .seg_en                                     (1'b1                      ),//�����ʹ���źţ��ߵ�ƽ��Ч
    .sign                                       (sign                      ),//����λ���ߵ�ƽ��ʾ����

    .stcp                                       (stcp                      ),//������ݴ洢��ʱ��
    .shcp                                       (shcp                      ),//��λ�Ĵ�����ʱ������
    .ds                                         (ds                        ),//������������
    .oe                                         (oe                        ) //���ʹ���ź�

);

        endmodule
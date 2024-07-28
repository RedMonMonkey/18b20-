/*
gh18b20��ʱ����us��������Ҫ�ȷ�Ƶ��1us��ʱ��
����gh18b20��������ʱ����̶������ʹ����ȫ�ɼ�ʱ�����Ƶ�״̬��
״̬��ʵ�ֹ��ܣ�
1.S_INIT,����׶���0-500us,�������ߣ����͸�λ���壩��500us֮���ͷ����ߣ��ȴ������ϵ�Ӧ�����壬��flag_pulseΪ1ʱ��˵���յ���Ӧ�����壬INIT״̬��1000us�������һ��״̬
2.S_WR_CMD������׶ο�ʼд���ݣ�����16λ��cc������ROM������44��ת��T���󣬽���WAIT״̬
3.S_WAIT������׶εȴ�750ms���ȴ�ת�����
4.S_INIT_AGAIN������׶��ٴγ�ʼ������S_INITһ�����ȴ������ϵ�Ӧ�����壬��flag_pulseΪ1ʱ��˵���յ���Ӧ�����壬INIT״̬��1000us�������һ��״̬
5.S_RD_CMD������׶ο�ʼ�����ݣ�����16λ��cc������ROM������be����T���󣬽���RD_TEMP״̬
6.S_RD_TEMP������׶ζ����ݣ���ȡ2�ֽڵ����ݣ��ж�����������¶�(��ȡ������ͨ����λ�Ĵ���)


*/
module gh18b20_ctrl#(
    parameter                                   p_1us_cnt                 = 5'd24, //������������̷�������
    parameter                                   S_WAIT_MAX                = 750000 //750ms
)
(
    input  wire                                 sys_clk                    ,//ϵͳʱ�ӣ�Ƶ��50MHz
    input  wire                                 sys_rst_n                  ,//��λ�źţ��͵�ƽ��Ч

    inout  wire                                 dq                         ,//��������

    output wire        [  19: 0]                data_out                   ,//����¶�
    output reg                                  sign                        //����¶ȷ���λ

);

////
//\* Parameter and Internal Signal \//
////

//parameter define
    parameter                                   S_INIT                    = 3'd1  , //��ʼ״̬
S_WR_CMD = 3'd2,                                                    //������ROM���¶�ת��ָ��
S_WAIT = 3'd3,                                                      //�ȴ��¶�ת�����
S_INIT_AGAIN = 3'd4,                                                //�ٴλص���ʼ��
S_RD_CMD = 3'd5,                                                    //������ROM�����¶�ת��ָ��
S_RD_TEMP = 3'd6;                                                   //���¶�״̬

    parameter                                   WR_44CC_CMD               = 16'h44cc; //����ROM���¶�ת�������λ��ǰ
    parameter                                   WR_BECC_CMD               = 16'hbecc; //����ROM����ȡ�¶������λ��ǰ

    

//reg define
    reg                                         clk_1us                    ;//��Ƶʱ�ӣ���λʱ��1us
    reg                [   4: 0]                cnt                        ;//��Ƶ������
    reg                [   2: 0]                state                      ;//״̬��״̬
    reg                [  19: 0]                cnt_1us                    ;//΢�������
    reg                [   3: 0]                bit_cnt                    ;//�ֽڼ�����
    reg                [  15: 0]                data_tmp                   ;//��ȡgh18b20���¶�
    reg                [  19: 0]                data                       ;//�ж�����������¶�
    reg                                         flag_pulse                 ;//��ʼ�����������־�ź�
    reg                                         dq_out                     ;//����������ݣ���FPGA������������ֵ
    reg                                         dq_en                      ;//�����������ʹ���ź�

////
//\* Main Code \//
////

//�¶�ת�������������λ�����ޣ������ﱣ��С�������λ
    assign                                      data_out                  = (data * 10'd625)/ 4'd10;

//��ʹ���ź�Ϊ1�����ߵ�ֵΪdq_out��ֵ��Ϊ0ʱΪ����̬
    assign                                      dq                        = (dq_en ==1 ) ? dq_out : 1'bz;

//cnt:��Ƶ������
    always@(posedge sys_clk or negedge sys_rst_n)
            if(sys_rst_n == 1'b0)
                cnt <= 5'b0;
            else if(cnt == p_1us_cnt)
                cnt <= 5'b0;
            else 
                cnt <= cnt + 1'b1;

//clk_1us��������λʱ��Ϊ1us��ʱ��
    always@(posedge sys_clk or negedge sys_rst_n)
            if(sys_rst_n == 1'b0)
                clk_1us <= 1'b0;
            else if(cnt == p_1us_cnt)
                clk_1us <= ~clk_1us;
            else 
                clk_1us <= clk_1us;

//cnt_1us��1usʱ�Ӽ�����������״̬��ת
    always@(posedge clk_1us or negedge sys_rst_n)
            if(sys_rst_n == 1'b0)
                cnt_1us <= 20'b0;
            else if(((state==S_WR_CMD || state==S_RD_CMD || state==S_RD_TEMP)
&& cnt_1us==20'd64) || ((state==S_INIT || state==S_INIT_AGAIN) &&
cnt_1us==20'd999) || (state==S_WAIT && cnt_1us==S_WAIT_MAX))
                cnt_1us <= 20'b0;
            else 
                cnt_1us <= cnt_1us + 1'b1;

//bit_cnt��bit��������д1bit���1bit��1��һ��д��֮������
    always@(posedge clk_1us or negedge sys_rst_n)
            if(sys_rst_n == 1'b0)
                bit_cnt <= 4'b0;
            else if((state == S_RD_TEMP || state == S_WR_CMD ||
state == S_RD_CMD) && (cnt_1us == 20'd64 && bit_cnt == 4'd15))
                bit_cnt <= 4'b0;
            else if((state == S_WR_CMD || state == S_RD_CMD ||
state == S_RD_TEMP) && cnt_1us == 20'd64)
                bit_cnt <= bit_cnt + 1'b1;

//��ʼ�����������־�źţ���ʼ��״̬ʱ�������߷�������������ܳ�ʼ���ɹ�
    always@(posedge clk_1us or negedge sys_rst_n)
            if(sys_rst_n == 1'b0)
                flag_pulse <= 1'b0;
            else if(cnt_1us == 20'd570 && dq == 1'b0 && (state == S_INIT ||
state == S_INIT_AGAIN))
                flag_pulse <= 1'b1;
            else if(cnt_1us == 999)

                flag_pulse <= 1'b0;
            else 
                flag_pulse <= flag_pulse;

//״̬��ת
    always@(posedge clk_1us or negedge sys_rst_n)
            if(sys_rst_n == 1'b0)
                state <= S_INIT;
            else 
case(state)
//��ʼ����Сʱ��Ϊ960us
S_INIT:                                                             //�յ�����������ʱ�������960us��ת
            if(cnt_1us == 20'd999 && flag_pulse == 1'b1  )
                state <= S_WR_CMD;
            else 
                state <= S_INIT;
S_WR_CMD:                                                           //����������ROM���¶�ת���������ת
            if(bit_cnt == 4'd15 && cnt_1us == 20'd64 )
                state <= S_WAIT;
            else 
                state <= S_WR_CMD;
S_WAIT:                                                             //�ȴ�750ms����ת
            if(cnt_1us == S_WAIT_MAX)
                state <= S_INIT_AGAIN;
            else 
                state <= S_WAIT;
S_INIT_AGAIN:                                                       //�ٴγ�ʼ������ת
            if(cnt_1us == 20'd999 && flag_pulse == 1'b1  )
                state <= S_RD_CMD;
            else 
                state <= S_INIT_AGAIN;
S_RD_CMD:                                                           //����������ROM�Ͷ�ȡ�¶��������ת
            if(bit_cnt == 4'd15 && cnt_1us == 20'd64)
                state <= S_RD_TEMP;
            else 
                state <= S_RD_CMD;
S_RD_TEMP:                                                          //����2�ֽڵ��¶Ⱥ���ת
            if(bit_cnt == 4'd15 && cnt_1us == 20'd64)
                state <= S_INIT;
            else 
                state <= S_RD_TEMP;
default:
                state <= S_INIT;
        endcase

//����״̬�µ�������Ӧ��ʱ��
    always@(posedge clk_1us or negedge sys_rst_n)
            if(sys_rst_n == 1'b0)
        begin
                dq_out <= 1'b0;
                dq_en <= 1'b0;
        end
            else 
case(state)
//��ʼ������С480us�͵�ƽ��Ȼ���ͷ�����
S_INIT:
            if(cnt_1us < 20'd499)
        begin
                dq_out <= 1'b0;
                dq_en <= 1'b1;
        end
            else 
        begin
                dq_out <= 1'b0;
                dq_en <= 1'b0;
        end
//ÿһ��дʱ��������60us�ĳ���ʱ�������1us�Ļָ�ʱ��
//д0���������ͺ�һֱ���ͣ�����60us
//д1���������ͺ������15us���ͷ�����
S_WR_CMD:
            if(cnt_1us > 20'd62)
        begin
                dq_out <= 1'b0;
                dq_en <= 1'b0;          //д��һ�����ݺ��ͷ�
        end
            else if(cnt_1us <= 20'b1)
        begin
                dq_out <= 1'b0;
                dq_en <= 1'b1;              //�������ߣ�д���ݿ�ʼ
        end
            else if(WR_44CC_CMD[bit_cnt] == 1'b0)
        begin
                dq_out <= 1'b0;
                dq_en <= 1'b1;          //����44CC��44˵��������ROM���˴�д0
        end
            else if(WR_44CC_CMD[bit_cnt] == 1'b1)
        begin
                dq_out <= 1'b0;
                dq_en <= 1'b0;          //����44CC��44˵��������ROM���˴�д1
        end
//Ϊ��Ӧ������Դ���¶�ת���������������
S_WAIT:
        begin
                dq_out <= 1'b1;
                dq_en <= 1'b1;
        end
//���һ�γ�ʼ��ʱ��һ��
S_INIT_AGAIN:
            if(cnt_1us < 20'd499)
        begin
                dq_out <= 1'b0;
                dq_en <= 1'b1;
        end
            else 
        begin
                dq_out <= 1'b0;
                dq_en <= 1'b0;
        end
//�뷢������ROM�Ͷ�ȡ�¶�����ʱ��һ��
S_RD_CMD:
            if(cnt_1us > 20'd62)
        begin
                dq_out <= 1'b0;
                dq_en <= 1'b0;
        end
            else if(cnt_1us <= 20'b1)
        begin
                dq_out <= 1'b0;
                dq_en <= 1'b1;
        end
            else if(WR_BECC_CMD[bit_cnt] == 1'b0)
        begin
                dq_out <= 1'b0;
                dq_en <= 1'b1;
        end
            else if(WR_BECC_CMD[bit_cnt] == 1'b1)
        begin
                dq_out <= 1'b0;
                dq_en <= 1'b0;
        end
//�������߳���1us���ͷ�����
S_RD_TEMP:
            if(cnt_1us <=1)
        begin
                dq_out <= 1'b0;
                dq_en <= 1'b1;
        end
            else 
        begin
                dq_out <= 1'b0;
                dq_en <= 1'b0;
        end
default:;
        endcase

//data_tmp:�����¶ȣ��Ĵ���data_tmp��
    always@(posedge clk_1us or negedge sys_rst_n)
            if(sys_rst_n == 1'b0)
                data_tmp <= 12'b0;
//�������ͺ�������Чʱ��Ϊ15us
            else if(state == S_RD_TEMP && cnt_1us == 20'd13)
                data_tmp <= {dq,data_tmp[15:1]};
            else 
                data_tmp <= data_tmp;

//�¶��жϣ�����¶�
    always@(posedge clk_1us or negedge sys_rst_n)
            if(sys_rst_n == 1'b0)
                data <= 20'b0;
            else if(data_tmp[15] == 1'b0 && state == S_RD_TEMP &&
cnt_1us == 20'd60 && bit_cnt == 4'd15)
                data <= data_tmp[10:0];
            else if(data_tmp[15] == 1'b1 && state == S_RD_TEMP &&
cnt_1us == 20'd60 && bit_cnt == 4'd15)
                data <= ~data_tmp[10:0] + 1'b1;

//�¶��жϣ��������λ
    always@(posedge clk_1us or negedge sys_rst_n)
            if(sys_rst_n == 1'b0)
                sign <= 1'b0;
            else if(data_tmp[15] == 1'b0 && state == S_RD_TEMP &&
cnt_1us == 20'd60 && bit_cnt == 4'd15)
                sign <= 1'b0;
            else if(data_tmp[15] == 1'b1 && state == S_RD_TEMP &&
cnt_1us == 20'd60 && bit_cnt == 4'd15)
                sign <= 1'b1;

        endmodule
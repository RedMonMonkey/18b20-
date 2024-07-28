`timescale 1ns/1ns
module tb_gh18b20();

////
//\* Parameter And Internal Signal \//
////

//wire define

    wire                                        dq                         ;

//reg define
    reg                                         sys_clk                    ;
    reg                                         sys_rst_n                  ;

////
//\* Instantiation \//
////



//��sys_clk,sys_rst_n����ʼֵ
initial
        begin
sys_clk = 1'b1;
                sys_rst_n <= 1'b0;
#100
                sys_rst_n <= 1'b1;
#1000000000 $finish;
        end

`ifdef FSDB
    initial begin
        $fsdbDumpfile("gh18b20.fsdb");
        $fsdbDumpvars(0);
        $fsdbDumpMDA ;
    end
`endif


//clk:����ʱ��
    always #10 sys_clk <= ~sys_clk;

//���¶������ֵ�����̷���ʱ��
//defparam gh18b20_inst.gh18b20_ctrl_inst.p_1us_cnt = 1;
//defparam gh18b20_inst.gh18b20_ctrl_inst.S_WAIT_MAX = 1;

//-------------gh18b20_inst-------------
gh18b20  gh18b20_inst
(
    .sys_clk                                    (sys_clk                   ),//ϵͳʱ�ӣ�Ƶ��50MHz
    .sys_rst_n                                  (sys_rst_n                 ),//��λ�źţ��͵�ƽ��Ч

    .dq                                         (dq                        )//��������

);

gh18b20_model gh18b20_model_inst
(
    dq
);
        endmodule
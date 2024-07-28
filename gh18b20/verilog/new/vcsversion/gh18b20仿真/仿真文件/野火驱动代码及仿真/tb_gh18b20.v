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



//对sys_clk,sys_rst_n赋初始值
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


//clk:产生时钟
    always #10 sys_clk <= ~sys_clk;

//重新定义参数值，缩短仿真时间
//defparam gh18b20_inst.gh18b20_ctrl_inst.p_1us_cnt = 1;
//defparam gh18b20_inst.gh18b20_ctrl_inst.S_WAIT_MAX = 1;

//-------------gh18b20_inst-------------
gh18b20  gh18b20_inst
(
    .sys_clk                                    (sys_clk                   ),//系统时钟，频率50MHz
    .sys_rst_n                                  (sys_rst_n                 ),//复位信号，低电平有效

    .dq                                         (dq                        )//数据总线

);

gh18b20_model gh18b20_model_inst
(
    dq
);
        endmodule
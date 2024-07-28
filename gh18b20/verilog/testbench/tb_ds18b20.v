module tb_gh18b20();

////
//\* Parameter And Internal Signal \//
////

//wire define
    wire                                        stcp                       ;
    wire                                        shcp                       ;
    wire                                        ds                         ;
    wire                                        oe                         ;
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
#10000000 $finish;
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
defparam gh18b20_inst.gh18b20_ctrl_inst.p_1us_cnt = 1;
defparam gh18b20_inst.gh18b20_ctrl_inst.S_WAIT_MAX = 1;

//-------------gh18b20_inst-------------
gh18b20  gh18b20_inst
(
    .sys_clk                                    (sys_clk                   ),//系统时钟，频率50MHz
    .sys_rst_n                                  (sys_rst_n                 ),//复位信号，低电平有效

    .dq                                         (dq                        ),//数据总线

    .stcp                                       (stcp                      ),//输出数据存储寄时钟
    .shcp                                       (shcp                      ),//移位寄存器的时钟输入
    .ds                                         (ds                        ),//串行数据输入
    .oe                                         (oe                        ) //输出使能信号

);

        endmodule
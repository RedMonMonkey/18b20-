根据https://doc.embedfire.com/fpga/altera/ep4ce10_mini/zh/latest/fpga/DS18B20.html
修改后实现读取温度并输入至数码管

gh18b20计时采用us，所以需要先分频出1us的时钟
由于gh18b20三个工作时间均固定，因此使用完全由计时器控制的状态机
状态机实现功能：
1.S_INIT,这个阶段在0-500us,拉低总线（发送复位脉冲），500us之后释放总线，等待总线上的应答脉冲，当flag_pulse为1时，说明收到了应答脉冲，INIT状态的1000us后进入下一个状态
2.S_WR_CMD，这个阶段开始写数据，发送16位（cc，跳过ROM），（44，转换T）后，进入WAIT状态
3.S_WAIT，这个阶段等待750ms，等待转换完成
4.S_INIT_AGAIN，这个阶段再次初始化，与S_INIT一样，等待总线上的应答脉冲，当flag_pulse为1时，说明收到了应答脉冲，INIT状态的1000us后进入下一个状态
5.S_RD_CMD，这个阶段开始读数据，发送16位（cc，跳过ROM），（be，读T）后，进入RD_TEMP状态
6.S_RD_TEMP，这个阶段读数据，读取2字节的数据，判断正负，输出温度(读取方法，通过移位寄存器)


仿真注意事项
需将gh18b20_ctrl的129行和144行后面的条件注释掉，如：
        if(cnt_1us == 20'd999 /*&& flag_pulse == 1'b1 */ )

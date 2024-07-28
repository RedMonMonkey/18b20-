module gh18b20_simulator(
    inout logic dq
);

// 仿真参数
timeunit 1us;
timeprecision 1us;

pullup(dq);

// 初始化状态
int init_state = 0;
time init_start_time;

initial begin
    // 初始化开始时的监测
    forever begin
        if (dq === 1'b0 && init_state === 0) begin
            // 记录开始时间
            init_start_time = $realtovertime;
            init_state = 1;
            $display("Initialization started at %0t", init_start_time);
        end else if (init_state === 1 && $realtovertime - init_start_time >= 480) begin
            // 等待480us，开始初始化过程
            $display("DQ line held low for 480us, starting init process at %0t", $realtovertime);
            init_state = 2; // 进入初始化过程状态
            #60;  // 等待60us
            dq = 1'b0;  // 模拟DS18B20将DQ拉低240us
            #240;  // 保持拉低240us
            dq = 1'b1;  // 释放DQ，模拟初始化完成
            #240;  // 等待240us
            $display("Initialization completed at %0t", $realtovertime);
            init_state = 3; // 初始化完成状态
        end
    end
end

// 监视dq信号的变化
initial begin
    $monitor("Time = %0t, DQ = %b, State = %0d", $time, dq, init_state);
end

endmodule
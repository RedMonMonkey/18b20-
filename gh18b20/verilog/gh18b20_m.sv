module gh18b20_simulator(
    inout logic dq
);

// �������
timeunit 1us;
timeprecision 1us;

pullup(dq);

// ��ʼ��״̬
int init_state = 0;
time init_start_time;

initial begin
    // ��ʼ����ʼʱ�ļ��
    forever begin
        if (dq === 1'b0 && init_state === 0) begin
            // ��¼��ʼʱ��
            init_start_time = $realtovertime;
            init_state = 1;
            $display("Initialization started at %0t", init_start_time);
        end else if (init_state === 1 && $realtovertime - init_start_time >= 480) begin
            // �ȴ�480us����ʼ��ʼ������
            $display("DQ line held low for 480us, starting init process at %0t", $realtovertime);
            init_state = 2; // �����ʼ������״̬
            #60;  // �ȴ�60us
            dq = 1'b0;  // ģ��DS18B20��DQ����240us
            #240;  // ��������240us
            dq = 1'b1;  // �ͷ�DQ��ģ���ʼ�����
            #240;  // �ȴ�240us
            $display("Initialization completed at %0t", $realtovertime);
            init_state = 3; // ��ʼ�����״̬
        end
    end
end

// ����dq�źŵı仯
initial begin
    $monitor("Time = %0t, DQ = %b, State = %0d", $time, dq, init_state);
end

endmodule
`timescale 1us/1us
module gh18b20_model(
    inout wire dq
);
logic dq_en;
time neg_time;
time pos_time;
wire rst_start;
reg rsting;
logic rst_finish;
reg [7:0] rom_ins;

logic read_finish_one_bit;
logic read_finish_one_byte;
logic reading;
logic [5:0]read_cnt;
wire [63:0]time_gap;


localparam skip_rom = 8'hcc;

pullup(dq);

initial begin
    dq_en = 1'b0;
    rsting = 1'b0;
    pos_time = 0;
    neg_time = 0;
    rst_finish = 1'b0;
    reading = 1'b0;
end

//clock
always @(negedge dq) begin
    neg_time = $realtime;
end
always @(posedge dq) begin
    pos_time = $realtime;
end
assign time_gap = pos_time - neg_time;
assign rst_start = (time_gap>= 'd480)&(rsting == 0)&(time_gap<= 'd1000);
assign dq = dq_en?1'b0:1'bz;

always @(posedge rst_start) begin
    if(dq)
    rst_detect_and_init;
end



//rst task
task rst_detect_and_init;
begin
    #5;
    rsting = 1'b1;
    begin //stop read
        reading = 1'b0;
    end
    $display("DQ line held low for 480us, starting init process at %0t", $realtime);
    #60;  // 等待60us
    dq_en = 1'b1;  // 模拟DS18B20将DQ拉低240us
    #240;  // 保持拉低240us
    dq_en = 1'b0;  // 释放DQ，模拟初始化完成
    #235;  // 等待235us
    
    rst_finish = 1'b1;
    
    #5;
    rst_finish = 1'b0;
    reading = 1;
    rsting = 1'b0;
    rom_ins = 8'b00000000;
    $display("Initialization completed at %0t", $realtime);
    
end
endtask

always @(posedge rst_finish) begin
    read_finish_one_byte = 0;
    
    read_cnt = 0;
end

//read_one_bit from master_task
task read_one_bit;
begin
    #30;
    rom_ins <= {dq,rom_ins[7:1]};
    #30;
    read_finish_one_byte = 1;
    #1;
    read_finish_one_byte = 0;
    read_cnt <= read_cnt + 1;
    
end
endtask

always @(negedge dq) begin
    if(reading) begin
        read_one_bit;
    end
end



endmodule


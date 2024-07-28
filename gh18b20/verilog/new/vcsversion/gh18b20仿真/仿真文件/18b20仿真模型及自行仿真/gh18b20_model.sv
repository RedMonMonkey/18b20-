`timescale 1us/1us
module gh18b20_model(
    inout wire dq
);
reg dq_en;
time neg_time;
time pos_time;
wire rst_start;
reg rsting;
reg rst_finish;
reg [7:0] rom_ins;
reg [7:0] op_ins;
reg send_start;
reg sending;
reg reading_one;

reg read_finish_one_bit;
reg read_finish_rom_byte;
reg read_finish_op_byte;
reg reading_rom;
reg [5:0]read_cnt;
wire [63:0]time_gap;

reg sending_all_cache;
reg sending_byte_start;

reg [5:0] send_cnt;
reg [5:0] send_byte_cnt;

reg [7:0] byte0_t_lsb;

reg [7:0] byte1_t_msb;

reg [7:0] byte2_th;

reg [7:0] byte3_tl;

reg [7:0] byte4_config;

reg [7:0] byte5_res0;

reg [7:0] byte6_res1;

reg [7:0] byte7_res2;

reg [7:0] byte7_crc;

reg [7:0] send_tmp;

reg sending_one;


reg reading_op;


localparam  SKIP_ROM    = 8'hcc;

localparam  TEMP_CONV   = 8'h44,
            READ_CACHE  = 8'hbe;

pullup(dq);

initial begin
    dq_en = 1'b0;
    rsting = 1'b0;
    pos_time = 0;
    neg_time = 0;
    rst_finish = 1'b0;
    reading_rom = 1'b0;
    send_start = 1'b0;
    sending_one = 1'b0;
    reading_op = 1'b0;
    sending = 1'b0;
    sending_all_cache = 1'b0;
    sending_byte_start = 1'b0; 

    send_cnt = 0;
    send_byte_cnt = 0;

end

//clock
always @(negedge dq) begin
    neg_time = $realtime;
end
always @(posedge dq) begin
    pos_time = $realtime;
end
assign time_gap = pos_time - neg_time;
assign rst_start = (time_gap>= 'd480)&(rsting == 0)&(time_gap<= 'd20000000);
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
        reading_rom = 1'b0;
    end
    $display("DQ line held low for 480us, starting init process at %0t", $realtime);
    #60;  // 等待60us
    dq_en = 1'b1;  // 模拟DS18B20将DQ拉低240us
    #240;  // 保持拉低240us
    dq_en = 1'b0;  // 释放DQ，模拟初始化完成
    #150;  // 等待150us
    
    rst_finish = 1'b1;
    
    #5;
    rom_ins = 8'b00000000;
    rst_finish = 1'b0;
    reading_rom = 1;
    rsting = 1'b0;
    op_ins = 8'b00000000;
    send_start = 1'b0;
    sending_one = 1'b0;
    reading_op = 1'b0;
    sending = 1'b0;
    sending_all_cache = 1'b0;
    sending_byte_start = 1'b0; 

    send_cnt = 0;
    send_byte_cnt = 0;
    byte0_t_lsb = 8'h91;
    byte1_t_msb = 8'h01;
    byte2_th = 8'h4b;
    byte3_tl = 8'h46;
    byte4_config = 8'h7f;
    byte5_res0 = 8'h55;
    byte6_res1 = 8'h55;
    byte7_res2 = 8'h55;
    byte7_crc = 8'h55;
    
    reading_one = 1'b0;

    $display("Initialization completed at %0t", $realtime);
    
end
endtask

always @(posedge rsting) begin
    read_finish_rom_byte = 0;
    
    read_cnt = 0;
end

//read_one_bit from master_task
task read_one_bit_rom;
begin
    reading_one = 1;
    #30;
    rom_ins <= {dq,rom_ins[7:1]};
    #27;
    read_finish_one_bit = 1;
    #1;
    read_finish_one_bit = 0;
    read_cnt <= read_cnt + 1;
    #1;
    if(read_cnt == 8) begin
        reading_rom = 0;
        read_finish_rom_byte = 1;
        read_cnt = 0;
    end
    #1;
    read_finish_rom_byte = 0;
    reading_one = 0;
    
end
endtask

always @(negedge dq) begin
    if(reading_rom) begin
        if(reading_one == 0)
        read_one_bit_rom;
    end
end
//judge rom instruction
always @(negedge read_finish_rom_byte) begin
    case(rom_ins)
        SKIP_ROM: begin
            reading_op = 1;
            $display("SKIP_ROM");
        end
        default: begin
            $display("error rom instruction");
        end
    endcase
end


//read_one_bit from master_task
task read_one_bit_opcode;
begin
    reading_one = 1;
    #30;
    op_ins <= {dq,op_ins[7:1]};
    #30;
    read_finish_one_bit = 1;
    #1;
    read_finish_one_bit = 0;
    read_cnt <= read_cnt + 1;
    #1;
    if(read_cnt == 8) begin
        reading_op = 0;
        read_finish_op_byte = 1;
        read_cnt = 0;
    end
    #1;
    read_finish_op_byte = 0;
    reading_one = 0;
    
end
endtask

//begin read operation code
always @(negedge dq) begin
    if(reading_op) begin
        if(reading_one == 0)
        read_one_bit_opcode;
    end
end



//judge op instruction
always @(negedge read_finish_op_byte) begin
    case(op_ins)
        TEMP_CONV: begin
            $display("TEMP_CONV");
        end
        READ_CACHE: begin
            #1;
            sending_all_cache= 1;
            sending = 1;
            $display("READ_CACHE");
        end
        default: begin
            $display("error op instruction");
        end
    endcase
end
//sending 
always @(posedge sending_all_cache) begin
    case(send_byte_cnt)
        'd0: begin
            send_tmp = byte0_t_lsb;
        end
        'd1: begin
            send_tmp = byte1_t_msb;
        end
        'd2: begin
            send_tmp = byte2_th;
        end
        'd3: begin
            send_tmp = byte3_tl;
        end
        'd4: begin
            send_tmp = byte4_config;
        end
        'd5: begin
            send_tmp = byte5_res0;
        end
        'd6: begin
            send_tmp = byte6_res1;
        end
        'd7: begin
            send_tmp = byte7_res2;
        end
        'd8: begin
            send_tmp = byte7_crc;
        end
        default: begin
            $display("error send byte cnt");
        end

        
    endcase
end

task sending_one_bit;
begin
    sending_one = 1;
    #1;
    dq_en = !send_tmp[0];
    #20;
    dq_en = 1'b0;
    send_tmp = send_tmp >> 1;
    #39;
    sending_one = 0;
    send_cnt = send_cnt + 1;

end
endtask

always @(send_cnt) begin
    if (send_cnt == 'd8) begin
        #2;
        send_cnt = 0;
        send_byte_cnt = send_byte_cnt + 1;
        sending_all_cache = 0;
        #2;
        sending_all_cache = 1;

    end
end

always @(send_byte_cnt) begin
    if (send_byte_cnt == 'd9) begin
        #2;
        sending_all_cache = 0;
        send_byte_cnt = 0;
    end
end

always @(posedge dq) begin
    if (sending) begin
        if((time_gap >= 'd1) &(time_gap <= 'd200000)&(sending_one==0))begin
            sending_one_bit;
        end
    end
end
endmodule


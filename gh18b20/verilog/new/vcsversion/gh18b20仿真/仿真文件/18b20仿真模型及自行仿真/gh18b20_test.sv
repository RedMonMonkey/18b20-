`timescale 1us/1us
module test();
    wire dq;
    reg dq_en;
    
    reg [15:0]temp;

    initial
    begin
        dq_en = 1'b0;
        #20;            //rst
        rst;
        //send SKIP_ROM
        send_skip_rom;
        send_temp_conv;
        
        rst;
        send_skip_rom;
        send_read_cache;
        reci_temp_task;

        $display("temp = %d  she shi du",temp[10:4]);

        #1000;
        $finish;

    end

    assign dq = dq_en?(1'b0):(1'bz);

    task send0;
    begin
        dq_en = 1'b1;
        #60;
        dq_en = 1'b0;
    end
    endtask

    task send1;
    begin
        dq_en = 1'b1;
        #15;
        dq_en = 1'b0;
        #45;
    end
    endtask

    task rst;
    dq_en = 1'b1;
    temp = 16'h0000;
        #480;
        dq_en = 1'b0;

        #600;
    endtask

    task send_skip_rom;
    send0;
        #20;
        send0;
        #20;
        send1;
        #20;
        send1;
        #20;
        send0;
        #20;
        send0;
        #20;
        send1;
        #20;
        send1;
        #20;
endtask

task send_temp_conv;
    send0;
    #20;
    send0;
    #20;
    send1;
    #20;
    send0;
    #20;
    send0;
    #20;
    send0;
    #20;
    send1;
    #20;
    send0;
    #20;
endtask

task send_read_cache;
    send0;
    #20;
    send1;
    #20;
    send1;
    #20;
    send1;
    #20;
    send1;
    #20;
    send1;
    #20;
    send0;
    #20;
    send1;
    #20;
endtask

task reci_temp;

endtask

task reci_bit;
    dq_en = 1'b1;
    #2;
    dq_en = 1'b0;
    #13;
    temp = {dq,temp[15:1]};
    #50;
endtask

integer i;
task reci_temp_task;
    for(i = 0; i < 16; i = i + 1)
    begin
        reci_bit;
    end
endtask

    gh18b20_model uut(
        .dq(dq)
    );

`ifdef FSDB
initial begin
$fsdbDumpfile("axi4_wr_master.fsdb");
$fsdbDumpvars(0);
$fsdbDumpMDA ;
end
`endif


    
    
    
    
    


endmodule

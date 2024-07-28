`timescale 1us/1us
module test();
    wire dq;
    reg dq_en;
    


    initial
    begin
        dq_en = 1'b0;
        #20;
        dq_en = 1'b1;
        #480;
        dq_en = 1'b0;
        #600;
        dq_en = 1'b1;
        #60;
        dq_en = 1'b0;

        #20
        dq_en = 1'b1;
        #15;
        dq_en = 1'b0;
        #1000;
        $finish;

    end

    assign dq = dq_en?(1'b0):(1'bz);

    initial begin
        $dumpfile("gh18b20test.vcd");
        $dumpvars(0, test);
    end

    gh18b20_model uut(
        .dq(dq)
    );


    
    
    
    
    


endmodule
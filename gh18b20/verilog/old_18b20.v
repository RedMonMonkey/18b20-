module gh18b20_model_control_unit(
    output reg init,
    output reg rd_sr,
    output reg [8:0] load_cache,
    output reg read_next_bit,
    output reg dq_init,
    output reg dq_trans,
    output reg load_cmd1,
    output reg load_cmd2,
    input dq,
    input clk,
    input [7:0]cmd,
    input rst
);
localparam  IDLE        =   4'b0000,
            WAIT_INIT   =   4'b0001,
            SEND_INIT   =   4'b0010,
            WAIT_ROM    =   4'b0011,
            RECV_ROM    =   4'b0100,
            WAIT_OP     =   4'b0110,
            RECV_OP     =   4'b0111,
            SEND_CACHE  =   4'b1000,
            TEMP_CONV_S =   4'b1001;
//rom code
localparam  SKIP_ROM    =   8'hCC;
//operation code
localparam  READ_CACHE  =   8'hBE,
            TEMP_CONV   =   8'h44;

localparam  LOAD_BYTE0 =    9'b000000001,       //LSB of temperature 
            LOAD_BYTE1 =    9'b000000010,       //MSB of temperature 
            LOAD_BYTE2 =    9'b000000100,       //threshold of high temperature alarm 
            LOAD_BYTE3 =    9'b000001000,       //threshold of low temperature alarm 
            LOAD_BYTE4 =    9'b000010000,       //configuration register 
            LOAD_BYTE5 =    9'b000100000,       //reserved 
            LOAD_BYTE6 =    9'b001000000,       //reserved 
            LOAD_BYTE7 =    9'b010000000,       //reserved 
            LOAD_BYTE8 =    9'b100000000;       //CRC 

reg [3:0] recv_cnt;
reg [3:0] send_cnt;

reg [3:0] state, next_state;

always @(posedge clk )           
    begin                                        
        if(rst)                                                                
            state <= IDLE;                        
        else                                     
            state <= next_state;                                                                   
    end 

always @(dq,clk,cmd,rst,state)           
    begin:output_and_next_state
        init = 0;
        rd_sr = 0;
        load_cache = 9'b0;
        read_next_bit = 0;
        dq_init = 0;
        dq_trans = 0;                                      
        case(state)
        IDLE : begin
            next_state = WAIT_INIT;
        end
        WAIT_INIT : begin
            init = 0;
            if(rst) begin #60 next_state = SEND_INIT;
            init = 1;
            end
            else next_state = WAIT_INIT;
        end
        SEND_INIT : begin
            dq_init = 0;
            if(rst) next_state = WAIT_INIT;
            else begin dq_init = 1;
                #240; 
                dq_init = 0;
                next_state = WAIT_ROM;

            end
        end
        WAIT_ROM:begin
            if(rst) next_state  = WAIT_INIT;
            else 
                #240;
                next_state = RECV_ROM;
        end
        RECV_ROM:begin
            if(rst) next_state = WAIT_INIT;
            else if (recv_cnt < 16 ) begin
                if(dq == 0) begin
                # 30;
                rd_sr = 1;
                #30;
                end else begin
                    next_state = RECV_ROM;
                end
            end
            else begin
                case (cmd)
                    SKIP_ROM: begin
                        next_state = WAIT_OP;
                    end
                    default: begin
                        next_state = RECV_OP;
                    end
                endcase
            end
        end
        RECV_OP:begin
            if(rst) next_state = WAIT_INIT;
            else if (recv_cnt < 16 ) begin
                if(dq == 0) begin
                # 30;
                rd_sr = 1;
                #30;
                end else begin
                    next_state = RECV_OP;
                end
            end
            else begin
                case (cmd)
                    TEMP_CONV: begin
                        next_state = TEMP_CONV_S;
                    end
                    READ_CACHE: begin
                        next_state = SEND_CACHE;
                    end
                    default: begin
                        next_state = RECV_OP;
                    end
                endcase
            end
        end
        TEMP_CONV_S:begin
            if(rst) next_state = WAIT_INIT;
            else begin
                next_state = TEMP_CONV_S;
            end
        end
        SEND_CACHE:begin
            if(rst) next_state = WAIT_INIT;
            else if (recv_cnt < 8 ) begin
                if(dq == 0) begin
                # 30;
                dq_init = 1;
                dq_trans = 1;
                #30;
                end else begin
                next_state = SEND_CACHE;
                end
                else if (send_cnt = 8) begin
                    
                end
            end
        end

        endcase                                   
    end                                          

endmodule

module gh18b20_model_datapath(
    inout dq,
    output reg [15:0]cmd,        ////shift register,receive 8 bits cmd
    output reg rst,
    //from control_unit
    input clk,
    input init,
    input rd_sr,
    input [8:0]load_cache,       //load cache
    input read_next_bit,
    input dq_init,
    input dq_trans
);
localparam  LOAD_BYTE0 =    9'b000000001,       //LSB of temperature 
            LOAD_BYTE1 =    9'b000000010,       //MSB of temperature 
            LOAD_BYTE2 =    9'b000000100,       //threshold of high temperature alarm 
            LOAD_BYTE3 =    9'b000001000,       //threshold of low temperature alarm 
            LOAD_BYTE4 =    9'b000010000,       //configuration register 
            LOAD_BYTE5 =    9'b000100000,       //reserved 
            LOAD_BYTE6 =    9'b001000000,       //reserved 
            LOAD_BYTE7 =    9'b010000000,       //reserved 
            LOAD_BYTE8 =    9'b100000000;       //CRC 

//cache
reg [7:0]   byte0;      //LSB of temperature
reg [7:0]   byte1;      //MSB of temperature
reg [7:0]   byte2;      //threshold of high temperature alarm
reg [7:0]   byte3;      //threshold of low temperature alarm
reg [7:0]   byte4;      //configuration register
reg [7:0]   byte5;      //reserved
reg [7:0]   byte6;      //reserved
reg [7:0]   byte7;      //reserved
reg [7:0]   byte8;      //CRC

reg [5:0]   rst_count;  //receive 0 in 470us mean reset 



always @(posedge clk or posedge init)           
    if(init)
        cmd <= 15'b0;
    else if(rd_sr)
        cmd <= {dq,cmd[15:1]};                                  

//send all cache
reg [7:0] data_buf;

always @(posedge clk or posedge init) begin
    if (init) begin
        data_buf <= 8'b0;
    end
    else if (load_cache)begin
        case(load_cache) 
            LOAD_BYTE0: data_buf <= byte0;
            LOAD_BYTE1: data_buf <= byte1;
            LOAD_BYTE2: data_buf <= byte2;
            LOAD_BYTE3: data_buf <= byte3;
            LOAD_BYTE4: data_buf <= byte4;
            LOAD_BYTE5: data_buf <= byte5;
            LOAD_BYTE6: data_buf <= byte6;
            LOAD_BYTE7: data_buf <= byte7;
            LOAD_BYTE8: data_buf <= byte8;
        endcase
    end
    else if(read_next_bit)
        data_buf <= data_buf >>1; 	//将寄存器内的值左移，依次读出
        //data_buf <= {data_buf[6:0],1'b0};
        end


//cache init
always @(posedge clk or posedge init) begin
    if (init) begin
        byte0 <= 8'h91;
        byte1 <= 8'h01;
        byte2 <= 8'h55;
        byte3 <= 8'h55;
        byte4 <= 8'hD5;
        byte5 <= 8'h6F;
        byte6 <= 8'hFF;
        byte7 <= 8'hFF;
        byte8 <= 8'h00;
    end
end

//rst,
always @(posedge clk) begin
    rst <= 0 ;
    if (rst_count == 47) begin
        rst <= 1;
    end
    else
        rst <= 0;
end

always @(posedge clk) begin
    if (rst) begin
        rst_count <= 0;
    end
    else if (dq==0)
        rst_count <= 0;
    else if (rst_count < 94)
        rst_count <= rst_count + 1;
end

        
assign dq = dq_init?1'b1:dq_trans?(data_buf[0]):1'bz;



endmodule


//LSB of temperature
//MSB of temperature
//threshold of high temperature alarm
//threshold of low temperature alarm
//configuration register
//reserved
//reserved
//reserved
//CRC
 //load cache
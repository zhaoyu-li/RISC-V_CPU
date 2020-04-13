`include "Defines.v"

module MEM_Ctrl(
    input wire               clk,
    input wire               rst,
    input wire               rdy,
    
    input wire               branch_flag_i,
    
    input wire[`InstAddrBus] if_addr_i,
    
    input wire               mem_ls_i,                    // load/store signal (0 for laod)    
    input wire[`MemAddrBus]  mem_addr_i,
    input wire[`MemDataBus]  mem_data_i,
    input wire[2:0]          mem_sel_i,
    input wire               mem_req_i,
    
    input wire[7:0]          din,
    
    output reg[7:0]          dout,
    output reg[`InstAddrBus] addr,
    output wire              wr,                          // write/read signal (1 for write)
    
    output reg[`InstBus]     if_inst_o,
    output reg[`MemDataBus]  mem_data_o,
    
    output reg               if_stallreq,
    output reg               mem_stallreq
    );
    
    reg[`InstAddrBus] Icache[`Cacheline];
    reg[`InstAddrBus] Icache_tag[`Cacheline];
    wire[5:0] index;
    
    reg cache_hit;
    
    reg[2:0] counter;
    reg[2:0] circle;
    reg flag;                                             //0 for if, 1 for load and store
    
    reg mem_ls;
    reg[`MemAddrBus] mem_addr;
    reg[`MemDataBus] mem_data;
    reg[2:0] mem_sel;
    
    reg[`InstAddrBus] _if_inst_o;
    reg[`MemDataBus] _mem_data_o;
    
    assign wr = ((flag == 1'b1) && (mem_ls == 1'b1) && (counter != circle)) ? 1'b1 : 1'b0;
    assign index = if_addr_i[6:2];
    
    always @ (negedge clk) begin
        if ((Icache_tag[index] == if_addr_i) && (flag == 1'b0) && (counter == 0)) begin
            cache_hit <= 1'b1;
            if_inst_o <= Icache[index];
            _if_inst_o <= Icache[index];
        end else begin
            cache_hit <= 1'b0;
        end
    end
    
    always @ (negedge clk) begin
        if (cache_hit == 1'b0 && flag == 1'b0 && counter == circle) begin
            Icache[index] <= if_inst_o;
            Icache_tag[index] <= if_addr_i;
        end
    end
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            if_stallreq = `NoStop;
        end else if (rdy == `NotReady) begin
            if_stallreq = `Stop;
        end else if (cache_hit == 1'b1) begin
            if_stallreq = `NoStop;
        end else if (counter == circle) begin
            if_stallreq = `NoStop;
        end else begin
            if_stallreq = `Stop;
        end
    end
    
    always @ (negedge clk) begin
        if (rst == `RstEnable) begin
            mem_stallreq = `NoStop;
        end else if ((mem_req_i == 1'b1) && (flag == 1'b0)) begin
            mem_stallreq = `Stop;
            mem_ls = mem_ls_i;
            mem_addr = mem_addr_i;
            mem_data = mem_data_i;
            mem_sel = mem_sel_i;
        end else if ((counter == circle) && (flag == 1'b1)) begin
            mem_stallreq = `NoStop;
        end
    end
    
    //counter
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            counter <= 3'b000;
            circle <= 3'b100;
            flag <= 1'b0;
        end else if (rdy == `NotReady) begin
            counter <= 3'b000;
            circle <= 3'b100;
            flag <= 1'b0;
        end else if ((branch_flag_i == `Branch) && (mem_stallreq != `Stop)) begin
            counter <= 3'b000;
            circle <= 3'b100;
            flag <= 1'b0;
        end else if (cache_hit == 1'b1) begin
            counter <= 3'b000;
            if (mem_stallreq == 1'b1) begin
                flag <= 1'b1;
                circle <= mem_sel;
            end else begin
                flag <= 1'b0;
                circle <= 3'b100;
            end
        end else if (counter == circle) begin
            counter <= 3'b000;
            if (mem_stallreq == 1'b1) begin
                flag <= 1'b1;
                circle <= mem_sel;
            end else begin
                flag <= 1'b0;
                circle <= 3'b100;
            end
        end else begin
            counter <= counter + 3'b001;
        end
    end
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            addr = `ZeroWord;
        end else if (flag == 1'b0) begin
            addr = if_addr_i + counter;
        end else if (flag == 1'b1) begin
            if(flag == 1'b1 && mem_ls == 1'b0 && circle == 3'b001) begin
                addr = mem_addr;
            end else begin
                addr = mem_addr + counter;
            end
        end else begin
            addr = addr;
        end
    end
    
    always @ (posedge clk) begin
        _if_inst_o <= if_inst_o;
        _mem_data_o <= mem_data_o;
    end
    
    //if
    always @ (*) begin
        if (rst == `RstEnable) begin
            if_inst_o = `ZeroWord;
        end else if (flag == 1'b0 && cache_hit == 1'b0) begin
            case (counter)
                3'b001 : begin
                    if_inst_o = {_if_inst_o[31:8], din};
                end
                3'b010 : begin
                    if_inst_o = {_if_inst_o[31:16], din, _if_inst_o[7:0]};
                end
                3'b011 : begin
                    if_inst_o = {_if_inst_o[31:24], din, _if_inst_o[15:0]};
                end
                3'b100 : begin
                    if_inst_o = {din, _if_inst_o[23:0]};
                end
                default : begin
                    if_inst_o = _if_inst_o;
                end
            endcase
        end else begin
            if_inst_o = _if_inst_o;
        end
    end
    
    //load
    always @ (*) begin
        if (rst == `RstEnable) begin
            mem_data_o = `ZeroWord;
        end else if (flag == 1'b1 && mem_ls == 1'b0) begin
            case (counter)
                3'b001 : begin
                    mem_data_o = {24'b0, din};
                end
                3'b010 : begin
                    mem_data_o = {16'b0, din, _mem_data_o[7:0]};
                end
                3'b011 : begin
                    mem_data_o = {8'b0, din, _mem_data_o[15:0]};
                end
                3'b100 : begin
                    mem_data_o = {din, _mem_data_o[23:0]};
                end
                default : begin
                    mem_data_o = _mem_data_o;
                end
            endcase
        end else begin
            mem_data_o = _mem_data_o;
        end
    end
    
    //store
    always @ (*) begin
        if (rst == `RstEnable) begin
            dout = 8'b00000000;
        end else if (flag == 1'b1 && mem_ls == 1'b1) begin
            if (counter < circle) begin
                case (counter)
                    3'b000 : begin
                        dout = mem_data[7:0];
                    end
                    3'b001 : begin
                        dout = mem_data[15:8];
                    end
                    3'b010 : begin
                        dout = mem_data[23:16];
                    end
                    3'b011 : begin
                        dout = mem_data[31:24];
                    end
                    default : begin
                        dout = 8'b00000000;
                    end
                endcase
            end else begin
                dout = 8'b00000000;
            end
        end else begin
            dout = 8'b00000000;
        end
    end
    
endmodule

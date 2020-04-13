`include "Defines.v"

module IF_ID(
    input wire               clk,
    input wire               rst,
    
    input wire[5:0]          stall,
    
    input wire               branch_flag_i,
    
    input wire[`InstAddrBus] if_pc,
    input wire[`InstBus]     if_inst,
    
    output reg[`InstAddrBus] id_pc,
    output reg[`InstBus]     id_inst
    );
    
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end else if (stall[1] == `Stop && stall[2] == `NoStop) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end else if (stall[1] == `NoStop) begin
            if (branch_flag_i == `Branch) begin
                id_pc <= `ZeroWord;
                id_inst <= `ZeroWord;
            end else begin
                id_pc <= if_pc;
                id_inst <= if_inst;
                //$display("%h", if_inst);
            end
        end
    end

endmodule

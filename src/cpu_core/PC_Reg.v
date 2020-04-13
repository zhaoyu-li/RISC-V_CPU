`include "Defines.v"

module PC_Reg(
    input wire               clk,
    input wire               rst,
    
    input wire[5:0]          stall,
    
    input wire               branch_flag_i,
    input wire[`RegBus]      branch_target_address_i,
    
    output reg[`InstAddrBus] pc
    );

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            pc <= `ZeroWord;
        end else if (branch_flag_i == `Branch) begin
            pc <= branch_target_address_i;
        end else if(stall[0] == `NoStop) begin
            pc <= pc + 32'd4;
        end
    end
    
endmodule

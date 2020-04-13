`include "Defines.v"

module EX_MEM(
    input wire               clk,
    input wire               rst,
    
    input wire[5:0]          stall,
    
    input wire[`AluOpBus]    ex_aluop,
    input wire[`MemAddrBus]  ex_mem_addr,
    
    input wire[`RegAddrBus]  ex_wd,
    input wire               ex_wreg,
    input wire[`RegBus]      ex_wdata,

    output reg[`RegAddrBus]  mem_wd,
    output reg               mem_wreg,
    output reg[`RegBus]      mem_wdata,
    
    output reg[`AluOpBus]    mem_aluop,
    output reg[`MemAddrBus]  mem_mem_addr
    );
    
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            mem_wd <= `NOPRegAddr;
            mem_wreg <= `WriteDisable;
            mem_wdata <= `ZeroWord;
            mem_aluop <= `EXE_NOP_OP;
            mem_mem_addr <= `ZeroWord;
        end else if(stall[3] == `Stop && stall[4] == `NoStop) begin
            mem_wd <= `NOPRegAddr;
            mem_wreg <= `WriteDisable;
            mem_wdata <= `ZeroWord;
            mem_aluop <= `EXE_NOP_OP;
            mem_mem_addr <= `ZeroWord;
        end else if (stall[3] == `NoStop) begin
            mem_wd <= ex_wd;
            mem_wreg <= ex_wreg;
            mem_wdata <= ex_wdata;
            mem_aluop <= ex_aluop;
            mem_mem_addr <= ex_mem_addr;
        end
    end
    
endmodule

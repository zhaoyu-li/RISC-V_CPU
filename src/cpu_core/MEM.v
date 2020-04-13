`include "Defines.v"

module MEM(
    input wire              rst,
    
    input wire[`AluOpBus]   aluop_i,    
    input wire[`MemAddrBus] mem_addr_i,
    input wire[`MemDataBus] mem_data_i,
    
    input wire[`RegAddrBus] wd_i,
    input wire              wreg_i,
    input wire[`RegBus]     wdata_i,
    
    output reg[`RegAddrBus] wd_o,
    output reg              wreg_o,
    output reg[`RegBus]     wdata_o,
    
    output reg[`MemAddrBus] mem_addr_o,
    output reg[2:0]         mem_sel_o,
    output reg[`RegBus]     mem_data_o,    
    output reg              mem_ls_o,
    output reg              mem_req_o
    );
        
    always @ (*) begin
        if (rst == `RstEnable) begin
            wd_o = `NOPRegAddr;
            wreg_o = `WriteDisable;
            wdata_o = `ZeroWord;
            mem_req_o = `MemNotReq;
            mem_addr_o = `ZeroWord;
            mem_sel_o = `MemSelZero;
            mem_data_o = `ZeroWord;
            mem_ls_o = `Load;
        end else begin
            wd_o = wd_i;
            wreg_o = wreg_i;
            wdata_o = wdata_i;
            mem_addr_o = mem_addr_i;
            mem_req_o = `MemNotReq;
            mem_sel_o = `MemSelZero;
            mem_data_o = `ZeroWord;
            mem_ls_o = `Load;
            case (aluop_i)
                `EXE_LB_OP : begin
                    mem_req_o = `MemReq;
                    mem_ls_o = `Load;
                    mem_data_o = `ZeroWord;
                    mem_sel_o = 3'b001;
                    wdata_o = {{24{mem_data_i[7]}}, mem_data_i[7:0]};
                end
                `EXE_LH_OP : begin
                    mem_req_o = `MemReq;
                    mem_ls_o = `Load;
                    mem_data_o = `ZeroWord;
                    mem_sel_o = 3'b010;
                    wdata_o = {{16{mem_data_i[15]}}, mem_data_i[15:0]};
                end
                `EXE_LW_OP : begin
                    mem_req_o = `MemReq;
                    mem_ls_o = `Load;
                    mem_data_o = `ZeroWord;
                    mem_sel_o = 3'b100;
                    wdata_o = mem_data_i;
                end
                `EXE_LBU_OP : begin
                    mem_req_o = `MemReq;
                    mem_ls_o = `Load;
                    mem_data_o = `ZeroWord;
                    mem_sel_o = 3'b001;
                    wdata_o = {{24{1'b0}}, mem_data_i[7:0]};
                end
                `EXE_LHU_OP : begin
                    mem_req_o = `MemReq;
                    mem_ls_o = `Load;
                    mem_data_o = `ZeroWord;
                    mem_sel_o = 3'b010;
                    wdata_o = {{16{1'b0}}, mem_data_i[15:0]};
                end
                `EXE_SB_OP : begin
                    mem_req_o = `MemReq;
                    mem_ls_o = `Store;
                    mem_data_o = {4{wdata_i[7:0]}};
                    mem_sel_o = 3'b001;
                    wdata_o = `ZeroWord;
                end
                `EXE_SH_OP : begin
                    mem_req_o = `MemReq;
                    mem_ls_o = `Store;
                    mem_data_o = {2{wdata_i[15:0]}};
                    mem_sel_o = 3'b010;
                    wdata_o = `ZeroWord;
                end
                `EXE_SW_OP : begin
                    mem_req_o = `MemReq;
                    mem_ls_o = `Store;
                    mem_data_o = wdata_i;
                    mem_sel_o = 3'b100;
                    wdata_o = `ZeroWord;
                end
                default : begin
                end
            endcase
        end
    end
    
endmodule

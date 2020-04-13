`include "Defines.v"

module EX(
    input wire                rst,
    
    input wire[`AluOpBus]     aluop_i,
    input wire[`AluSelBus]    alusel_i,
    input wire[`RegBus]       reg1_i,
    input wire[`RegBus]       reg2_i,
    input wire[`RegAddrBus]   wd_i,
    input wire                wreg_i,
    
    input wire[`RegBus]       link_address_i,
    input wire[`RegBus]       mem_offset_i,
    
    output reg[`RegAddrBus]   wd_o,
    output reg                wreg_o,
    output reg[`RegBus]       wdata_o,
    
    output wire[`AluOpBus]    aluop_o,
    output reg[`MemAddrBus]   mem_addr_o
    );
    
    reg[`RegBus]            logic_res;
    reg[`RegBus]            shift_res;
    reg[`RegBus]            arithmetic_res;
    reg[`RegBus]            mem_res;
    
    wire[`RegBus]           result_sum;
    wire                    reg1_eq_reg2;
    wire                    reg1_lt_reg2;
    
    assign aluop_o = aluop_i;
    
    assign result_sum = (aluop_i == `EXE_ADD_OP ? reg1_i + reg2_i : reg1_i - reg2_i);
    assign reg1_lt_reg2 = ((aluop_i == `EXE_SLT_OP || aluop_i == `EXE_BLT_OP || aluop_i == `EXE_BGE_OP) ? 
                    $signed(reg1_i) < $signed(reg2_i) : reg1_i < reg2_i);
    assign reg1_eq_reg2 = (reg1_i == reg2_i);
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            logic_res = `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_OR_OP : begin
                    logic_res = reg1_i | reg2_i;
                end
                `EXE_AND_OP : begin
                    logic_res = reg1_i & reg2_i;
                end
                `EXE_XOR_OP : begin
                    logic_res = reg1_i ^ reg2_i;
                end
                default : begin
                    logic_res = `ZeroWord;
                end
            endcase
        end
    end
    
    always @ (*) begin
        if(rst == `RstEnable) begin
            shift_res = `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_SLL_OP : begin
                    shift_res = reg1_i << reg2_i[4:0] ;
                end
                `EXE_SRL_OP : begin
                    shift_res = reg1_i >> reg2_i[4:0];
                end
                `EXE_SRA_OP : begin
                    shift_res = ({32{reg1_i[31]}} << (6'd32-{1'b0, reg2_i[4:0]})) | reg1_i >> reg2_i[4:0];
                end
                default : begin
                    shift_res = `ZeroWord;
                end
            endcase
        end
    end
    
    always @ (*) begin
        if(rst == `RstEnable) begin
            arithmetic_res = `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_SLT_OP, `EXE_SLTU_OP : begin
                    arithmetic_res = reg1_lt_reg2 ;
                end
                `EXE_ADD_OP, `EXE_SUB_OP : begin
                    arithmetic_res = result_sum;
                end
                default : begin
                    arithmetic_res = `ZeroWord;
                end
            endcase
        end
    end
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            mem_res = `ZeroWord;
        end else begin
            case (alusel_i)
                `EXE_RES_LOAD_STORE : begin
                    mem_res = reg1_i + mem_offset_i;
                end
                default : begin
                    mem_res = `ZeroWord;
                end
            endcase
        end
    end
    
    always @ (*) begin
        wd_o = wd_i;
        wreg_o = wreg_i;
        case (alusel_i)
            `EXE_RES_LOGIC : begin
                wdata_o = logic_res;
                mem_addr_o = `ZeroWord;
            end
            `EXE_RES_SHIFT : begin
                wdata_o = shift_res;
                mem_addr_o = `ZeroWord;
            end
            `EXE_RES_ARITHMETIC : begin
                wdata_o = arithmetic_res;
                mem_addr_o = `ZeroWord;
            end
            `EXE_RES_JUMP_BRANCH : begin
                wdata_o = link_address_i;
                mem_addr_o = `ZeroWord;
            end
            `EXE_RES_LOAD_STORE : begin
                wdata_o = reg2_i;
                mem_addr_o = mem_res;
            end
            default : begin
                wdata_o = `ZeroWord;
                mem_addr_o = `ZeroWord;
            end
        endcase
    end
    
endmodule

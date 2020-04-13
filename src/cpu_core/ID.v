`include "Defines.v"

module ID(
    input wire                 rst,
	input wire[`InstAddrBus]   pc_i,
	input wire[`InstBus]       inst_i,
	
	input wire[`RegBus]        reg1_data_i,
    input wire[`RegBus]        reg2_data_i,
	
	input wire[`AluOpBus]      ex_aluop_i,
	input wire                 ex_wreg_i,
    input wire[`RegBus]        ex_wdata_i,
    input wire[`RegAddrBus]    ex_wd_i,
    
    input wire                 mem_wreg_i,
    input wire[`RegBus]        mem_wdata_i,
    input wire[`RegAddrBus]    mem_wd_i,
        
    output reg                 reg1_read_o,
    output reg                 reg2_read_o,     
    output reg[`RegAddrBus]    reg1_addr_o,
    output reg[`RegAddrBus]    reg2_addr_o,           
    
    output reg[`AluOpBus]      aluop_o,
    output reg[`AluSelBus]     alusel_o,
    output reg[`RegBus]        reg1_o,
    output reg[`RegBus]        reg2_o,
    output reg[`RegAddrBus]    wd_o,
    output reg                 wreg_o,
    
    output reg                 branch_flag_o,
    output reg[`RegBus]        branch_target_address_o,       
    output reg[`RegBus]        link_addr_o,
    
    output reg[`RegBus]        mem_offset_o
    
    //output wire                stallreq
    );
    
    wire[6:0] opcode =	inst_i[6:0];
    wire[4:0] rd = inst_i[11:7];
    wire[2:0] funct3 = inst_i[14:12];
    wire[4:0] rs1 = inst_i[19:15];
    wire[4:0] rs2 = inst_i[24:20];
    wire[6:0] funct7 = inst_i[31:25];
    wire[31:0] imm_I  = {{20{inst_i[31]}}, inst_i[31:20]};
    wire[31:0] imm_S = {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
    wire[31:0] imm_B = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8],1'h0};
    wire[31:0] imm_U = {inst_i[31:12], 12'h0};
    wire[31:0] imm_J = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21],1'h0};
    
    //reg stallreq_for_reg1_loadrelate;
    //reg stallreq_for_reg2_loadrelate;
    //assign stallreq = stallreq_for_reg1_loadrelate | stallreq_for_reg2_loadrelate;
    
    //wire pre_inst_is_load = (ex_aluop_i == `EXE_LB_OP)  || (ex_aluop_i == `EXE_LH_OP)  ||
    //                         (ex_aluop_i == `EXE_LW_OP)  || (ex_aluop_i == `EXE_LBU_OP) ||
    ///                         (ex_aluop_i == `EXE_LHU_OP);
    
    reg[`RegBus] imm1;
    reg[`RegBus] imm2;
    reg instvalid;
    
    wire[`RegBus] pc_plus_4 = pc_i + 4;
    wire[`RegBus] reg1_data_plus_imm_I;
    assign reg1_data_plus_imm_I = reg1_data_i + imm_I;
        
    always @ (*) begin
        if (rst == `RstEnable) begin
            alusel_o = `EXE_RES_NOP;
            aluop_o = `EXE_NOP_OP;
            instvalid = `InstInvalid;
            reg1_read_o = `ReadDisable;
            reg1_addr_o = `NOPRegAddr;
            reg2_read_o =`ReadDisable;
            reg2_addr_o = `NOPRegAddr;
            wreg_o = `WriteDisable;
            wd_o = `NOPRegAddr;
            imm1 = `ZeroWord;
            imm2 = `ZeroWord;
            mem_offset_o = `ZeroWord;
            branch_flag_o = `NotBranch;
            branch_target_address_o = `ZeroWord;
            link_addr_o = `ZeroWord;
        end else begin
            alusel_o = `EXE_RES_NOP;
            aluop_o = `EXE_NOP_OP;
            instvalid = `InstInvalid;
            reg1_read_o = `ReadDisable;
            reg1_addr_o = `NOPRegAddr;
            reg2_read_o = `ReadDisable;
            reg2_addr_o = `NOPRegAddr;
            wreg_o = `WriteDisable;
            wd_o =  `NOPRegAddr;
            imm1 = `ZeroWord;
            imm2 = `ZeroWord;
            mem_offset_o = `ZeroWord;
            branch_flag_o = `NotBranch;
            branch_target_address_o = `ZeroWord;
            link_addr_o = `ZeroWord;
            case (opcode)
                `OP_LUI : begin
                    alusel_o = `EXE_RES_ARITHMETIC;
                    aluop_o = `EXE_ADD_OP;
                    instvalid = `InstValid;
                    reg1_read_o = `ReadDisable;
                    reg1_addr_o = `NOPRegAddr;
                    reg2_read_o = `ReadDisable;
                    reg2_addr_o = `NOPRegAddr;
                    wreg_o = `WriteEnable;
                    wd_o = rd;
                    imm1 = imm_U;
                    imm2 = `ZeroWord;
                    mem_offset_o = `ZeroWord;
                end
                `OP_AUIPC : begin
                    alusel_o = `EXE_RES_ARITHMETIC;
                    aluop_o = `EXE_ADD_OP;
                    instvalid = `InstValid;
                    reg1_read_o = `ReadDisable;
                    reg1_addr_o = `NOPRegAddr;
                    reg2_read_o = `ReadDisable;
                    reg2_addr_o = `NOPRegAddr;
                    wreg_o = `WriteEnable;
                    wd_o = rd;
                    imm1 = imm_U;
                    imm2 = pc_i;
                    mem_offset_o = `ZeroWord;
                end
                `OP_JAL : begin
                    alusel_o = `EXE_RES_JUMP_BRANCH;
                    aluop_o = `EXE_JAL_OP;
                    instvalid = `InstValid;
                    reg1_read_o = `ReadDisable;
                    reg1_addr_o = `NOPRegAddr;
                    reg2_read_o = `ReadDisable;
                    reg2_addr_o = `NOPRegAddr;
                    wreg_o = `WriteEnable;
                    wd_o = rd;
                    imm1 = `ZeroWord;
                    imm2 = `ZeroWord;
                    mem_offset_o = `ZeroWord;
                    branch_flag_o = `Branch;
                    branch_target_address_o = pc_i + imm_J;
                    link_addr_o = pc_plus_4;
                end
                `OP_JALR : begin
                    alusel_o = `EXE_RES_JUMP_BRANCH;
                    aluop_o = `EXE_JALR_OP;
                    instvalid = `InstValid;
                    reg1_read_o = `ReadEnable;
                    reg1_addr_o =  rs1;
                    reg2_read_o = `ReadDisable;
                    reg2_addr_o = `NOPRegAddr;
                    wreg_o = `WriteEnable;
                    wd_o = rd;
                    imm1 = `ZeroWord;
                    imm2 = `ZeroWord;
                    mem_offset_o = `ZeroWord;
                    branch_flag_o = `Branch;
                    branch_target_address_o = {reg1_data_plus_imm_I[31:1], 1'h0};
                    link_addr_o = pc_plus_4;           
                end
                `OP_BRANCH : begin
                    case (funct3)
                        `FUNCT3_BEQ : begin
                            alusel_o = `EXE_RES_JUMP_BRANCH;
                            aluop_o = `EXE_BEQ_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadEnable;
                            reg2_addr_o = rs2;
                            wreg_o = `WriteDisable;
                            wd_o =  `NOPRegAddr;
                            imm1 = `ZeroWord;
                            imm2 = `ZeroWord;
                            mem_offset_o = `ZeroWord;
                            if (reg1_o == reg2_o) begin
                                branch_flag_o = `Branch;
                                branch_target_address_o = pc_i + imm_B;
                                link_addr_o = `ZeroWord;
                            end
                        end
                        `FUNCT3_BNE : begin
                            alusel_o = `EXE_RES_JUMP_BRANCH;
                            aluop_o = `EXE_BNE_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadEnable;
                            reg2_addr_o = rs2;
                            wreg_o = `WriteDisable;
                            wd_o =  `NOPRegAddr;
                            imm1 = `ZeroWord;
                            imm2 = `ZeroWord;
                            mem_offset_o = `ZeroWord;
                            if (reg1_o != reg2_o) begin
                                branch_flag_o = `Branch;
                                branch_target_address_o = pc_i + imm_B;
                                link_addr_o = `ZeroWord;
                            end
                        end
                        `FUNCT3_BLT : begin
                            alusel_o = `EXE_RES_JUMP_BRANCH;
                            aluop_o = `EXE_BLT_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadEnable;
                            reg2_addr_o = rs2;
                            wreg_o = `WriteDisable;
                            wd_o =  `NOPRegAddr;
                            imm1 = `ZeroWord;
                            imm2 = `ZeroWord;
                            mem_offset_o = `ZeroWord;
                            if ($signed(reg1_o) < $signed(reg2_o)) begin
                                branch_flag_o = `Branch;
                                branch_target_address_o = pc_i + imm_B;
                                link_addr_o = `ZeroWord;
                            end
                        end
                        `FUNCT3_BGE : begin
                            alusel_o = `EXE_RES_JUMP_BRANCH;
                            aluop_o = `EXE_BGE_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadEnable;
                            reg2_addr_o = rs2;
                            wreg_o = `WriteDisable;
                            wd_o =  `NOPRegAddr;
                            imm1 = `ZeroWord;
                            imm2 = `ZeroWord;
                            mem_offset_o = `ZeroWord;
                            if ($signed(reg1_o) >= $signed(reg2_o)) begin
                                branch_flag_o = `Branch;
                                branch_target_address_o = pc_i + imm_B;
                                link_addr_o = `ZeroWord;
                            end
                        end
                        `FUNCT3_BLTU : begin
                            alusel_o = `EXE_RES_JUMP_BRANCH;
                            aluop_o = `EXE_BLTU_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadEnable;
                            reg2_addr_o = rs2;
                            wreg_o = `WriteDisable;
                            wd_o =  `NOPRegAddr;
                            imm1 = `ZeroWord;
                            imm2 = `ZeroWord;
                            mem_offset_o = `ZeroWord;
                            if (reg1_o < reg2_o) begin
                                branch_flag_o = `Branch;
                                branch_target_address_o = pc_i + imm_B;
                                link_addr_o = `ZeroWord;
                            end
                        end
                        `FUNCT3_BGEU : begin
                            alusel_o = `EXE_RES_JUMP_BRANCH;
                            aluop_o = `EXE_BGEU_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadEnable;
                            reg2_addr_o = rs2;
                            wreg_o = `WriteDisable;
                            wd_o =  `NOPRegAddr;
                            imm1 = `ZeroWord;
                            imm2 = `ZeroWord;
                            mem_offset_o = `ZeroWord;
                            if (reg1_o >= reg2_o) begin
                                branch_flag_o = `Branch;
                                branch_target_address_o = pc_i + imm_B;
                                link_addr_o = `ZeroWord;
                            end
                        end
                        default : begin
                        end
                    endcase
                end
                `OP_LOAD : begin
                    case (funct3)
                        `FUNCT3_LB : begin
                            alusel_o = `EXE_RES_LOAD_STORE;
                            aluop_o = `EXE_LB_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadDisable;
                            reg2_addr_o = `NOPRegAddr;
                            wreg_o = `WriteEnable;
                            wd_o =  rd;
                            imm1 = `ZeroWord;
                            imm2 = `ZeroWord;
                            mem_offset_o = imm_I;
                        end
                        `FUNCT3_LH : begin
                            alusel_o = `EXE_RES_LOAD_STORE;
                            aluop_o = `EXE_LH_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadDisable;
                            reg2_addr_o = `NOPRegAddr;
                            wreg_o = `WriteEnable;
                            wd_o =  rd;
                            imm1 = `ZeroWord;
                            imm2 = `ZeroWord;
                            mem_offset_o = imm_I;
                        end
                        `FUNCT3_LW : begin
                             alusel_o = `EXE_RES_LOAD_STORE;
                             aluop_o = `EXE_LW_OP;
                             instvalid = `InstValid;
                             reg1_read_o = `ReadEnable;
                             reg1_addr_o = rs1;
                             reg2_read_o = `ReadDisable;
                             reg2_addr_o = `NOPRegAddr;
                             wreg_o = `WriteEnable;
                             wd_o =  rd;
                             imm1 = `ZeroWord;
                             imm2 = `ZeroWord;
                             mem_offset_o = imm_I;
                        end
                        `FUNCT3_LBU : begin
                             alusel_o = `EXE_RES_LOAD_STORE;
                             aluop_o = `EXE_LBU_OP;
                             instvalid = `InstValid;
                             reg1_read_o = `ReadEnable;
                             reg1_addr_o = rs1;
                             reg2_read_o = `ReadDisable;
                             reg2_addr_o = `NOPRegAddr;
                             wreg_o = `WriteEnable;
                             wd_o =  rd;
                             imm1 = `ZeroWord;
                             imm2 = `ZeroWord;
                             mem_offset_o = imm_I;
                        end
                        `FUNCT3_LHU : begin
                             alusel_o = `EXE_RES_LOAD_STORE;
                             aluop_o = `EXE_LHU_OP;
                             instvalid = `InstValid;
                             reg1_read_o = `ReadEnable;
                             reg1_addr_o = rs1;
                             reg2_read_o = `ReadDisable;
                             reg2_addr_o = `NOPRegAddr;
                             wreg_o = `WriteEnable;
                             wd_o =  rd;
                             imm1 = `ZeroWord;
                             imm2 = `ZeroWord;
                             mem_offset_o = imm_I;
                        end
                        default : begin
                        end
                    endcase
                end
                `OP_STORE : begin
                    case (funct3)
                        `FUNCT3_SB : begin
                            alusel_o = `EXE_RES_LOAD_STORE;
                            aluop_o = `EXE_SB_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadEnable;
                            reg2_addr_o = rs2;
                            wreg_o = `WriteDisable;
                            wd_o =  `NOPRegAddr;
                            imm1 = `ZeroWord;
                            imm2 = `ZeroWord;
                            mem_offset_o = imm_S;
                        end
                        `FUNCT3_SH : begin
                            alusel_o = `EXE_RES_LOAD_STORE;
                            aluop_o = `EXE_SH_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadEnable;
                            reg2_addr_o = rs2;
                            wreg_o = `WriteDisable;
                            wd_o =  `NOPRegAddr;
                            imm1 = `ZeroWord;
                            imm2 = `ZeroWord;
                            mem_offset_o = imm_S;
                        end
                        `FUNCT3_SW : begin
                            alusel_o = `EXE_RES_LOAD_STORE;
                            aluop_o = `EXE_SW_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadEnable;
                            reg2_addr_o = rs2;
                            wreg_o = `WriteDisable;
                            wd_o =  `NOPRegAddr;
                            imm1 = `ZeroWord;
                            imm2 = `ZeroWord;
                            mem_offset_o = imm_S;
                        end
                        default : begin
                        end
                    endcase
                end
                `OP_OPI : begin
                    case (funct3)
                        `FUNCT3_ADDI : begin
                            alusel_o = `EXE_RES_ARITHMETIC;
                            aluop_o = `EXE_ADD_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadDisable;
                            reg2_addr_o = `NOPRegAddr;
                            wreg_o = `WriteEnable;
                            wd_o =  rd;
                            imm1 = `ZeroWord;
                            imm2 = imm_I;
                            mem_offset_o = `ZeroWord;
                        end
                        `FUNCT3_SLTI : begin
                            alusel_o = `EXE_RES_ARITHMETIC;
                            aluop_o = `EXE_SLT_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadDisable;
                            reg2_addr_o = `NOPRegAddr;
                            wreg_o = `WriteEnable;
                            wd_o =  rd;
                            imm1 = `ZeroWord;
                            imm2 = imm_I;
                            mem_offset_o = `ZeroWord;
                        end
                        `FUNCT3_SLTIU : begin
                            alusel_o = `EXE_RES_ARITHMETIC;
                            aluop_o = `EXE_SLTU_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadDisable;
                            reg2_addr_o = `NOPRegAddr;
                            wreg_o = `WriteEnable;
                            wd_o =  rd;
                            imm1 = `ZeroWord;
                            imm2 = imm_I;
                            mem_offset_o = `ZeroWord;
                        end
                        `FUNCT3_XORI : begin
                            alusel_o = `EXE_RES_LOGIC;
                            aluop_o = `EXE_XOR_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadDisable;
                            reg2_addr_o = `NOPRegAddr;
                            wreg_o = `WriteEnable;
                            wd_o =  rd;
                            imm1 = `ZeroWord;
                            imm2 = imm_I;
                            mem_offset_o = `ZeroWord;
                        end
                        `FUNCT3_ORI : begin
                            alusel_o = `EXE_RES_LOGIC;
                            aluop_o = `EXE_OR_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadDisable;
                            reg2_addr_o = `NOPRegAddr;
                            wreg_o = `WriteEnable;
                            wd_o =  rd;
                            imm1 = `ZeroWord;
                            imm2 = imm_I;
                            mem_offset_o = `ZeroWord;
                        end
                        `FUNCT3_ANDI : begin
                            alusel_o = `EXE_RES_LOGIC;
                            aluop_o = `EXE_AND_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadDisable;
                            reg2_addr_o = `NOPRegAddr;
                            wreg_o = `WriteEnable;
                            wd_o =  rd;
                            imm1 = `ZeroWord;
                            imm2 = imm_I;
                            mem_offset_o = `ZeroWord;
                        end
                        `FUNCT3_SLLI : begin
                            alusel_o = `EXE_RES_SHIFT;
                            aluop_o = `EXE_SLL_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadDisable;
                            reg2_addr_o = `NOPRegAddr;
                            wreg_o = `WriteEnable;
                            wd_o =  rd;
                            imm1 = `ZeroWord;
                            imm2 = {27'h0, rs2};
                            mem_offset_o = `ZeroWord;
                        end
                        `FUNCT3_SRLI_SRAI : begin
                            case (funct7)
                                `FUNCT7_SRLI : begin
                                    alusel_o = `EXE_RES_SHIFT;
                                    aluop_o = `EXE_SRL_OP;
                                    instvalid = `InstValid;
                                    reg1_read_o = `ReadEnable;
                                    reg1_addr_o = rs1;
                                    reg2_read_o = `ReadDisable;
                                    reg2_addr_o = `NOPRegAddr;
                                    wreg_o = `WriteEnable;
                                    wd_o =  rd;
                                    imm1 = `ZeroWord;
                                    imm2 = {27'h0, rs2};
                                    mem_offset_o = `ZeroWord;
                                end
                                `FUNCT7_SRAI : begin
                                    alusel_o = `EXE_RES_SHIFT;
                                    aluop_o = `EXE_SRA_OP;
                                    instvalid = `InstValid;
                                    reg1_read_o = `ReadEnable;
                                    reg1_addr_o = rs1;
                                    reg2_read_o = `ReadDisable;
                                    reg2_addr_o = `NOPRegAddr;
                                    wreg_o = `WriteEnable;
                                    wd_o =  rd;
                                    imm1 = `ZeroWord;
                                    imm2 = {27'h0, rs2};
                                    mem_offset_o = `ZeroWord;
                                end
                                default : begin
                                end
                            endcase
                        end
                        default : begin
                        end
                    endcase
                end
                `OP_OP : begin
                    case (funct3)
                        `FUNCT3_ADD_SUB : begin
                            case (funct7)
                                `FUNCT7_ADD : begin
                                    alusel_o = `EXE_RES_ARITHMETIC;
                                    aluop_o = `EXE_ADD_OP;
                                    instvalid = `InstValid;
                                    reg1_read_o = `ReadEnable;
                                    reg1_addr_o = rs1;
                                    reg2_read_o = `ReadEnable;
                                    reg2_addr_o = rs2;
                                    wreg_o = `WriteEnable;
                                    wd_o =  rd;
                                    imm1 = `ZeroWord;
                                    imm2 = `ZeroWord;
                                    mem_offset_o = `ZeroWord;
                                end
                                `FUNCT7_SUB : begin
                                    alusel_o = `EXE_RES_ARITHMETIC;
                                    aluop_o = `EXE_SUB_OP;
                                    instvalid = `InstValid;
                                    reg1_read_o = `ReadEnable;
                                    reg1_addr_o = rs1;
                                    reg2_read_o = `ReadEnable;
                                    reg2_addr_o = rs2;
                                    wreg_o = `WriteEnable;
                                    wd_o =  rd;
                                    imm1 = `ZeroWord;
                                    imm2 = `ZeroWord;
                                    mem_offset_o = `ZeroWord;
                                end
                                default : begin
                                end
                            endcase
                        end
                        `FUNCT3_SLL : begin
                            alusel_o = `EXE_RES_SHIFT;
                            aluop_o = `EXE_SLL_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadEnable;
                            reg2_addr_o = rs2;
                            wreg_o = `WriteEnable;
                            wd_o =  rd;
                            imm1 = `ZeroWord;
                            imm2 = `ZeroWord;
                            mem_offset_o = `ZeroWord;
                        end
                        `FUNCT3_SLT : begin
                            alusel_o = `EXE_RES_ARITHMETIC;
                            aluop_o = `EXE_SLT_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadEnable;
                            reg2_addr_o = rs2;
                            wreg_o = `WriteEnable;
                            wd_o =  rd;
                            imm1 = `ZeroWord;
                            imm2 = `ZeroWord;
                            mem_offset_o = `ZeroWord;
                        end
                        `FUNCT3_SLTU : begin
                            alusel_o = `EXE_RES_ARITHMETIC;
                            aluop_o = `EXE_SLTU_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadEnable;
                            reg2_addr_o = rs2;
                            wreg_o = `WriteEnable;
                            wd_o =  rd;
                            imm1 = `ZeroWord;
                            imm2 = `ZeroWord;
                            mem_offset_o = `ZeroWord;
                        end
                        `FUNCT3_XOR : begin
                            alusel_o = `EXE_RES_LOGIC;
                            aluop_o = `EXE_XOR_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadEnable;
                            reg2_addr_o = rs2;
                            wreg_o = `WriteEnable;
                            wd_o =  rd;
                            imm1 = `ZeroWord;
                            imm2 = `ZeroWord;
                            mem_offset_o = `ZeroWord;
                        end
                        `FUNCT3_SRL_SRA : begin
                            case (funct7)
                                `FUNCT7_SRL : begin
                                    alusel_o = `EXE_RES_SHIFT;
                                    aluop_o = `EXE_SRL_OP;
                                    instvalid = `InstValid;
                                    reg1_read_o = `ReadEnable;
                                    reg1_addr_o = rs1;
                                    reg2_read_o = `ReadEnable;
                                    reg2_addr_o = rs2;
                                    wreg_o = `WriteEnable;
                                    wd_o =  rd;
                                    imm1 = `ZeroWord;
                                    imm2 = `ZeroWord;
                                    mem_offset_o = `ZeroWord;
                                end
                                `FUNCT7_SRA : begin
                                    alusel_o = `EXE_RES_SHIFT;
                                    aluop_o = `EXE_SRA_OP;
                                    instvalid = `InstValid;
                                    reg1_read_o = `ReadEnable;
                                    reg1_addr_o = rs1;
                                    reg2_read_o = `ReadEnable;
                                    reg2_addr_o = rs2;
                                    wreg_o = `WriteEnable;
                                    wd_o =  rd;
                                    imm1 = `ZeroWord;
                                    imm2 = `ZeroWord;
                                    mem_offset_o = `ZeroWord;
                                end
                                default : begin
                                end
                            endcase
                        end
                        `FUNCT3_OR : begin
                            alusel_o = `EXE_RES_LOGIC;
                            aluop_o = `EXE_OR_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadEnable;
                            reg2_addr_o = rs2;
                            wreg_o = `WriteEnable;
                            wd_o =  rd;
                            imm1 = `ZeroWord;
                            imm2 = `ZeroWord;
                            mem_offset_o = `ZeroWord;
                        end
                        `FUNCT3_AND : begin
                            alusel_o = `EXE_RES_LOGIC;
                            aluop_o = `EXE_AND_OP;
                            instvalid = `InstValid;
                            reg1_read_o = `ReadEnable;
                            reg1_addr_o = rs1;
                            reg2_read_o = `ReadEnable;
                            reg2_addr_o = rs2;
                            wreg_o = `WriteEnable;
                            wd_o =  rd;
                            imm1 = `ZeroWord;
                            imm2 = `ZeroWord;
                            mem_offset_o = `ZeroWord;
                        end
                        default : begin
                        end
                    endcase
                end
                default : begin
                end
            endcase
        end
    end
    
	always @ (*) begin
        //stallreq_for_reg1_loadrelate = `NoStop;    
        if (rst == `RstEnable) begin
            reg1_o = `ZeroWord;    
        //end else if (pre_inst_is_load == 1'b1 && ex_wd_i == reg1_addr_o && reg1_read_o == 1'b1) begin
        //    stallreq_for_reg1_loadrelate = `Stop;   
        //end else if (reg1_addr_o == 5'b00000) begin
        //    reg1_o = `ZeroWord;
        end else if ((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o) && (reg1_addr_o != 5'b00000)) begin
            reg1_o = ex_wdata_i;
        end else if ((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o) && (reg1_addr_o == 5'b00000)) begin
            reg1_o = `ZeroWord; 
        end else if ((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg1_addr_o) && (reg1_addr_o != 5'b00000)) begin
            reg1_o = mem_wdata_i;
         end else if ((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg1_addr_o) && (reg1_addr_o == 5'b00000)) begin
            reg1_o = `ZeroWord;
        end else if (reg1_read_o == 1'b1) begin
            reg1_o = reg1_data_i;
        end else if (reg1_read_o == 1'b0) begin
            reg1_o = imm1;
        end else begin
            reg1_o = `ZeroWord;
        end
    end
    
	always @ (*) begin
        //stallreq_for_reg2_loadrelate = `NoStop;    
        if (rst == `RstEnable) begin
            reg2_o = `ZeroWord;    
        //end else if (pre_inst_is_load == 1'b1 && ex_wd_i == reg2_addr_o && reg2_read_o == 1'b1) begin
        //    stallreq_for_reg2_loadrelate = `Stop;
        //end else if (reg2_addr_o == 5'b00000) begin
        //    reg2_o = `ZeroWord;
        end else if ((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o) && (reg2_addr_o != 5'b00000)) begin
            reg2_o = ex_wdata_i;
        end else if ((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o) && (reg2_addr_o == 5'b00000)) begin
            reg2_o = `ZeroWord; 
        end else if ((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o) && (reg2_addr_o != 5'b00000)) begin
            reg2_o = mem_wdata_i;
        end else if ((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o) && (reg2_addr_o == 5'b00000)) begin
            reg2_o = `ZeroWord;
        end else if (reg2_read_o == 1'b1) begin
            reg2_o = reg2_data_i;
        end else if (reg2_read_o == 1'b0) begin
            reg2_o = imm2;
        end else begin
            reg2_o = `ZeroWord;
        end
    end
       
endmodule

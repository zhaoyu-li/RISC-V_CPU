//global
`define RstEnable            1'b1
`define RstDisable           1'b0
`define ZeroWord             32'h00000000
`define WriteEnable          1'b1
`define WriteDisable         1'b0
`define ReadEnable           1'b1
`define ReadDisable          1'b0
`define InstValid            1'b1
`define InstInvalid          1'b0
`define Stop                 1'b1
`define NoStop               1'b0
`define Branch               1'b1
`define NotBranch            1'b0
`define ChipEnable           1'b1
`define ChipDisable          1'b0
`define MemDone              1'b1
`define MemNotDone           1'b0
`define MemBusy              1'b1
`define MemNotBusy           1'b0
`define Ready                1'b1
`define NotReady             1'b0
`define MemReq               1'b1
`define MemNotReq            1'b0
`define Load                 1'b0
`define Store                1'b1

//opcode
`define OP_LUI      		  7'b0110111
`define OP_AUIPC    		  7'b0010111
`define OP_JAL      		  7'b1101111
`define OP_JALR     		  7'b1100111
`define OP_BRANCH   		  7'b1100011
`define OP_LOAD     		  7'b0000011
`define OP_STORE    		  7'b0100011
`define OP_OPI				  7'b0010011
`define OP_OP       		  7'b0110011

//alu
`define AluOpBus             4:0
`define AluSelBus            2:0

//aluop
`define EXE_NOP_OP           5'b00000
`define EXE_AND_OP           5'b00001
`define EXE_OR_OP            5'b00010
`define EXE_XOR_OP           5'b00011

`define EXE_SLL_OP           5'b00100
`define EXE_SRL_OP           5'b00101
`define EXE_SRA_OP           5'b00110

`define EXE_ADD_OP           5'b00111
`define EXE_SLT_OP           5'b01000
`define EXE_SLTU_OP          5'b01001
`define EXE_SUB_OP           5'b01010

`define EXE_JAL_OP           5'b01011
`define EXE_JALR_OP          5'b01100
`define EXE_BEQ_OP           5'b01101
`define EXE_BNE_OP           5'b01110
`define EXE_BLT_OP           5'b01111
`define EXE_BGE_OP           5'b10000
`define EXE_BLTU_OP          5'b10001
`define EXE_BGEU_OP          5'b10010

`define EXE_LB_OP            5'b10011
`define EXE_LH_OP            5'b10100
`define EXE_LW_OP            5'b10101
`define EXE_LBU_OP           5'b10110
`define EXE_LHU_OP           5'b10111
`define EXE_SB_OP            5'b11000
`define EXE_SH_OP            5'b11001
`define EXE_SW_OP            5'b11010

//alusel
`define EXE_RES_LOGIC        3'b001
`define EXE_RES_SHIFT        3'b010
`define EXE_RES_ARITHMETIC   3'b011
`define EXE_RES_JUMP_BRANCH  3'b100
`define EXE_RES_LOAD_STORE   3'b101
`define EXE_RES_NOP          3'b000

// funct3
// JALR
`define FUNCT3_JALR		  3'b000
// BRANCH
`define FUNCT3_BEQ 	      3'b000
`define FUNCT3_BNE  		  3'b001
`define FUNCT3_BLT  		  3'b100
`define FUNCT3_BGE  		  3'b101
`define FUNCT3_BLTU 		  3'b110
`define FUNCT3_BGEU 		  3'b111
// LOAD
`define FUNCT3_LB   		  3'b000
`define FUNCT3_LH   		  3'b001
`define FUNCT3_LW   		  3'b010
`define FUNCT3_LBU  		  3'b100
`define FUNCT3_LHU  		  3'b101
// STORE
`define FUNCT3_SB   		  3'b000
`define FUNCT3_SH   		  3'b001
`define FUNCT3_SW   		  3'b010
// OP_OPI
`define FUNCT3_ADDI     	  3'b000
`define FUNCT3_SLTI     	  3'b010
`define FUNCT3_SLTIU    	  3'b011
`define FUNCT3_XORI     	  3'b100
`define FUNCT3_ORI      	  3'b110
`define FUNCT3_ANDI     	  3'b111
`define FUNCT3_SLLI     	  3'b001
`define FUNCT3_SRLI_SRAI	  3'b101
// OP_OP
`define FUNCT3_ADD_SUB		  3'b000
`define FUNCT3_SLL    		  3'b001
`define FUNCT3_SLT    		  3'b010
`define FUNCT3_SLTU   		  3'b011
`define FUNCT3_XOR    		  3'b100
`define FUNCT3_SRL_SRA		  3'b101
`define FUNCT3_OR     		  3'b110
`define FUNCT3_AND    		  3'b111

// funct7
`define FUNCT7_SLLI          7'b0000000
// SRLI_SRAI
`define FUNCT7_SRLI          7'b0000000
`define FUNCT7_SRAI          7'b0100000
// ADD_SUB
`define FUNCT7_ADD           7'b0000000
`define FUNCT7_SUB           7'b0100000
`define FUNCT7_SLL           7'b0000000
`define FUNCT7_SLT           7'b0000000
`define FUNCT7_SLTU          7'b0000000
`define FUNCT7_XOR           7'b0000000
// SRL_SRA
`define FUNCT7_SRL           7'b0000000
`define FUNCT7_SRA           7'b0100000
`define FUNCT7_OR            7'b0000000
`define FUNCT7_AND           7'b0000000

//inst_rom
`define InstAddrBus          31:0
`define InstBus              31:0
`define InstMemNum           131071
`define InstMemNumLog2       17

//data_ram
`define DataAddrBus          31:0
`define DataBus              31:0
`define DataMemNum           131071
`define DataMemNumLog2       17
`define ByteWidth            7:0

//regfile
`define RegAddrBus           4:0
`define RegBus               31:0
`define RegWidth             32
`define RegNum               32
`define RegNumLog2           5
`define NOPRegAddr           5'b00000

//memory
`define MemAddrBus           31:0
`define MemAddrWidth         32
`define MemDataBus           31:0
`define MemDataWidth         32
`define DataMemNumLog2       17
`define MemSelZero           4'b0000

//cache
`define Cacheline            0:31


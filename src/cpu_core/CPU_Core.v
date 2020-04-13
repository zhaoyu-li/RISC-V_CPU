`include "Defines.v"

module CPU_Core(
    input wire                clk,
    input wire                rst,
    input wire                rdy,
    
    input wire[7:0]           din,
    
    output wire[7:0]          dout,
    output wire[`InstAddrBus] addr,
    output wire               wr       
    );
    
    //Ctrl
    wire                   stallreq_from_if;
    //wire                   stallreq_from_id;
    wire                   stallreq_from_mem;
    wire[5:0]              stall;
    
    //PC_Reg
     wire[`InstAddrBus]     pc;
     wire                   id_branch_flag_o;
     wire[`RegBus]          branch_target_address;
    
    //MEM_Ctrl
    wire                   mem_req;
    wire                   mem_ls;
    wire[2:0]              mem_sel;
    wire[`MemAddrBus]      mem_addr;
    wire[`MemDataBus]      mem_data;
    wire[`MemDataBus]      ram_data;
    
    wire[`InstBus]         if_inst;
    
    //IF_ID
    wire[`InstAddrBus]     id_pc_i;
    wire[`InstBus]         id_inst_i;
    
    //ID
    wire[`AluOpBus]        id_aluop_o;
    wire[`AluSelBus]       id_alusel_o;
    wire[`RegBus]          id_reg1_o;
    wire[`RegBus]          id_reg2_o;
    wire                   id_wreg_o;
    wire[`RegAddrBus]      id_wd_o;
    wire[`RegBus]          id_link_address_o;    
    wire[`RegBus]          id_mem_offset_o;
    
    //Regfile
    wire                   reg1_read;
    wire                   reg2_read;
    wire[`RegBus]          reg1_data;
    wire[`RegBus]          reg2_data;
    wire[`RegAddrBus]      reg1_addr;
    wire[`RegAddrBus]      reg2_addr;
    
    //ID_EX
    wire[`AluOpBus]        ex_aluop_i;
    wire[`AluSelBus]       ex_alusel_i;
    wire[`RegBus]          ex_reg1_i;
    wire[`RegBus]          ex_reg2_i;
    wire                   ex_wreg_i;
    wire[`RegAddrBus]      ex_wd_i;
    wire[`RegBus]          ex_link_address_i;    
    wire[`RegBus]          ex_mem_offset_i;
    
    //EX
    wire                  ex_wreg_o;
    wire[`RegAddrBus]     ex_wd_o;
    wire[`RegBus]         ex_wdata_o;
    wire[`AluOpBus]       ex_aluop_o;
    wire[`MemAddrBus]     ex_mem_addr_o;
    
    //EX_MEM
    wire                  mem_wreg_i;
    wire[`RegAddrBus]     mem_wd_i;
    wire[`RegBus]         mem_wdata_i;   
    wire[`AluOpBus]       mem_aluop_i;
    wire[`MemAddrBus]     mem_mem_addr_i;
    
    //MEM
    wire                  mem_wreg_o;
    wire[`RegAddrBus]     mem_wd_o;
    wire[`RegBus]         mem_wdata_o;          
        
    //MEM_WB
    wire                 wb_wreg_i;
    wire[`RegAddrBus]    wb_wd_i;
    wire[`RegBus]        wb_wdata_i;  
    
    Ctrl ctrl0(
        .rst(rst),
        .rdy(rdy),
        .stallreq_from_if(stallreq_from_if),
        //.stallreq_from_id(stallreq_from_id),
        .stallreq_from_mem(stallreq_from_mem),
        
        .stall(stall)
    );
    
    MEM_Ctrl mem_ctrl0(
        .clk(clk),
        .rst(rst),
        .rdy(rdy),
        
        .branch_flag_i(id_branch_flag_o),
        
        .if_addr_i(pc),
        
        .mem_ls_i(mem_ls),
        .mem_addr_i(mem_addr),
        .mem_data_i(ram_data),
        .mem_sel_i(mem_sel),
        .mem_req_i(mem_req),
        
        .din(din),
        .dout(dout),
        .addr(addr),
        .wr(wr),
        
        .if_inst_o(if_inst),
        .mem_data_o(mem_data),
        
        .if_stallreq(stallreq_from_if),
        .mem_stallreq(stallreq_from_mem)
    );
    
    PC_Reg pc_reg0(
        .clk(clk),
        .rst(rst),
        
        .stall(stall),
        
        .branch_flag_i(id_branch_flag_o),
        .branch_target_address_i(branch_target_address),
        
        .pc(pc)
    );
    
    IF_ID if_id0(
        .clk(clk),
        .rst(rst),
        
        .stall(stall),
        
        .branch_flag_i(id_branch_flag_o),
        
        .if_pc(pc),
        .if_inst(if_inst),
        .id_pc(id_pc_i),
        .id_inst(id_inst_i)
    );
     
    ID id0(
        .rst(rst),
        .pc_i(id_pc_i),
        .inst_i(id_inst_i),
    
        .reg1_data_i(reg1_data),
        .reg2_data_i(reg2_data),
        
        .ex_aluop_i(ex_aluop_o),
        .ex_wreg_i(ex_wreg_o),
        .ex_wdata_i(ex_wdata_o),
        .ex_wd_i(ex_wd_o),
    
        .mem_wreg_i(mem_wreg_o),
        .mem_wdata_i(mem_wdata_o),
        .mem_wd_i(mem_wd_o),
    
        .reg1_read_o(reg1_read),
        .reg2_read_o(reg2_read),       
    
        .reg1_addr_o(reg1_addr),
        .reg2_addr_o(reg2_addr), 
        
        .aluop_o(id_aluop_o),
        .alusel_o(id_alusel_o),
        .reg1_o(id_reg1_o),
        .reg2_o(id_reg2_o),
        .wd_o(id_wd_o),
        .wreg_o(id_wreg_o),
    
        .branch_flag_o(id_branch_flag_o),
        .branch_target_address_o(branch_target_address),       
        .link_addr_o(id_link_address_o),
        .mem_offset_o(id_mem_offset_o)
        //.stallreq(stallreq_from_id)        
    );
    
    Regfile regfile0(
        .clk(clk),
        .rst(rst),
        
        .we(wb_wreg_i),
        .waddr(wb_wd_i),
        .wdata(wb_wdata_i),
        
        .re1(reg1_read),
        .raddr1(reg1_addr),
        .rdata1(reg1_data),
        
        .re2(reg2_read),
        .raddr2(reg2_addr),
        .rdata2(reg2_data)
    );
    
    ID_EX id_ex0(
        .clk(clk),
        .rst(rst),
             
        .stall(stall),
         
        .id_aluop(id_aluop_o),
        .id_alusel(id_alusel_o),
        .id_reg1(id_reg1_o),
        .id_reg2(id_reg2_o),
        .id_wd(id_wd_o),
        .id_wreg(id_wreg_o),
        .id_link_address(id_link_address_o),        
        .id_mem_offset(id_mem_offset_o),

        .ex_aluop(ex_aluop_i),
        .ex_alusel(ex_alusel_i),
        .ex_reg1(ex_reg1_i),
        .ex_reg2(ex_reg2_i),
        .ex_wd(ex_wd_i),
        .ex_wreg(ex_wreg_i),
        .ex_link_address(ex_link_address_i),
        .ex_mem_offset(ex_mem_offset_i)
    );
    
    EX ex0(
        .rst(rst),
        
        .aluop_i(ex_aluop_i),
        .alusel_i(ex_alusel_i),
        .reg1_i(ex_reg1_i),
        .reg2_i(ex_reg2_i),
        .wd_i(ex_wd_i),
        .wreg_i(ex_wreg_i),
    
        .link_address_i(ex_link_address_i),  
        .mem_offset_i(ex_mem_offset_i),
        
        .wd_o(ex_wd_o),
        .wreg_o(ex_wreg_o),
        .wdata_o(ex_wdata_o),
    
        .aluop_o(ex_aluop_o),
        .mem_addr_o(ex_mem_addr_o)
    );
    
    EX_MEM ex_mem0(
        .clk(clk),
        .rst(rst),
        
        .stall(stall),
        
        .ex_aluop(ex_aluop_o),
        .ex_mem_addr(ex_mem_addr_o),
        
        .ex_wd(ex_wd_o),
        .ex_wreg(ex_wreg_o),
        .ex_wdata(ex_wdata_o),

        .mem_wd(mem_wd_i),
        .mem_wreg(mem_wreg_i),
        .mem_wdata(mem_wdata_i),
  
        .mem_aluop(mem_aluop_i),
        .mem_mem_addr(mem_mem_addr_i)
    );
    
    MEM mem0(
        .rst(rst),
        
        .aluop_i(mem_aluop_i),
        .mem_addr_i(mem_mem_addr_i),
        .mem_data_i(mem_data),
        
        .wd_i(mem_wd_i),
        .wreg_i(mem_wreg_i),
        .wdata_i(mem_wdata_i),
          
        .wd_o(mem_wd_o),
        .wreg_o(mem_wreg_o),
        .wdata_o(mem_wdata_o),

        .mem_addr_o(mem_addr),
        .mem_sel_o(mem_sel),
        .mem_data_o(ram_data),
        .mem_ls_o(mem_ls),
        .mem_req_o(mem_req) 
    );
    
    MEM_WB mem_wb0(
        .clk(clk),
        .rst(rst),
    
        .stall(stall),
    
        .mem_wd(mem_wd_o),
        .mem_wreg(mem_wreg_o),
        .mem_wdata(mem_wdata_o),

        .wb_wd(wb_wd_i),
        .wb_wreg(wb_wreg_i),
        .wb_wdata(wb_wdata_i)                                               
    );
    
endmodule

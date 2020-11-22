module mips_cpu_harvard( 
    /* Standard signals */ 
    input  logic        clk, 
    input  logic        reset, 
    output logic        active, 
    output logic [31:0] register_v0, 
 
    /* New clock enable. See below */ 
    input  logic        clk_enable, 
 
    /* Combinatorial read access to instructions */ 
    input  logic[31:0]  instr_readdata, 
    output logic[31:0]  instr_address, 
    
    /* Combinatorial read and single-cycle write access to instructions */ 
    input  logic[31:0]  data_readdata 
    output logic        data_write, 
    output logic        data_read, 
    output logic[31:0]  data_writedata, 
    output logic[31:0]  data_address, 
); 


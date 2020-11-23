module mips_cpu_harvard_control
( 
    input  logic [5:0] instruction, 
    
    output logic       reg_dst,
    output logic       reg_write,  
    output logic       branch, 
    output logic       mem_read, 
    output logic       mem_write, 
    output logic       mem_to_reg, 
    output logic       alu_src, 
    output logic [1:0] alu_op, 
); 

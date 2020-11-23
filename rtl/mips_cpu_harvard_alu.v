module mips_cpu_harvard_alu
( 
    input  logic [3:0]  alu_control, 
    input  logic [31:0] A, 
    input  logic [31:0] B, 

    output logic        zero,  
    output logic [31:0] alu_result,  
); 

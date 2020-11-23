module mips_cpu_harvard_alu_ctrl
( 
    input  logic [1:0] alu_op, 
    input  logic [5:0] function_code,  

    output logic [3:0] alu_control,  
); 

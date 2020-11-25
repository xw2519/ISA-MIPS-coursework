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
    output logic       jump, 
    output logic [1:0] alu_op, 
); 

    typedef enum logic[5:0] 
    {
        LW  = 6'b100011
        SW  = 6'b101011
        BEQ = 6'b000100

    } instruction_t;

    always_comb begin

        if (instruction == LW) 
        begin
            reg_dst    = 0;
            reg_write  = 1;
            mem_to_reg = 1;
            alu_src    = 1;
            mem_read   = 0;
            mem_write  = 0;
            branch     = 0;
            alu_op     = 2'b00;
            jump       = 0;
        end

        else if (instruction == SW) 
        begin
            reg_dst    = x; // Don't know if it works or not 
            reg_write  = 1;
            mem_to_reg = x;
            alu_src    = 1;
            mem_read   = 0;
            mem_write  = 1;
            branch     = 0;
            alu_op     = 2'b00;
            jump       = 0;
        end

        else if (instruction == BEQ) 
        begin
            reg_dst    = x; // Don't know if it works or not 
            reg_write  = 0;
            mem_to_reg = x;
            alu_src    = 0;
            mem_read   = 0;
            mem_write  = 0;
            branch     = 1;
            alu_op     = 2'b01;
            jump       = 0;
        end
    end

endmodule
module mips_cpu_harvard_alu_ctrl
( 
    input  logic [1:0] alu_op, 
    input  logic [5:0] function_code,  

    output logic [2:0] alu_control,  
); 

    always_comb begin

        if (alu_op == 2'b00) 
        begin
            alu_control = 3'b010;
        end

        else if (alu_op == 2'b01) 
        begin
            alu_control = 3'b110;
        end
    end

endmodule
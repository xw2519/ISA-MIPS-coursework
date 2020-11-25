module mips_cpu_harvard_alu
( 
    input  logic [3:0]  alu_control, 
    input  logic [31:0] A, 
    input  logic [31:0] B, 

    output logic        zero,  
    output logic [31:0] alu_result,  
); 

    /* --- ALU Opcodes --- */
    typedef enum logic[3:0] {
        ADDU = 4'h0
        SUBU = 4'h1
        AND = 4'h2
        OR = 4'h3
        XOR = 4'h4
        LSR = 4'h5
        ASR = 4'h6
        LSL = 4'h7
        STL = 4'h8
        STLU = 4'h9
    } aluop_t;

    always_comb begin
        case(alu_control)
            ADDU : alu_out = alu_a + alu_b;
            SUBU : alu_out = alu_a - alu_b;
            AND  : alu_out = alu_a & alu_b;
            OR   : alu_out = alu_a | alu_b;
            XOR  : alu_out = alu_a ^ alu_b;

            STL  : alu_out = {31'h(0000),($signed(alu_a) < $signed(alu_b))};
            STLU : alu_out = {31'h(0000),(alu_a < alu_b)};
        endcase
    end
endmodule
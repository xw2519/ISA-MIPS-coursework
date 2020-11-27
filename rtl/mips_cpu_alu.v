module mips_cpu_alu
(
    input  logic [3:0]  alu_control,
    input  logic [4:0]  alu_shift_amt,
    input  logic [31:0] alu_a,
    input  logic [31:0] alu_b,
    input  logic [31:0] alu_pc,

    output logic        zero,
    output logic        equal,
    output logic        negative,
    output logic [31:0] alu_result
);

    /* --- ALU Opcodes --- */
    typedef enum logic[3:0] {
        ADDU = 4'h0,
        SUBU = 4'h1,
        AND  = 4'h2,
        OR   = 4'h3,
        XOR  = 4'h4,
        SRL  = 4'h5,
        SRA  = 4'h6,
        SLL  = 4'h7,
        STL  = 4'h8,
        STLU = 4'h9,
        PC   = 4'h10,
        RS   = 4'h11
    } alu_control_t;

    always_comb begin
        case(alu_control)
            ADDU    : alu_out = alu_a + alu_b;
            SUBU    : alu_out = alu_a - alu_b;
            AND     : alu_out = alu_a & alu_b;
            OR      : alu_out = alu_a | alu_b;
            XOR     : alu_out = alu_a ^ alu_b;
            SRL     : alu_out = alu_b >> alu_shift_amt;
            SRA     : alu_out = $signed(alu_b) >>> alu_shift_amt;
            SLL     : alu_out = alu_b << alu_shift_amt;
            STL     : alu_out = {31'h(0000),($signed(alu_a) < $signed(alu_b))};
            STLU    : alu_out = {31'h(0000),(alu_a < alu_b)};
            PC      : alu_out = alu_pc;
            RS      : alu_out = alu_a;
            default : alu_out = alu_b;
        endcase

        zero = (alu_a == 0);
        equal = (alu_a == alu_b);
        negative = ($signed(alu_a) < 0);
    end
endmodule

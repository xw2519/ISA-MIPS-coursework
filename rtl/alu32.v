module alu32(
    input[3:0] aluop,     // operation to produce alu_out
    input[4:0] shift_amt,     // amount to shift by
    input[31:0] alu_a,    // 32-bit input a
    input [31:0] alu_b,       // 32-bit input b
    output[31:0] alu_out, // 32-bit output
    output eq,                // high if a and b are equal
    output zero,          // high if a is zero
    output negative           // high if a is negative
);
          // alu opcodes for each operation can be modified here
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

        if (aluop == ADDU) begin
            alu_out = alu_a + alu_b;
        end
        else if (aluop == SUBU) begin
            alu_out = alu_a - alu_b;
        end
        else if (aluop == AND) begin
            alu_out = alu_a & alu_b;
        end
        else if (aluop == OR) begin
            alu_out = alu_a | alu_b;
        end
        else if (aluop == XOR) begin
            alu_out = alu_a ^ alu_b;
        end
        else if (aluop == LSR) begin
            alu_out = alu_a >> shift_amt;
        end
        else if (aluop == ASR) begin
            alu_out = $signed(alu_a) >>> shift_amt;
        end
        else if (aluop == LSL) begin
            alu_out = alu_a << shift_amt;
        end
        else if (aluop == STL) begin
            alu_out = {31'h(0000),($signed(alu_a) < $signed(alu_b))};
        end
        else if (aluop == STLU) begin
            alu_out = {31'h(0000),(alu_a < alu_b)};
        end

        eq = (alu_a == alu_b);
        zero = (alu_a == 0);
        negative = ($signed(alu_a) < 0);
    end
endmodule

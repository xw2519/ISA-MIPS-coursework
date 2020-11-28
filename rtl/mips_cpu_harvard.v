module mips_cpu_harvard
(
    /* Standard signals */
    input  logic        clk,
    input  logic        reset,
    output logic        active,
    output logic [31:0] register_v0,

    /* New clock enable. See below */
    input  logic        clk_enable,

    /* Combinatorial read access to instructions */
    input  logic [31:0] instr_readdata,
    output logic [31:0] instr_address,

    /* Combinatorial read and single-cycle write access to data */
    input  logic [31:0] data_readdata,
    output logic        data_write,
    output logic        data_read,
    output logic [31:0] data_writedata,
    output logic [31:0] data_address
);

    /* --- Module connection definitions --- */

    // ALU definitions
    logic [3:0]  alu_control;
    logic [4:0]  alu_shift_amt;
    logic [31:0] alu_b;

    logic        zero;
    logic        equal;
    logic        negative;
    logic [31:0] alu_result;

    // Register File definitions
    logic [31:0] read_data_a;
    logic [31:0] read_data_b;

    logic [4:0]  write_addr_c;
    logic        write_enable_c;
    logic [31:0] write_data_c;

    /* --- PC definitions --- */
    logic [31:0] pc_reg;
    logic [31:0] pc_in;

    /* --- IR definitions --- */  // required for delayed branching
    logic [31:0] ir_reg;
    logic        ir_valid;

    /* --- Internal signals --- */
    logic [31:0] sign_extended_immediate;
    logic [31:0] upper_immediate;
    logic [31:0] byte_enabled_read;
    logic [31:0] byte_enabled_write;

    /* --- Supported opcodes --- */
    typedef enum logic[5:0] {
        R_TYPE = 6'b000000, /* ADDU, AND, JALR, JR, OR, SLL, SLLV, SLT, SLTU, SRA, SRAV, SRL, SRLV, SUBU, XOR */
        BR_Z   = 6'b000001, /* BGEZ, BGEZAL, BLTZ, BLTZAL */
        ADDIU  = 6'b001001,
        ANDI   = 6'b001100,
        BEQ    = 6'b000100,
        BGTZ   = 6'b000111,
        BLEZ   = 6'b000110,
        BNE    = 6'b000101,
        J      = 6'b000010,
        JAL    = 6'b000011,
        LB     = 6'b100000,
        LBU    = 6'b100100,
        LH     = 6'b100001,
        LHU    = 6'b100101,
        LUI    = 6'b001111,
        LW     = 6'b100011,
        LWL    = 6'b100010,
        LWR    = 6'b100110,
        ORI    = 6'b001101,
        SB     = 6'b101000,
        SH     = 6'b101001,
        SLTI   = 6'b001010,
        SLTIU  = 6'b001011,
        SW     = 6'b101011,
        XORI   = 6'b001110
    } opcode_t;

    /* --- ALU Functions --- */
    typedef enum logic[5:0] {
        F_ADDU = 6'b100001,
        F_AND  = 6'b100100,
        F_JALR = 6'b001001,
        F_JR   = 6'b001000,
        F_OR   = 6'b100101,
        F_SLL  = 6'b000000,
        F_SLLV = 6'b000100,
        F_SLT  = 6'b101010,
        F_SLTU = 6'b101011,
        F_SRA  = 6'b000011,
        F_SRAV = 6'b000111,
        F_SRL  = 6'b000010,
        F_SRLV = 6'b000110,
        F_SUBU = 6'b100011,
        F_XOR  = 6'b100110
    } alu_function_t;

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
        SLT  = 4'h8,
        SLTU = 4'h9
    } alu_control_t;

    /*
    --- Values of Rt for zero conditional branches ---
        BGEZ   = 5'b00001,
        BGEZAL = 5'b10001,
        BLTZ   = 5'b00000,
        BLTZAL = 5'b10000
    */

    /* --- CPU connections --- */
    always @(*)
    begin
        instr_address = pc_reg;
        data_address = alu_result;    // data address is always calculated by alu
        // chooses between Rs and shamt instruction field for shifts
        alu_shift_amt = (ir_reg[5:2] == 4'h1) ? read_data_a[4:0] : ir_reg[10:6];
        // different ways to use the 16-bit immediate, sign extending is disabled if unsigned instruction
        sign_extended_immediate = ({ir_reg[31:28], ir_reg[26]} == 5'b00101) ? {16'h0000, ir_reg[15:0]} : {{16{ir_reg[15]}}, ir_reg[15:0]};
        upper_immediate = {16'h0000, ir_reg[15:0]} << 16;

        if (ir_reg[31:26] == R_TYPE)      // all R-type instructions are handled in this case statement
        begin
            data_write = 0;
            data_read = 0;
            data_writedata = 0;

            alu_b = read_data_b;

            write_addr_c = (ir_reg[5:0] == F_JALR) ? 5'b11111 : ir_reg[15:11];
            write_data_c = (ir_reg[5:0] == F_JALR) ? (pc_reg + 8) : alu_result;
            write_enable_c = ~(ir_reg[5:0] == F_JR);

            pc_in = (ir_reg[5:1] == 5'b00100) ? (read_data_a << 2) : (pc_reg + 4);

            case(ir_reg[5:0])
                F_ADDU    : alu_control = ADDU;
                F_AND     : alu_control = AND;
                F_JALR    : alu_control = ADDU;
                F_JR      : alu_control = ADDU;
                F_OR      : alu_control = OR;
                F_SLL     : alu_control = SLL;
                F_SLLV    : alu_control = SLL;
                F_SLT     : alu_control = SLT;
                F_SLTU    : alu_control = SLTU;
                F_SRA     : alu_control = SRA;
                F_SRAV    : alu_control = SRA;
                F_SRL     : alu_control = SRL;
                F_SRLV    : alu_control = SRL;
                F_SUBU    : alu_control = SUBU;
                F_XOR     : alu_control = XOR;
                default   : alu_control = ADDU;
            endcase
        end
        else if (ir_reg[31:26] == BR_Z)       // several conditional branches are handled here
        begin
            data_write = 0;
            data_read = 0;
            data_writedata = 0;

            alu_control = ADDU;
            alu_b = read_data_b;

            write_addr_c = 5'b11111;
            write_data_c = pc_reg;
            write_enable_c = ir_reg[20];

            pc_in = (ir_reg[16] ^ negative) ? (pc_reg + (sign_extended_immediate << 2)) : (pc_reg + 4);
        end
        else         // I-type instructions and J are handled here
        begin
            byte_enabled_write = read_data_b;
            byte_enabled_read = data_readdata;

            data_write = (ir_reg[31:26] == SB) || (ir_reg[31:26] == SH) || (ir_reg[31:26] == SW);
            data_read = (ir_reg[31:26] == LB);
            data_writedata = byte_enabled_write;

            case(ir_reg[31:26])
                ADDIU   : begin
                              alu_control = ADDU;
                              write_data_c = alu_result;
                              write_enable_c = 1;
                              pc_in = pc_reg + 4;
                          end
                ANDI    : begin
                              alu_control = AND;
                              write_data_c = alu_result;
                              write_enable_c = 1;
                              pc_in = pc_reg + 4;
                          end
                BEQ     : begin
                              alu_control = ADDU;
                              write_data_c = alu_result;
                              write_enable_c = 0;
                              pc_in = equal ? sign_extended_immediate : pc_reg + 4;
                          end
                BGTZ    : begin
                              alu_control = ADDU;
                              write_data_c = alu_result;
                              write_enable_c = 0;
                              pc_in = ((~negative) && ~(zero)) ? sign_extended_immediate : pc_reg + 4;
                          end
                BLEZ    : begin
                              alu_control = ADDU;
                              write_data_c = alu_result;
                              write_enable_c = 0;
                              pc_in = (negative || zero) ? sign_extended_immediate : pc_reg + 4;
                          end
                BNE     : begin
                              alu_control = ADDU;
                              write_data_c = alu_result;
                              write_enable_c = 0;
                              pc_in = ~(equal) ? sign_extended_immediate : pc_reg + 4;
                          end
                J       : begin
                              alu_control = ADDU;
                              write_data_c = alu_result;
                              write_enable_c = 0;
                              pc_in = pc_reg + {{6{ir_reg[25]}}, ir_reg[25:0]};
                          end
                JAL     : begin
                              alu_control = ADDU;
                              write_data_c = pc_reg + 8;
                              write_enable_c = 1;
                              pc_in = pc_reg + {{6{ir_reg[25]}}, ir_reg[25:0]};
                          end
                LB      : begin
                              alu_control = ADDU;
                              write_data_c = byte_enabled_read;
                              write_enable_c = 1;
                              pc_in = pc_reg + 4;
                          end
                LBU     : begin
                              alu_control = ADDU;
                              write_data_c = byte_enabled_read;
                              write_enable_c = 1;
                              pc_in = pc_reg + 4;
                          end
                LH      : begin
                              alu_control = ADDU;
                              write_data_c = byte_enabled_read;
                              write_enable_c = 1;
                              pc_in = pc_reg + 4;
                          end
                LHU     : begin
                              alu_control = ADDU;
                              write_data_c = byte_enabled_read;
                              write_enable_c = 1;
                              pc_in = pc_reg + 4;
                          end
                LUI     : begin
                              alu_control = ADDU;
                              write_data_c = upper_immediate;
                              write_enable_c = 1;
                              pc_in = pc_reg + 4;
                          end
                LW      : begin
                              alu_control = ADDU;
                              write_data_c = data_readdata;
                              write_enable_c = 1;
                              pc_in = pc_reg + 4;
                          end
                LWL     : begin
                              alu_control = ADDU;
                              write_data_c = byte_enabled_read;
                              write_enable_c = 1;
                              pc_in = pc_reg + 4;
                          end
                LWR     : begin
                              alu_control = ADDU;
                              write_data_c = byte_enabled_read;
                              write_enable_c = 1;
                              pc_in = pc_reg + 4;
                          end
                ORI     : begin
                              alu_control = OR;
                              write_data_c = alu_result;
                              write_enable_c = 1;
                              pc_in = pc_reg + 4;
                          end
                SB      : begin
                              alu_control = ADDU;
                              write_data_c = alu_result;
                              write_enable_c = 0;
                              pc_in = pc_reg + 4;
                          end
                SH      : begin
                              alu_control = ADDU;
                              write_data_c = alu_result;
                              write_enable_c = 0;
                              pc_in = pc_reg + 4;
                          end
                SLTI    : begin
                              alu_control = SLT;
                              write_data_c = alu_result;
                              write_enable_c = 1;
                              pc_in = pc_reg + 4;
                          end
                SLTIU   : begin
                              alu_control = SLTU;
                              write_data_c = alu_result;
                              write_enable_c = 1;
                              pc_in = pc_reg + 4;
                          end
                SW      : begin
                              alu_control = ADDU;
                              write_data_c = alu_result;
                              write_enable_c = 0;
                              pc_in = pc_reg + 4;
                          end
                XORI    : begin
                              alu_control = XOR;
                              write_data_c = alu_result;
                              write_enable_c = 1;
                              pc_in = pc_reg + 4;
                          end
                default : begin
                              alu_control = ADDU;
                              write_data_c = alu_result;
                              write_enable_c = 0;
                              pc_in = pc_reg + 4;
                          end
            endcase
            alu_b = ((ir_reg[31:26] == BEQ) || (ir_reg[31:26] == BNE)) ? ir_reg[20:16] : sign_extended_immediate;

            write_addr_c = (ir_reg[31:26] == JAL) ? 5'b11111 : ir_reg[20:16];
        end
    end

    /* --- CPU states --- */
    always_ff @(posedge clk)
    begin
        if (reset) // Reset logic
        begin
            pc_reg <= 32'hBFC00000;
            active <= 1;
            ir_reg <= 0;
            ir_valid <= 0;
        end
        else if(clk_enable && ir_valid) // CPU runs and updates states here
        begin
            pc_reg <= pc_in;
            active <= ~(pc_reg == 0);
            ir_reg <= instr_readdata;
        end
        else if(clk_enable) // sets ir_valid after reset
        begin
            ir_valid <= 1;
        end
    end

    mips_cpu_alu alu(
        .alu_control(alu_control),
        .alu_shift_amt(alu_shift_amt),
        .alu_a(read_data_a),
        .alu_b(alu_b),

        .zero(zero),
        .equal(equal),
        .negative(negative),
        .alu_out(alu_result)
    );

    mips_cpu_register_file reg_file(
        .clk(clk),
        .reset(reset),
        .register_v0(register_v0),

        /* Read ports */
        .read_addr_a(instr_readdata[25:21]),
        .read_data_a(read_data_a),
        .read_addr_b(instr_readdata[20:16]),
        .read_data_b(read_data_b),

        /* Write port */
        .write_addr_c(write_addr_c),
        .write_enable_c(write_enable_c),
        .write_data_c(write_data_c)
    );

endmodule

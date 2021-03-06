module mips_cpu_harvard_mod
(
    /* Standard signals */
    input  logic        clk,
    input  logic        reset,
    output logic        active,
    output logic [31:0] register_v0,

    /* Clock enable, only update state if asserted */
    input  logic        clk_enable,

    /* Combinatorial read access to instructions */
    input  logic [31:0] instr_readdata,
    output logic [31:0] instr_address,

    /* Combinatorial read and single-cycle write access to data */
    input  logic [31:0] data_readdata,
    output logic        data_write,
    output logic        data_read,
    output logic [3:0]  data_byteenable,
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

    logic        regfile_write_enable;
    logic [4:0]  regfile_write_addr;
    logic [31:0] regfile_write_data;

    /* --- Internal definitions --- */
    // PC definitions
    logic [31:0] pc_reg;
    logic [31:0] pc_in;

    // Instruction register definitions
    logic [31:0] ir_reg;

    // Hi and Lo registers
    logic [31:0] hi_reg;
    logic [31:0] hi_in;
    logic [31:0] lo_reg;
    logic [31:0] lo_in;

    // Internal signals
    logic [31:0] sign_extended_immediate;
    logic [63:0] product;
    logic [63:0] u_product;

    /* Sub-module declarations */
    mips_cpu_alu alu(
        .alu_control    (alu_control),
        .alu_shift_amt  (alu_shift_amt),
        .alu_a          (read_data_a),
        .alu_b          (alu_b),
        .zero           (zero),
        .equal          (equal),
        .negative       (negative),
        .alu_out        (alu_result)
    );

    mips_cpu_register_file reg_file(
        .clk            (clk),
        .clk_enable     (clk_enable),
        .reset          (reset),
        .register_v0    (register_v0),

        /* Read ports */
        .read_addr_a    (ir_reg[25:21]),
        .read_data_a    (read_data_a),
        .read_addr_b    (ir_reg[20:16]),
        .read_data_b    (read_data_b),

        /* Write port */
        .regfile_write_addr   (regfile_write_addr),
        .regfile_write_data   (regfile_write_data),
        .regfile_write_enable (regfile_write_enable)
    );

    /* --- Supported opcodes --- */
    typedef enum logic[5:0] {
        R_TYPE = 6'b000000,
        BR_Z   = 6'b000001,
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

    /* --- ALU function codes --- */
    typedef enum logic[5:0] {
        F_ADDU  = 6'b100001,
        F_AND   = 6'b100100,
        F_DIV   = 6'b011010,
        F_DIVU  = 6'b011011,
        F_JALR  = 6'b001001,
        F_JR    = 6'b001000,
        F_MFHI  = 6'b010000,
        F_MFLO  = 6'b010010,
        F_MTHI  = 6'b010001,
        F_MTLO  = 6'b010011,
        F_MULT  = 6'b011000,
        F_MULTU = 6'b011001,
        F_OR    = 6'b100101,
        F_SLL   = 6'b000000,
        F_SLLV  = 6'b000100,
        F_SLT   = 6'b101010,
        F_SLTU  = 6'b101011,
        F_SRA   = 6'b000011,
        F_SRAV  = 6'b000111,
        F_SRL   = 6'b000010,
        F_SRLV  = 6'b000110,
        F_SUBU  = 6'b100011,
        F_XOR   = 6'b100110
    } alu_function_t;

    /* --- ALU control codes --- */
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

    /* --- CPU combinatorial connections --- */
    always @(*) begin
        instr_address = pc_reg;
        data_address  = alu_result & 32'hFFFFFFFC;

        sign_extended_immediate = ((ir_reg[31:26] == ANDI) || (ir_reg[31:26] == ORI) || (ir_reg[31:26] == XORI)) ?
                                  {{16'h0000}, ir_reg[15:0]} : {{16{ir_reg[15]}}, ir_reg[15:0]};

        // Choose between 'Rs' and 'shamt' for standard and variable shifts.
        alu_shift_amt = (ir_reg[5:2] == 4'h1) ? read_data_a[4:0] : ir_reg[10:6];

        product   = $signed(read_data_a)   * $signed(read_data_b);
        u_product = $unsigned(read_data_a) * $unsigned(read_data_b);

        /*
        IF-ELSEIF-ELSE structure for decoding and executing instructions
            - R-type instructions
            - Conditional branches
            - I-type and J-type instructions

        Connections to the data memory:
            data_write - Enable write to memory
            data_read - Enable read from memory
            data_writedata - Data to be written to memory

        Connections to ALU:
            alu_control - ALU operation
            alu_b -> ALU port 'b' input, 'Rt' or sign-extended immediate

        Connections to Register File:
            regfile_write_addr - Address of destination register - 'Rd' or 'Rt'
            regfile_write_data - Data to be written to destination register: ALU output or PC or data read from memory
            regfile_write_enable - Enable write to register file

        Internal registers:
            pc_in - next value of PC
            hi_in - next value of 'hi' register
            lo_in - next value of 'lo' register
        */

        // R-type instructions
        if (ir_reg[31:26] == R_TYPE) begin

            // No memory accesses occur
            data_write      = 0;
            data_read       = 0;
            data_byteenable = 4'hf;
            data_writedata  = 0;

            // ALU input B is always Rt
            alu_b = read_data_b;

            // Register file connections
            regfile_write_addr   =  ir_reg[15:11];
            regfile_write_data   =  (ir_reg[5:0] == F_JALR) ? (pc_reg + 4) : alu_result;
            regfile_write_enable = ~((ir_reg[5:0] == F_JR)    || (ir_reg[5:0] == F_DIV)  || (ir_reg[5:0] == F_DIVU)  || (ir_reg[5:0] == F_MULT) ||
                                     (ir_reg[5:0] == F_MULTU) || (ir_reg[5:0] == F_MTHI) || (ir_reg[5:0] == F_MTLO)) && active;

            // PC control
            pc_in = (ir_reg[5:1] == 5'b00100) ? read_data_a : (pc_reg + 4);   // If instruction 'JR' or 'JALR', jump to 'Rs'.

            case(ir_reg[5:0])
                F_MTHI  : hi_in = read_data_a;
                F_MULT  : hi_in = product[63:32];
                F_MULTU : hi_in = u_product[63:32];
                F_DIV   : hi_in = $signed(read_data_a)   % $signed(read_data_b);
                F_DIVU  : hi_in = $unsigned(read_data_a) % $unsigned(read_data_b);
                default : hi_in = hi_reg;
            endcase

            case(ir_reg[5:0])
                F_MTLO  : lo_in = read_data_a;
                F_MULT  : lo_in = product[31:0];
                F_MULTU : lo_in = u_product[31:0];
                F_DIV   : lo_in = $signed(read_data_a)   / $signed(read_data_b);
                F_DIVU  : lo_in = $unsigned(read_data_a) / $unsigned(read_data_b);
                default : lo_in = lo_reg;
            endcase

            case(ir_reg[5:0])
                F_JALR  : regfile_write_data = (pc_reg + 4);
                F_MFHI  : regfile_write_data = hi_reg;
                F_MFLO  : regfile_write_data = lo_reg;
                default : regfile_write_data = alu_result;
            endcase

            case(ir_reg[5:0])
                F_AND   : alu_control = AND;
                F_OR    : alu_control = OR;
                F_SLL   : alu_control = SLL;
                F_SLLV  : alu_control = SLL;
                F_SLT   : alu_control = SLT;
                F_SLTU  : alu_control = SLTU;
                F_SRA   : alu_control = SRA;
                F_SRAV  : alu_control = SRA;
                F_SRL   : alu_control = SRL;
                F_SRLV  : alu_control = SRL;
                F_SUBU  : alu_control = SUBU;
                F_XOR   : alu_control = XOR;
                default : alu_control = ADDU;
            endcase
        end

        // Conditional branches
        else if (ir_reg[31:26] == BR_Z) begin
            data_write      = 0;
            data_read       = 0;
            data_byteenable = 4'hf;
            data_writedata  = 0;

            alu_control = ADDU;
            alu_b = read_data_b;

            regfile_write_addr   = 5'b11111;
            regfile_write_data   = pc_reg + 4;
            regfile_write_enable = ir_reg[20] && active;

            pc_in = (ir_reg[16] ^ negative) ? (pc_reg + {{14{ir_reg[15]}}, ir_reg[15:0], 2'b00}) : (pc_reg + 4);
            hi_in = hi_reg;
            lo_in = lo_reg;
        end

        // I-type and J-type instructions
        else begin
            data_write = ((ir_reg[31:26] == SB) || (ir_reg[31:26] == SH) || (ir_reg[31:26] == SW)) && active;
            data_read  = ((ir_reg[31:26] == LB) || (ir_reg[31:26] == LBU) || (ir_reg[31:26] == LWL)  || (ir_reg[31:26] == LW) ||
                          (ir_reg[31:26] == LH) || (ir_reg[31:26] == LHU) || (ir_reg[31:26] == LWR)) && active;

            alu_b = ((ir_reg[31:26] == BEQ) || (ir_reg[31:26] == BNE)) ? read_data_b : sign_extended_immediate;

            regfile_write_addr   = (ir_reg[31:26] == JAL) ? 5'b11111 : ir_reg[20:16];
            regfile_write_enable = ((ir_reg[31:26] == ADDIU) || (ir_reg[31:26] == ANDI)  || (ir_reg[31:26] == JAL) ||
                                    (ir_reg[31:26] == LB)    || (ir_reg[31:26] == LBU)   || (ir_reg[31:26] == LH)  ||
                                    (ir_reg[31:26] == LHU)   || (ir_reg[31:26] == LUI)   || (ir_reg[31:26] == LW)  ||
                                    (ir_reg[31:26] == LWL)   || (ir_reg[31:26] == LWR)   || (ir_reg[31:26] == ORI) ||
                                    (ir_reg[31:26] == SLTI)  || (ir_reg[31:26] == SLTIU) || (ir_reg[31:26] == XORI)) && active;
            hi_in = hi_reg;
            lo_in = lo_reg;

            case(ir_reg[31:26])
                ANDI    : alu_control = AND;
                ORI     : alu_control = OR;
                SLTI    : alu_control = SLT;
                SLTIU   : alu_control = SLTU;
                XORI    : alu_control = XOR;
                default : alu_control = ADDU;
            endcase

            if (ir_reg[31:26] == SB) begin
                data_byteenable[0] = (alu_result[1:0] == 0);
                data_byteenable[1] = (alu_result[1:0] == 1);
                data_byteenable[2] = (alu_result[1:0] == 2);
                data_byteenable[3] = (alu_result[1:0] == 3);
                data_writedata[7:0]   = (alu_result[1:0] == 0) ? read_data_b[7:0] : 8'h00;      // could remove mux, redundant because of byteenable
                data_writedata[15:8]  = (alu_result[1:0] == 1) ? read_data_b[7:0] : 8'h00;
                data_writedata[23:16] = (alu_result[1:0] == 2) ? read_data_b[7:0] : 8'h00;
                data_writedata[31:24] = (alu_result[1:0] == 3) ? read_data_b[7:0] : 8'h00;
            end
            else if (ir_reg[31:26] == SH) begin
                data_byteenable = alu_result[1] ? 4'b1100 : 4'b0011;
                data_writedata  = alu_result[1] ? {read_data_b[15:0], {16'h0000}} : {{16'h0000}, read_data_b[15:0]}; // could remove mux, redundant because of byteenable
            end
            else begin
                data_byteenable = 4'hF;
                data_writedata = read_data_b;
            end

            if ((ir_reg[31:26] == LB) || (ir_reg[31:26] == LBU)) begin
                case(alu_result[1:0])
                    0 : regfile_write_data = {{24{(ir_reg[31:26] == LB) && data_readdata[ 7]}}, data_readdata[ 7: 0]};
                    1 : regfile_write_data = {{24{(ir_reg[31:26] == LB) && data_readdata[15]}}, data_readdata[15: 8]};
                    2 : regfile_write_data = {{24{(ir_reg[31:26] == LB) && data_readdata[23]}}, data_readdata[23:16]};
                    3 : regfile_write_data = {{24{(ir_reg[31:26] == LB) && data_readdata[31]}}, data_readdata[31:24]};
                endcase
            end
            else if (ir_reg[31:26] == LWL) begin
                case(alu_result[1:0])
                    0 : regfile_write_data = {data_readdata[ 7:0], read_data_b[23:0]};
                    1 : regfile_write_data = {data_readdata[15:0], read_data_b[15:0]};
                    2 : regfile_write_data = {data_readdata[23:0], read_data_b[ 7:0]};
                    3 : regfile_write_data = data_readdata;
                endcase
            end
            else if (ir_reg[31:26] == LWR) begin
                case(alu_result[1:0])
                    0 : regfile_write_data = data_readdata;
                    1 : regfile_write_data = {read_data_b[31:24], data_readdata[31: 8]};
                    2 : regfile_write_data = {read_data_b[31:16], data_readdata[31:16]};
                    3 : regfile_write_data = {read_data_b[31: 8], data_readdata[31:24]};
                endcase
            end
            else if ((ir_reg[31:26] == LH) || (ir_reg[31:26] == LHU)) begin
                regfile_write_data[31:16] = {16{(ir_reg[31:26] == LH) && (alu_result[1] ? data_readdata[31] : data_readdata[15])}};
                regfile_write_data[15:0]  = alu_result[1] ? data_readdata[31:16] : data_readdata[15:0];
            end
            else begin
                case(ir_reg[31:26])
                    JAL     : regfile_write_data = pc_reg + 4;
                    LUI     : regfile_write_data = {{16'h0000}, ir_reg[15:0]} << 16;
                    LW      : regfile_write_data = data_readdata;
                    default : regfile_write_data = alu_result;
                endcase
            end

            case(ir_reg[31:26])
                BEQ     : pc_in = equal ? (pc_reg + ({{14{ir_reg[15]}}, ir_reg[15:0], 2'b00})) : pc_reg + 4;
                BGTZ    : pc_in = ((~negative) && ~(zero)) ? (pc_reg + ({{14{ir_reg[15]}}, ir_reg[15:0], 2'b00})) : pc_reg + 4;
                BLEZ    : pc_in = (negative || zero) ? (pc_reg + ({{14{ir_reg[15]}}, ir_reg[15:0], 2'b00})) : pc_reg + 4;
                BNE     : pc_in = ~(equal) ? (pc_reg + ({{14{ir_reg[15]}}, ir_reg[15:0], 2'b00})) : pc_reg + 4;
                J       : pc_in = {pc_reg[31:28], ir_reg[25:0], 2'b00};
                JAL     : pc_in = {pc_reg[31:28], ir_reg[25:0], 2'b00};
                default : pc_in = pc_reg + 4;
            endcase
        end

    end

    /* --- Clock assignment and CPU reset behaviour --- */
    always_ff @(posedge clk) begin

        if(reset) begin
            pc_reg <= 32'hBFC00000;
            ir_reg <= 0;
            hi_reg <= 0;
            lo_reg <= 0;
            active <= 1;
        end

        else if(clk_enable) begin
            pc_reg <= (pc_reg != 32'h00000000) ? pc_in : pc_reg;
            ir_reg <= instr_readdata;
            hi_reg <= hi_in;
            lo_reg <= lo_in;
            active <= (pc_reg != 32'h00000000);
        end

    end

endmodule

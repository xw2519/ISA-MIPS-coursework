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
    input  logic [31:0] data_readdata
    output logic        data_write,
    output logic        data_read,
    output logic [31:0] data_writedata,
    output logic [31:0] data_address,
);

    /* --- Signal definitions --- */
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
    logic [4:0]  write_addr_d;
    logic        write_enable_d;
    logic [31:0] write_data_d;

    // Control definitions

    // PC definitions
    logic [31:0] pc_reg;
    logic [31:0] pc_in;

    /* --- CPU connections --- */
    always_comb begin
        sign_extended_imm = UNS ? {16'h0000, instr_readdata[15:0]} : {{16{instr_readdata[15]}}, instr_readdata[15:0]}
        upper_imm = {16'h0000, instr_readdata[15:0]} << 16

        read_bytes =
        byte_enabled_read = {read_bytes[3] ? data_readdata[31:24] : 8'h00},
            {read_bytes[2] ? data_readdata[23:16] : 8'h00},
            {read_bytes[1] ? data_readdata[15:8] : 8'h00},
            {read_bytes[0] ? data_readdata[7:0] : 8'h00};

        alu_control =
        alu_shift_amt = VAR ? read_data_a[4:0] : instr_readdata[10:6];
        alu_b = IMM ? sign_extended_imm : read_data_b;

        write_addr_c = IMM ? instr_readdata[20:16] : instr_readdata[15:11];
        write_enable_c = RGW;
        write_data_c = alu_result : upper_imm : byte_enabled_read;
    end

    /* --- CPU states --- */
    always_ff @(posedge clk)
    begin
        if (reset) // Reset logic
        begin
            pc <= 32'hBFC00000;
            active <= 1;
        end
        else if(clk_enable)
        begin

        end
    end

    mips_cpu_harvard_alu alu(
        .alu_control(),
        .alu_shift_amt(alu_shift_amt),
        .alu_a(read_data_a),
        .alu_b(alu_b),

        .zero(zero),
        .equal(equal),
        .negative(negative),
        .alu_result(alu_result)
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

        /* Write ports */
        .write_addr_c,
        .write_enable_c,
        .write_data_c,
        .write_addr_d,
        .write_enable_d,
        .write_data_d
    );

endmodule

module mips_cpu_register_file
(
    /* Standard signals */
    input  logic        clk,
    input  logic        clk_enable,
    input  logic        reset,
    output logic [31:0] register_v0,

    /* Read ports */
    input  logic [4:0]  read_addr_a,
    output logic [31:0] read_data_a,

    input  logic [4:0]  read_addr_b,
    output logic [31:0] read_data_b,

    /* Write port */
    input  logic [4:0]  regfile_write_addr,
    input  logic        regfile_write_enable,
    input  logic [31:0] regfile_write_data
);

    integer i;
    logic [31:0] regs [31:0];

    always_comb begin
        register_v0 = reset ? 0 : regs[2];
        read_data_a = reset ? 0 : regs[read_addr_a];
        read_data_b = reset ? 0 : regs[read_addr_b];
    end

    always_ff @(posedge clk) begin
        // RESET behaviour
        if (reset) begin
            for (i=0; i<32; i=i+1) begin
                regs[i] <= 0;
            end
        end

        // Write at positive clock-edge
        else if (regfile_write_enable && (regfile_write_addr != 0) && clk_enable) begin
            regs[regfile_write_addr] <= regfile_write_data;
        end
    end
endmodule

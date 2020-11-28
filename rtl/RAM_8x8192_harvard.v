/* --- Implements a 8-bit x 8K RAM, with zero delay read. --- */
/* The memory is split int 4 parts in the 32-bit address space.
    Part 1: 0x00000000 -> 0x000003FF
    Part 2: 0x80000000 -> 0x800007FF
    Part 3: 0xBFBFF800 -> 0xBFC007FF
    Part 4: 0xFFFFFC00 -> 0xFFFFFFFF
*/
module RAM_8x8192_harvard(
    input  logic        clk,
    input  logic [31:0] instr_address,
    input  logic        data_write,
    input  logic        data_read,
    input  logic [31:0] data_writedata,
    input  logic [31:0] data_address,

    output logic [31:0] instr_readdata,
    output logic [31:0] data_readdata
);
    parameter RAM_INIT_FILE = "";

    reg   [7:0]  memory[8191:0]

    logic [12:0] mapped_instr_address;
    logic [12:0] mapped_data_address;

    initial
    begin
        integer i;

        for (i=0; i<8192; i++) begin
            memory[i]=0;
        end
        /* Load contents from file if specified */
        if (RAM_INIT_FILE != "") begin
            $display("RAM : INIT : Loading RAM contents from %s", RAM_INIT_FILE);
            $readmemh(RAM_INIT_FILE, memory);
        end
    end

    always_comb
    begin
        case(instr_address[31:24])
            8'h00   : mapped_instr_address = instr_address[12:0];
            8'h80   : mapped_instr_address = instr_address[12:0] + 13'h0400;
            8'hBF   : mapped_instr_address = instr_address[12:0] - 13'h0800;
            8'hFF   : mapped_instr_address = {{1'h1}, instr_address[11:0]};
            default : mapped_instr_address = instr_address[12:0];
        endcase

        case(data_address[31:24])
            8'h00   : mapped_data_address = data_address[12:0];
            8'h80   : mapped_data_address = data_address[12:0] + 13'h0400;
            8'hBF   : mapped_data_address = data_address[12:0] - 13'h0800;
            8'hFF   : mapped_data_address = {{1'h1}, data_address[11:0]};
            default : mapped_data_address = data_address[12:0];
        endcase

        instr_readdata = {memory[mapped_instr_address+3], memory[mapped_instr_address+2], memory[mapped_instr_address+1], memory[mapped_instr_address]};
        data_readdata = data_read ? {memory[mapped_data_address+3], memory[mapped_data_address+2], memory[mapped_data_address+1], memory[mapped_data_address]} : 32'hxxxxxxxx;
    end

    always @(posedge clk) begin
        $display("RAM : INFO : read=%h, addr = %h, mem=%h", data_read, mapped_data_address,
                  {memory[mapped_data_address+3], memory[mapped_data_address+2], memory[mapped_data_address+1], memory[mapped_data_address]});
        if (data_write) begin
            memory[mapped_data_address]   <= data_writedata[7:0];
            memory[mapped_data_address+1] <= data_writedata[15:8];
            memory[mapped_data_address+2] <= data_writedata[23:16];
            memory[mapped_data_address+3] <= data_writedata[31:24];
        end
    end
endmodule

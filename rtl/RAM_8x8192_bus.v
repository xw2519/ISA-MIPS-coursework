/* --- Implements a 8-bit x 8K RAM, with sequential read. --- */
/* The memory is split int 4 parts in the 32-bit address space.
    Part 1: 0x00000000 -> 0x000003FF
    Part 2: 0x80000000 -> 0x800007FF
    Part 3: 0xBFBFF800 -> 0xBFC007FF
    Part 4: 0xFFFFFC00 -> 0xFFFFFFFF
*/
module RAM_8x8192_bus(
    input  logic         clk,
    input  logic         write,
    input  logic         read,
    input  logic [31:0]  writedata,
    input  logic [31:0]  address,

    output logic [31:0]  readdata
);
    parameter RAM_INIT_FILE = "";

    reg   [7:0]  memory[8191:0];

    logic [12:0] mapped_address;

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

    always @(*)
    begin
        case(address[31:24])
            8'h00   : mapped_address = address[12:0];
            8'h80   : mapped_address = address[12:0] + 13'h0400;
            8'hBF   : mapped_address = address[12:0] + 13'h1400;
            8'hFF   : mapped_address = {{1'h1}, address[11:0]};
            default : mapped_address = address[12:0];
        endcase
    end

    always @(posedge clk) begin
        //$display("RAM : INFO : read=%h, addr = %h, mem=%h", read, mapped_address,
                  //{memory[mapped_address+3], memory[mapped_address+2], memory[mapped_address+1], memory[mapped_address]});
        if (write) begin
          memory[mapped_address]   <= writedata[7:0];
          memory[mapped_address+1] <= writedata[15:8];
          memory[mapped_address+2] <= writedata[23:16];
          memory[mapped_address+3] <= writedata[31:24];
        end
        readdata <= {memory[mapped_address+3], memory[mapped_address+2], memory[mapped_address+1], memory[mapped_address]};
    end
endmodule

module mips_cpu_harvard_tb;
    //timeunit 1ns / 10ps;

    //parameter RAM_INIT_FILE = "test/test.hex.txt";
    parameter RAM_INIT_FILE = "";
    parameter TIMEOUT_CYCLES = 10000;

    logic        clk;
    logic        reset;
    logic        clk_enable;

    logic        active;
    logic [31:0] register_v0;

    logic [31:0] instr_readdata;
    logic [31:0] instr_address;

    logic [31:0] data_readdata;
    logic        data_write;
    logic        data_read;
    logic [31:0] data_writedata;
    logic [31:0] data_address;

    RAM_8x8192_harvard #(RAM_INIT_FILE) ramInst(clk, instr_address, data_write, data_read, data_writedata, data_address, instr_readdata, data_readdata);

    mips_cpu_harvard cpuInst(clk, reset, active, register_v0, clk_enable,
    instr_readdata, instr_address, data_readdata, data_write,
    data_read, data_writedata, data_address);

    // Generate clock
    initial begin
        clk=0;

        repeat (TIMEOUT_CYCLES) begin
            #10;
            clk = !clk;
            #10;
            clk = !clk;
        end

        $fatal(2, "Simulation did not finish within %d cycles.", TIMEOUT_CYCLES);
    end

    initial begin
        clk_enable = 1;

        reset <= 0;

        @(posedge clk);
        reset <= 1;

        @(posedge clk);
        reset <= 0;

        @(posedge clk);
        assert(active==1)
        else $display("TB : CPU did not set running=1 after reset.");

        while (active) begin
            @(posedge clk);
        end

        $display("TB : finished; running=0");

        $finish;

    end



endmodule

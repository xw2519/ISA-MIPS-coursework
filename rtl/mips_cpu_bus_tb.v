module mips_cpu_bus_tb;
    //timeunit 1ns / 10ps;

    parameter RAM_INIT_FILE = "test.hex.txt";
    parameter TIMEOUT_CYCLES = 10000;

    logic        clk;
    logic        reset;
    logic        waitrequest;

    logic        active;
    logic [31:0] register_v0;

    logic [31:0] readdata;
    logic        write;
    logic        read;
    logic [31:0] writedata;
    logic [31:0] address;
    logic [3:0]  byteenable;

    RAM_8x8192_bus #(RAM_INIT_FILE) ramInst(clk, write, read, writedata, address, byteenable, readdata);

    mips_cpu_bus cpuInst(clk, reset, active, register_v0,
    waitrequest, readdata, write, read,
    byteenable, writedata, address);

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
      waitrequest = 0;

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

        $display("TB : INFO : register_v0=%h", register_v0);
        $display("TB : finished; running=0");

        $finish;

    end



endmodule

module mips_cpu_bus_tb;
    //timeunit 1ns / 10ps;

    parameter RAM_INIT_FILE = "";
    parameter TIMEOUT_CYCLES = 10000;

    logic        clk;
    logic        reset;
    logic        waitrequest;

    logic        active;
    logic [31:0] register_v0;

    logic [31:0] readdata;
    logic [31:0] delayed_readdata;
    logic        write;
    logic        read;
    logic [31:0] writedata;
    logic [31:0] address;
    logic [3:0]  byteenable;

    RAM_8x8192_bus #(RAM_INIT_FILE) ramInst(clk, write, read, writedata, address, byteenable, readdata);

    mips_cpu_bus cpuInst(clk, reset, active, register_v0,
    waitrequest, delayed_readdata, write, read,
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

    initial
    begin
      waitrequest = 0;

        reset <= 0;

        @(posedge clk);
        reset <= 1;

        @(posedge clk);
        reset <= 0;

        @(posedge clk);
        assert(active==1)
        else $display("TB : CPU did not set active=1 after reset.");

        while (active) begin
            @(posedge clk);
        end

        $display("TB : INFO : register_v0=%h", register_v0);
        $display("TB : finished; active=0");

        $finish;

    end

    always @(posedge read) // Uses waitrequest to cause fetch to take 3 cycles
    begin
        waitrequest = 1;
        $display("TB : INFO : Waiting for FETCH; address=%h", address);
        delayed_readdata = 32'hxxxxxxxx;
        #25;
        delayed_readdata = readdata;
        $display("TB : INFO : FETCH completed; readdata=%h \n", delayed_readdata);
        waitrequest = 0;
    end

    always @(posedge write)   // Uses waitrequest to make writes take 4 cycles
    begin
        waitrequest = 1;
        $display("TB : INFO : Waiting for WRITE; address=%h", address);
        #35;
        $display("TB : INFO : WRITE completed; writedata=%h \n", writedata);
        waitrequest = 0;
    end

endmodule

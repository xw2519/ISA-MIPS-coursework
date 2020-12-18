module mips_cpu_bus_tb;

    /* Parameter and logic declarations */
    parameter RAM_INIT_FILE  = "";
    parameter TIMEOUT_CYCLES = 10000;


    logic        clk;
    logic        reset;
    logic        waitrequest;

    logic        active;
    logic [31:0] register_v0;

    logic        write;
    logic        read;
    logic [3:0]  byteenable;
    logic [31:0] readdata;
    logic [31:0] writedata;
    logic [31:0] address;

    /* Connections to Memory */
    RAM_8x8192_avalon_mapped #(RAM_INIT_FILE) ramInst(
        .clk(clk),
    		.address(address),
    		.write(write),
    		.read(read),
    		.waitrequest(waitrequest),
    		.writedata(writedata),
    		.byteenable(byteenable),
    		.readdata(readdata)
    );

    /* Connections to Design Under Test */
    mips_cpu_bus cpuInst(
        .clk(clk),
        .reset(reset),
        .active(active),
        .register_v0(register_v0),
        .waitrequest(waitrequest),
        .readdata(readdata),
        .write(write),
        .read(read),
        .byteenable(byteenable),
        .writedata(writedata),
        .address(address)
    );

    /* Generate clock */
    initial begin
        $dumpfile("mips_cpu_bus_tb.vcd");
        $dumpvars(0, mips_cpu_bus_tb);

        clk = 0;

        repeat (TIMEOUT_CYCLES) begin
            #10;
            clk = !clk;
        end

        $fatal(2, "Simulation did not finish within %d cycles.", TIMEOUT_CYCLES);
    end

    /* Simulate RESET and instructions */
    initial begin
        reset <= 0;
        waitrequest <= 0;
        @(posedge clk);     
        reset <= 1;

        @(posedge clk);
        reset <= 0;

        @(posedge clk);
        assert(active == 1);
        else $display("TB : CPU did not set active=1 after reset.");

        while (active) begin
            @(posedge clk);
        end

        $display("TB : INFO : register_v0=%h", register_v0);
        $display("TB : Finished : active=0");
        $finish;
    end
endmodule

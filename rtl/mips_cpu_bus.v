module mips_cpu_bus( 
    /* Standard signals */ 
    input  logic        clk, 
    input  logic        reset, 
    output logic        active, 
    output logic[31:0]  register_v0, 
 
    /* Avalon memory mapped bus controller (master) */ 
    input  logic        waitrequest, 
    input  logic[31:0]  readdata 
    output logic        write, 
    output logic        read, 
    output logic[3:0]   byteenable, 
    output logic[31:0]  writedata, 
    output logic[31:0]  address, 
);



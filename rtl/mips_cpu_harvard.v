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
    
    /* Combinatorial read and single-cycle write access to instructions */ 
    input  logic [31:0] data_readdata 
    output logic        data_write, 
    output logic        data_read, 
    output logic [31:0] data_writedata, 
    output logic [31:0] data_address, 
); 

    /* --- Wire definitions --- */
    // ALU definitions 
    logic        alu_zero;	
	logic [31:0] alu_result;
    logic [31:0] alu_mux;

	// ALU Control definitions 
    logic [3:0]  alu_control_output;
    logic [5:0]  alu_control_input
    
    // Register file definitions 
    logic [4:0]  regfile_read_reg_1;
    logic [4:0]  regfile_read_reg_2;
    logic [4:0]  regfile_write_reg;
    logic [31:0] regfile_write_data;
    logic [31:0] regfile_read_data_1;
    logic [31:0] regfile_read_data_2;
    logic [31:0] regfile_register_v0; // special output for coursework

    // Sign extender definitions 
    logic [15:0] sign_extended_in;
    logic [31:0] sign_extended_out;

    // Control definitions
    logic        ctrl_reg_dst;
    logic        ctrl_reg_write;  
    logic        ctrl_branch;
    logic        ctrl_mem_read; 
    logic        ctrl_mem_write; 
    logic        ctrl_mem_to_reg; 
    logic        ctrl_alu_src; 
    logic [1:0]  ctrl_alu_op; 
    logic [5:0]  ctrl_instr_opcode 

    // PC definitions
    logic [31:0] pc_out
    logic [31:0] pc_in
    logic [31:0] pc_mux

    // Add definitions 
    logic [31:0] add_input_1;
    logic [31:0] add_input_2;
    parameter four = 64'h0000000000000004;


    /* --- Assign relationships --- */
    assign add_input_1 = pc_out + four; // PC add 4
    assign pc_mux = (ctrl_branch && alu_zero) ? add_input_2 : add_input_1; // PC mux
    assign write_reg = (reg_dst) ? instr_readdata[15:11] : instr_readdata[20:16]; // Reg MUX
    assign write_data = (mem_to_reg) ? data_readdata : alu_result; // Write data mux
    assign alu_mux = (alu_src) ? sign_extended : read_data_2; // ALU mux 
    assign ctrl_instr_opcode = instr_readdata[31:26]; // Control input 
    assign regfile_read_reg_1 = instr_readdata[25:21]; // Read register 1
    assign regfile_read_reg_2 = instr_readdata[20:16]; // Read register 2
    assign sign_extended_in = instr[15:0]; // Sign extended input
    assign alu_control = instr_readdata[5:0]; // ALU control input


    // TODO: Conditional structure to assign depending on type of instruction 

    /* --- CPU construction --- */ 
    always_ff @(posedge clk) 
    begin
        if (reset) // Reset logic
        begin
            pc <= 0;
            active <= 1;
        end
        else if(clk_enable) 
        begin

        end
    end


endmodule



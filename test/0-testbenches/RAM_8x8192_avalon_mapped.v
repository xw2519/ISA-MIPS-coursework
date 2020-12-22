module RAM_8x8192_avalon_mapped(
		input  logic        clk,
		input  logic [31:0] address,
		input  logic        write,
		input  logic        read,
		input  logic        waitrequest,
		input  logic [31:0] writedata,
		input  logic [3:0]  byteenable,
		output logic [31:0] readdata
);
	parameter RAM_FILE = "";

	logic [31:0] word;
	logic [12:0] mapped_address;
	logic        supress_read;

	reg   [7:0]  mem[8191:0];

	initial begin
		integer i;
		for (i=0;i<8192;i++) begin
			mem[i] = 0;
		end
		if (RAM_FILE!="") begin
			$display("Loading %s into RAM",RAM_FILE);
			$readmemh(RAM_FILE, mem, 0, 8191);
		end

		supress_read = 0;
	end

/* The memory is split into 4 parts in the 32-bit address space.
Only memory accesses to these addresses in this range are guaranteed to give expected results.
	32-bit address											: 			13-bit memory
    Part 1: 0x00000000 -> 0x000003FF 	: 			0x0000 -> 0x03FF
    Part 2: 0x80000000 -> 0x800007FF		: 			0x0400 -> 0xBFF
    Part 3: 0xBFBFF800 -> 0xBFC007FF	:			0x0C00 -> 0x1BFF
    Part 4: 0xFFFFFC00 -> 0xFFFFFFFF	:			0x1C00 -> 0x1FFF
*/
	always @(*) begin
      case(address[31:24])
          8'h00   : mapped_address = address[12:0]; 						//Lowest 13 bits maps the address to Part 1 of the memory
          8'h80   : mapped_address = address[12:0] + 13'h0400; 	//Lowest 13 bits + 0x0400  (0x0000 -> 0x0400)
          8'hBF   : mapped_address = address[12:0] + 13'h1400;	//Lowest 13 bits - 0x0C00	(0x1800 -> 0x0C00) [-0x0C00 equivalent to + 0x1400 when only 13 bits wide, 0x1800 and not 0xF800 as 13 bits wide, not 16]
          8'hFF   : mapped_address =  address[12:0];						//Lowest 13 bits (0x1C00 -> 0x1C00)
          default : mapped_address = address[12:0];
      endcase
  end



	always@(posedge clk) begin
		if(read && ~waitrequest && ~supress_read) begin
			readdata <=  {mem[mapped_address+3],mem[mapped_address+2],mem[mapped_address+1],mem[mapped_address]};
			$display("TB : INFO : RAM_ACCESS: Read from 0x%h, data: 0x%h",address, {mem[mapped_address+3],mem[mapped_address+2],mem[mapped_address+1],mem[mapped_address]});
		end
		else if (read && ~waitrequest && supress_read) begin
			supress_read = 0;
		end
		if (write && ~waitrequest)  begin
			$write("TB : INFO : RAM_ACCESS: Write to 0x%h, data: 0x",address);
			if(byteenable[3]) begin
				mem[mapped_address+3] <= writedata[31:24];
				$write("%h",writedata[31:24]);
			end
			else begin
					$write("xx");
			end
			if(byteenable[2]) begin
				mem[mapped_address+2] <= writedata[23:16];
				$write("%h",writedata[23:16]);
			end
			else begin
					$write("xx");
			end
			if(byteenable[1]) begin
				mem[mapped_address+1] <= writedata[15:8];
				$write("%h",writedata[15:8]);
			end
			else begin
				$write("xx");
			end
			if(byteenable[0]) begin
				mem[mapped_address] <= writedata[7:0];
				$display("%h",writedata[7:0]);
			end
			else begin
				$display("xx");
			end
		end
	end

	always @(negedge waitrequest) begin
		if(read) begin
			readdata <=  {mem[mapped_address+3],mem[mapped_address+2],mem[mapped_address+1],mem[mapped_address]};
			$display("TB : INFO : RAM_ACCESS: Read from 0x%h, data: 0x%h",address, {mem[mapped_address+3],mem[mapped_address+2],mem[mapped_address+1],mem[mapped_address]});
			supress_read = 1;
		end
	end

endmodule

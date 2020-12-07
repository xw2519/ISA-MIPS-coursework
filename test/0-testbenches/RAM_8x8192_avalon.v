module RAM_8x8192_avalon(

input logic clk,
input logic[31:0] address,
input logic write,
input logic read,
input logic assert_waitrequest,
output logic waitrequest,
input logic[31:0] writedata,
input logic[3:0] byteenable,
output logic[31:0] readdata

);
	parameter RAM_FILE = "";
	logic [31:0] word;
	reg [7:0] mem [8191:0];
	
	initial begin
		integer i;
		for (i=0;i<8192;i++) begin
			mem[i] = 0;
		end
		if (RAM_FILE!="") begin
			$display("Loading %s into RAM",RAM_FILE);
			$readmemh(RAM_FILE,mem);
		end
	end
	
	assign waitrequest = assert_waitrequest;
	
	always_ff @(negedge waitrequest) begin
		if(read) begin
			readdata <=  {mem[address+3],mem[address+2],mem[address+1],mem[address]};
		end
		else if(write) begin
			if(byteenable[0]) begin
				mem[address] <= writedata[7:0];
			end
			if(byteenable[1]) begin
				mem[address+1] <= writedata[15:8];
			end
			if(byteenable[2]) begin
				mem[address+2] <= writedata[23:16];
			end
			if(byteenable[3]) begin
				mem[address+3] <= writedata[31:24];
			end
		end
		
	end
endmodule
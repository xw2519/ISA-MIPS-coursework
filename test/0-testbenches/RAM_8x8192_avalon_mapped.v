module RAM_8x8192_avalon_mapped(

input logic clk,
input logic[31:0] address,
input logic write,
input logic read,
input logic waitrequest,
input logic[31:0] writedata,
input logic[3:0] byteenable,
output logic[31:0] readdata

);
	parameter RAM_FILE = "";
	logic [31:0] word;
	reg [7:0] mem [8191:0];
	logic[12:0] mapped_address;
	initial begin
		integer i;
		for (i=0;i<8192;i++) begin
			mem[i] = 0;
		end
		if (RAM_FILE!="") begin
			$display("Loading %s into RAM",RAM_FILE);
			$readmemh(RAM_FILE, mem, 0, 8191);
		end
	end

	always @(*) begin
      case(address[31:24])
          8'h00   : mapped_address = address[12:0];
          8'h80   : mapped_address = address[12:0] + 13'h0400;
          8'hBF   : mapped_address = address[12:0] + 13'h1400;
          8'hFF   : mapped_address = {{1'h1}, address[11:0]};
          default : mapped_address = address[12:0];
      endcase
  end


	always_ff @(posedge clk) begin
		if(read) begin
			readdata <=  {mem[mapped_address+3],mem[mapped_address+2],mem[mapped_address+1],mem[mapped_address]};
		end
		else if(write) begin
			if(byteenable[0]) begin
				mem[mapped_address] <= writedata[7:0];
			end
			if(byteenable[1]) begin
				mem[mapped_address+1] <= writedata[15:8];
			end
			if(byteenable[2]) begin
				mem[mapped_address+2] <= writedata[23:16];
			end
			if(byteenable[3]) begin
				mem[mapped_address+3] <= writedata[31:24];
			end
		end

	end
endmodule

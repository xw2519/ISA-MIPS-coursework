module RAM(

input logic clk,
input logic[31:0] address,
input logic write,
input logic read,
output logic waitrequest,
input logic[31:0] writedata,
input logic[3:0] byteenable,
output logic[31:0] readdata

);
	parameter RAM_FILE = "";
	
	reg [31:0] mem [4095:0]

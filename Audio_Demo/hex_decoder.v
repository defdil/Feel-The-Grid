`timescale 1ns/1ns

module hexDecoder(hex, outputHEX);

	input [3:0] hex;
	output [6:0] outputHEX;
	
	wire a, b, c, d;
	
	assign a = hex[3];
	assign b = hex[2];
	assign c = hex[1];
	assign d = hex[0];
	
	assign outputHEX[0]  = ~((~b & ~d) | (~a & c) | (b & c) | (a & ~d) | (~a & b & d) | (a & ~b & ~c));
	
	assign outputHEX[1] = ~((~a & ~b) | (~b & ~d) | (~a & ~c & ~d) | (~a & c & d) | (a & ~c & d));
	
	assign outputHEX[2] = ~((~a & ~c) | (~a & d) | (~c & d) | (~a & b) | (a & ~b));
	
	assign outputHEX[3] = ~((~a & ~b & ~d) | (~b & c & d) | (b & ~c & d) | (b & c & ~d) | (a & ~c & ~d));
		
	assign outputHEX[4] = ~((~b & ~d) | (c & ~d) | (a & c) | (a & b));
	
	assign outputHEX[5] = ~((~c & ~d) | (b & ~d) | (a & ~b) |(a & c) | (~a & b & ~c));
	
	assign outputHEX[6] = ~((~b & c) | (c & ~d) | (a & ~b) | (a & d) | (~a & b & ~c));
	
endmodule

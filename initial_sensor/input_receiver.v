`timescale 1ns/1ns

module input_receiver(SW, LEDR, GPIO_0);
	input [0:0] SW;
	input [0:0] GPIO_0;
	output [9:0] LEDR;
	
	assign LEDR[0] = SW[0];
	
	assign LEDR[9] = 
	GPIO_0[0];
	
endmodule

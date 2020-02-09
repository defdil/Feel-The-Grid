module datapath_intermediate_vga(CLOCK_50, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B, gpio, reset, input_key, ld_start, ld_read, ld_input, ld_evaluate, ld_level, board, ld_reset, level);
	input CLOCK_50, ld_evaluate, ld_input, ld_read, ld_start, reset, ld_reset, ld_level, input_key;
	input [8:0] board;
	input [3:0] gpio;
	input [1:0] level;
	output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
	output [9:0] VGA_R, VGA_G, VGA_B;

	wire [3:0] position;
	wire [8:0] color_vga, ram_out;
	
	reg [8:0] color_vga_reg, ram_board;
	reg [3:0] position_reg, counter, counter1, counter2, counter3, counter4;
	reg [9:0] clock_count, clock_count1, clock_count2, clock_count3, clock_count4;
	
	localparam green = 9'b000_111_000,
	 			//white = 9'b111_111_111 ,
				white = 9'b111_111_111,
	  			red = 9'b111_000_000;
	
	vga_main v0(.CLOCK_50(CLOCK_50), .VGA_CLK(VGA_CLK), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK_N(VGA_BLANK_N), .VGA_SYNC_N(VGA_SYNC_N),
	 .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .gpio(position), .reset(~reset), .color_vga(color_vga), .level(level), .ld_level(ld_level));
	
	
	always @(posedge CLOCK_50) begin
		if(reset) begin 
			counter <= 0;
			counter1 <= 0;
			counter2 <= 0;
			counter3 <= 0;
			counter4 <= 0;
			clock_count <= 0;
			clock_count1 <= 0;
			clock_count2 <= 0;
			clock_count3 <= 0;
			clock_count4 <= 0;
			color_vga_reg <= white;
		end
		if(ld_level) begin
			counter <= 0;
			counter1 <= 0;
			counter2 <= 0;
			counter3 <= 0;
			counter4 <= 0;
			clock_count <= 0;
			clock_count1 <= 0;
			clock_count2 <= 0;
			clock_count3 <= 0;
			clock_count4 <= 0;
			color_vga_reg <= white;
		end
		//else begin
	if(ld_start) begin
			if (clock_count3 == 10'd1000) begin
				if (counter3 <= 4'd8) begin
					case (counter3)
						4'd0: begin
							position_reg <= 4'b1111;
						end
						4'd1: begin 
							position_reg <= 4'b1110;
						end
						4'd2: begin 
							position_reg <= 4'b1101;
						end
						4'd3: begin 
							position_reg <= 4'b1011;
						end
						4'd4: begin
						
						 	position_reg <= 4'b1010;
						end
						4'd5: begin 
							position_reg <= 4'b1001;
						end
						4'd6: begin 
							position_reg <= 4'b0111;
						end
						4'd7: begin 
							position_reg <= 4'b0110;
						end
						4'd8: begin 
							position_reg <= 4'b0101;
						end
						default: position_reg <= 4'b0;
					endcase
					color_vga_reg <= white;
					clock_count3 <= 9'b0;
					if(counter3 == 4'd8) 
						begin
							counter3 <=0;
						end
					else begin counter3 <= counter3 + 1;
					end
				end
			end // if (clock_count ==9'd496)
			else clock_count3 <= clock_count3 + 1;
		end
		if(ld_read) begin
			if (clock_count == 10'd1000) begin
				if (counter <= 4'd8) begin
					case (counter)
						4'd0: begin
							position_reg <= 4'b1111;
						end
						4'd1: begin 
							position_reg <= 4'b1110;
						end
						4'd2: begin 
							position_reg <= 4'b1101;
						end
						4'd3: begin 
							position_reg <= 4'b1011;
						end
						4'd4: begin
						 	position_reg <= 4'b1010;
						end
						4'd5: begin 
							position_reg <= 4'b1001;
						end
						4'd6: begin 
							position_reg <= 4'b0111;
						end
						4'd7: begin 
							position_reg <= 4'b0110;
						end
						4'd8: begin 
							position_reg <= 4'b0101;
						end
						default: position_reg <= 4'b0;
					endcase
					color_vga_reg <= board[counter] ? green : white;
					clock_count <= 9'b0;
					counter <= counter + 1;
					ram_board <= board;
				end
			end // if (clock_count ==9'd496)
			else clock_count <= clock_count + 1;
		end

		if(ld_reset) begin
			if (clock_count1 == 10'd1000) begin
				if (counter1 <= 4'd8) begin
					case (counter1)
						4'd0: begin
							position_reg <= 4'b1111;
						end
						4'd1: begin 
							position_reg <= 4'b1110;
						end
						4'd2: begin 
							position_reg <= 4'b1101;
						end
						4'd3: begin 
							position_reg <= 4'b1011;
						end
						4'd4: begin
						
						 	position_reg <= 4'b1010;
						end
						4'd5: begin 
							position_reg <= 4'b1001;
						end
						4'd6: begin 
							position_reg <= 4'b0111;
						end
						4'd7: begin 
							position_reg <= 4'b0110;
						end
						4'd8: begin 
							position_reg <= 4'b0101;
						end
						default: position_reg <= 4'b0;
					endcase
					color_vga_reg <= white;
					clock_count1 <= 9'b0;
					if(counter1 == 4'd8) 
						begin
							counter1 <=0;
						end
					else begin counter1 <= counter1 + 1;
					end
				end
			end // if (clock_count ==9'd496)
			else clock_count1 <= clock_count1 + 1;
		end
		if (ld_input) begin
			if (input_key) counter2 <= 0;
			else counter2 <= counter2;
			if (clock_count2 == 10'd1000) begin
				if (counter2 <= 4'd8) begin
					case (counter2)
						4'd0: begin
							position_reg <= 4'b1111;
						end
						4'd1: begin 
							position_reg <= 4'b1110;
						end
						4'd2: begin 
							position_reg <= 4'b1101;
						end
						4'd3: begin 
							position_reg <= 4'b1011;
						end
						4'd4: begin
						 	position_reg <= 4'b1010;
						end
						4'd5: begin 
							position_reg <= 4'b1001;
						end
						4'd6: begin 
							position_reg <= 4'b0111;
						end
						4'd7: begin 
							position_reg <= 4'b0110;
						end
						4'd8: begin 
							position_reg <= 4'b0101;
						end
						default: position_reg <= 4'b0;
					endcase
					color_vga_reg <= board[counter2] ? green : white;
					clock_count2 <= 9'b0;
					counter2 <= counter2 + 1;
				end
			end // if (clock_count ==9'd496)
			else clock_count2 <= clock_count2 + 1;
		end
		if(ld_evaluate) begin
			if (clock_count4 == 10'd1000) begin
				if (counter4 <= 4'd8) begin
					case (counter4)
						4'd0: begin
							position_reg <= 4'b1111;
						end
						4'd1: begin 
							position_reg <= 4'b1110;
						end
						4'd2: begin 
							position_reg <= 4'b1101;
						end
						4'd3: begin 
							position_reg <= 4'b1011;
						end
						4'd4: begin
						 	position_reg <= 4'b1010;
						end
						4'd5: begin 
							position_reg <= 4'b1001;
						end
						4'd6: begin 
							position_reg <= 4'b0111;
						end
						4'd7: begin 
							position_reg <= 4'b0110;
						end
						4'd8: begin 
							position_reg <= 4'b0101;
						end
						default: position_reg <= 4'b0;
					endcase
					color_vga_reg <= (board[counter4] && ram_board[counter4])  ? green : (board[counter4] ? red : (ram_board[counter4] ? red : white));
					clock_count4 <= 9'b0;
					counter4 <= counter4 + 1;
				end
			end // if (clock_count ==9'd496)
			else clock_count4 <= clock_count4 + 1;
		end
		end
		//end
	
	assign position = position_reg;
	assign color_vga = color_vga_reg;
endmodule

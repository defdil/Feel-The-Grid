module datapath (go, gp_input, input_key, reset, clock, ld_start, ld_read, ld_input, ld_evaluate, ld_reset, ld_level, sound_select, audio_en, HEX0, board_out, level, ld_level_draw_comp);
	input [3:0] gp_input;
	input reset, go, ld_start, ld_read, ld_input, ld_evaluate, clock, input_key, ld_reset, ld_level;
	output reg [8:0] board_out;
	output audio_en;
	output reg ld_level_draw_comp;
	
	reg [9:0] level_draw_counter;
	reg pattern_match;
	reg audio_en_reg;
	reg [1:0] state;
	output reg [1:0] sound_select;
	output [6:0] HEX0;
	
	reg [5:0] address_reg;
	reg [8:0] user_pattern;
	output reg [1:0] level;
	
	wire [8:0] ram_out;
	wire [4:0] address;
	wire [9:0] random_number;
	
	assign address = {level [1:0], random_number [2:0]};
	
	hexDecoder h0(.hex({2'b0, state}), .outputHEX(HEX0));
	
	lfsr l0(.out(random_number), .enable(ld_start), .clk(clock), .reset(reset)); 
	
	pattern_ram pr0 (.address(address), .clock (clock), .wren (1'b0), .q (ram_out));
	
	//assign LEDR[8:0] = ram_out;
	
	always @ (posedge clock) begin
	if(reset) begin
				audio_en_reg <= 1'b0;
				state <= 2'b0;
				user_pattern <= 9'b0;
				sound_select <= 2'b0;
				board_out <= 9'b0;
				level <= 2'b0;
				level_draw_counter <= 10'd0;
				ld_level_draw_comp <= 1'b0;
		end
		else begin
		if(ld_level) begin
			if(level_draw_counter == 10'd1000) begin
				level <= (pattern_match) ? level + 2'd1 : 2'b0;
				ld_level_draw_comp <= 1'b1;
			end
			else begin 
				level_draw_counter <= level_draw_counter + 1'b1;
				ld_level_draw_comp <= 1'b0;
			end
		end
		if(ld_reset) begin
			board_out <= 9'b0;
			ld_level_draw_comp <= 1'b0;
		end
		if (ld_start) begin
			address_reg <= 5'b0;
			state <= 2'b0;	
			audio_en_reg <= 1'b0;
			user_pattern <= 9'b0;
			ld_level_draw_comp <= 1'b0;
		end
		if (ld_read) begin
			state <= 2'b01;
			sound_select <= 2'b0;
			board_out <= ram_out;
		case (gp_input[3:0])
				4'b0101: begin
					audio_en_reg <= ram_out[8];
				end
				4'b0110: begin
					audio_en_reg <= ram_out[7];
				end
				4'b0111: begin
					audio_en_reg <= ram_out[6];
				end
				4'b1001: begin
					audio_en_reg <= ram_out[5];
				end
				4'b1010: begin
					audio_en_reg <= ram_out[4];
				end
				4'b1011: begin
					audio_en_reg <= ram_out[3];
				end
				4'b1101: begin
					audio_en_reg <= ram_out[2];
				end
				4'b1110: begin
					audio_en_reg <= ram_out[1];
				end
				4'b1111: begin
					audio_en_reg <= ram_out[0];
				end
				default: 
					audio_en_reg <= 1'b0;
			endcase
		end
		
		if(ld_input) begin
			state <= 2'b10;
			audio_en_reg <= 1'b0;
			sound_select <= 2'b10;
			board_out <= user_pattern;
			if (input_key) begin
				case (gp_input[3:0]) 
					4'b0101: begin
						user_pattern[8] <= 1'b1;
						audio_en_reg <= 1'b1;
					end
					4'b0110: begin
						user_pattern[7] <= 1'b1;
						audio_en_reg <= 1'b1;
					end
					4'b0111: begin
						user_pattern[6] <= 1'b1;
						audio_en_reg <= 1'b1;
					end
					4'b1001: begin
						user_pattern[5] <= 1'b1;
						audio_en_reg <= 1'b1;
					end
					4'b1010: begin
						user_pattern[4] <= 1'b1;
						audio_en_reg <= 1'b1;
					end
					4'b1011: begin
						user_pattern[3] <= 1'b1;
						audio_en_reg <= 1'b1;
					end
					4'b1101: begin
						user_pattern[2] <= 1'b1;
						audio_en_reg <= 1'b1;
					end
					4'b1110: begin
						user_pattern[1] <= 1'b1;
						audio_en_reg <= 1'b1;
					end
					4'b1111: begin
						user_pattern[0] <= 1'b1;
						audio_en_reg <= 1'b1;
					end
					default: begin
						user_pattern <= user_pattern;
						audio_en_reg <= 1'b0;
					end
				endcase
			end
			
			
		end
		
		if(ld_evaluate) begin
			state <= 2'b11;
			pattern_match <= (user_pattern == ram_out) ? 1'b1 : 1'b0;
			audio_en_reg <= 1'b1;
			sound_select <= (user_pattern == ram_out) ? 2'b11 : 2'b01;
			ld_level_draw_comp <= 1'b0;
		end
	end
	end
	
	assign audio_en = audio_en_reg;
	//assign LEDR[8:0] = user_pattern;
	//assign LEDR[9] = pattern_match;
	
endmodule


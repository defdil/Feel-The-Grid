module finalproject(SW, KEY, CLOCK_50, GPIO_0, AUD_ADCDAT, AUD_BCLK, 
	AUD_ADCLRCK, AUD_DACLRCK, FPGA_I2C_SDAT, AUD_XCK, AUD_DACDAT, LEDR, FPGA_I2C_SCLK, HEX0, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B, HEX1);
	
	input [9:0] SW;
	input [3:0] KEY;
	input [34:0] GPIO_0;
	input AUD_ADCDAT;
	input CLOCK_50;

	inout AUD_BCLK;
	inout AUD_ADCLRCK;
	inout AUD_DACLRCK;
	inout FPGA_I2C_SDAT;
	
	output AUD_XCK, AUD_DACDAT, FPGA_I2C_SCLK;
	output [9:0] LEDR;
	output [6:0] HEX0, HEX1;
	output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
	output [9:0] VGA_R, VGA_G, VGA_B;
	
	reg [3:0] in_board_config_reg, counter;
	wire reset, go, input_key, ld_read, ld_input, ld_evaluate, ld_start, audio_en, ld_reset, ld_level;
	wire [8:0] color_vga;
	wire [3:0] gp_input;
	wire [1:0] sound_select;
	wire [3:0] in_board_config;
	wire [8:0] board;
	wire [1:0] level;
	wire ld_level_draw_comp;
	
	reg [9:0] clock_count;
	reg [8:0] color;

	
	assign go = ~KEY[0];
	assign input_key = ~KEY[1];

	assign reset = SW[9];
	//assign gp_input= {GPIO_0[5:4], GPIO_0[1:0]}; //[5:4] ROWS, [1:0] COLUMNS
	assign gp_input= {SW[3:0]}; //[5:4] ROWS, [1:0] COLUMNS
	
	assign LEDR[9:6] = gp_input;

	hexDecoder({2'b0, level+1'b1}, HEX1);
	control c0(.clock(CLOCK_50), .reset(reset), .go(go), .ld_read(ld_read), 
		.ld_input(ld_input), .ld_evaluate(ld_evaluate), .ld_start(ld_start), .ld_reset(ld_reset), .ld_level(ld_level), .ld_level_draw_comp(ld_level_draw_comp));
	
	datapath d0(.go(go), .gp_input(gp_input), .sound_select(sound_select), .input_key(input_key), .reset(reset), .clock(CLOCK_50), .HEX0(HEX0),
		.ld_start(ld_start), .ld_read(ld_read), .ld_input(ld_input), .ld_evaluate(ld_evaluate), .ld_reset(ld_reset),
		.audio_en(audio_en), .level(level), .board_out(board), .ld_level(ld_level), .ld_level_draw_comp(ld_level_draw_comp));
	
	audio_main defne(CLOCK_50, KEY, AUD_ADCDAT, AUD_BCLK,
		AUD_ADCLRCK, AUD_DACLRCK, FPGA_I2C_SDAT, AUD_XCK, AUD_DACDAT, FPGA_I2C_SCLK, audio_en, sound_select);
	
	datapath_intermediate_vga sarhad(.CLOCK_50(CLOCK_50), .VGA_CLK(VGA_CLK), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK_N(VGA_BLANK_N), 
	.VGA_SYNC_N(VGA_SYNC_N), .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .input_key(input_key),
	.gpio(gp_input), .reset(reset), .ld_start(ld_start), .ld_read(ld_read), .ld_input(ld_input), .ld_evaluate(ld_evaluate), 
	.ld_reset(ld_reset), .ld_level(ld_level), .board(board), .level(level));
	
endmodule


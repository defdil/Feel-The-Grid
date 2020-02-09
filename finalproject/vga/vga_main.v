module vga_main(CLOCK_50, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B, gpio, reset, color_vga, level, ld_level);
	input CLOCK_50, reset;
	input [8:0] color_vga;
	input [3:0] gpio;
	input ld_level;
	
	input [1:0] level;
	
	output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
	output [9:0] VGA_R, VGA_G, VGA_B;
	wire reset, ld_coord, ld_draw, plot, go, ld_draw_done, ld_coord_level, ld_draw_done_level, ld_draw_level, go_level, plot_level, plot_main;
	wire [7:0] out_x, out_xcoord_level, final_x;
	wire [6:0] out_y, out_ycoord_level, final_y;
	wire [8:0] color_out_level;
	wire [8:0] final_color;
	
//	hexDecoder();
	
	
	vga_adapter VGA(.resetn(reset), .clock(CLOCK_50), .colour(color_vga), .x(out_x), .y(out_y), .plot(plot), .VGA_R(VGA_R), .VGA_G(VGA_G), 
		.VGA_B(VGA_B), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK(VGA_BLANK_N), .VGA_SYNC(VGA_SYNC_N), .VGA_CLK(VGA_CLK));
		
	defparam VGA.RESOLUTION = "160x120";
	defparam VGA.MONOCHROME = "FALSE";
	defparam VGA.BITS_PER_COLOUR_CHANNEL = 3;
	defparam VGA.BACKGROUND_IMAGE = "grid.mif";
	
	control_vga c0(.ld_coord(ld_coord), .ld_draw(ld_draw), .go(go), .resetn(reset), .clock(CLOCK_50), .ld_draw_done(ld_draw_done));
	datapath_vga d0(.ld_coord(ld_coord), .gpio(gpio), .ld_draw(ld_draw), .plot(plot), .ld_draw_done(ld_draw_done), .out_xcoord(out_x), .out_ycoord(out_y), .resetn(reset), .clock(CLOCK_50));

	//control_level c1(.ld_coord(ld_coord_level), .ld_draw(ld_draw_level), .ld_draw_done(ld_draw_done_level), .go(go_level), .resetn(reset), .clock(CLOCK_50));
	//datapath_level d1(.ld_coord(ld_coord_level), .ld_draw(ld_draw_level), .level(level), .resetn(reset), .plot(plot_main), .clock(CLOCK_50),
	 //.out_xcoord(out_xcoord_level), .out_ycoord(out_ycoord_level), .ld_draw_done(ld_draw_done_level), .level_out(color_out_level));

	//assign final_x = ld_level ? out_xcoord_level : out_x;
	//assign final_y = ld_level ? out_ycoord_level : out_y;
	//assign final_color = ld_level ? color_out_level : color_vga;
	//assign plot = (ld_level) ? plot_level : plot_main;
	 //you need a mux to choose between which one to use??????

endmodule

module control_level(ld_coord, ld_draw, ld_draw_done, go, resetn, clock);
	input clock, resetn, go, ld_draw_done;
	output reg ld_coord, ld_draw;

	reg [3:0] current_state, next_state;  	 
	
	localparam S_LOAD_COORD = 3'd0,
					S_LOAD_COORD_WAIT = 3'd1,
              S_DRAW = 3'd2, 
				  S_DUMMY = 3'd3;

	always@(*)
	begin: state_table
        	case (current_state)
         S_LOAD_COORD: next_state = S_LOAD_COORD_WAIT;
			S_LOAD_COORD_WAIT: next_state = S_DRAW;
			S_DRAW: next_state = ld_draw_done ? S_DRAW : S_DUMMY;
			S_DUMMY: next_state = S_LOAD_COORD;
        	default: next_state = S_LOAD_COORD;
			endcase
	end
   
	always @(*)
	begin: enable_signals
    // By default make all our signals 0
		ld_coord = 1'b0;
      ld_draw = 1'b0;
		case (current_state)
        	S_LOAD_COORD: begin
              ld_coord = 1'b1;
	        end
			S_DRAW: begin
              ld_draw = 1'b1;
			end
			default: begin
			ld_coord = 1'b0;
			ld_draw = 1'b0;
			end
	  endcase
	end
					
// current_state registers
	always@(posedge clock)
	begin: state_FFs
    	if(!resetn)
        	current_state <= S_LOAD_COORD; //try setting this to coord
    	else
        	current_state <= next_state;
	end // state_FFS
endmodule // control_level

module datapath_level(ld_coord, ld_draw, level, resetn, plot, clock, out_xcoord, out_ycoord, ld_draw_done, level_out);
input ld_coord, ld_draw, resetn, clock;
input [1:0] level;
output reg [7:0] out_xcoord;
output reg [6:0] out_ycoord;
output reg plot, ld_draw_done;

reg [7:0] reg_x;
reg [6:0] reg_y;
reg [5:0] counterx, countery;

wire [9:0] level_addr;
wire [9:0] level_incr;
output [8:0] level_out; //this is the color

levels_ram l0(.address(level_addr), .clock(clock), .wren(1'b0), .q(level_out));
//120x 48y
// localparam start_1 = 7'd0, end_1 = 7'd24,
// 		   start_2 = 7'd24, end_2 = 7'd48,
// 		   start_3 = 7'd48, end_3 = 7'd72,
// 	   	   start_4 = 7'd72, end_4 = 7'd96;

assign level_incr = {8'b0, 2} * {4'b0,counterx};
assign level_addr = ({4'b0, countery} * 10'b11000) + level_incr ;

localparam start_1 = 7'd120, end_1 = 7'd48,
		   start_2 = 7'd120, end_2 = 7'd48,
		   start_3 = 7'd120, end_3 = 7'd48,
	   	start_4 = 7'd120, end_4 = 7'd48;

always@(posedge clock)
	begin
	if(!resetn)
		begin
			plot <= 1'b0;
			reg_x <= {1'b0, start_1};
			reg_y <= end_1;
		end
	else
	begin
	 if(ld_coord)
	 	plot <= 1'b1;
		case (level[1:0])
				2'b00: begin
					reg_x <= {1'b0, start_1};
					reg_y <= end_1;
				end // 2'b00:

				2'b01: begin
					reg_x <= {1'b0, start_2};
					reg_y <= end_2;
				end // 2'b01:

				2'b10: begin
					reg_x <= {1'b0, start_3};
					reg_y <= end_3;
				end // 2'b10:

				2'b11: begin
					reg_x <= {1'b0, start_4};
					reg_y <= end_4;
				end // 2'b11:

				default: begin
					reg_x <= {1'b0, start_1};
					reg_y <= end_1;
				end // default:
			endcase
	 end
	end
	
always@ (posedge clock)
	begin
	if(ld_draw)
		begin
			if(!resetn)
				begin
				out_xcoord <= 8'b0;
				out_ycoord <= 7'b0;
				counterx <= 5'b0;
				countery <= 5'b0;
				ld_draw_done <= 1'b0;
				//level_addr_reg <= 10'b0;
				end
			if(counterx < 5'd25 && countery < 5'd25 && resetn)
				begin
				ld_draw_done <= 1'b0;	
				out_xcoord <= {1'b0, 7'd120} + counterx;
				counterx <= counterx + 1'b1;
				if(out_ycoord == 7'b0) out_ycoord <= 7'd48;
				end
			else if(counterx == 5'd25 && countery < 5'd24 && resetn) begin
				counterx <= 5'b0;
				out_ycoord <= 7'd48 + countery;
				countery <= countery + 1'b1;
			end
			else
				begin
			 	ld_draw_done <= 1'b1;
				out_xcoord <= out_xcoord;
				out_ycoord <= out_ycoord;
				counterx <= 5'b0;
				countery <= 5'b0;
				end
		end
	else
	 begin
	 out_xcoord <= out_xcoord;
	 out_ycoord <= out_ycoord;
	 end
end

//assign level_out = 9'b111_000_111;
endmodule 


module control_vga(ld_coord, ld_draw, ld_draw_done, go, resetn, clock);
	input clock, resetn, go, ld_draw_done;
	output reg ld_coord, ld_draw;

	reg [3:0] current_state, next_state;  	 
	
	localparam S_LOAD_COORD = 3'd0,
					S_LOAD_COORD_WAIT = 3'd1,
              S_DRAW = 3'd2;

	always@(*)
	begin: state_table
        	case (current_state)
         S_LOAD_COORD: next_state = S_LOAD_COORD_WAIT;
			S_LOAD_COORD_WAIT: next_state = S_DRAW;
			S_DRAW: next_state = ld_draw_done ? S_LOAD_COORD : S_DRAW;
				
        	default: next_state = S_LOAD_COORD;
			endcase
	end
   
	always @(*)
	begin: enable_signals
    // By default make all our signals 0
		ld_coord = 1'b0;
      ld_draw = 1'b0;
		case (current_state)
        	S_LOAD_COORD: begin
              ld_coord = 1'b1;
	        end
			S_DRAW: begin
              ld_draw = 1'b1;
			end
			default: begin
			ld_coord = 1'b0;
			ld_draw = 1'b0;
			end
	  endcase
	end
					
// current_state registers
	always@(posedge clock)
	begin: state_FFs
    	if(!resetn)
        	current_state <= S_LOAD_COORD;
    	else
        	current_state <= next_state;
	end // state_FFS
endmodule 

module datapath_vga(ld_coord, ld_draw, gpio, resetn, plot, clock, out_xcoord, out_ycoord, ld_draw_done);

input ld_coord, ld_draw, resetn, clock;
input [3:0] gpio;
output reg [7:0] out_xcoord;
output reg [6:0] out_ycoord;
output reg plot, ld_draw_done;

reg [7:0] reg_x;
reg [6:0] reg_y;
reg [5:0] counterx, countery;

localparam GRID_1_X = 7'd20, GRID_1_Y = 7'd27,
	GRID_2_X = 7'd48, GRID_2_Y = 7'd55,
	GRID_3_X = 7'd76, GRID_3_Y = 7'd83;

always@(posedge clock)
	begin
	if(!resetn)
		begin
			reg_x <= {1'b0, GRID_1_X};
			reg_y <= GRID_2_X;
			plot <= 1'b0;
		end
	else
	begin
	 if(ld_coord)
	 	plot <= 1'b1;
		case (gpio[3:0])
				4'b0101: begin // (1,1)
					reg_x <= {1'b0, GRID_1_X};
					reg_y <= GRID_1_Y;
				end
				4'b0110: begin //(1,2)
					reg_x <= {1'b0, GRID_2_X};
					reg_y <= GRID_1_Y;
				end
				4'b0111: begin // (1, 3)
					reg_x <= {1'b0, GRID_3_X};
					reg_y <= GRID_1_Y;
				end
				4'b1001: begin //(2, 1)
					reg_x <= {1'b0, GRID_1_X};
					reg_y <= GRID_2_Y;
				end
				4'b1010: begin //(2,2)
					reg_x <= {1'b0, GRID_2_X};
					reg_y <= GRID_2_Y;
				end
				4'b1011: begin //(2,3)
					reg_x <= {1'b0, GRID_3_X};
					reg_y <= GRID_2_Y;
				end
				4'b1101: begin //(3,1)
					reg_x <= {1'b0, GRID_1_X};
					reg_y <= GRID_3_Y;
				end
				4'b1110: begin //(3,2)
					reg_x <= {1'b0, GRID_2_X};
					reg_y <= GRID_3_Y;
				end
				4'b1111: begin//(3,3)
					reg_x <= {1'b0, GRID_3_X};
					reg_y <= GRID_3_Y;
				end
				default: begin
					reg_x <= 8'b0;
					reg_y <= 7'b0;
					plot <= 1'b0;
				end
			endcase
	 end
	end
	
always@ (posedge clock)
	begin
	if(ld_draw)
		begin
			if(!resetn)
				begin
				out_xcoord <= 8'b0;
				out_ycoord <= 7'b0;
				counterx <= 5'b0;
				countery <= 5'b0;
				ld_draw_done <= 1'b0;
				end
			if(counterx < 5'd25 && countery < 5'd25 && resetn)
				begin
				ld_draw_done <= 1'b0;	
				out_xcoord<= reg_x + counterx;
				counterx <= counterx + 1'b1;
				if(out_ycoord == 7'b0) out_ycoord <= reg_y;
				end
			else if(counterx == 5'd25 && countery < 5'd24 && resetn) begin
				counterx <= 5'b0;
				out_ycoord <= reg_y + countery;
				countery <= countery + 1'b1;
			end
			else
				begin
			 	ld_draw_done <= 1'b1;
				out_xcoord <= out_xcoord;
				out_ycoord <= out_ycoord;
				counterx <= 5'b0;
				countery <= 5'b0;
				end
		end
	else
	 begin
	 out_xcoord <= out_xcoord;
	 out_ycoord <= out_ycoord;
	 end
end
endmodule 

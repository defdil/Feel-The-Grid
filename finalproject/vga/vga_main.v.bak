module Lab7Part3(CLOCK_50, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B, KEY, SW, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR);
	input CLOCK_50;
	input [9:0] SW;
	input [3:0] KEY;
	input [8:0] color;
	
	output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
	output [9:0] VGA_R, VGA_G, VGA_B;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output [9:0] LEDR;
	
	wire reset, ld_coord, ld_draw, plot, go, ld_draw_done;
	wire [7:0] out_x;
	wire [6:0] out_y;
	
	assign reset = KEY[0];
	assign go = ~KEY[1];
	
	hexDecoder(out_y[3:0], HEX2);
	hexDecoder({1'b0, out_y[6:4]}, HEX3);
	
	hexDecoder(out_x[3:0], HEX4);
	hexDecoder(out_x[7:4], HEX5);
	
	vga_adapter VGA(.resetn(reset), .clock(CLOCK_50), .colour(color), .x(out_x), .y(out_y), .plot(plot), .VGA_R(VGA_R), .VGA_G(VGA_G), 
		.VGA_B(VGA_B), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK(VGA_BLANK_N), .VGA_SYNC(VGA_SYNC_N), .VGA_CLK(VGA_CLK));
		
	defparam VGA.RESOLUTION = "160x120";
	defparam VGA.MONOCHROME = "FALSE";
	defparam VGA.BITS_PER_COLOUR_CHANNEL = 3;
	defparam VGA.BACKGROUND_IMAGE = "grid.mif";
	
	control c0(.ld_coord(ld_coord), .ld_draw(ld_draw), .go(go), .resetn(reset), .clock(CLOCK_50), .ld_draw_done(ld_draw_done));
	datapath d0(.ld_coord(ld_coord), .gpio(SW[3:0]), .ld_draw(ld_draw), .plot(plot), .ld_draw_done(ld_draw_done), .out_xcoord(out_x), .out_ycoord(out_y), .resetn(reset), .clock(CLOCK_50));
endmodule

module control(ld_coord, ld_draw, ld_draw_done, go, resetn, clock);
	input clock, resetn, go, ld_draw_done;
	output reg ld_coord, ld_draw;

	reg [3:0] current_state, next_state;  	 
	
	localparam S_LOAD_COORD = 3'd0,
					S_LOAD_COORD_WAIT = 3'd1,
              S_DRAW = 3'd2;

	always@(*)
	begin: state_table
        	case (current_state)
         S_LOAD_COORD: next_state = go? S_LOAD_COORD_WAIT : S_LOAD_COORD;
			S_LOAD_COORD_WAIT: next_state = go ? S_LOAD_COORD_WAIT: S_DRAW;
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

module datapath(ld_coord, ld_draw, gpio, resetn, plot, clock, out_xcoord, out_ycoord, ld_draw_done);

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
			reg_x <= 8'b0;
			reg_y <= 7'b0;
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
			if(counterx < 5'd25 && countery < 5'd25)
				begin
				ld_draw_done <= 1'b0;	
				out_xcoord<= reg_x + counterx;
				counterx <= counterx + 1'b1;
				if(out_ycoord == 7'b0) out_ycoord <= reg_y;
				end
			else if(counterx == 5'd25 && countery < 5'd24) begin
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

module control(clock, reset, go, ld_read, ld_input, ld_evaluate, ld_start, ld_reset, ld_level, ld_level_draw_comp);
	input clock, reset, go, ld_level_draw_comp;
	output reg ld_start, ld_read, ld_evaluate, ld_input, ld_reset, ld_level;
	
localparam S_SET_LEVEL = 5'd0,
			  S_START = 5'd1,
			  S_READ_LOAD = 5'd2,
			  S_READING = 5'd3,
			  S_INPUT_LOAD = 5'd4,
			  S_INPUT = 5'd5,
			  S_EVALUATE_LOAD = 5'd6,
			  S_EVALUATE = 5'd7,
			  S_EVALUATE_WAIT = 5'd8;
			  
reg [4:0] current_state, next_state;
always@(*)
 begin: state_table 
     case (current_state)
		S_SET_LEVEL: next_state = ld_level_draw_comp ? S_START : S_SET_LEVEL;
		S_START: next_state = go ? S_READ_LOAD : S_START; //if go = 1, continue. Else,loop in current state
		S_READ_LOAD: next_state = go ? S_READ_LOAD : S_READING;
		S_READING: next_state = go ?  S_INPUT_LOAD : S_READING; 
		//If go = 1, continue. Else, loop in current state
		S_INPUT_LOAD: next_state = go ? S_INPUT_LOAD : S_INPUT; 
		S_INPUT: next_state = go ? S_EVALUATE_LOAD : S_INPUT;
		//If go = 1, continue. Else, loop in current state
		S_EVALUATE_LOAD: next_state = go ? S_EVALUATE_LOAD : S_EVALUATE;
		S_EVALUATE: next_state = go ? S_EVALUATE_WAIT :S_EVALUATE;
		S_EVALUATE_WAIT: next_state = go ? S_EVALUATE_WAIT : S_SET_LEVEL;
		default: next_state = S_START;  
		endcase
 end
 
always @ (*)
	begin: enable_signals
	ld_start =  1'b0;
	ld_read= 1'b0;
	ld_input = 1'b0;
	ld_evaluate = 1'b0;
	ld_reset = 1'b0;
	ld_level = 1'b0;
		case (current_state)
			S_SET_LEVEL: begin
				ld_level = 1'b1;
			end
			S_START: begin 
				ld_start = 1'b1;
			end
			S_READING: begin
				ld_read = 1'b1;
			end // S_READING:end
			S_INPUT_LOAD: begin
				ld_reset = 1'b1;
			end
			S_INPUT: begin
				ld_input = 1'b1;
			end // S_INPUT:end
			S_EVALUATE: begin
				ld_evaluate = 1'b1;
			end
			default: begin
			ld_start = 0;
			ld_read = 0;
			ld_input = 0;
			ld_evaluate = 0;
			ld_reset = 1'b0;
			ld_level = 1'b0;
			end
	endcase
end

 always @ (posedge clock)
 	begin
 		if (reset) current_state <= S_SET_LEVEL;
 		else current_state <= next_state;
 	end 
endmodule

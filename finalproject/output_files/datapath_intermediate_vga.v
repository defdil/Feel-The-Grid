module datapath_intermediate_vga(CLOCK_50, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B, gpio, reset);
endmodule

vga_main v0(.CLOCK_50(CLOCK_50), .VGA_CLK(VGA_CLK), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK_N(VGA_BLANK_N), .VGA_SYNC_N(VGA_SYNC_N),
	 .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .gpio(in_board_config), .reset(~reset), .color_vga(color_vga));
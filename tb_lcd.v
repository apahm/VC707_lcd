`timescale 10ns/10ps

module tb_lcd();

	reg sys_clk;
	reg sys_rst;

	initial 
		sys_clk = 1'b0;
	always 
		sys_clk = #(2.5) ~sys_clk;

	initial begin
		sys_rst = 1'b0;
	    #20000
	    sys_rst = 1'b1;
	end

	top_lcd
	top_lcd_inst
	(
		// Clock
	    .rst(sys_rst),
	    // input clk
	    .clk_in_p(sys_clk),           
	    .clk_in_n(~sys_clk),
	    // leds
		.leds(),
		// LCD data bus
		.lcd_data(), 
		// LCD: E   (control bit)	
		.lcd_e(),	
		// LCD: RS  (setup or data)
		.lcd_rs(),	
		// LCD: R/W (read or write)
		.lcd_rw()	
	);

endmodule
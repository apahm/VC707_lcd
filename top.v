module top_lcd(
	// Clock
    input wire rst,
    // input clk
    input wire clk_in_p,           
    input wire clk_in_n,
    // leds
	output wire [7:0] leds,
	// LCD data bus
	output wire [3:0] lcd_data, 
	// LCD: E   (control bit)	
	output wire lcd_e,	
	// LCD: RS  (setup or data)
	output wire lcd_rs,	
	// LCD: R/W (read or write)
	output wire lcd_rw	
);

lcd
lcd_inst
(
	.clk(),  
	.rst(),  
	.ctrl_lcd({lcd_rs,lcd_rw,lcd_e}),
	.data_lcd(lcd_data)
);

	

endmodule : top_lcd
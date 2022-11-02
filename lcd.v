`timescale 1ns/1ps

module lcd #(
	parameter CYCLES_PER_US = 50
)
(
	input wire clk,    
	input wire rst, 
	output wire [2:0] ctrl_lcd,
	output wire [3:0] data_lcd
);

	localparam [3:0]
		WAITING = 4'd0,
        INIT_H30_ONE = 4'd1,
        INIT_H30_TWO = 4'd2,
        INIT_H30_THREE = 4'd3,
        INIT_H20 = 4'd4,
        INIT_FUNCTION_SET = 4'd5,
        INIT_DISPLAY_ON = 4'd6,
		INIT_DISPLAY_CLEAR = 4'd7,
		INIT_SET_ENTRY_MODE = 4'd8,
		LCD_IDLE = 4'd9;


	reg [3:0] lcd_state_r;		
	reg [2:0] ctrl_lcd_r; 
	reg [3:0] data_lcd_r;
	reg [31:0] counter_r;

	reg [15:0] upper_line [7:0];
	reg [15:0] lower_line [7:0];

	parameter integer wait__1us = 1 * CYCLES_PER_US;
	parameter integer wait__2us = 2 *  CYCLES_PER_US;    // 10us 
	parameter integer wait__3us = 3 * CYCLES_PER_US;    // 20us 
	parameter integer wait__4us = 4 * CYCLES_PER_US;    // 40us 
	parameter integer wait__200us = 200 * CYCLES_PER_US; // 5ms

	parameter integer wait__dispay_clear = 3000 * CYCLES_PER_US; // 1.52ms 
	parameter integer wait__power_on = 45000 * CYCLES_PER_US; // 45ms 

	parameter integer wait__init_h30_one = 5000 * CYCLES_PER_US; // 5ms 
	parameter integer wait__init_h30_two = 200 * CYCLES_PER_US; // 5ms
	
	assign ctrl_lcd = ctrl_lcd_r; // {RS, RW, E} 2, 1, 0
	assign data_lcd = data_lcd_r;

	initial begin
		upper_line[0] = 4'h46; // F
		upper_line[1] = 4'h69; // i
		upper_line[2] = 4'h72; // r
		upper_line[3] = 4'h6d; // m
		upper_line[4] = 4'h77; // w
		upper_line[5] = 4'h61; // a
		upper_line[6] = 4'h72; // r
		upper_line[7] = 4'h65; // e
		upper_line[8] = 4'h20; // 
		upper_line[9] = 4'h6c; // l
		upper_line[10] = 4'h6f; // o
		upper_line[11] = 4'h61; // a
		upper_line[12] = 4'h64; // d
		upper_line[13] = 4'h65; // e
		upper_line[14] = 4'h64; // d
		upper_line[15] = 4'h21; // !
				
		lower_line[0] = 4'h30; // 0
		lower_line[1] = 4'h31; // 1
		lower_line[2] = 4'h32; // 2
		lower_line[3] = 4'h33; // 3
		lower_line[4] = 4'h34; // 4
		lower_line[5] = 4'h35; // 5
		lower_line[6] = 4'h36; // 6
		lower_line[7] = 4'h37; // 7
		lower_line[8] = 4'h38; // 8
		lower_line[9] = 4'h39; // 9
		lower_line[10] = 4'h61; // a
		lower_line[11] = 4'h62; // b
		lower_line[12] = 4'h63; // c
		lower_line[13] = 4'h64; // d
		lower_line[14] = 4'h65; // e
		lower_line[15] = 4'h66; // f
	end

    always @(posedge clk) begin
        if (rst) begin
        	lcd_state_r <= WAITING;
        	ctrl_lcd_r <= 3'b0;
        	data_lcd_r <= 4'b0;
        	counter_r <= 32'b0;
        end else begin
            case (lcd_state_r)
                WAITING: begin 
					if(counter_r >= wait__power_on) begin
                		lcd_state_r <= INIT_H30_ONE;
                		counter_r <= 32'b0;
                	end else begin
                		counter_r <= counter_r + 1;
                		lcd_state_r <= WAITING;
                	end
                end
                INIT_H30_ONE: begin // 0x30
        			data_lcd <= 4'b0011;
                	if(counter_r >= wait__init_h30_one) begin
                		counter_r <= 32'b0;
                		lcd_state_r <= INIT_H30_TWO;
                	end else if(counter_r < wait__init_h30_one && counter_r >= wait__1us) begin
                		counter_r <= counter_r + 1;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_H30_ONE;
                	end else begin
                		counter_r <= counter_r + 1;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_H30_ONE;
                	end
                end
				INIT_H30_TWO: begin // 0x30
        			data_lcd <= 4'b0011;
                	if(counter_r >= wait__init_h30_two) begin
                		counter_r <= 32'b0;
                		lcd_state_r <= INIT_H30_THREE;
                	end else if(counter_r < wait__init_h30_two && counter_r >= wait__1us) begin
                		counter_r <= counter_r + 1;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_H30_TWO;
                	end else begin
                		counter_r <= counter_r + 1;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_H30_TWO;
                	end
                end
                INIT_H30_THREE: begin // 0x30
        			data_lcd <= 4'b0011;
                	if(counter_r >= wait__200us) begin
                		counter_r <= 32'b0;
                		lcd_state_r <= INIT_H20;
                	end else if(counter_r < wait__200us && counter_r >= wait__1us) begin
                		counter_r <= counter_r + 1;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_H30_THREE;
                	end else begin
                		counter_r <= counter_r + 1;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_H30_THREE;
                	end
                end
				INIT_H20: begin // 0x20
        			data_lcd <= 4'b0010;
                	if(counter_r >= wait__200us) begin
                		counter_r <= 32'b0;
                		lcd_state_r <= INIT_FUNCTION_SET;
                	end else if(counter_r < wait__200us && counter_r >= wait__1us) begin
                		counter_r <= counter_r + 1;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_H20;
                	end else begin
                		counter_r <= counter_r + 1;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_H20;
                	end
                end
               	INIT_FUNCTION_SET: begin // 0x28
               		if(counter_r < wait__1us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0010;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_FUNCTION_SET;
                	end else if(wait__1us <= counter_r < wait_2us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0010;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_FUNCTION_SET;
                	end else if(wait_2us <= counter_r < wait_3us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b1000;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_FUNCTION_SET;
                	end else if(wait_3us <= counter_r < wait_4us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b1000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_FUNCTION_SET;
                	end else if(wait_4us <= counter_r < wait__200us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_FUNCTION_SET;
                	end else begin
						counter_r <= 32'b0;
                		lcd_state_r <= INIT_DISPLAY_ON;
                	end
               	end
               	INIT_DISPLAY_ON: begin // 0x0F
               		if(counter_r < wait__1us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0000;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_FUNCTION_SET;
                	end else if(wait__1us <= counter_r < wait_2us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_FUNCTION_SET;
                	end else if(wait_2us <= counter_r < wait_3us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b1111;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_FUNCTION_SET;
                	end else if(wait_3us <= counter_r < wait_4us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b1111;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_FUNCTION_SET;
                	end else if(wait_4us <= counter_r < wait__200us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_FUNCTION_SET;
                	end else begin
						counter_r <= 32'b0;
                		lcd_state_r <= INIT_DISPLAY_CLEAR;
                	end
               	end
               	INIT_DISPLAY_CLEAR: begin // 0x01
					if(counter_r < wait__1us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0000;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_DISPLAY_CLEAR;
                	end else if(wait__1us <= counter_r < wait_2us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_DISPLAY_CLEAR;
                	end else if(wait_2us <= counter_r < wait_3us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0001;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_DISPLAY_CLEAR;
                	end else if(wait_3us <= counter_r < wait_4us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0001;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_DISPLAY_CLEAR;
                	end else if(wait_4us <= counter_r < wait__dispay_clear) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_DISPLAY_CLEAR;
                	end else begin
						counter_r <= 32'b0;
                		lcd_state_r <= INIT_SET_ENTRY_MODE;
                	end
               	end
               	INIT_SET_ENTRY_MODE: begin //0x06
               		if(counter_r < wait__1us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0000;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_SET_ENTRY_MODE;
                	end else if(wait__1us <= counter_r < wait_2us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_SET_ENTRY_MODE;
                	end else if(wait_2us <= counter_r < wait_3us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0110;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_SET_ENTRY_MODE;
                	end else if(wait_3us <= counter_r < wait_4us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0110;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_SET_ENTRY_MODE;
                	end else if(wait_4us <= counter_r < wait__200us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_SET_ENTRY_MODE;
                	end else begin
						counter_r <= 32'b0;
                		lcd_state_r <= LCD_IDLE;
                	end
               	end
               	LCD_IDLE: begin

               	end
            endcase
        end
    end

endmodule
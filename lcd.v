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
		CUR_FIRST_ROW = 4'd9,
		WRITE_UPPER_LINE = 4'd10,
		COUNTER_UPPER_LINE = 4'd11,
		CUR_SECOND_ROW = 4'd12,
		WRITE_LOWER_LINE = 4'd13,
		COUNTER_LOWER_LINE = 4'd14,
		DONE = 4'd15;

	reg [3:0] lcd_state_r;		
	reg [2:0] ctrl_lcd_r; 
	reg [3:0] data_lcd_r;
	
	reg [31:0] counter_r;
	reg [3:0] counter_upper_line_r;
	reg [3:0] counter_lower_line_r;

	reg [7:0] upper_line [15:0];
	reg [7:0] lower_line [15:0];

	parameter integer wait__1us = 1 * CYCLES_PER_US;
	parameter integer wait__2us = 2 * CYCLES_PER_US;    // 10us 
	parameter integer wait__3us = 3 * CYCLES_PER_US;    // 20us 
	parameter integer wait__4us = 4 * CYCLES_PER_US;    // 40us 
	parameter integer wait__200us = 200 * CYCLES_PER_US; // 5ms

	parameter integer wait__dispay_clear = 3000 * CYCLES_PER_US; // 1.52ms 
	parameter integer wait__power_on = 15000 * CYCLES_PER_US; // 45ms 

	parameter integer wait__init_h30_one = 5000 * CYCLES_PER_US; // 5ms 
	parameter integer wait__init_h30_two = 500 * CYCLES_PER_US; // 5ms
	
	assign ctrl_lcd = ctrl_lcd_r; // {RS, RW, E} 2, 1, 0
	assign data_lcd = data_lcd_r;

	initial begin
		upper_line[0] = 8'h46; // F
		upper_line[1] = 8'h69; // i
		upper_line[2] = 8'h72; // r
		upper_line[3] = 8'h6d; // m
		upper_line[4] = 8'h77; // w
		upper_line[5] = 8'h61; // a
		upper_line[6] = 8'h72; // r
		upper_line[7] = 8'h65; // e
		upper_line[8] = 8'h20; // 
		upper_line[9] = 8'h6c; // l
		upper_line[10] = 8'h6f; // o
		upper_line[11] = 8'h61; // a
		upper_line[12] = 8'h64; // d
		upper_line[13] = 8'h65; // e
		upper_line[14] = 8'h64; // d
		upper_line[15] = 8'h21; // !
				
		lower_line[0] = 8'h30; // 0
		lower_line[1] = 8'h31; // 1
		lower_line[2] = 8'h32; // 2
		lower_line[3] = 8'h33; // 3
		lower_line[4] = 8'h34; // 4
		lower_line[5] = 8'h35; // 5
		lower_line[6] = 8'h36; // 6
		lower_line[7] = 8'h37; // 7
		lower_line[8] = 8'h38; // 8
		lower_line[9] = 8'h39; // 9
		lower_line[10] = 8'h61; // a
		lower_line[11] = 8'h62; // b
		lower_line[12] = 8'h63; // c
		lower_line[13] = 8'h64; // d
		lower_line[14] = 8'h65; // e
		lower_line[15] = 8'h66; // f
	end

    always @(posedge clk) begin
        if (rst) begin
        	lcd_state_r <= WAITING;
        	ctrl_lcd_r <= 3'b0;
        	data_lcd_r <= 4'b0;
        	counter_r <= 32'b0;
        	counter_upper_line_r <= 4'b0;
			counter_lower_line_r <= 4'b0;
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
        			data_lcd_r <= 4'b0011;
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
        			data_lcd_r <= 4'b0011;
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
        			data_lcd_r <= 4'b0011;
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
        			data_lcd_r <= 4'b0010;
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
                		data_lcd_r <= 4'b0010;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_FUNCTION_SET;
                	end else if(wait__1us <= counter_r && counter_r < wait__2us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b0010;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_FUNCTION_SET;
                	end else if(wait__2us <= counter_r && counter_r < wait__3us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b1000;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_FUNCTION_SET;
                	end else if(wait__3us <= counter_r && counter_r < wait__4us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b1000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_FUNCTION_SET;
                	end else if(wait__4us <= counter_r && counter_r < wait__200us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b0000;
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
                		data_lcd_r <= 4'b0000;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_DISPLAY_ON;
                	end else if(wait__1us <= counter_r && counter_r < wait__2us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_DISPLAY_ON;
                	end else if(wait__2us <= counter_r && counter_r < wait__3us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b1111;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_DISPLAY_ON;
                	end else if(wait__3us <= counter_r && counter_r < wait__4us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b1111;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_DISPLAY_ON;
                	end else if(wait__4us <= counter_r && counter_r < wait__200us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_DISPLAY_ON;
                	end else begin
						counter_r <= 32'b0;
                		lcd_state_r <= INIT_DISPLAY_CLEAR;
                	end
               	end
               	INIT_DISPLAY_CLEAR: begin // 0x01
					if(counter_r < wait__1us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b0000;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_DISPLAY_CLEAR;
                	end else if(wait__1us <= counter_r && counter_r < wait__2us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_DISPLAY_CLEAR;
                	end else if(wait__2us <= counter_r && counter_r < wait__3us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b0001;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_DISPLAY_CLEAR;
                	end else if(wait__3us <= counter_r && counter_r < wait__4us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b0001;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_DISPLAY_CLEAR;
                	end else if(wait__4us <= counter_r && counter_r < wait__dispay_clear) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b0000;
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
                		data_lcd_r <= 4'b0000;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_SET_ENTRY_MODE;
                	end else if(wait__1us <= counter_r && counter_r < wait__2us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_SET_ENTRY_MODE;
                	end else if(wait__2us <= counter_r && counter_r < wait__3us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b0110;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_SET_ENTRY_MODE;
                	end else if(wait__3us <= counter_r && counter_r < wait__4us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b0110;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_SET_ENTRY_MODE;
                	end else if(wait__4us <= counter_r && counter_r < wait__200us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_SET_ENTRY_MODE;
                	end else begin
						counter_r <= 32'b0;
                		lcd_state_r <= CUR_FIRST_ROW;
                	end
               	end
               	CUR_FIRST_ROW: begin // 0x80
					if(counter_r < wait__1us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b1000;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= CUR_FIRST_ROW;
                	end else if(wait__1us <= counter_r && counter_r < wait__2us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b1000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= CUR_FIRST_ROW;
                	end else if(wait__2us <= counter_r && counter_r < wait__3us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b0000;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= CUR_FIRST_ROW;
                	end else if(wait__3us <= counter_r && counter_r < wait__4us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= CUR_FIRST_ROW;
                	end else if(wait__4us <= counter_r && counter_r < wait__200us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= CUR_FIRST_ROW;
                	end else begin
						counter_r <= 32'b0;
                		lcd_state_r <= WRITE_UPPER_LINE;
                	end
               	end
				WRITE_UPPER_LINE: begin
					if(counter_r < wait__1us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= upper_line[counter_upper_line_r][7:4];
                		ctrl_lcd_r <= 3'b101;
                		lcd_state_r <= WRITE_UPPER_LINE;
                	end else if(wait__1us <= counter_r && counter_r < wait__2us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= upper_line[counter_upper_line_r][7:4];
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= WRITE_UPPER_LINE;
                	end else if(wait__2us <= counter_r && counter_r < wait__3us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= upper_line[counter_upper_line_r][3:0];;
                		ctrl_lcd_r <= 3'b101;
                		lcd_state_r <= WRITE_UPPER_LINE;
                	end else if(wait__3us <= counter_r && counter_r < wait__4us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= upper_line[counter_upper_line_r][3:0];;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= WRITE_UPPER_LINE;
                	end else if(wait__4us <= counter_r && counter_r < wait__200us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= WRITE_UPPER_LINE;
                	end else begin
						counter_r <= 32'b0;
                		lcd_state_r <= COUNTER_UPPER_LINE;
                	end
               	end
               	COUNTER_UPPER_LINE: begin
               		if(counter_upper_line_r == 4'd15) begin
						counter_upper_line_r <= 4'b0;
						lcd_state_r <= CUR_SECOND_ROW;		
                	end else begin
	                	counter_upper_line_r <= counter_upper_line_r + 1;
	                	lcd_state_r <= WRITE_UPPER_LINE;
                	end
                end
                CUR_SECOND_ROW: begin
                	if(counter_r < wait__1us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b1100;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= CUR_SECOND_ROW;
                	end else if(wait__1us <= counter_r && counter_r < wait__2us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b1100;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= CUR_SECOND_ROW;
                	end else if(wait__2us <= counter_r && counter_r < wait__3us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b0000;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= CUR_SECOND_ROW;
                	end else if(wait__3us <= counter_r && counter_r < wait__4us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= CUR_SECOND_ROW;
                	end else if(wait__4us <= counter_r && counter_r < wait__200us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= CUR_SECOND_ROW;
                	end else begin
						counter_r <= 32'b0;
                		lcd_state_r <= WRITE_LOWER_LINE;
                	end
                end
				WRITE_LOWER_LINE: begin
					if(counter_r < wait__1us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= lower_line[counter_lower_line_r][7:4];
                		ctrl_lcd_r <= 3'b101;
                		lcd_state_r <= WRITE_LOWER_LINE;
                	end else if(wait__1us <= counter_r && counter_r < wait__2us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= lower_line[counter_lower_line_r][7:4];
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= WRITE_LOWER_LINE;
                	end else if(wait__2us <= counter_r && counter_r < wait__3us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= lower_line[counter_lower_line_r][3:0];;
                		ctrl_lcd_r <= 3'b101;
                		lcd_state_r <= WRITE_LOWER_LINE;
                	end else if(wait__3us <= counter_r && counter_r < wait__4us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= lower_line[counter_lower_line_r][3:0];;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= WRITE_LOWER_LINE;
                	end else if(wait__4us <= counter_r && counter_r < wait__200us) begin
                		counter_r <= counter_r + 1;
                		data_lcd_r <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= WRITE_LOWER_LINE;
                	end else begin
						counter_r <= 32'b0;
                		lcd_state_r <= COUNTER_LOWER_LINE;
                	end
               	end
				COUNTER_LOWER_LINE: begin
               		if(counter_lower_line_r == 32'd15) begin
						counter_lower_line_r <= 32'b0;
						lcd_state_r <= DONE;		
                	end else begin
	                	counter_lower_line_r <= counter_lower_line_r + 1;
	                	lcd_state_r <= WRITE_LOWER_LINE;
                	end
               	end
               	DONE: begin
               		lcd_state_r <= DONE;
               	end
            endcase
        end
    end

endmodule
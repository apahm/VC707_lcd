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
        INIT_H38 = 4'd1,
        INIT_H28_ONE = 4'd2,
        INIT_H28_TWO = 4'd3,
        INIT_DISPLAY_OFF_ON = 4'd4,
		INIT_DISPLAY_CLEAR = 4'd5,
		INIT_SET_ENTRY_MODE = 4'd6,
		INIT_DISPLAY_ON = 4'd7,
		CHECK_BUSY_FLAG = 4'd8,
		LCD_IDLE = 4'd9,
		UPPER_LINE_POS = 4'd10,
		UPPER_LINE_CHAR = 4'd11,
		LOWER_LINE_POS = 4'd12,
		LOWER_LINE_CHAR = 4'd13,
		DONESTATE = 4'd14;

	reg [3:0] lcd_state_r;		
	reg [2:0] ctrl_lcd_r; 
	reg [3:0] data_lcd_r;
	reg [31:0] counter_r;

	parameter integer wait_1us = CYCLES_PER_US;
	parameter integer wait__2us = 2 *  CYCLES_PER_US;    // 10us 
	parameter integer wait__3us = 3 * CYCLES_PER_US;    // 20us 
	parameter integer wait__4us = 4 * CYCLES_PER_US;    // 40us 

	parameter integer wait__37us = 100 * CYCLES_PER_US;   // 100us
	parameter integer wait__dispay_clear = 3000 * CYCLES_PER_US; // 1.52ms 
	parameter integer wait__power_on = 45000 * CYCLES_PER_US; // 45ms 

	assign ctrl_lcd = ctrl_lcd_r; // {RS, RW, E} 2, 1, 0
	assign data_lcd = data_lcd_r;

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
                		lcd_state_r <= INIT_H38;
                		counter_r <= 32'b0;
                	end else begin
                		counter_r <= counter_r + 1;
                		lcd_state_r <= WAITING;
                	end
                end
                INIT_H38: begin
        			data_lcd <= 4'b0011;
                	if(counter_r >= wait__37us) begin
                		counter_r <= 32'b0;
                		lcd_state_r <= INIT_H28_ONE;
                	end else if(counter_r < wait__37us && counter_r >= wait_1us) begin
                		counter_r <= counter_r + 1;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_H38;
                	end else begin
                		counter_r <= counter_r + 1;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_H38;
                	end
                end
				INIT_H28_ONE: begin
        			if(counter_r < wait_1us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0010;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_H28_ONE;
                	end else if(wait_1us <= counter_r < wait_2us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0010;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_H28_ONE;
                	end else if(wait_2us <= counter_r < wait_3us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b1000;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_H28_ONE;
                	end else if(wait_3us <= counter_r < wait_4us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b1000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_H28_ONE;
                	end else if(wait_4us <= counter_r < wait__37us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_H28_ONE;
                	end else begin
						counter_r <= 32'b0;
                		lcd_state_r <= INIT_H28_TWO;
                	end
                end
                INIT_H28_TWO: begin
        			if(counter_r < wait_1us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0010;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_H28_TWO;
                	end else if(wait_1us <= counter_r < wait_2us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0010;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_H28_TWO;
                	end else if(wait_2us <= counter_r < wait_3us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b1000;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_H28_TWO;
                	end else if(wait_3us <= counter_r < wait_4us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b1000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_H28_TWO;
                	end else if(wait_4us <= counter_r < wait__37us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_H28_TWO;
                	end else begin
						counter_r <= 32'b0;
                		lcd_state_r <= INIT_DISPLAY_OFF_ON;
                	end
               	end
               	INIT_DISPLAY_OFF_ON: begin
               		if(counter_r < wait_1us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0000;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_DISPLAY_OFF_ON;
                	end else if(wait_1us <= counter_r < wait_2us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_DISPLAY_OFF_ON;
                	end else if(wait_2us <= counter_r < wait_3us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b1111;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_DISPLAY_OFF_ON;
                	end else if(wait_3us <= counter_r < wait_4us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b1111;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_DISPLAY_OFF_ON;
                	end else if(wait_4us <= counter_r < wait__37us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0000;
                		ctrl_lcd_r <= 3'b000;
                		lcd_state_r <= INIT_DISPLAY_OFF_ON;
                	end else begin
						counter_r <= 32'b0;
                		lcd_state_r <= INIT_DISPLAY_OFF_ON;
                	end
               	end
               	INIT_DISPLAY_CLEAR: begin
					if(counter_r < wait_1us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0000;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_DISPLAY_CLEAR;
                	end else if(wait_1us <= counter_r < wait_2us) begin
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
               	INIT_SET_ENTRY_MODE: begin
               		if(counter_r < wait_1us) begin
                		counter_r <= counter_r + 1;
                		data_lcd <= 4'b0000;
                		ctrl_lcd_r <= 3'b001;
                		lcd_state_r <= INIT_SET_ENTRY_MODE;
                	end else if(wait_1us <= counter_r < wait_2us) begin
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
                	end else if(wait_4us <= counter_r < wait__37us) begin
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
/*
 SW8 (GLOBAL RESET) resets LCD
ENTITY LCD_Display IS
-- Enter number of live lcd hardware data values to display
-- (do not count ASCII character constants)
	GENERIC(Num_lcd_Digits: Integer:= 2); 
-----------------------------------------------------------------------
-- LCD Displays 16 Characters on 2 lines
-- LCD_display string is an ASCII character string entered in lcd for 
-- the two lines of the  LCD Display   (See ASCII to lcd table below)
-- Edit LCD_Display_String entries above to modify display
-- Enter the ASCII character's 2 lcd digit equivalent value
-- (see table below for ASCII lcd values)
-- To display character assign ASCII value to LCD_display_string(x)
-- To skip a character use 8'h20" (ASCII space)
-- To dislay "live" lcd values from hardware on LCD use the following: 
--   make array element for that character location 8'h0" & 4-bit field from lcd_Display_Data
--   state machine sees 8'h0" in high 4-bits & grabs the next lower 4-bits from lcd_Display_Data input
--   and performs 4-bit binary to ASCII conversion needed to print a lcd digit
--   Num_lcd_Digits must be set to the count of lcd data characters (ie. "00"s) in the display
--   Connect hardware bits to display to lcd_Display_Data input
-- To display less than 32 characters, terminate string with an entry of 8'hFE"
--  (fewer characters may slightly increase the LCD's data update rate)
------------------------------------------------------------------- 
--                        ASCII lcd TABLE
--  lcd						Low lcd Digit
-- Value  0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
------\----------------------------------------------------------------
--H  2 |  SP  !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /
--i  3 |  0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?
--g  4 |  @   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O
--h  5 |  P   Q   R   S   T   U   V   W   X   Y   Z   [   \   ]   ^   _
--   6 |  `   a   b   c   d   e   f   g   h   i   j   k   l   m   n   o
--   7 |  p   q   r   s   t   u   v   w   x   y   z   {   |   }   ~ DEL
-----------------------------------------------------------------------
-- Example "A" is row 4 column 1, so lcd value is 8'h41"
-- *see LCD Controller's Datasheet for other graphics characters available
*/
		
module LCD_Display(iCLK_50MHZ, iRST_N, lcd1, lcd0, lcd2, lcd3, lcd4, lcd5, lcd6, lcd7, cont_a, cont_e,botoes, LCD_RS,LCD_E,LCD_RW,DATA_BUS);

input iCLK_50MHZ, iRST_N;
input [6:0] lcd1; 
input [6:0] lcd0;
input [6:0] lcd2;
input [6:0] lcd3;
input [6:0] lcd4;
input [6:0] lcd5;
input [6:0] lcd6;
input [6:0] lcd7;
input [32:0] cont_a,cont_e;
input [3:0] botoes;
output LCD_RS, LCD_E, LCD_RW;
inout [7:0] DATA_BUS;

parameter
HOLD = 4'h0,
FUNC_SET = 4'h1,
DISPLAY_ON = 4'h2,
MODE_SET = 4'h3,
Print_String = 4'h4,
LINE2 = 4'h5,
RETURN_HOME = 4'h6,
DROP_LCD_E = 4'h7,
RESET1 = 4'h8,
RESET2 = 4'h9,
RESET3 = 4'ha,
DISPLAY_OFF = 4'hb,
DISPLAY_CLEAR = 4'hc;

reg [3:0] state, next_command;
// Enter new ASCII lcd data above for LCD Display
reg [7:0] DATA_BUS_VALUE;
wire [7:0] Next_Char;
reg [19:0] CLK_COUNT_400HZ;
reg [4:0] CHAR_COUNT;
reg CLK_400HZ, LCD_RW_INT, LCD_E, LCD_RS;

// BIDIRECTIONAL TRI STATE LCD DATA BUS
assign DATA_BUS = (LCD_RW_INT? 8'bZZZZZZZZ: DATA_BUS_VALUE);


//Define the ports used for LCD string
LCD_display_string u1(
.index(CHAR_COUNT),
.out(Next_Char),
.lcd1(lcd1),
.lcd0(lcd0),
.lcd2 (lcd2),
.lcd3 (lcd3),
.lcd4 (lcd4),
.lcd5 (lcd5),
.lcd6 (lcd6),
.lcd7 (lcd7),
.cont_a (cont_a),
.cont_e (cont_e),
);

assign LCD_RW = LCD_RW_INT;


//Esse always cria um clock de 40MHz
always @(posedge iCLK_50MHZ or negedge iRST_N)
	if (!iRST_N) // Reseta o contador e o clock
	begin
	   CLK_COUNT_400HZ <= 20'h00000;
	   CLK_400HZ <= 1'b0;
	end
	else if (CLK_COUNT_400HZ < 20'h0F424)
	begin
	   CLK_COUNT_400HZ <= CLK_COUNT_400HZ + 1'b1;
	end
	else
	begin
	  CLK_COUNT_400HZ <= 20'h00000;
	  CLK_400HZ <= ~CLK_400HZ;
	end
// State Machine to send commands and data to LCD DISPLAY

always @(posedge CLK_400HZ or negedge iRST_N) //Uso do clock de 400Mhz 
	if (!iRST_N)
	begin
	 state <= RESET1; //If reset button is pressed the state is changed to RESET1
	end
	else
	case (state)
	RESET1:			
// Set Function to 8-bit transfer and 2 line display with 5x8 Font size
// see Hitachi HD44780 family data sheet for LCD command and timing details
	begin
	  LCD_E <= 1'b1; //Starts data READ / WRITE
	  LCD_RS <= 1'b0;
	  LCD_RW_INT <= 1'b0;
	  DATA_BUS_VALUE <= 8'h38;
	  state <= DROP_LCD_E;
	  next_command <= RESET2;
	  CHAR_COUNT <= 5'b00000;
	end
	RESET2:
	begin
	  LCD_E <= 1'b1;
	  LCD_RS <= 1'b0;
	  LCD_RW_INT <= 1'b0;
	  DATA_BUS_VALUE <= 8'h38;
	  state <= DROP_LCD_E;
	  next_command <= RESET3;
	end
	RESET3:
	begin
	  LCD_E <= 1'b1;
	  LCD_RS <= 1'b0;
	  LCD_RW_INT <= 1'b0;
	  DATA_BUS_VALUE <= 8'h38;
	  state <= DROP_LCD_E;
	  next_command <= FUNC_SET;
	end
// EXTRA STATES ABOVE ARE NEEDED FOR RELIABLE PUSHBUTTON RESET OF LCD

	FUNC_SET:
	begin
	  LCD_E <= 1'b1;
	  LCD_RS <= 1'b0;
	  LCD_RW_INT <= 1'b0;
	  DATA_BUS_VALUE <= 8'h38;
	  state <= DROP_LCD_E;
	  next_command <= DISPLAY_OFF;
	end

// Turn off Display and Turn off cursor
	DISPLAY_OFF:
	begin
	  LCD_E <= 1'b1;
	  LCD_RS <= 1'b0;
	  LCD_RW_INT <= 1'b0;
	  DATA_BUS_VALUE <= 8'h08;
	  state <= DROP_LCD_E;
	  next_command <= DISPLAY_CLEAR;
	end

// Clear Display and Turn off cursor
	DISPLAY_CLEAR:
	begin
	  LCD_E <= 1'b1;
	  LCD_RS <= 1'b0;
	  LCD_RW_INT <= 1'b0;
	  DATA_BUS_VALUE <= 8'h01;
	  state <= DROP_LCD_E;
	  next_command <= DISPLAY_ON;
	end

// Turn on Display and Turn off cursor
	DISPLAY_ON:
	begin
	  LCD_E <= 1'b1;
	  LCD_RS <= 1'b0;
	  LCD_RW_INT <= 1'b0;
	  DATA_BUS_VALUE <= 8'h0C;
	  state <= DROP_LCD_E;
	  next_command <= MODE_SET;
	end

// Set write mode to auto increment address and move cursor to the right
	MODE_SET:
	begin
	  LCD_E <= 1'b1;
	  LCD_RS <= 1'b0;
	  LCD_RW_INT <= 1'b0;
	  DATA_BUS_VALUE <= 8'h06;
	  state <= DROP_LCD_E;
	  next_command <= Print_String;
	end

//---------------------------------------------------------------------
	Print_String: // Write ASCII lcd character in first LCD character location
	begin
	  state <= DROP_LCD_E;
	  LCD_E <= 1'b1;
	  LCD_RS <= 1'b1; // activate RECEIVE/SEND
	  LCD_RW_INT <= 1'b0;
	
	  if (Next_Char[7:4] != 4'h0)// ASCII character to output
		DATA_BUS_VALUE <= Next_Char; // Convert 4-bit value to an ASCII lcd digit
	  else if (Next_Char[3:0]>9)// ASCII A...F
		 DATA_BUS_VALUE <= {4'h4,Next_Char[3:0]-4'h9};
	  else // ASCII 0...9
		 DATA_BUS_VALUE <= {4'h3,Next_Char[3:0]};
	
	  // Loop to send out 32 characters to LCD Display  (16 by 2 lines)
	  if ((CHAR_COUNT < 31) && (Next_Char != 8'hFE))
	     CHAR_COUNT <= CHAR_COUNT + 1'b1;
	  else
	     CHAR_COUNT <= 5'b00000; 
	  
	  // Jump to second line?
	  if (CHAR_COUNT == 15)
	    next_command <= LINE2;
	  else if ((CHAR_COUNT == 31) || (Next_Char == 8'hFE))
	    next_command <= RETURN_HOME; // Return to first line?
	  else
	    next_command <= Print_String;
	end

//---------------------------------------------------------------------
	LINE2: // Set write address to line 2 character 1
	begin
	  LCD_E <= 1'b1;
	  LCD_RS <= 1'b0;
	  LCD_RW_INT <= 1'b0;
	  DATA_BUS_VALUE <= 8'hC0;
	  state <= DROP_LCD_E;
	  next_command <= Print_String;
	end
//---------------------------------------------------------------------
	RETURN_HOME: // Return write address to first postion on line 1
	begin
	  LCD_E <= 1'b1;
	  LCD_RS <= 1'b0;
	  LCD_RW_INT <= 1'b0;
	  DATA_BUS_VALUE <= 8'h80;
	  state <= DROP_LCD_E;
	  next_command <= Print_String;
	end
//---------------------------------------------------------------------
	DROP_LCD_E: // Falling edge loads inst/data to LCD controller
	begin
	  LCD_E <= 1'b0; // Stops READ / WRITE
	  state <= HOLD;
	end
//---------------------------------------------------------------------		
	HOLD: // Hold LCD inst/data valid after falling edge of E line		
	begin
	  state <= next_command;
	end
	endcase
endmodule


// Module to show the characters on the LCD 16x2

module LCD_display_string(index,out,lcd0,lcd1, lcd2, lcd3, lcd4, lcd5, lcd6, lcd7, cont_a, cont_e, botoes);
input [4:0] index;
input [6:0] lcd0,lcd1, lcd2, lcd3, lcd4, lcd5, lcd6, lcd7;
input [32:0] cont_a, cont_e;
input [3:0] botoes;
output [7:0] out;
reg [7:0] out;
// ASCII lcd values for LCD Display
// Enter Live lcd Data Values from hardware here
// Line 1

	always @(lcd1) begin
	//capture a toupeira
	case (lcd0)
		'd0: begin
			//capture a toupeira
			case (index)
				5'h00: out <= 8'h43;
				5'h01: out <= 8'h61;
				5'h02: out <= 8'h70;
				5'h03: out <= 8'h74;
				5'h04: out <= 8'h75;
				5'h05: out <= 8'h72;
				5'h06: out <= 8'h65;
				5'h07: out <= 8'h20;
				5'h08: out <= 8'h61;
				// Line 2
				5'h10: out <= 8'h74;
				5'h11: out <= 8'h6F;
				5'h12: out <= 8'h75;
				5'h13: out <= 8'h70;
				5'h14: out <= 8'h65;
				5'h15: out <= 8'h69;
				5'h16: out <= 8'h72;
				5'h17: out <= 8'h61;
				default: out <= 8'h20; //Blank spaces
				endcase
				end
			//Toupeira capturada
		'd1: begin
			if(lcd1 < 5'h02)begin
				case (index)
					5'h00: out <= 8'h30;
					5'h01: out <= 8'h31;
					5'h03: out <= 8'h74;
					5'h04: out <= 8'h6F;
					5'h05: out <= 8'h75;
					5'h06: out <= 8'h70;
					5'h07: out <= 8'h65;
					5'h08: out <= 8'h69;
					5'h09: out <= 8'h72;
					5'hA: out <= 8'h61;
					// Line 2
					5'h10: out <= 8'h43;
					5'h11: out <= 8'h61;
					5'h12: out <= 8'h70;
					5'h13: out <= 8'h74;
					5'h14: out <= 8'h75;
					5'h15: out <= 8'h72;
					5'h16: out <= 8'h61;
					5'h17: out <= 8'h64;
					5'h18: out <= 8'h61;
					default: out <= 8'h20; //Blank spaces
					endcase
				end
				
				else begin
					case (index)
					5'h00: out <= lcd6;
					5'h01: out <= lcd7;
					5'h03: out <= 8'h74;
					5'h04: out <= 8'h6F;
					5'h05: out <= 8'h75;
					5'h06: out <= 8'h70;
					5'h07: out <= 8'h65;
					5'h08: out <= 8'h69;
					5'h09: out <= 8'h72;
					5'hA: out <= 8'h61;
					5'hB:  out <= 8'h73;
					// Line 2
					5'h10: out <= 8'h43;
					5'h11: out <= 8'h61;
					5'h12: out <= 8'h70;
					5'h13: out <= 8'h74;
					5'h14: out <= 8'h75;
					5'h15: out <= 8'h72;
					5'h16: out <= 8'h61;
					5'h17: out <= 8'h64;
					5'h18: out <= 8'h61;
					5'h19: out <= 8'h73;
					default: out <= 8'h20; //Blank spaces
					endcase
				end
				end
			// Toupeira escapou
		'd2:
			case (index)
				5'h00: out <= 8'h74;
				5'h01: out <= 8'h6F;
				5'h02: out <= 8'h75;
				5'h03: out <= 8'h70;
				5'h04: out <= 8'h65;
				5'h05: out <= 8'h69;
				5'h06: out <= 8'h72;
				5'h07: out <= 8'h61;
				// Line 2
				5'h10: out <= 8'h65;
				5'h11: out <= 8'h73;
				5'h12: out <= 8'h63;
				5'h13: out <= 8'h61;
				5'h14: out <= 8'h70;
				5'h15: out <= 8'h6F;
				5'h16: out <= 8'h75;
				default: out <= 8'h20; //Blank spaces
				endcase
	
			'd3:
					case (index)
					5'h00: out <= 8'h47; //G
					5'h01: out <= 8'h41; //A
					5'h02: out <= 8'h4D; //M
					5'h03: out <= 8'h45; //E
					// Line 2
					5'h10: out <= 8'h4F; //O
					5'h11: out <= 8'h56; //V
					5'h12: out <= 8'h45; //E
					5'h13: out <= 8'h52; //R
					5'h14: out <= 8'h21; //!
					default: out <= 8'h20; //Blank spaces
					endcase
					
			'd4:
					case (index)
					5'h00: out <= 8'h50; //P
					5'h01: out <= 8'h61; //a
					5'h02: out <= 8'h72; //r
					5'h03: out <= 8'h61; //a
					5'h04: out <= 8'h62; //b
					5'h05: out <= 8'h65; //e
					5'h06: out <= 8'h6E; //n
					5'h07: out <= 8'h73; //s
					5'h08: out <= 8'h20; //
					5'h09: out <= 8'h76; //v
					5'hA:  out <= 8'h6F; //o
					5'hB:  out <= 8'h63; //c
					5'hC:  out <= 8'h65; //e
					// Line 2
					5'h10: out <= 8'h56; //V
					5'h11: out <= 8'h65; //e
					5'h12: out <= 8'h6E; //n
					5'h13: out <= 8'h63; //c
					5'h14: out <= 8'h65; //e
					5'h15: out <= 8'h75; //u
					5'h16: out <= 8'h21; //!
					default: out <= 8'h20; //Blank spaces
					endcase
	
			endcase
	end
	endmodule
   
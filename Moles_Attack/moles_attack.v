module moles_attack (
	input CLOCK_50, 
	input [3:0] KEY, //Botoes
	output [8:0] LEDG,    //    LED Green
	output reg [6:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7, //Display de 7 segmentos
	inout [35:0] GPIO_0,GPIO_1,    //    GPIO Connections
  //---> LCD Module 16X2
	output LCD_ON,        // LCD Power ON/OFF
  output LCD_BLON,      // LCD Back Light ON/OFF
  output LCD_RW,        // LCD Read/Write Select, 0 = Write, 1 = Read
  output LCD_EN,        // LCD Enable
  output LCD_RS,        // LCD Command/Data Select, 0 = Command, 1 = Data
  inout [7:0] LCD_DATA);  // LCD Data bus 8 bits
  
// Turn LCD ON
	assign LCD_ON      =    1'b1;
	assign LCD_BLON    =    1'b1;
	
	// reset delay gives some time for peripherals to initialize
	wire DLY_RST;
	Reset_Delay r0(	.iCLK(CLOCK_50),.oRESET(DLY_RST) );
  
   //    All inout port turn to tri-state
	assign    GPIO_0        =    36'hzzzzzzzzz;
	assign    GPIO_1        =    36'hzzzzzzzzz;
	
	wire [3:0]BT; //Botoes "Debounceados"
	
	reg [32:0] contador;
	
	wire [6:0] lcd0, lcd1, lcd2, lcd5, lcd6, lcd7;
	assign lcd0 = auxiliar0; //estado do lcd
	assign lcd1 = auxiliar1; // influencia auxilia7
	assign lcd2 = auxiliar2; // influencia auxilia6
	assign lcd5 = auxiliar5; //saber se ganhou
	assign lcd6 = auxiliar6; //contagem das topeiras 1 casa do display
	assign lcd7 = auxiliar7; //contagem das topeiras 2 casa do display
	
	initial 
		begin
		cont_a = 'd0;
		cont_e = 'd0;
		auxiliar0 = 'd0;
		auxiliar1 = 'd0;
		auxiliar2 = 'd0;
		auxiliar5 = 8'h0;
		auxiliar6 = 8'h0;
		auxiliar7 = 8'h0;
		end
		
always @(lcd7) begin
	case (lcd7)
						
				'd2 : begin
				auxiliar7 <= 8'h32;
				end
				'd3 : begin
				auxiliar7 <= 8'h33;
				end
				'd4 : begin
				auxiliar7 <= 8'h34;
				end
				'd5 : begin
				auxiliar7 <= 8'h35;
				end
				'd6 : begin
				auxiliar7 <= 8'h36;
				end
				'd7 : begin
				auxiliar7 <= 8'h37;
				end
				'd8 : begin
				auxiliar7 <= 8'h38;
				end
				'd9 : begin
				auxiliar7 <= 8'h39;
				end
				'd10 : begin
				auxiliar7 <= 8'h30;
				end
				'd11: begin 
				auxiliar7 <= 8'h31;
				end
				'd12 : begin
				auxiliar7 <= 8'h32;
				end
				'd13 : begin
				auxiliar7 <= 8'h33;
				end
				'd14 : begin
				auxiliar7 <= 8'h34;
				end
				'd15 : begin
				auxiliar7 <= 8'h35;
				end
				'd16 : begin
				auxiliar7 <= 8'h36;
				end
				'd17 : begin
				auxiliar7 <= 8'h37;
				end
				'd18 : begin
				auxiliar7 <= 8'h38;
				end
				'd19 : begin
				auxiliar7 <= 8'h39;
				end
				'd20 : begin
				auxiliar7 <= 8'h30;
				end
		endcase
end

always @(lcd6) begin
	case (lcd6)
						
				'd2 : begin
				auxiliar6 <= 8'h30;
				end
				'd3 : begin
				
				auxiliar6 <= 8'h30;
				end
				'd4 : begin
				
				auxiliar6 <= 8'h30;
				end
				'd5 : begin
				
				auxiliar6 <= 8'h30;
				end
				'd6 : begin
				
				auxiliar6 <= 8'h30;
				end
				'd7 : begin
				
				auxiliar6 <= 8'h30;
				end
				'd8 : begin
				
				auxiliar6 <= 8'h30;
				end
				'd9 : begin
				
				auxiliar6 <= 8'h30;
				end
				'd10 : begin
				
				auxiliar6 <= 8'h31;
				end
				'd11 : begin 
				
				auxiliar6 <= 8'h31;
				end
				'd12: begin
				
				auxiliar6 <= 8'h31;
				end
				'd13 : begin
				
				auxiliar6 <= 8'h31;
				end
				'd14 : begin
				
				auxiliar6 <= 8'h31;
				end
				'd15 : begin
				
				auxiliar6 <= 8'h31;
				end
				'd16 : begin
				
				auxiliar6 <= 8'h31;
				end
				'd17 : begin
				
				auxiliar6 <= 8'h31;
				end
				'd18 : begin
				
				auxiliar6 <= 8'h31;
				end
				'd19 : begin
				
				auxiliar6 <= 8'h31;
				end
				'd20 : begin
				auxiliar6 <= 8'h32;
				end
		endcase
end

	LCD_Display u1(
// Host Side
   .iCLK_50MHZ(CLOCK_50),
   .iRST_N(DLY_RST),
   .lcd0(lcd0),
   .lcd1(lcd1),
	.lcd2 (lcd2),
	.lcd3 (lcd3),
	.lcd6 (lcd6),
	.lcd7 (lcd7),
	.cont_a(cont_a),
	.cont_e (cont_e),
	.botoes (KEY[3:0]),
// LCD Side
   .DATA_BUS(LCD_DATA),
   .LCD_RW(LCD_RW),
   .LCD_E(LCD_EN),
   .LCD_RS(LCD_RS)
);
	
	//Debouncing dos botoes
	DeBounce (CLOCK_50, RESET, KEY[3], BT[3]);
	DeBounce (CLOCK_50, RESET, KEY[2], BT[2]);
	DeBounce (CLOCK_50, RESET, KEY[1], BT[1]);
	DeBounce (CLOCK_50, RESET, KEY[0], BT[0]);
	
	reg [32:0] cont_a, cont_e, auxiliar0, auxiliar1, auxiliar2, auxiliar5, auxiliar6, auxiliar7;
	
	
	reg [3:0] MOLE;
	
	assign LEDG[7] = MOLE[3];
	assign LEDG[6] = MOLE[3];
	assign LEDG[5] = MOLE[2];
	assign LEDG[4] = MOLE[2];
	assign LEDG[3] = MOLE[1];
	assign LEDG[2] = MOLE[1];
	assign LEDG[1] = MOLE[0];
	assign LEDG[0] = MOLE[0];
	
	
	//GERADOR DE NUMEROS ALEATORIOS///////////////////
	reg clock_rand;
	wire [3:0]LFSR_out;
	wire [1:0]rand;
	
	LFSR_counter (clock_rand, LFSR_out);
	
	assign rand = LFSR_out;
	/////////////////////////////////////////////////
	
	always @(posedge CLOCK_50) begin
	   contador <= contador + 1;
		if (cont_a < 5) begin
			if(contador[27]) begin
			   clock_rand = contador[27];
				MOLE[0] <= !rand[1] & !rand[0];
				MOLE[1] <= !rand[1] & rand[0];
				MOLE[2] <= rand[1] & !rand[0];
				MOLE[3] <= rand[1] & rand[0];
			end
			else begin
			   clock_rand = 0;
				MOLE[0] <= 0;
				MOLE[1] <= 0;
				MOLE[2] <= 0;
				MOLE[3] <= 0;
			end
		end
		
		if (cont_a >= 5 & cont_a < 10) begin
			if(contador[26]) begin
				clock_rand = contador[26];
				MOLE[0] <= !rand[1] & !rand[0];
				MOLE[1] <= !rand[1] & rand[0];
				MOLE[2] <= rand[1] & !rand[0];
				MOLE[3] <= rand[1] & rand[0];
			end
			else begin
			   clock_rand = 0;
				MOLE[0] <= 0;
				MOLE[1] <= 0;
				MOLE[2] <= 0;
				MOLE[3] <= 0;
			end
		end
			
		if (cont_a >= 10 & cont_a <15) begin
			if(contador[25]) begin
			   clock_rand = contador[25];
				MOLE[0] <= !rand[1] & !rand[0];
				MOLE[1] <= !rand[1] & rand[0];
				MOLE[2] <= rand[1] & !rand[0];
				MOLE[3] <= rand[1] & rand[0];
			end
			else begin
				clock_rand = 0;
				MOLE[0] <= 0;
				MOLE[1] <= 0;
				MOLE[2] <= 0;
				MOLE[3] <= 0;
			end
		end
		
		if (cont_a >= 15 & cont_a <20) begin
			if(contador[24]) begin
				clock_rand = contador[24];
				MOLE[0] <= !rand[1] & !rand[0];
				MOLE[1] <= !rand[1] & rand[0];
				MOLE[2] <= rand[1] & !rand[0];
				MOLE[3] <= rand[1] & rand[0];
			end
			else begin
				clock_rand = 0;
				MOLE[0] <= 0;
				MOLE[1] <= 0;
				MOLE[2] <= 0;
				MOLE[3] <= 0;
			end
		end
	end
	
	
	always @(negedge KEY[rand])begin
			if(MOLE[rand] & ~KEY[rand]) begin
				cont_a <= cont_a + 1;
				auxiliar0 <= 'd1;
				auxiliar1 <= auxiliar1 + 1;
				auxiliar2 <= auxiliar2 + 1;
			end
			else begin
				cont_e <= cont_e +1;
				auxiliar0 <= 'd2;
				if(cont_e == 'd3) begin
					auxiliar0 <= 'd3;
					auxiliar2 <= 'd0;
					cont_a <= 'd0;
					auxiliar1 <= 8'h0;
				end
				else begin
					if(cont_a == 'd20)begin
						auxiliar0 <= 'd4;
					end
				end
			end
		end
	
	
	//DISPLAY 7 SEG
always @ (cont_a or cont_e)begin
	//acertos e nivel
	case(cont_a)
		0:begin
		 lcd0 = 7'b1000000;//0	
		 lcd1 = 7'b1000000;//0
		 lcd2 = 7'b1000000;//0
		 lcd3 = 7'b1000000;//0
		 
		 lcd6 = 7'b1111001; //1
		 lcd7 = 7'b1000000;//0
	end
	
		1:begin
		 lcd0 = 7'b1000000; //0	
		 lcd1 = 7'b0110000; //3
		 lcd2 = 7'b1000000; //0
		 lcd3 = 7'b1000000; //0
	end
	
		2:begin
		 lcd0 = 7'b1000000; //0	
		 lcd1 = 7'b0000010; //6
		 lcd2 = 7'b1000000; //0
		 lcd3 = 7'b1000000; //0
	end
	
		3:begin
		 lcd0 = 7'b1000000; //0	
		 lcd1 = 7'b0010000; //9
		 lcd2 = 7'b1000000; //0
		 lcd3 = 7'b1000000; //0
	end
	
		4:begin
		 lcd0 = 7'b1000000; //0	
		 lcd1 = 7'b0100100; //2
		 lcd2 = 7'b1111001; //1
		 lcd3 = 7'b1000000; //0
	end
	
		5:begin
		 lcd0 = 7'b1000000; //0	
		 lcd1 = 7'b0010010; //5
		 lcd2 = 7'b1111001; //1
		 lcd3 = 7'b1000000; //0
		 
		 lcd6 = 7'b0100100; //2	
		 lcd7 = 7'b1000000;//0
	end
	
		6:begin
		 lcd0 = 7'b1000000; //0	
		 lcd1 = 7'b1000000; //0
		 lcd2 = 7'b0100100; //2
		 lcd3 = 7'b1000000; //0
		 
		 lcd6 = 7'b0100100; //2	
		 lcd7 = 7'b1000000;//0
	end
	
		7:begin
		 lcd0 = 7'b1000000; //0	
		 lcd1 = 7'b0010010; //5
		 lcd2 = 7'b0100100; //2
		 lcd3 = 7'b1000000; //0
		 
		 lcd6 = 7'b0100100; //2	
		 lcd7 = 7'b1000000;//0
	end
	
		8:begin
		 lcd0 = 7'b1000000; //0	
		 lcd1 = 7'b1000000; //0
		 lcd2 = 7'b0110000; //3
		 lcd3 = 7'b1000000; //0
		 
		 lcd6 = 7'b0100100; //2	
		 lcd7 = 7'b1000000;//0
	end
	
		9:begin
		 lcd0 = 7'b1000000; //0	
		 lcd1 = 7'b0010010; //5
		 lcd2 = 7'b0110000; //3
		 lcd3 = 7'b1000000; //0
		 
		 lcd6 = 7'b0100100; //2	
		 lcd7 = 7'b1000000;//0
	end
	
		10:begin
		 lcd0 = 7'b1000000; //0	
		 lcd1 = 7'b1000000; //0
		 lcd2 = 7'b0011001; //4
		 lcd3 = 7'b1000000; //0
		 
		 lcd6 = 7'b0110000; //3
		 lcd7 = 7'b1000000;//0
	end
	
		11:begin
		 lcd0 = 7'b1000000; //0	
		 lcd1 = 7'b1111000; //7
		 lcd2 = 7'b0011001; //4
		 lcd3 = 7'b1000000; //0
		 
		 lcd6 = 7'b0110000; //3
		 lcd7 = 7'b1000000;//0
	end
	
		12:begin
		 lcd0 = 7'b1000000; //0	
		 lcd1 = 7'b0011001; //4
		 lcd2 = 7'b0010010; //5
		 lcd3 = 7'b1000000; //0
		 
		 lcd6 = 7'b0110000; //3
		 lcd7 = 7'b1000000;//0
	end
	
		13:begin
		 lcd0 = 7'b1000000; //0	
		 lcd1 = 7'b1111001; //1
		 lcd2 = 7'b0000010; //6
		 lcd3 = 7'b1000000; //0
		 
		 lcd6 = 7'b0110000; //3
		 lcd7 = 7'b1000000;//0
	end
	
		14:begin
		 lcd0 = 7'b1000000; //0	
		 lcd1 = 7'b0000000; //8
		 lcd2 = 7'b0000010; //6
		 lcd3 = 7'b1000000; //0
		 
		 lcd6 = 7'b0110000; //3
		 lcd7 = 7'b1000000;//0
	end
	
		15:begin
		 lcd0 = 7'b1000000; //0	
		 lcd1 = 7'b0010010; //5
		 lcd2 = 7'b1111000; //7
		 lcd3 = 7'b1000000; //0
		 
		 lcd6 = 7'b0011001; //4
		 lcd7 = 7'b1000000;//0
	end
	
		16:begin
		 lcd0 = 7'b1000000; //0	
		 lcd1 = 7'b0010010; //5
		 lcd2 = 7'b0000000; //8	
		 lcd3 = 7'b1000000; //0
		 
		 lcd6 = 7'b0011001; //4
		 lcd7 = 7'b1000000;//0
	end
	
		17:begin
		 lcd0 = 7'b1000000; //0	
		 lcd1 = 7'b0010010; //5
		 lcd2 = 7'b0010000; //9		
		 lcd3 = 7'b1000000; //0	
		 
		 lcd6 = 7'b0011001; //4
		 lcd7 = 7'b1000000;//0
	end
	
		18:begin
		 lcd0 = 7'b1000000; //0	
		 lcd1 = 7'b0010010; //5
		 lcd2 = 7'b1000000; //0	
		 lcd3 = 7'b1111001; //1
		 
		 lcd6 = 7'b0011001; //4
		 lcd7 = 7'b1000000;//0
	end
	
		19:begin
		 lcd0 = 7'b1000000; //0	
		 lcd1 = 7'b0010010; //5
		 lcd2 = 7'b1111001; //1	
		 lcd3 = 7'b1111001; //1
		 
		 lcd6 = 7'b0011001; //4
		 lcd7 = 7'b1000000;//0
	end
	
		20:begin
		 lcd0 = 7'b1000000; //0	
		 lcd1 = 7'b0010010; //5
		 lcd2 = 7'b0100100; //2
		 lcd3 = 7'b1111001; //1
		 
		 lcd6 = 7'b0011001; //4
		 lcd7 = 7'b1000000;//0
	end

	endcase
	// erros
	case (cont_e)
	
		0:begin
		 lcd4 = 7'b1000000;//0	
		 lcd5 = 7'b1000000;//0
	end
	
		1:begin
		 lcd4 = 7'b1111001; //1
		 lcd5 = 7'b1000000;//0
	end
	
		2:begin
		 lcd4 = 7'b0100100; //2
		 lcd5 = 7'b1000000;//0
	end
	
		3:begin
		 lcd4 = 7'b0110000; //3
		 lcd5 = 7'b1000000;//0
	end
	
	endcase
	end

endmodule
		
//7'b1000000; //0
//7'b1111001; //1
//7'b0100100; //2
//7'b0110000; //3
//7'b0011001; //4
//7'b0010010; //5
//7'b0000010; //6
//7'b1111000; //7
//7'b0000000; //8
//7'b0010000; //9		

	
			
			
		
	
	
	
	
	
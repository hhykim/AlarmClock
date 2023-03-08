module CH3_WATCH(
	RESETN, CLK,
	BTN_A, BTN_B, BTN_C, BTN_D, BTN_E,
	LCD_E, LCD_RS, LCD_RW,
	LCD_DATA,
	PIEZO
);

input RESETN, CLK;
input BTN_A, BTN_B, BTN_C, BTN_D, BTN_E;
output LCD_E, LCD_RS, LCD_RW;
output [7:0] LCD_DATA;
output PIEZO;

wire LCD_E;
reg LCD_RS, LCD_RW;
reg [7:0] LCD_DATA;

wire PIEZO;
reg BUFF;

reg [6:0] HOUR, MIN, SEC;
wire [3:0] H10, H1, M10, M1, S10, S1;

reg [6:0] ALM_HOUR, ALM_MIN;
wire [3:0] ALM_H10, ALM_H1, ALM_M10, ALM_M1;

integer CNT;
integer CNT_SCAN;
integer CNT_BEAT;
integer CNT_SOUND;

integer TGL_BTN_A;
integer TGL_BTN_B;
integer TGL_BTN_CDE;
integer TGL_ALM;

function [7:0] DECODE;
input [3:0] BCD;

begin
	case (BCD)
		4'd0: DECODE = "0";
		4'd1: DECODE = "1";
		4'd2: DECODE = "2";
		4'd3: DECODE = "3";
		4'd4: DECODE = "4";
		4'd5: DECODE = "5";
		4'd6: DECODE = "6";
		4'd7: DECODE = "7";
		4'd8: DECODE = "8";
		4'd9: DECODE = "9";
		default: DECODE = " ";
	endcase
end
endfunction

always @(posedge CLK or negedge RESETN)
begin
	if (~RESETN)
		begin
			CNT = 0;
		end
	else
		begin
			if (CNT >= 99999)
				CNT = 0;
			else
				CNT = CNT + 1;
		end
end

always @(posedge CLK or negedge RESETN)
begin
	if (~RESETN)
		begin
			SEC = 0;
		end
	else
		begin
			if (CNT == 99999)
				begin
					if (SEC >= 59)
						SEC = 0;
					else
						SEC = SEC + 1;
				end
		end
end

always @(posedge CLK or negedge RESETN)
begin
	if (~RESETN)
		begin
			MIN = 0;
			TGL_BTN_B = 0;
		end
	else if (BTN_B)
		begin
			if (TGL_BTN_B == 0)
				begin
					TGL_BTN_B = 1;
					
					if (MIN >= 59)
						MIN = 0;
					else
						MIN = MIN + 1;
				end
		end
	else
		begin
			TGL_BTN_B = 0;
			
			if (CNT == 99999 && SEC == 59)
				begin
					if (MIN >= 59)
						MIN = 0;
					else
						MIN = MIN + 1;
				end
		end
end

always @(posedge CLK or negedge RESETN)
begin
	if (~RESETN)
		begin
			HOUR = 0;
			TGL_BTN_A = 0;
		end
	else if (BTN_A)
		begin
			if (TGL_BTN_A == 0)
				begin
					TGL_BTN_A = 1;
					
					if (HOUR >= 23)
						HOUR = 0;
					else
						HOUR = HOUR + 1;
				end
		end
	else
		begin
			TGL_BTN_A = 0;
			
			if (CNT == 99999 && SEC == 59 && MIN == 59)
				begin
					if (HOUR >= 23)
						HOUR = 0;
					else
						HOUR = HOUR + 1;
				end
		end
end

always @(posedge CLK or negedge RESETN)
begin
	if (~RESETN)
		begin
			ALM_MIN = 0;
			ALM_HOUR = 0;
			
			TGL_BTN_CDE = 0;
			TGL_ALM = 0;
		end
	else if (BTN_C)
		begin
			if (TGL_BTN_CDE == 0)
				begin
					TGL_BTN_CDE = 1;
					
					if (ALM_HOUR >= 23)
						ALM_HOUR = 0;
					else
						ALM_HOUR = ALM_HOUR + 1;
				end
		end
	else if (BTN_D)
		begin
			if (TGL_BTN_CDE == 0)
				begin
					TGL_BTN_CDE = 1;
					
					if (ALM_MIN >= 59)
						ALM_MIN = 0;
					else
						ALM_MIN = ALM_MIN + 1;
				end
		end
	else if (BTN_E)
		begin
			if (TGL_BTN_CDE == 0)
				begin
					TGL_BTN_CDE = 1;
					
					if (TGL_ALM == 0)
						TGL_ALM = 1;
					else
						TGL_ALM = 0;
				end
		end
	else
		begin
			TGL_BTN_CDE = 0;
		end
end

always @(posedge CLK or negedge RESETN)
begin
	if (~RESETN)
		begin
			// Display clear
			LCD_RS = 1'b0;
			LCD_RW = 1'b0;
			LCD_DATA = 8'b00000001;
			
			CNT_SCAN = 0;
		end
	else
		begin
			if (CNT_SCAN >= 193)
				CNT_SCAN = 160;
			else
				CNT_SCAN = CNT_SCAN + 1;
			
			case (CNT_SCAN)
				70:
					begin
						// Function set
						LCD_DATA = 8'b00111100;
					end
				100:
					begin
						// Display on/off control
						LCD_DATA = 8'b00001100;
					end
				130:
					begin
						// Entry mode set
						LCD_DATA = 8'b00000110;
					end
				160:
					begin
						LCD_RS = 1'b0;
						LCD_DATA = { 1'b1, 7'h00 };
					end
				161:
					begin
						LCD_RS = 1'b1;
						LCD_DATA = "T";
					end
				162:
					begin
						LCD_DATA = "I";
					end
				163:
					begin
						LCD_DATA = "M";
					end
				164:
					begin
						LCD_DATA = "E";
					end
				165:
					begin
						LCD_DATA = " ";
					end
				166:
					begin
						LCD_DATA = ":";
					end
				167:
					begin
						LCD_DATA = " ";
					end
				168:
					begin
						LCD_DATA = DECODE(H10);
					end
				169:
					begin
						LCD_DATA = DECODE(H1);
					end
				170:
					begin
						LCD_DATA = ":";
					end
				171:
					begin
						LCD_DATA = DECODE(M10);
					end
				172:
					begin
						LCD_DATA = DECODE(M1);
					end
				173:
					begin
						LCD_DATA = ":";
					end
				174:
					begin
						LCD_DATA = DECODE(S10);
					end
				175:
					begin
						LCD_DATA = DECODE(S1);
					end
				176:
					begin
						LCD_DATA = " ";
					end
				177:
					begin
						LCD_RS = 1'b0;
						LCD_DATA = { 1'b1, 7'h40 };
					end
				178:
					begin
						LCD_RS = 1'b1;
						LCD_DATA = "A";
					end
				179:
					begin
						LCD_DATA = "L";
					end
				180:
					begin
						LCD_DATA = "A";
					end
				181:
					begin
						LCD_DATA = "R";
					end
				182:
					begin
						LCD_DATA = "M";
					end
				183:
					begin
						LCD_DATA = ":";
					end
				184:
					begin
						LCD_DATA = " ";
					end
				185:
					begin
						LCD_DATA = DECODE(ALM_H10);
					end
				186:
					begin
						LCD_DATA = DECODE(ALM_H1);
					end
				187:
					begin
						LCD_DATA = ":";
					end
				188:
					begin
						LCD_DATA = DECODE(ALM_M10);
					end
				189:
					begin
						LCD_DATA = DECODE(ALM_M1);
					end
				190:
					begin
						LCD_DATA = " ";
					end
				191:
					begin
						LCD_DATA = "(";
					end
				192:
					begin
						if (TGL_ALM == 0)
							LCD_DATA = "X";
						else
							LCD_DATA = "O";
					end
				193:
					begin
						LCD_DATA = ")";
					end
			endcase
		end
end

always @(posedge CLK or negedge RESETN)
begin
	if (~RESETN)
		begin
			BUFF = 1'b0;
			CNT_BEAT = 0;
			CNT_SOUND = 0;
		end
	else
		begin
			if (TGL_ALM == 1 && MIN == ALM_MIN && HOUR == ALM_HOUR)
				begin
					case (CNT_BEAT / 30000)
						0:
							begin
								if (CNT_SOUND >= 190)
									begin
										CNT_SOUND = 0;
										BUFF = ~BUFF;
									end
								else
									begin
										CNT_SOUND = CNT_SOUND + 1;
									end
							end
						1:
							begin
								if (CNT_SOUND >= 151)
									begin
										CNT_SOUND = 0;
										BUFF = ~BUFF;
									end
								else
									begin
										CNT_SOUND = CNT_SOUND + 1;
									end
							end
						2:
							begin
								if (CNT_SOUND >= 127)
									begin
										CNT_SOUND = 0;
										BUFF = ~BUFF;
									end
								else
									begin
										CNT_SOUND = CNT_SOUND + 1;
									end
							end
						3:
							begin
								if (CNT_SOUND >= 95)
									begin
										CNT_SOUND = 0;
										BUFF = ~BUFF;
									end
								else
									begin
										CNT_SOUND = CNT_SOUND + 1;
									end
							end
					endcase
					
					if (CNT_BEAT >= 119999)
						CNT_BEAT = 0;
					else
						CNT_BEAT = CNT_BEAT + 1;
					
					if (CNT_BEAT % 30000 == 0)
						CNT_SOUND = 0;
				end
			else
				begin
					CNT_BEAT = 0;
					CNT_SOUND = 0;
				end
		end
end

assign LCD_E = CLK;
assign PIEZO = BUFF;

CH3_WT_SEP S_SEP(SEC, S10, S1);
CH3_WT_SEP M_SEP(MIN, M10, M1);
CH3_WT_SEP H_SEP(HOUR, H10, H1);

CH3_WT_SEP ALM_M_SEP(ALM_MIN, ALM_M10, ALM_M1);
CH3_WT_SEP ALM_H_SEP(ALM_HOUR, ALM_H10, ALM_H1);

endmodule
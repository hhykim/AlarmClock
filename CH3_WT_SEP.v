module CH3_WT_SEP(
	NUMBER,
	SEP_A, SEP_B
);

input [6:0] NUMBER;
output [3:0] SEP_A, SEP_B;

reg [3:0] SEP_A, SEP_B;

always @(NUMBER)
begin
	if (NUMBER <= 9)
		begin
			SEP_A = 3'd0;
			SEP_B = NUMBER[3:0];
		end
	else if (NUMBER <= 19)
		begin
			SEP_A = 1;
			SEP_B = NUMBER - 10;
		end
	else if (NUMBER <= 29)
		begin
			SEP_A = 2;
			SEP_B = NUMBER - 20;
		end
	else if (NUMBER <= 39)
		begin
			SEP_A = 3;
			SEP_B = NUMBER - 30;
		end
	else if (NUMBER <= 49)
		begin
			SEP_A = 4;
			SEP_B = NUMBER - 40;
		end
	else if (NUMBER <= 59)
		begin
			SEP_A = 5;
			SEP_B = NUMBER - 50;
		end
	else
		begin
			SEP_A = 0;
			SEP_B = 0;
		end
end

endmodule
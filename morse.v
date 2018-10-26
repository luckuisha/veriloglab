module morse(input [9:0]SW, input [3:0]KEY, input CLOCK_50, output [9:0]LEDR);
	thing u0 (SW[0], SW[1], SW[3], CLOCK_50, KEY[0] ,LEDR[0]);
endmodule

module thing (input a, b, c, clock, clear_b, output reg o);
	reg [25:0]w;
	always @ (posedge clock)
		begin
			if (w==0)
				w<=26'b01011111010111100000111111;
			else
				w<=w-1;
		end
		
	reg q;
	always @ (posedge clock)
		begin
		if (w == 0)
				q<=1;
			else
				q<=0;
		end
		
	wire [13:0]w2;
	wire [13:0]w3;
	letter u1 (a, b, c, w2[13:0]);
	
	access u2 (q, 1'b0, clear_b, 1'b0, 1'b0, w2[13:0], w3);
	
	always @ (posedge clock) begin
		if (clear_b == 0)
			o <= 0;
		else if (w == 26'b00000000000000000000000000)
			o <= w3[13];
			end
			
endmodule


module letter(input a, b, c, output reg [13:0]out);
	wire [2:0]w;
	assign w = {c, b, a};
	always @ (*)
		case (w)
			3'b000: out = 14'b01010100000000;
			3'b001: out = 14'b01110000000000;
			3'b010: out = 14'b01010111000000;
			3'b011: out = 14'b01010101110000;
			3'b100: out = 14'b01011101110000;
			3'b101: out = 14'b01110101011100;
			3'b110: out = 14'b01110101110111;
			3'b111: out = 14'b01110111010100;
			default: out = 14'b00000000000000;
		endcase
	endmodule

	module access (input Clock, reset, parallelLoadn, rotateRight, lsRight, input [13:0]DATA_IN, output [13:0]q);
	reg w1;
	always@(*)
	begin
		if(lsRight == 1'b1 && rotateRight == 1'b1 && parallelLoadn == 1'b1)
			w1 = 1'b0;
		else
			w1 = q[0];
	end
		shifter u3 (q[1], q[13], rotateRight, DATA_IN[0], parallelLoadn, Clock, reset, q[0]);
		shifter u4 (q[2], q[0], rotateRight, DATA_IN[1], parallelLoadn, Clock, reset, q[1]);
		shifter u5 (q[3], q[1], rotateRight, DATA_IN[2], parallelLoadn, Clock, reset, q[2]);
		shifter u6 (q[4], q[2], rotateRight, DATA_IN[3], parallelLoadn, Clock, reset, q[3]);
		shifter u7 (q[5], q[3], rotateRight, DATA_IN[4], parallelLoadn, Clock, reset, q[4]);
		shifter u8 (q[6], q[4], rotateRight, DATA_IN[5], parallelLoadn, Clock, reset, q[5]);
		shifter u9 (q[7], q[5], rotateRight, DATA_IN[6], parallelLoadn, Clock, reset, q[6]);
		shifter u10 (q[8], q[6], rotateRight, DATA_IN[7], parallelLoadn, Clock, reset, q[7]);
		shifter u11 (q[9], q[7], rotateRight, DATA_IN[8], parallelLoadn, Clock, reset, q[8]);
		shifter u12 (q[10], q[8], rotateRight, DATA_IN[9], parallelLoadn, Clock, reset, q[9]);
		shifter u13 (q[11], q[9], rotateRight, DATA_IN[10], parallelLoadn, Clock, reset, q[10]);
		shifter u14 (q[12], q[10], rotateRight, DATA_IN[11], parallelLoadn, Clock, reset, q[11]);
		shifter u15 (q[13], q[11], rotateRight, DATA_IN[12], parallelLoadn, Clock, reset, q[12]);
		shifter u16 (w1, q[12], rotateRight, DATA_IN[13], parallelLoadn, Clock, reset, q[13]);
endmodule

	
module shifter(input left, right, loadLeft, d, loadn, Clock, reset, output reg q);
	reg [2:0]w;
	 always@(posedge Clock)
		begin
		if (loadLeft)
			w[0] <= left;
		else
			w[0] <= right;
		
		if (loadn)
			w[1] <= w[0];
		else
			w[1]<= d;
			
		if(reset == 1'b1)
			q<=0;
		else
			q<=w[1];

	end
endmodule

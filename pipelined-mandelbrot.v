module mandelbrot (
	input clk
);
	reg [31:0] x,y;
	always @(posedge clk) begin
		
	end
endmodule

module mandelbrot_compute_0 (
	input [31:0] x,
	input [31:0] y,
	output [31:0] xx,
	output [31:0] yy,
	output [31:0] xy
);
	mandelbrot_fxp_mul xx_mul (x, x, xx);
	mandelbrot_fxp_mul yy_mul (y, y, yy);
	mandelbrot_fxp_mul xy_mul (x, y, xy);
endmodule

module mandelbrot_compute_1 (
	input [31:0] xx,
	input [31:0] yy,
	input [31:0] xy,
	output [31:0] xxsubyy,
	output [31:0] xy2,
	output [31:0] xxaddyy
);
	assign xxsubyy = xxin - yyin;
	assign xy2 = xyin * 2'd2;
	assign xxaddyy = xxin + yyin;
endmodule

module mandelbrot_compute_2 (
	input [31:0] xxsubyy,
	input [31:0] xy2,
	input [31:0] x0,
	input [31:0] y0,
	output [31:0] x,
	output [31:0] y
);
	assign x = xxsubyy + x0;
	assign y = xy2 + y0;
endmodule

module mandelbrot_loopback (
	input [31:0] xxaddyy,
	input [31:0] imax
);
	
endmodule

module mandelbrot_input_0 (
	input [10:0] xin,
	input [10:0] yin,
	output [31:0] xout,
	output [31:0] yout
);
	assign xout = xin*3.5;
	assign yout = y*2'd2;
endmodule

module mandelbrot_fxp_mul (
	input [31:0] a,
	input [31:0] b,
	output [31:0] c
);
	wire [63:0] result;
	assign result = a * b;
	assign c = result[63:32];
endmodule

module mandelbrot_fifo #(parameter SIZE = 16) (
	input [31:0] clk,
	input [31:0] in,
	output [31:0] out
);
	reg [31:0] mem [SIZE:0];
	reg [4:0] p = 4'd0;
	always @(posedge clk) begin
		mem[p] <= in;
		p <= (p + 1'b1) % SIZE-1;
	end
	assign out = mem[p+1'b1];
endmodule

module testbench (

);

endmodule

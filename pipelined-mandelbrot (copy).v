module mandelbrot (
	input clk
);
	// Instance mess
	wire [31:0] x,y,xx,yy,xy;
	
	mandelbrot_compute_0 compute_0 (
		clk,
		x,
		y,
		xx,
		yy,
		xy
	);
	
	wire [31:0] xxsubyy,xy2,xxaddyy;
	
	mandelbrot_compute_1 compute_1 (
		clk,
		xx,
		yy,
		xy,
		xxsubyy,
		xy2,
		xxaddyy
	);
endmodule

module mandelbrot_compute_0 (
	input clk,
	input [31:0] x,
	input [31:0] y,
	output [31:0] xx,
	output [31:0] yy,
	output [31:0] xy
);
	reg [31:0] xin, yin;
	
	always @(posedge clk) begin
		xin <= x;
		yin <= y;
	end
	
	assign xx = x*x;
	assign yy = y*y;
	assign xy = x*y;
endmodule

module mandelbrot_compute_1 (
	input clk,
	input [31:0] xx,
	input [31:0] yy,
	input [31:0] xy,
	output [31:0] xxsubyy,
	output [31:0] xy2,
	output [31:0] xxaddyy
);
	reg [31:0] xxin;
	reg [31:0] yyin;
	reg [31:0] xyin;
	always @(posedge clk) begin
		xxin <= xx;
		yyin <= yy;
		xyin <= xy;
	end
	
	assign xxsubyy = xxin - yyin;
	assign xy2 = xyin * 2;
	assign xxaddyy = xxin + yyin;
endmodule

module mandelbrot_compute_2 (
	input clk,
	input [31:0] xxsubyy,
	input [31:0] yy,
	input [31:0] xy,
	output [31:0] xxsubyy,
	output [31:0] xy2,
	output [31:0] xxaddyy
);
	reg [31:0] xxin;
	reg [31:0] yyin;
	reg [31:0] xyin;
	always @(posedge clk) begin
		xxin <= xx;
		yyin <= yy;
		xyin <= xy;
	end
	
	assign xxsubyy = xxin - yyin;
	assign xy2 = xyin * 2;
	assign xxaddyy = xxin + yyin;
endmodule

// Using fixed point, 1 sign bit + 3 integer bits, 28 decimal bits
// Coordinate input is 11x11 bits for a maximum output resolution of 2048x2048

module mandelbrot #(
	parameter [10:0] RESX = 0,
	parameter [10:0] RESY = 0
) (
	input clk,
	input [10:0] xin,
	input [10:0] yin,
	output in_enable,
	output [10:0] xout,
	output [10:0] yout,
	output [31:0] v
);
	reg [10:0] x,y;

	always @(posedge clk) begin
		x <= xin;
		y <= yin;
	end

	wire [31:0] stage_0_xout, stage_0_yout;
	mandelbrot_input_0 #(.RESX(RESX), .RESY(RESY)) input_0 (
		.xin(x),
		.yin(y),
		.xout(stage_0_xout),
		.yout(stage_0_yout)
	);
endmodule

// Convert input to normalized fixed point
module mandelbrot_input_0 #(
	parameter [10:0] RESX = 0,
	parameter [10:0] RESY = 0
	) (
	input [10:0] xin,
	input [10:0] yin,
	output [31:0] xout,
	output [31:0] yout
);
	wire [31:0] xfxp, yfxp;
	assign xfxp = {1'b0,xin,20'd0};
	assign yfxp = {1'b0,yin,20'd0};

	wire [31:0] RESXFXP, RESYFXP;
	assign RESXFXP = {1'b0,RESX,20'd0};
	assign RESYFXP = {1'b0,RESY,20'd0};

	assign xout = xfxp * (32'd1/RESXFXP);
	assign yout = yfxp * (32'd1/RESYFXP);
endmodule

// x*3.5, y*2
module mandelbrot_input_1 (
	input [31:0] xin,
	input [31:0] yin,
	output [31:0] xout,
	output [31:0] yout
);
	mandelbrot_fxp_mul xin_mul (xin, {1'b0,3'd3,1'b1,27'd0}, xout);
	assign yout = yin*2'd2;
endmodule

// x-2.5, y-1
module mandelbrot_input_2 (
	input [31:0] xin,
	input [31:0] yin,
	output [31:0] xout,
	output [31:0] yout
);
	assign xout = xin - {1'b0,3'd2,1'b1,27'd0};
	assign yout = yin - {1'b0,3'd1,28'd0};
endmodule

// x*x, y*y, x*y
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

// xx-yy, 2xy, xx+yy
module mandelbrot_compute_1 (
	input [31:0] xx,
	input [31:0] yy,
	input [31:0] xy,
	output [31:0] xxsubyy,
	output [31:0] xy2,
	output [31:0] xxaddyy
);
	assign xxsubyy = xx - yy;
	assign xy2 = xy * 2'd2;
	assign xxaddyy = xx + yy;
endmodule

// xxaddyy+x0, 2xy+y0
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

// TODO Just for fun, a reorder buffer could be added to the output
module mandelbrot_writeback (
	input [31:0] xxaddyy,
	input [31:0] imax
);

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

module mandelbrot_fifo #(parameter SIZE = 15) (
	input [31:0] clk,
	input [31:0] in,
	output [31:0] out
);
	reg [31:0] mem [SIZE:0];
	reg [3:0] p = 4'd0;
	always @(posedge clk) begin
		mem[p] <= in;
		p <= (p + 1'b1) % SIZE-1;
	end
	assign out = mem[p+1'b1];
endmodule

// Using fixed point, 1 sign bit + 8 integer bits, 23 decimal bits
// Coordinate input is 11x11 bits for a maximum output resolution of 2048x2048

module mandelbrot #(
	parameter [3:0] RANGE = 0,
	parameter [15:0] IMAX = 15
) (
	input clk,
	input [10:0] xin,
	input [10:0] yin,
	input [80:0] pin,
	output output_ready,
	output [80:0] pout
);
	// Unpack input
	wire unpacked_f;
	wire [31:0] unpacked_x,unpacked_y;
	wire [15:0] unpacked_i;
	assign unpacked_f = pin[80];
	assign unpacked_x = pin[79:48];
	assign unpacked_y = pin[47:16];
	assign unpacked_i = pin[15:0];

	// Clocked logic
	always @(posedge clk) begin
		// Input stage 0
		input_xin <= xin;
		input_yin <= yin;

		// Input stage 1
		input_1_xin <= input_0_xout;
		input_1_yin <= input_0_yout;

		// Input stage 2
		input_2_xin <= input_1_xout;
		input_2_yin <= input_1_yout;

		// Compute stage 0

		// Compute stage 1
		compute_1_xxin <= compute_xx;
		compute_1_yyin <= compute_yy;
		compute_1_xyin <= compute_xy;


		// Compute stage 2
		compute_2_xxsubyyin <= compute_xxsubyy;
		compute_2_xy2in <= compute_xy2;

		// Output stage 0
		output_xin <= compute_xout;
		output_yin <= compute_yout;

		// Output stage 1
		output_1_xxin <= output_xx;
		output_1_yyin <= output_yy;

		// Output stage 2
		output_2_xxaddyyin <= output_xxaddyy;

		// Flushing counter
		if (~output_ready)
			flush_counter <= flush_counter + 1'b1;
	end

	// Modules and connecting wires/regs
	reg [4:0] flush_counter = 0;
	assign output_ready = flush_counter > 8;

	mandelbrot_fifo #(5) staged_pxin (
		.clk(clk),
		.in(unpacked_x),
		.out(compute_xin)
	);
	mandelbrot_fifo #(5) staged_pyin (
		.clk(clk),
		.in(unpacked_y),
		.out(compute_yin)
	);
	mandelbrot_fifo #(10,15) staged_pi (
		.clk(clk),
		.in(unpacked_i),
		.out(output_2_iin)
	);
	mandelbrot_fifo #(10,0) staged_pf (
		.clk(clk),
		.in(unpacked_f),
		.out(output_2_fin)
	);
	mandelbrot_fifo #(4) staged_x0 (
		.clk(clk),
		.in(input_x0),
		.out(compute_2_x0in)
	);
	mandelbrot_fifo #(4) staged_y0 (
		.clk(clk),
		.in(input_y0),
		.out(compute_2_y0in)
	);
	mandelbrot_fifo #(4) staged_pxout (
		.clk(clk),
		.in(compute_xout),
		.out(pout[79:48])
	);
	mandelbrot_fifo #(4) staged_pyout (
		.clk(clk),
		.in(compute_yout),
		.out(pout[47:16])
	);

	reg [10:0] input_xin,input_yin;
	wire [31:0] input_0_xout,input_0_yout;
	mandelbrot_input_0 #(RANGE) input_0 (
		.xin(input_xin),
		.yin(input_yin),
		.xout(input_0_xout),
		.yout(input_0_yout)
	);

	reg [31:0] input_1_xin,input_1_yin;
	wire [31:0] input_1_xout,input_1_yout;
	mandelbrot_input_1 input_1 (
		.xin(input_1_xin),
		.yin(input_1_yin),
		.xout(input_1_xout),
		.yout(input_1_yout)
	);

	reg [31:0] input_2_xin,input_2_yin;
	wire [31:0] input_x0,input_y0;
	mandelbrot_input_2 input_2 (
		.xin(input_2_xin),
		.yin(input_2_yin),
		.xout(input_x0),
		.yout(input_y0)
	);

	wire [31:0] compute_xin,compute_yin,compute_xx,compute_yy,compute_xy;
	mandelbrot_compute_0 compute_0 (
		.x(compute_xin),
		.y(compute_yin),
		.xx(compute_xx),
		.yy(compute_yy),
		.xy(compute_xy)
	);

	reg [31:0] compute_1_xxin,compute_1_yyin,compute_1_xyin;
	wire [31:0] compute_xxsubyy,compute_xy2;
	mandelbrot_compute_1 compute_1 (
		.xx(compute_1_xxin),
		.yy(compute_1_yyin),
		.xy(compute_1_xyin),
		.xxsubyy(compute_xxsubyy),
		.xy2(compute_xy2)
	);

	reg [31:0] compute_2_xxsubyyin,compute_2_xy2in;
	wire [31:0] compute_2_x0in,compute_2_y0in,compute_xout,compute_yout;
	mandelbrot_compute_2 compute_2 (
		.xxsubyy(compute_2_xxsubyyin),
		.xy2(compute_2_xy2in),
		.x0(compute_2_x0in),
		.y0(compute_2_y0in),
		.x(compute_xout),
		.y(compute_yout)
	);

	reg [31:0] output_xin,output_yin;
	wire [31:0] output_xx,output_yy;
	mandelbrot_output_0 output_0 (
		.xin(output_xin),
		.yin(output_yin),
		.xxout(output_xx),
		.yyout(output_yy)
	);

	reg [31:0] output_1_xxin,output_1_yyin;
	wire [31:0] output_xxaddyy;
	mandelbrot_output_1 output_1 (
		.xin(output_1_xxin),
		.yin(output_1_yyin),
		.xxaddyy(output_xxaddyy)
	);

	reg [31:0] output_2_xxaddyyin;
	wire [15:0] output_2_iin;
	wire output_2_fin;
	mandelbrot_output_2 #(IMAX) output_2 (
		.xxaddyy(output_2_xxaddyyin),
		.iin(output_2_iin),
		.fin(output_2_fin),
		.iout(pout[15:0]),
		.fout(pout[80])
	);
endmodule

// Convert input to normalized fixed point
module mandelbrot_input_0 #(
	parameter [3:0] range = 2
	) (
	input [10:0] xin,
	input [10:0] yin,
	output [31:0] xout,
	output [31:0] yout
);
	wire [31:0] xfxp,yfxp;
	assign xfxp = {1'b0,xin,20'd0};
	assign yfxp = {1'b0,yin,20'd0};

	assign xout = xfxp >> range;
	assign yout = yfxp >> range;
endmodule

// x*3.5, y*2
module mandelbrot_input_1 (
	input [31:0] xin,
	input [31:0] yin,
	output [31:0] xout,
	output [31:0] yout
);
	mandelbrot_fxp_mul xin_mul (xin, {1'b0,8'd3,1'b1,22'd0}, xout);
	assign yout = yin*2'd2;
endmodule

// x-2.5, y-1
module mandelbrot_input_2 (
	input [31:0] xin,
	input [31:0] yin,
	output [31:0] xout,
	output [31:0] yout
);
	assign xout = xin - {1'b0,8'd2,1'b1,22'd0};
	assign yout = yin - {1'b0,8'd1,23'd0};
endmodule

// x*x, y*y, x*y
module mandelbrot_compute_0 (
	input [31:0] x,
	input [31:0] y,
	output [31:0] xx,
	output [31:0] yy,
	output [31:0] xy
);
	mandelbrot_fxp_mul compute_xx_mul (x, x, xx);
	mandelbrot_fxp_mul compute_yy_mul (y, y, yy);
	mandelbrot_fxp_mul xy_mul (x, y, xy);
endmodule

// xx-yy, 2xy
module mandelbrot_compute_1 (
	input [31:0] xx,
	input [31:0] yy,
	input [31:0] xy,
	output [31:0] xxsubyy,
	output [31:0] xy2
);
	assign xxsubyy = xx - yy;
	assign xy2 = xy * 2'd2;
endmodule

// x = xxsubyy+x0, y = 2xy+y0
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

// x*x, y*y
module mandelbrot_output_0 (
	input [31:0] xin,
	input [31:0] yin,
	output [31:0] xxout,
	output [31:0] yyout
);
	mandelbrot_fxp_mul output_xx_mul (xin, xin, xxout);
	mandelbrot_fxp_mul output_yy_mul (yin, yin, yyout);
endmodule

// xx+yy
module mandelbrot_output_1 (
	input [31:0] xin,
	input [31:0] yin,
	output [31:0] xxaddyy
);
	assign xxaddyy = xin + yin;
endmodule

module mandelbrot_output_2 #(parameter IMAX = 16) (
	input [31:0] xxaddyy,
	input [15:0] iin,
	input fin,
	output [15:0] iout,
	output fout
);
	wire a,b,c;
	assign a = xxaddyy[30:23] <= 8'd4;
	assign b = iin < IMAX;
	assign c = a && b;
	assign iout = iin + {15'd0,c && ~fin};
	assign fout = fin || ~c;
endmodule

module mandelbrot_fxp_mul (
	input [31:0] a,
	input [31:0] b,
	output [31:0] c
);
	wire [63:0] a_sx,b_sx,result;
	wire sign;
	assign a_sx = {{32{a[31]}},a};
	assign b_sx = {{32{b[31]}},b};
	assign result = a_sx * b_sx;
	assign sign = result[63];
	assign c = {sign,result[53:47],result[46:23]};
endmodule

module mandelbrot_fifo #(parameter SIZE = 15,parameter XLEN = 31) (
	input clk,
	input [XLEN:0] in,
	output [XLEN:0] out
);
	reg [XLEN:0] mem [SIZE:0];
	reg [3:0] p = 4'd0;
	always @(posedge clk) begin
		mem[p] <= in;
		p <= (p + 1'b1) % SIZE;
	end
	assign out = mem[(p+1'b1)%SIZE];
endmodule

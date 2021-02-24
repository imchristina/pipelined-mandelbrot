// Using fixed point, 1 sign bit + 3 integer bits, 28 decimal bits
// Coordinate input is 11x11 bits for a maximum output resolution of 2048x2048

module mandelbrot #(
	parameter [10:0] RESX = 0,
	parameter [10:0] RESY = 0,
	parameter [15:0] IMAX = 15
) (
	input clk,
	input [10:0] xin,
	input [10:0] yin,
	output reg next_in,
	output reg next_out,
	output reg [10:0] xout,
	output reg [10:0] yout,
	output reg [15:0] i
);
	// Clocked logic
	always @(posedge clk) begin
		// Only iterate input stages if not returning or if flushing pipeline
		if (~ret || flush) begin
			// Input stage 0
			input_xin <= xin;
			input_yin <= yin;

			// Input stage 1
			input_1_xin <= input_0_xout;
			input_1_yin <= input_0_yout;

			// Input stage 2
			input_2_xin <= input_1_xout;
			input_2_yin <= input_1_yout;
		end

		// Compute stage 0
		compute_xin <= ret && ~flush ? staged_x_2 : 32'd0;
		compute_yin <= ret && ~flush ? staged_y_2 : 32'd0;
		staged_x0_0 <= ret && ~flush ? staged_x0_5 : input_x0;
		staged_y0_0 <= ret && ~flush ? staged_y0_5 : input_y0;
		staged_i_0 <= ret && ~flush ? ret_i : 16'd0;

		// Compute stage 1
		compute_1_xxin <= compute_xx;
		compute_1_yyin <= compute_yy;
		compute_1_xyin <= compute_xy;
		staged_x0_1 <= staged_x0_0;
		staged_y0_1 <= staged_y0_0;
		staged_i_1 <= staged_i_0;

		// Compute stage 2
		compute_2_xxsubyyin <= compute_xxsubyy;
		compute_2_xy2in <= compute_xy2;
		compute_2_x0in <= staged_x0_1;
		compute_2_y0in <= staged_y0_1;
		staged_x0_2 <= staged_x0_1;
		staged_y0_2 <= staged_y0_1;
		staged_i_2 <= staged_i_1;

		// Output stage 0
		output_xin <= compute_xout;
		output_yin <= compute_yout;
		staged_x0_3 <= staged_x0_2;
		staged_y0_3 <= staged_y0_2;
		staged_i_3 <= staged_i_2;
		staged_x_0 <= compute_xout;
		staged_y_0 <= compute_yout;

		// Output stage 1
		output_1_xxin <= output_xx;
		output_1_yyin <= output_yy;
		staged_x0_4 <= staged_x0_3;
		staged_y0_4 <= staged_y0_3;
		staged_i_4 <= staged_i_3;
		staged_x_1 <= staged_x_0;
		staged_y_1 <= staged_y_0;

		// Output stage 2
		output_2_xxaddyyin <= output_xxaddyy;
		output_2_iin <= staged_i_4;
		staged_x0_5 <= staged_x0_4;
		staged_y0_5 <= staged_y0_4;
		staged_x_2 <= staged_x_1;
		staged_y_2 <= staged_y_1;

		// Module outputs
		next_in <= ret || flush;
		next_out <= ret && ~flush;
		if (~ret) begin
			xout <= staged_xin_out;
			yout <= staged_yin_out;
			i <= ret_i;
		end

		// Flushing counter
		if (flush)
			flush_counter <= flush_counter + 1'b1;
	end

	// Modules and connecting wires/regs
	reg [4:0] flush_counter = 0;
	wire flush;
	assign flush = flush_counter <= 9;

	wire [10:0] staged_xin_out,staged_yin_out;
	mandelbrot_fifo #(9,10) staged_xin (
		.clk(clk),
		.in(ret ? staged_xin_out : xin),
		.out(staged_xin_out)
	);
	mandelbrot_fifo #(9,10) staged_yin (
		.clk(clk),
		.in(ret ? staged_yin_out : yin),
		.out(staged_yin_out)
	);

	reg [10:0] input_xin,input_yin;
	wire [31:0] input_0_xout,input_0_yout;
	mandelbrot_input_0 #(RESX, RESY) input_0 (
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

	reg [31:0] staged_x0_0,staged_y0_0,staged_x0_1,staged_y0_1,
		staged_x0_2,staged_y0_2,staged_x0_3,staged_y0_3,staged_x0_4,
		staged_y0_4,staged_x0_5,staged_y0_5;
	reg [15:0] staged_i_0,staged_i_1,staged_i_2,staged_i_3,staged_i_4;

	reg [31:0] compute_xin,compute_yin;
	wire [31:0] compute_xx,compute_yy,compute_xy;
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

	reg [31:0] compute_2_xxsubyyin,compute_2_xy2in,compute_2_x0in,compute_2_y0in;
	wire [31:0] compute_xout,compute_yout;
	mandelbrot_compute_2 compute_2 (
		.xxsubyy(compute_2_xxsubyyin),
		.xy2(compute_2_xy2in),
		.x0(compute_2_x0in),
		.y0(compute_2_y0in),
		.x(compute_xout),
		.y(compute_yout)
	);

	reg [31:0] staged_x_0,staged_y_0,staged_x_1,staged_y_1,staged_x_2,
		staged_y_2;

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
	reg [15:0] output_2_iin;
	wire ret;
	wire [15:0] ret_i;
	mandelbrot_output_2 #(IMAX) output_2 (
		.xxaddyy(output_2_xxaddyyin),
		.i(output_2_iin),
		.ret(ret),
		.ipp(ret_i)
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
	wire [31:0] xfxp,yfxp;
	assign xfxp = {1'b0,xin,20'd0};
	assign yfxp = {1'b0,yin,20'd0};

	wire [31:0] RESXFXP,RESYFXP,XCOEFF,YCOEFF;
	assign RESXFXP = {1'b0,RESX,20'd0};
	assign RESYFXP = {1'b0,RESY,20'd0};
	assign XCOEFF = {1'b0,3'd1,28'd0}/RESXFXP;
	assign YCOEFF = {1'b0,3'd1,28'd0}/RESYFXP;

	assign xout = xfxp * XCOEFF;
	assign yout = yfxp * YCOEFF;
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

// x = xxaddyy+x0, y = 2xy+y0
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

// TODO Reorder buffer on output
module mandelbrot_output_2 #(parameter IMAX = 16) (
	input [31:0] xxaddyy,
	input [15:0] i,
	output ret,
	output [15:0] ipp
);
	wire a,b;
	// Signed compare xxaddyy <= 4
	assign a = (xxaddyy <= {1'b0,3'd4,27'd0} || xxaddyy[31]);
	assign b = i < IMAX;
	assign ret = a && b;
	assign ipp = i + 1'b1;
endmodule

module mandelbrot_fxp_mul (
	input [31:0] a,
	input [31:0] b,
	output [31:0] c
);
	wire [63:0] a_sx,b_sx,result;
	assign a_sx = {{32{a[31]}},a};
	assign b_sx = {{32{b[31]}},b};
	assign result = a_sx * b_sx;
	assign c = {result[63],result[58:28]};
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

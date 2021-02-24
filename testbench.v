`include "pipelined-mandelbrot.v"
`define RESX 128
`define RESY 128
`define IMAX 2

module testbench ();
	reg clk = 0;
	always #1 clk = ~clk;

    wire next_in,next_out;
    wire [10:0] xout,yout;
    wire [15:0] i;

	reg [10:0] xin = 0,yin = 0;
	always @(negedge clk) begin
		if (next_in) begin
			xin <= (xin + 1) % `RESX;
			if (xin == 0)
				yin <= (yin + 1) % `RESY;
		end
	end

	mandelbrot #(`RESX,`RESY,`IMAX) mandelbrot_test (
        .clk(clk),
        .xin(xin),
        .yin(yin),
        .next_in(next_in),
		.next_out(next_out),
        .xout(xout),
        .yout(yout),
        .i(i)
    );

	testbench_pipeline mandelbrot_pipeline_test ();

	integer f;
	initial begin
		f = $fopen("output.ppm", "wb");
		$fwrite(f, "P3\n%0d %0d\n%0d\n",`RESX,`RESY,`IMAX);
		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);
		#100000 $finish;
	end

	reg f_done = 0;
	always @(posedge clk) begin
		if (next_out && ~f_done) begin
			$fwrite(f,"%0d %0d %0d ",i,i,i);
			if (xout == `RESX-1 && yout == `RESY-1)
				f_done <= 1;
		end
	end
endmodule

// Just the fixed-function pipeline bits with a static input for easy verification
module testbench_pipeline ();
	localparam xin = 11'd0;
	localparam yin = 11'd0;
	mandelbrot_input_0 #(`RESX,`RESY) input_0 (
			.xin(xin),
			.yin(yin),
			.xout(input_1_xin),
			.yout(input_1_yin)
	);
	wire [31:0] input_1_xin,input_1_yin;
	mandelbrot_input_1 input_1 (
		.xin(input_1_xin),
		.yin(input_1_yin),
		.xout(input_2_xin),
		.yout(input_2_yin)
	);
	wire [31:0] input_2_xin,input_2_yin,x0,y0;
	mandelbrot_input_2 input_2 (
		.xin(input_2_xin),
		.yin(input_2_yin),
		.xout(x0),
		.yout(y0)
	);
	mandelbrot_compute_0 compute_0 (
			.x(0),
			.y(0),
			.xx(compute_1_xxin),
			.yy(compute_1_yyin),
			.xy(compute_1_xyin)
	);
	wire [31:0] compute_1_xxin,compute_1_yyin,compute_1_xyin;
	mandelbrot_compute_1 compute_1 (
		.xx(compute_1_xxin),
		.yy(compute_1_yyin),
		.xy(compute_1_xyin),
		.xxsubyy(compute_2_xxsubyyin),
		.xy2(compute_2_xy2in)
	);
	wire [31:0] compute_2_xxsubyyin,compute_2_xy2in;
	mandelbrot_compute_2 compute_2 (
			.xxsubyy(compute_2_xxsubyyin),
			.xy2(compute_2_xy2in),
			.x0(x0),
			.y0(y0),
			.x(compute_3_xin),
			.y(compute_3_yin)
	);
	wire [31:0] compute_3_xin,compute_3_yin;
	mandelbrot_output_0 output_0 (
		.xin(compute_3_xin),
		.yin(compute_3_yin),
		.xxout(compute_4_xxin),
		.yyout(compute_4_yyin)
	);
	wire [31:0] compute_4_xxin,compute_4_yyin;
	mandelbrot_output_1 output_1 (
			.xin(compute_4_xxin),
			.yin(compute_4_yyin),
			.xxaddyy()
	);
endmodule

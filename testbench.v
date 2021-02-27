`include "mandelbrot.v"
`define RESX 32
`define RESY 32
`define IMAX 8

module testbench ();
	reg clk = 0;
	always #1 clk = ~clk;

    wire output_ready;
    wire [80:0] pin,pout;
	reg [80:0] fb [`RESX:0][`RESY:0];

	reg [10:0] xout=0,yout=0;
	always @(posedge clk) begin
		if (output_ready) begin
			fb[xout][yout] <= pout;
		end
	end

	reg [10:0] xin = 0,yin = 0;
	reg fb_init = 1'b0;
	always @(negedge clk) begin
		xin <= xin + 1;
		if (xin == `RESX-1) begin
			yin <= (yin + 1) % `RESY;
			xin <= 0;
		end
		if (output_ready) begin
			xout <= xout + 1;
			if (xout >= `RESX-1) begin
				yout <= yout+1;
				if (yout >= `RESY-1) begin
					fb_init <= 1;
					yout <= 0;
				end
				xout <= 0;
			end
		end
	end

	assign pin = fb_init ? fb[xin][yin] : '0;

	mandelbrot #(`RESX,`RESY,`IMAX) mandelbrot_test (
        .clk(clk),
        .xin(xin),
        .yin(yin),
		.output_ready(output_ready),
		.pin(pin),
        .pout(pout)
    );

	testbench_pipeline mandelbrot_pipeline_test ();

	reg [15:0] v;
	integer f,x,y;
	initial begin
		f = $fopen("output.ppm", "wb");
		$fwrite(f, "P3\n%0d %0d\n%0d\n",`RESX,`RESY,`IMAX);
		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);
		#100000 begin
			for (x=0;x<`RESX;x++) begin
				for (y=0;y<`RESY;y++) begin
					v = fb[x][y][15:0];
					if (v === 16'bxxxxxxxxxxxxxxxx)
						$fwrite(f,"%0d 0 0 ",`IMAX);
					else
						$fwrite(f,"%0d %0d %0d ",v,v,v);
				end
			end
			$finish;
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

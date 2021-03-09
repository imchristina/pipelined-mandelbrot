`include "mandelbrot.v"
`define RESX 32
`define RESY 32
`define RANGE 2
`define IMAX 16

module testbench ();
	reg clk = 0;
	always #1 clk = ~clk;

    wire output_ready;
    wire [80:0] pin,pout;
	reg [80:0] fb [`RESX:0][`RESY:0];

	reg [10:0] xout=0,yout=0;
	always @(negedge clk) begin
		if (output_ready) begin
			fb[xout][yout] <= pout;
		end
	end

	reg [10:0] xin = 0,yin = 0;
	reg fb_init = 1'b0;
	always @(posedge clk) begin
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

	assign pin = fb_init ? fb[xin][yin] : 81'd0;

	mandelbrot #(`RANGE,`IMAX) mandelbrot_test (
        .clk(clk),
        .xin(xin),
        .yin(yin),
		.output_ready(output_ready),
		.pin(pin),
        .pout(pout)
    );

	//testbench_pipeline mandelbrot_pipeline_test ();

	reg [15:0] v;
	integer f,x,y;
	initial begin
		f = $fopen("output.ppm", "wb");
		$fwrite(f, "P3\n%0d %0d\n%0d\n",`RESX,`RESY,`IMAX);
		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);
		#100000 begin
			for (y=0;y<`RESY;y++) begin
				for (x=0;x<`RESX;x++) begin
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

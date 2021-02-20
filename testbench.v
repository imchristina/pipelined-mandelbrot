`include "pipelined-mandelbrot.v"
`define RESX 32
`define RESY 32

module testbench ();
	reg clk = 0;
	always #1 clk = ~clk;

    wire in_enable;
    wire [10:0] xout,yout;
    wire [31:0] v;

	reg [10:0] xin = 0,yin = 0;
	always @(negedge clk) begin
		if (in_enable) begin
			xin = (xin + 1) % `RESX;
			yin = (yin + 1) % `RESY;
		end
	end

	mandelbrot #(`RESX,`RESY) mandelbrot_test(
        .clk(clk),
        .xin(xin),
        .yin(yin),
        .in_enable(in_enable),
        .xout(xout),
        .yout(yout),
        .v(v)
    );

	initial begin
		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);
		#10000 $finish;
	end
endmodule

`include "pipelined-mandelbrot.v"

module testbench ();
	reg clk = 0;
	always #1 clk = ~clk;

    wire in_enable;
    wire [10:0] xout,yout;
    wire [31:0] v;

	mandelbrot #(.RESX(32),.RESY(32)) mandelbrot_test(
        .clk(clk),
        .xin(11'd16),
        .yin(11'd16),
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

filename="pipelined-mandelbrot.v"

rm testbench.vvp
rm testbench.vcd
iverilog -s testbench -o testbench.vvp $filename
vvp testbench.vvp
gtkwave testbench.vcd

filename="testbench.v"

iverilog -s testbench -o testbench.vvp $filename
vvp testbench.vvp
gtkwave testbench.vcd
rm testbench.vvp
rm testbench.vcd

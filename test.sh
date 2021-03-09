filename="testbench.v"

iverilog -s testbench -o /tmp/testbench.vvp $filename
(cd /tmp && vvp testbench.vvp)
mv /tmp/output.ppm output.ppm
gtkwave /tmp/testbench.vcd
rm /tmp/testbench.vvp
rm /tmp/testbench.vcd

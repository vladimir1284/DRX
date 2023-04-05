ghdl --remove
ghdl --clean

ghdl -a ./data_gen.vhd
ghdl -a ./data_gen_tb.vhd

ghdl -e data_gen_tb

#ghdl -r cic_tb --stop-time=20ms --vcd=./cic.vcd
ghdl -r data_gen_tb --max-stack-alloc=1048576 --ieee-asserts=disable --assert-level=error --stop-time=400ms --vcd=./data.vcd

gtkwave -g ./data.vcd

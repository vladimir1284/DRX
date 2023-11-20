ghdl -a LoopCounter_v1_0_M00_AXIS.vhd 
ghdl -a LoopCounter_v1_0_M00_AXIS_tb.vhd 
ghdl -e LoopCounter_v1_0_M00_AXIS_tb
ghdl -r LoopCounter_v1_0_M00_AXIS_tb --vcd=sim.vcd --stop-time=10us
# gtkwave sim.vcd
gtkwave signal_config.gtkw
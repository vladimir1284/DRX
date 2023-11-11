ghdl -a LoopCounterConfig_v1_0_S00_AXI.vhd 
ghdl -a LoopCounterConfig_v1_0_S00_AXI_tb.vhd 
ghdl -e LoopCounterConfig_v1_0_S00_AXI_tb
ghdl -r LoopCounterConfig_v1_0_S00_AXI_tb --vcd=sim.vcd --stop-time=100ns
#gtkwave sim.vcd
gtkwave signal_config.gtkw
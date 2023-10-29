ghdl -a counterConfig_v1_0_S00_AXI.vhd 
ghdl -a counterConfig_v1_0_S00_AXI_tb.vhd 
ghdl -e counterConfig_v1_0_S00_AXI_tb
ghdl -r counterConfig_v1_0_S00_AXI_tb --vcd=sim.vcd --stop-time=80ns
#gtkwave sim.vcd
gtkwave signal_config.gtkw
ghdl -a counterSimulator_v1_0_M00_AXIS.vhd
ghdl -a counterSimulator_v1_0_M00_AXIS_tb.vhd 
ghdl -e counterSimulator_v1_0_M00_AXIS_tb
ghdl -r counterSimulator_v1_0_M00_AXIS_tb --vcd=sim.vcd --stop-time=1000ns
#gtkwave sim.vcd
gtkwave signal_config.gtkw
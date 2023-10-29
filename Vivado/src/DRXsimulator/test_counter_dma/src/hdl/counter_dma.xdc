# ----------------------------------------------------------------------------
# User LEDs - Bank 33
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN T22 [get_ports {Dout_0[0]}]
set_property PACKAGE_PIN T21 [get_ports {Dout_0[1]}]
set_property PACKAGE_PIN U22 [get_ports {Dout_0[2]}]
set_property PACKAGE_PIN U21 [get_ports {Dout_0[3]}]
set_property PACKAGE_PIN V22 [get_ports {Dout_0[4]}]
set_property PACKAGE_PIN W22 [get_ports {Dout_0[5]}]
set_property PACKAGE_PIN U19 [get_ports {Dout_0[6]}]
set_property PACKAGE_PIN U14 [get_ports {Dout_0[7]}]

# ----------------------------------------------------------------------------
# IOSTANDARD Constraints
#
# Note that these IOSTANDARD constraints are applied to all IOs currently
# assigned within an I/O bank.  If these IOSTANDARD constraints are
# evaluated prior to other PACKAGE_PIN constraints being applied, then
# the IOSTANDARD specified will likely not be applied properly to those
# pins.  Therefore, bank wide IOSTANDARD constraints should be placed
# within the XDC file in a location that is evaluated AFTER all
# PACKAGE_PIN constraints within the target bank have been evaluated.
#
# Un-comment one or more of the following IOSTANDARD constraints according to
# the bank pin assignments that are required within a design.
# ----------------------------------------------------------------------------

# Note that the bank voltage for IO Bank 33 is fixed to 3.3V on ZedBoard.
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]]


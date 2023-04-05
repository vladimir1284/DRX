# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct /home/vladimir/Documentos/LADETEC/DRX/Tutorial/labs/test_zed_mem/design_1_wrapper/platform.tcl
# 
# OR launch xsct and run below command.
# source /home/vladimir/Documentos/LADETEC/DRX/Tutorial/labs/test_zed_mem/design_1_wrapper/platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {design_1_wrapper}\
-hw {/home/vladimir/Documentos/LADETEC/DRX/Tutorial/labs/test_zed_mem/design_1_wrapper.xsa}\
-out {/home/vladimir/Documentos/LADETEC/DRX/Tutorial/labs/test_zed_mem}

platform write
domain create -name {standalone_ps7_cortexa9_0} -display-name {standalone_ps7_cortexa9_0} -os {standalone} -proc {ps7_cortexa9_0} -runtime {cpp} -arch {32-bit} -support-app {hello_world}
platform generate -domains 
platform active {design_1_wrapper}
domain active {zynq_fsbl}
domain active {standalone_ps7_cortexa9_0}
platform generate -quick
platform generate
bsp reload
platform generate -domains 

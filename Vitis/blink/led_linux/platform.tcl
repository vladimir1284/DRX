# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct /home/vladimir/Documentos/LADETEC/DRX/Tutorial/labs/test_zed_mem/led_linux/platform.tcl
# 
# OR launch xsct and run below command.
# source /home/vladimir/Documentos/LADETEC/DRX/Tutorial/labs/test_zed_mem/led_linux/platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {led_linux}\
-hw {/home/vladimir/Documentos/LADETEC/DRX/Tutorial/labs/test_zed_mem/design_1_wrapper.xsa}\
-proc {ps7_cortexa9} -os {linux} -out {/home/vladimir/Documentos/LADETEC/DRX/Tutorial/labs/test_zed_mem}

platform write
platform active {led_linux}
platform config -remove-boot-bsp
platform write
platform active {led_linux}
domain config -rootfs {/home/vladimir/LAPTOP/vladimir/Documentos/SOFTWARE/Petalinux/proyects/zedboard_leds/images/linux/rootfs.tar.gz}
platform write
platform active {led_linux}
domain config -bif {/home/vladimir/LAPTOP/vladimir/Documentos/SOFTWARE/Petalinux/proyects/zedboard_leds/images/linux/bootgen.bif}
platform write
domain config -boot {/home/vladimir/LAPTOP/vladimir/Documentos/SOFTWARE/Petalinux/proyects/zedboard_leds/images/linux}
platform write
domain config -rootfs {}
platform write
platform generate
platform clean
platform generate
platform active {led_linux}
platform clean

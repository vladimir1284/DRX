# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct /home/vladimir/Documentos/LADETEC/DRX/Work/DRX/Vitis/DRXsimulator/test_counter_config/counter_dma_wrapper/platform.tcl
# 
# OR launch xsct and run below command.
# source /home/vladimir/Documentos/LADETEC/DRX/Work/DRX/Vitis/DRXsimulator/test_counter_config/counter_dma_wrapper/platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {counter_dma_wrapper}\
-hw {/home/vladimir/Documentos/LADETEC/DRX/Tutorial/labs/counter_dma/counter_dma_wrapper.xsa}\
-out {/home/vladimir/Documentos/LADETEC/DRX/Work/DRX/Vitis/DRXsimulator/test_counter_config}

platform write
domain create -name {standalone_ps7_cortexa9_0} -display-name {standalone_ps7_cortexa9_0} -os {standalone} -proc {ps7_cortexa9_0} -runtime {cpp} -arch {32-bit} -support-app {hello_world}
platform generate -domains 
platform active {counter_dma_wrapper}
domain active {zynq_fsbl}
domain active {standalone_ps7_cortexa9_0}
platform generate -quick
platform generate
platform config -updatehw {/home/vladimir/Documentos/LADETEC/DRX/Tutorial/labs/counter_dma/counter_dma_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/vladimir/Documentos/LADETEC/DRX/Tutorial/labs/counter_dma/counter_dma_wrapper.xsa}
platform generate -domains 
platform active {counter_dma_wrapper}
platform config -updatehw {/home/vladimir/Documentos/LADETEC/DRX/Tutorial/labs/counter_dma/counter_dma_wrapper.xsa}
platform generate -domains 
platform active {counter_dma_wrapper}
platform config -updatehw {/home/vladimir/Documentos/LADETEC/DRX/Tutorial/labs/counter_dma/dma_github_wrapper.xsa}
platform generate -domains 

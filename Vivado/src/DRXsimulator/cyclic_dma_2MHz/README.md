# Cyclic DMA 2MHz
Proyecto para probar la comunicación entre S y PL a generando muestras con el 
LoopCounter a 2MHz.

Se configura:
- Cells in PRT (cuantas celdas en un rayo)
- Cells to capture (cuantas celdas pasan al PS)
- Habilitar o deshabilitar el contador

## Run script
Vivado/2022.2/bin/vivado -mode batch -source dcm_dma_cyclic.tcl
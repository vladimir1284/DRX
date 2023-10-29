# Counter Config
Proyecto para probar en hardware el IP que simula el dato adquirido por medio de un contador contador.
Se pasan los datos generados por el contador hacia la memoria del PS usando DMA.

Permite que se configure:
- PRF (cuantas celdas)
- Habilitar o deshabilitar el contador

## Run script
Vivado/2022.2/bin/vivado -mode batch -source counter_dma.tcl 

## Block design
![image](https://github.com/vladimir1284/DRX/blob/main/Vivado/src/DRXsimulator/test_counter_dma/counter_dma.png)
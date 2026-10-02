# Simulador del flujo de datos del DRX

En esta carpeta se incluyen todos los diseños de hardware, módulos e IP cores del trabajo asociado al simulador del DRX (Receptor Digital de Radar).

El objetivo principal es generar un flujo continuo y controlado de datos (muestras IQ / contadores correlativos de celdas) en la FPGA (PL) y transferirlos de forma eficiente mediante AXI DMA hacia la memoria RAM del Procesador (PS), para luego enviarlos por la red Ethernet hacia la computadora de procesamiento final. Esto permite medir tasas de transferencia reales y validar que la información llegue sin pérdida de paquetes ni errores al destino.

---

## 📚 Documentación de IPs y Arquitectura de Hardware

Cada IP core desarrollado cuenta con su propia guía de producto detallada en español, elaborada según los estándares de documentación de Xilinx/AMD Vivado:

### 1. Documentación de Módulos e IP Cores Customizados
- [**LoopCounter_v1_0**](ip_repo/LoopCounter_1_0/README.md): IP Core con interfaz AXI4-Stream Master para la simulación de celdas de distancia dentro de un período de repetición de pulso (PRT).
- [**LoopCounterConfig_v1_0**](ip_repo/LoopCounterConfig_1_0/README.md): IP Core con interfaz AXI4-Lite Slave para la configuración en tiempo real de los parámetros del `LoopCounter` (Habilitación, celdas por PRT y celdas a transmitir).
- [**counterSimulator_v1_0**](ip_repo/counterSimulator_1_0/README.md): IP Core AXI4-Stream Master para la generación de patrones numéricos contiguos de prueba de ancho de banda.
- [**counterConfig_v1_0**](ip_repo/counterConfig_1_0/README.md): IP Core AXI4-Lite Slave para el control del simulador de contador desde el PS.
- [**data_gen**](../data_gen/README.md): Módulo generador de tramas sintéticas de muestras IQ de radar de 64 bits con cabecera de sincronización (`0xCAFEFFFFFFFFFFFF`).

### 2. Diagramas de Sistema e Interacción
- [**Arquitectura Global del Sistema e Interacción entre IPs**](docs/System_Architecture.md): Documento integral que detalla los diagramas de bloques del sistema, el flujo de información entre el PS y la PL, y las matrices de interconexión entre IP Cores customizados, AXI DMA y memoria DDR.

---

## 🛠️ Diseños de Referencia e Proyectos de Prueba

En este directorio se encuentran los scripts en Tcl para regenerar los diseños de bloques (*Block Design*) en Vivado:

- **`cyclic_dma_2MHz/`**: Proyecto para evaluar la comunicación entre PL y PS generando muestras con `LoopCounter` a 2MHz y canalizándolas mediante DMA Cíclico (`dcm_dma_cyclic.tcl`).
- **`test_counter_dma/`**: Proyecto para probar en hardware la transferencia por DMA de datos generados por el simulador contador hacia la memoria del PS (`counter_dma.tcl`).
- **`test_conter_config/`**: Proyecto para probar la comunicación AXI4-Lite y registros del configurador del contador (`test_counterConfig.tcl`).

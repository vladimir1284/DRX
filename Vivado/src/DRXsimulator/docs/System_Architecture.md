# Documentación de Arquitectura del Sistema e Interacción entre IP Cores

## 1. Introducción y Propósito del Sistema

El simulador del flujo de datos del **DRX** (Receptor Digital de Radar) está diseñado para sintetizar y transmitir patrones de prueba y muestras IQ desde la lógica programable (**PL** - FPGA Zynq-7000) hacia el sistema de procesamiento (**PS** - Procesador ARM Cortex-A9), escribiendo las ráfagas directamente en la memoria RAM (DDR) vía AXI DMA (*Direct Memory Access*). Desde el PS, los datos son empaquetados y retransmitidos a través de la red Ethernet hacia la estación de procesamiento central.

El propósito principal de esta arquitectura es evaluar el ancho de banda, la latencia de transferencia y validar que la información fluya sin pérdida de paquetes ni corrupción de muestras a altas tasas de adquisición (p. ej. a $2\text{ MHz}$).

---

## 2. Diagrama de Arquitectura Global e Interconexión de IPs

```
+----------------------------------------------------------------------------------------------------+
|                                      ZYNQ-7000 PROCESSING SYSTEM                                   |
|                                                                                                    |
|  +--------------------------------+                  +------------------------------------------+  |
|  |  Aplicación Software / Kernel  |                  |        Memoria Principal (DDR RAM)        |  |
|  |   (Driver AXI-Lite & DMA)      |                  |   [Buffers Cíclicos de Recepción S2MM]   |  |
|  +--------------------------------+                  +------------------------------------------+  |
|                 |                                                          ^                       |
+-----------------|----------------------------------------------------------|-----------------------+
                  |                                                          |
                  | AXI4-Lite (GP0 Master)                                   | AXI4 Memory Mapped
                  v                                                          | (HP0 High Performance)
+----------------------------------------------------------------------------|-----------------------+
| PL (LOGICA PROGRAMABLE FPGA)                                               |                       |
|                                                                            |                       |
|   +---------------------------------------+                                |                       |
|   |         AXI INTERCONNECT              |                                |                       |
|   +---------------------------------------+                                |                       |
|        |                             |                                     |                       |
|        | AXI4-Lite (Control)         | AXI4-Lite (Control)                 |                       |
|        v                             v                                     |                       |
|   +------------------------+    +--------------------+                     |                       |
|   | LoopCounterConfig_v1_0 |    | counterConfig_v1_0 |                     |                       |
|   | (IP Config Registros)  |    | (IP Config Regs)   |                     |                       |
|   +------------------------+    +--------------------+                     |                       |
|        |                             |                                     |                       |
|        | Senales de                  | Senales de                          |                       |
|        | Control Paralelo            | Control Paralelo                    |                       |
|        v                             v                                     |                       |
|   +------------------------+    +-----------------------+                  |                       |
|   |    LoopCounter_v1_0    |    | counterSimulator_v1_0 |                  |                       |
|   | (Generador de Celdas)  |    |  (Generador Cuentas)  |                  |                       |
|   +------------------------+    +-----------------------+                  |                       |
|        |                             |                                     |                       |
|        | AXI4-Stream Master          | AXI4-Stream Master                  |                       |
|        +------------------+----------+                                     |                       |
|                           |                                                |                       |
|                           v AXI4-Stream (M00_AXIS)                         |                       |
|                 +------------------+                                       |                       |
|                 | AXI DIRECT       |                                       |                       |
|                 | MEMORY ACCESS    |---------------------------------------+                       |
|                 | (AXI DMA S2MM)   |                                       |                       |
|                 +------------------+                                       |                       |
+----------------------------------------------------------------------------------------------------+
```

---

## 3. Flujo de Información e Interacción entre Módulos

El flujo de información y control opera en dos planos claramente diferenciados:

### Plano A: Control y Configuración (Flujo Descendente / PS -> PL)
1. **Inicialización en Software**: La aplicación ejecutable en el PS inicializa los mapas de dirección base AXI4-Lite asignados a `LoopCounterConfig_v1_0` o `counterConfig_v1_0`.
2. **Programación de Parámetros**:
   - Para el modo celdas radar: Escribe en `slv_reg1` el número de celdas por PRT (`CELLS_IN_PRT`) y en `slv_reg2` las celdas activas a enviar (`CELLS_TO_SEND`).
   - Para el modo contador lineal: Escribe en `slv_reg2` la cuenta máxima por ráfaga (`max_count`).
3. **Activación de Generación**: Escribe el bit `0` de `slv_reg0` / `slv_reg1` (`ENABLE = '1'`).
4. **Respuesta en Hardware**: El IP de configuración deserializa los datos AXI4-Lite y activa inmediatamente las líneas directas de habilitación y parámetros de control hacia el IP de generación (`LoopCounter_v1_0` / `counterSimulator_v1_0`).

### Plano B: Generación y Transferencia de Datos (Flujo Ascendente / PL -> PS)
1. **Mapeo de Paquetes AXI4-Stream**:
   - Al estar habilitado (`ENABLE = '1'`), el IP generador (`LoopCounter_v1_0`) valida la consistencia de parámetros (`VALID_CONFIG = '1'`) e inicia su máquina de estados (FSM).
   - Genera la primera muestra con el ID consecutivo de la ráfaga/rayo (`transaction_counter`).
   - Genera las subsecuentes muestras del contador de celdas ($1, 2, \dots, N$).
   - Marca el fin del paquete asertando la señal `M_AXIS_TLAST = '1'` en la muestra $N$.
2. **Transferencia DMA (S2MM)**:
   - El core **AXI DMA** recibe el flujo de datos AXI4-Stream en su puerto esclavo `S_AXIS_S2MM`.
   - Realiza un *handshake* continuo mediante las señales `TVALID` y `TREADY`.
   - Mueve las palabras mediante ráfagas de alta velocidad AXI4 Memory Mapped (vía puerto High Performance `HP0`) hacia los *buffers* de la memoria DDR RAM del Zynq PS.
3. **Atención por Interrupción y Procesamiento**:
   - Al detectar la finalización de un bloque o cuadro mediante `TLAST` (o transferencia de anillo de descriptores en DMA cíclico), el AXI DMA puede notificar al procesador mediante una interrupción (IRQ).
   - El programa en el PS lee los datos recibidos desde la memoria DDR y los envía a la red Ethernet.

---

## 4. Matriz de Conexiones entre IP Cores Customizados

### Conexión 1: `LoopCounterConfig_v1_0` $\longrightarrow$ `LoopCounter_v1_0`
| Puerto Salida (`LoopCounterConfig`) | Puerto Entrada (`LoopCounter`) | Tipo / Ancho | Descripción |
| :--- | :--- | :--- | :--- |
| `ENABLE` | `m00_ENABLE` | `std_logic` | Habilitador global y reset de la FSM. |
| `CELLS_IN_PRT` | `m00_CELLS_IN_PRT` | `std_logic_vector(15:0)` | Tamaño total del período de pulso. |
| `CELLS_TO_SEND` | `m00_CELLS_TO_SEND` | `std_logic_vector(15:0)` | Cantidad de muestras activas por ráfaga. |

### Conexión 2: `counterConfig_v1_0` $\longrightarrow$ `counterSimulator_v1_0`
| Puerto Salida (`counterConfig`) | Puerto Entrada (`counterSimulator`) | Tipo / Ancho | Descripción |
| :--- | :--- | :--- | :--- |
| `s00_enable` | `m00_enable` | `std_logic` | Habilitación del generador AXI4-Stream. |
| `s00_max_count` | `m00_max_count` | `std_logic_vector(15:0)` | Límite de conteo / palabras por ráfaga. |
| `s00_freq_div` | *(Lógica de reloj en PL)* | `std_logic` | Selector de divisor de frecuencia. |

### Conexión 3: IP Generador $\longrightarrow$ AXI DMA
| Puerto Salida Generador (`M00_AXIS`) | Puerto Entrada AXI DMA | Tipo / Ancho | Descripción |
| :--- | :--- | :--- | :--- |
| `m00_axis_tdata` | `S_AXIS_S2MM_tdata` | `std_logic_vector(31:0)` | Bus de datos primario. |
| `m00_axis_tvalid` | `S_AXIS_S2MM_tvalid` | `std_logic` | Indicador de dato válido. |
| `m00_axis_tlast` | `S_AXIS_S2MM_tlast` | `std_logic` | Delimitador de paquete/trama. |
| `m00_axis_tready` (Entrada) | `S_AXIS_S2MM_tready` (Salida) | `std_logic` | Aceptación de transferencia por el DMA. |

---

## 5. Diseños de Referencia Incluidos en el Repositorio

El proyecto incluye scripts TCL de construcción de hardware en `Vivado/src/DRXsimulator/` para desplegar las siguientes arquitecturas de prueba:

1. **`test_conter_config`** (`test_counterConfig.tcl`):
   - Proyecto para verificación de lectura/escritura de registros y control de estado de `counterConfig_v1_0` desde Zynq PS.
2. **`test_counter_dma`** (`counter_dma.tcl`):
   - Sistema de prueba integrando `counterConfig_v1_0` + `counterSimulator_v1_0` + **AXI DMA** para transferencia contigua a DDR.
3. **`cyclic_dma_2MHz`** (`dcm_dma_cyclic.tcl`):
   - Proyecto completo de evaluación con el IP **LoopCounter** operando a $2\text{ MHz}$ para transferencias cíclicas por DMA hacia la memoria RAM.

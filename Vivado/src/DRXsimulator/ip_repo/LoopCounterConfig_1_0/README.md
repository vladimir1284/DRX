# Guía del Producto: LoopCounterConfig v1.0 IP Core

## 1. Resumen General (Overview)

El IP Core **LoopCounterConfig_v1_0** es un controlador con interfaz esclava **AXI4-Lite Slave (S00_AXI)** diseñado para la configuración dinámica y el control en tiempo real del módulo simulador de celdas **LoopCounter_v1_0** en la FPGA.

Permite que el procesador (PS - *Processing System*, ejecute Linux/PetaLinux o aplicaciones bare-metal) programe mediante accesos a memoria mapped (MMIO) los parámetros fundamentales de simulación de celdas de radar: habilitación del generador, cantidad total de celdas por PRT y cantidad de celdas a adquirir.

### Características Clave
- **Interfaz AXI4-Lite Slave**: Mapeo de registros de 32 bits conforme a las especificaciones AXI4-Lite.
- **Acceso en Lectura/Escritura (R/W)**: Todos los registros de configuración pueden ser leídos para verificación o modificados al vuelo por software.
- **Control Directo de Salidas**: Conexión punto a punto de las salidas registradas (`ENABLE`, `CELLS_IN_PRT`, `CELLS_TO_SEND`) hacia el IP de procesamiento en PL.
- **Driver de Software Incluido**: Código fuente en C (`LoopCounterConfig.h`, `LoopCounterConfig.c`) autogenerado para integración directa en aplicaciones Vitis / PetaLinux.

---

## 2. Diagrama de Bloques y Arquitectura Interna

```
              +-------------------------------------------------------------------+
              |                     LoopCounterConfig_v1_0                        |
              |                                                                   |
              |   +-----------------------+     +-----------------------------+   |
  S00_AXI ===>|---| Interfaz AXI4-Lite    |---->| Registros de Control/Config |---|===> ENABLE (slv_reg0[0])
 (32-bit)     |   | Decodificador Dirección|     | (slv_reg0, reg1, reg2, reg3)|---|===> CELLS_IN_PRT (slv_reg1[15:0])
              |   +-----------------------+     +-----------------------------+   |===> CELLS_TO_SEND (slv_reg2[15:0])
              +-------------------------------------------------------------------+
```

El módulo recibe transacciones AXI4-Lite compuestas por direcciones de 4 bits (`S_AXI_AWADDR`, `S_AXI_ARADDR`) y datos de 32 bits (`S_AXI_WDATA`, `S_AXI_RDATA`). Las escrituras en registros son decodificadas y almacenadas sincrónicamente con `s00_axi_aclk`.

---

## 3. Parámetros Genéricos (Generics)

| Nombre del Genérico | Tipo | Valor por Defecto | Descripción |
| :--- | :--- | :--- | :--- |
| **C_S00_AXI_DATA_WIDTH** | `integer` | `32` | Ancho del bus de datos AXI4-Lite (fijo en 32 bits). |
| **C_S00_AXI_ADDR_WIDTH** | `integer` | `4` | Ancho del bus de direcciones AXI4-Lite (4 bits para direccionar 4 registros de 32 bits). |
| **M00_CELLS_DATA_WIDTH** / **CELLS_DATA_WIDTH** | `integer` | `16` | Ancho en bits de los campos de celdas (16 bits por defecto). |

---

## 4. Mapas de Registros (Register Map)

El espacio de direcciones del IP consta de 4 registros mapeados en memoria de 32 bits cada uno:

| Offset de Dirección | Registro | Permiso | Valor por Defecto | Descripción |
| :---: | :---: | :---: | :---: | :--- |
| **`0x00`** | `slv_reg0` | R/W | `0x00000000` | Registro de Control y Habilitación. |
| **`0x04`** | `slv_reg1` | R/W | `0x00000000` | Registro de Celdas por PRT (`CELLS_IN_PRT`). |
| **`0x08`** | `slv_reg2` | R/W | `0x00000000` | Registro de Celdas a Enviar (`CELLS_TO_SEND`). |
| **`0x0C`** | `slv_reg3` | R/W | `0x00000000` | Registro reservado / propósito general. |

### Detalle de Campos de Bits por Registro

#### 1. Registro de Control (`slv_reg0` - Offset `0x00`)
| Bits | Nombre de Campo | Acceso | Descripción |
| :---: | :--- | :---: | :--- |
| `0` | **ENABLE** | R/W | **Habilitador del Generador**: <br> `1` = Habilita `LoopCounter_v1_0`. <br> `0` = Inhabilita y mantiene en reset el módulo de generación. |
| `31:1` | *Reservado* | R/O | Bits no utilizados (retornan `'0'`). |

#### 2. Registro `CELLS_IN_PRT` (`slv_reg1` - Offset `0x04`)
| Bits | Nombre de Campo | Acceso | Descripción |
| :---: | :--- | :---: | :--- |
| `15:0` | **CELLS_IN_PRT** | R/W | Número total de celdas por período de repetición de pulso (PRT). Valor máximo $2^{16}-1 = 65535$. |
| `31:16` | *Reservado* | R/O | Bits no utilizados. |

#### 3. Registro `CELLS_TO_SEND` (`slv_reg2` - Offset `0x08`)
| Bits | Nombre de Campo | Acceso | Descripción |
| :---: | :--- | :---: | :--- |
| `15:0` | **CELLS_TO_SEND** | R/W | Número de celdas activas a capturar e incluir en la ráfaga AXI4-Stream. Se debe cumplir: $\text{CELLS\_TO\_SEND} \le \text{CELLS\_IN\_PRT}$. |
| `31:16` | *Reservado* | R/O | Bits no utilizados. |

---

## 5. Descripción de Puertos e Interfaces

### Puertos de Salida de Configuración hacia PL
| Nombre del Puerto | Dirección | Tipo | Descripción |
| :--- | :--- | :--- | :--- |
| **ENABLE** / **s00_enable** | Salida | `std_logic` | Señal directa desde `slv_reg0(0)`. |
| **CELLS_IN_PRT** / **s00_cells_in_prt** | Salida | `std_logic_vector(15 downto 0)` | Bus de datos directo desde `slv_reg1(15 downto 0)`. |
| **CELLS_TO_SEND** / **s00_cells_to_send** | Salida | `std_logic_vector(15 downto 0)` | Bus de datos directo desde `slv_reg2(15 downto 0)`. |

### Interfaz AXI4-Lite Slave (`S00_AXI` / `S_AXI`)
| Nombre del Puerto | Dirección | Tipo | Descripción |
| :--- | :--- | :--- | :--- |
| **s00_axi_aclk** | Entrada | `std_logic` | Reloj de la interfaz AXI4-Lite. |
| **s00_axi_aresetn** | Entrada | `std_logic` | Reset global AXI4-Lite (Activo en '0'). |
| **s00_axi_awaddr** | Entrada | `std_logic_vector(3 downto 0)` | Dirección de escritura. |
| **s00_axi_awvalid** | Entrada | `std_logic` | Dirección de escritura válida. |
| **s00_axi_awready** | Salida | `std_logic` | Esclavo listo para recibir dirección de escritura. |
| **s00_axi_wdata** | Entrada | `std_logic_vector(31 downto 0)` | Bus de datos de escritura. |
| **s00_axi_wstrb** | Entrada | `std_logic_vector(3 downto 0)` | Estrobos de byte para escritura. |
| **s00_axi_wvalid** | Entrada | `std_logic` | Datos de escritura válidos. |
| **s00_axi_wready** | Salida | `std_logic` | Esclavo listo para recibir datos de escritura. |
| **s00_axi_bresp** | Salida | `std_logic_vector(1 downto 0)` | Respuesta de escritura. |
| **s00_axi_bvalid** | Salida | `std_logic` | Respuesta de escritura válida. |
| **s00_axi_bready** | Entrada | `std_logic` | Maestro listo para recibir respuesta. |
| **s00_axi_araddr** | Entrada | `std_logic_vector(3 downto 0)` | Dirección de lectura. |
| **s00_axi_arvalid** | Entrada | `std_logic` | Dirección de lectura válida. |
| **s00_axi_arready** | Salida | `std_logic` | Esclavo listo para recibir dirección de lectura. |
| **s00_axi_rdata** | Salida | `std_logic_vector(31 downto 0)` | Bus de datos de lectura. |
| **s00_axi_rresp** | Salida | `std_logic_vector(1 downto 0)` | Respuesta de lectura. |
| **s00_axi_rvalid** | Salida | `std_logic` | Datos de lectura válidos. |
| **s00_axi_rready** | Entrada | `std_logic` | Maestro listo para recibir datos de lectura. |

---

## 6. Guía de Uso del Driver de Software (C API)

El IP incluye archivos de cabecera C en `drivers/LoopCounterConfig_v1_0/src/LoopCounterConfig.h`:

### Macros de Acceso a Registros
```c
#include "LoopCounterConfig.h"

// Offsets
#define LOOPCOUNTERCONFIG_S00_AXI_SLV_REG0_OFFSET 0
#define LOOPCOUNTERCONFIG_S00_AXI_SLV_REG1_OFFSET 4
#define LOOPCOUNTERCONFIG_S00_AXI_SLV_REG2_OFFSET 8
#define LOOPCOUNTERCONFIG_S00_AXI_SLV_REG3_OFFSET 12
```

### Ejemplo de Configuración en Bare-metal / PetaLinux (Linux `/dev/mem` o UIO)
```c
#include "xil_io.h"
#include "LoopCounterConfig.h"

#define LOOP_COUNTER_CFG_BASEADDR 0x43C00000 // Dirección base asignada en Vivado Address Editor

void configure_loop_counter(u32 base_addr, u16 cells_in_prt, u16 cells_to_send) {
    // 1. Inhabilitar IP antes de cambiar parámetros
    LOOPCOUNTERCONFIG_mWriteReg(base_addr, LOOPCOUNTERCONFIG_S00_AXI_SLV_REG0_OFFSET, 0x00);

    // 2. Programar Celdas en PRT (p. ej. 2000 celdas)
    LOOPCOUNTERCONFIG_mWriteReg(base_addr, LOOPCOUNTERCONFIG_S00_AXI_SLV_REG1_OFFSET, cells_in_prt);

    // 3. Programar Celdas a Capturar/Enviar (p. ej. 1000 celdas)
    LOOPCOUNTERCONFIG_mWriteReg(base_addr, LOOPCOUNTERCONFIG_S00_AXI_SLV_REG2_OFFSET, cells_to_send);

    // 4. Habilitar el módulo
    LOOPCOUNTERCONFIG_mWriteReg(base_addr, LOOPCOUNTERCONFIG_S00_AXI_SLV_REG0_OFFSET, 0x01);
}
```

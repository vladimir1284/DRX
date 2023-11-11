
# Entity: LoopCounterConfig_v1_0_S00_AXI 
- **File**: LoopCounterConfig_v1_0_S00_AXI.vhd

## Diagram
![Diagram](LoopCounterConfig_v1_0_S00_AXI.svg "Diagram")
## Description

Configuration IP for the Loop Counter Simulator.
This module allows to configure the parameters of the loop counter
from the PS. The configurations parameters are mapped as:

ENABLE is the LSB in the address 0 (slv_reg0)

CELLS_IN_PRT is in the CELLS_DATA_WIDTH - 1 downto 0 bits of address 4 (slv_reg1)

CELLS_TO_SEND is in the CELLS_DATA_WIDTH - 1 downto 0 bits of address 8 (slv_reg2)

## Generics

| Generic name       | Type    | Value | Description                                                        |
| ------------------ | ------- | ----- | ------------------------------------------------------------------ |
| CELLS_DATA_WIDTH   | integer | 16    | The maximum number of cells in a transaction is 2^CELLS_DATA_WIDTH |
| C_S_AXI_DATA_WIDTH | integer | 32    | Width of S_AXI data bus                                            |
| C_S_AXI_ADDR_WIDTH | integer | 4     | Width of S_AXI address bus                                         |

## Ports

| Port name     | Direction | Type                                            | Description                                              |
| ------------- | --------- | ----------------------------------------------- | -------------------------------------------------------- |
| ENABLE        | out       | std_logic                                       | Ascynchronous reset signal from the counter configurator |
| CELLS_IN_PRT  | out       | std_logic_vector(CELLS_DATA_WIDTH - 1 downto 0) | Number of cells in a Pulse Repetition Time (PRT)         |
| CELLS_TO_SEND | out       | std_logic_vector(CELLS_DATA_WIDTH - 1 downto 0) | Number of cells to be adquired                           |
| S00_AXI       | in        | Virtual bus                                     | an AXI4-Lite interface to write core registers           |

### Virtual Buses

#### S00_AXI

| Port name     | Direction | Type                                                  | Description                                                                                                                                                                      |
| ------------- | --------- | ----------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| S_AXI_ACLK    | in        | std_logic                                             | Global Clock Signal                                                                                                                                                              |
| S_AXI_ARESETN | in        | std_logic                                             | Global Reset Signal. This Signal is Active LOW                                                                                                                                   |
| S_AXI_AWADDR  | in        | std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0)     | Write address (issued by master, acceped by Slave)                                                                                                                               |
| S_AXI_AWPROT  | in        | std_logic_vector(2 downto 0)                          | Write channel Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access. |
| S_AXI_AWVALID | in        | std_logic                                             | Write address valid. This signal indicates that the master signaling valid write address and control information.                                                                |
| S_AXI_AWREADY | out       | std_logic                                             | Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.                                                          |
| S_AXI_WDATA   | in        | std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0)     | Write data (issued by master, acceped by Slave)                                                                                                                                  |
| S_AXI_WSTRB   | in        | std_logic_vector((C_S_AXI_DATA_WIDTH/8) - 1 downto 0) | Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.                                  |
| S_AXI_WVALID  | in        | std_logic                                             | Write valid. This signal indicates that valid write data and strobes are available.                                                                                              |
| S_AXI_WREADY  | out       | std_logic                                             | Write ready. This signal indicates that the slave can accept the write data.                                                                                                     |
| S_AXI_BRESP   | out       | std_logic_vector(1 downto 0)                          | Write response. This signal indicates the status of the write transaction.                                                                                                       |
| S_AXI_BVALID  | out       | std_logic                                             | Write response valid. This signal indicates that the channel is signaling a valid write response.                                                                                |
| S_AXI_BREADY  | in        | std_logic                                             | Response ready. This signal indicates that the master can accept a write response.                                                                                               |
| S_AXI_ARADDR  | in        | std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0)     | Read address (issued by master, acceped by Slave)                                                                                                                                |
| S_AXI_ARPROT  | in        | std_logic_vector(2 downto 0)                          | Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access.               |
| S_AXI_ARVALID | in        | std_logic                                             | Read address valid. This signal indicates that the channel is signaling valid read address and control information.                                                              |
| S_AXI_ARREADY | out       | std_logic                                             | Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals.                                                           |
| S_AXI_RDATA   | out       | std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0)     | Read data (issued by slave)                                                                                                                                                      |
| S_AXI_RRESP   | out       | std_logic_vector(1 downto 0)                          | Read response. This signal indicates the status of the read transfer.                                                                                                            |
| S_AXI_RVALID  | out       | std_logic                                             | Read valid. This signal indicates that the channel is signaling the required read data.                                                                                          |
| S_AXI_RREADY  | in        | std_logic                                             | Read ready. This signal indicates that the master can accept the read data and response information.                                                                             |

## Signals

| Name         | Type                                              | Description      |
| ------------ | ------------------------------------------------- | ---------------- |
| axi_awaddr   | std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) | AXI4LITE signals |
| axi_awready  | std_logic                                         |                  |
| axi_wready   | std_logic                                         |                  |
| axi_bresp    | std_logic_vector(1 downto 0)                      |                  |
| axi_bvalid   | std_logic                                         |                  |
| axi_araddr   | std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) |                  |
| axi_arready  | std_logic                                         |                  |
| axi_rdata    | std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) |                  |
| axi_rresp    | std_logic_vector(1 downto 0)                      |                  |
| axi_rvalid   | std_logic                                         |                  |
| slv_reg0     | std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) |                  |
| slv_reg1     | std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) |                  |
| slv_reg2     | std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) |                  |
| slv_reg3     | std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) |                  |
| slv_reg_rden | std_logic                                         |                  |
| slv_reg_wren | std_logic                                         |                  |
| reg_data_out | std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) |                  |
| byte_index   | integer                                           |                  |
| aw_en        | std_logic                                         |                  |

## Constants

| Name              | Type    | Value                       | Description                                                                                                                                                                                                                                |
| ----------------- | ------- | --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| ADDR_LSB          | integer | (C_S_AXI_DATA_WIDTH/32) + 1 | Example-specific design signals local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH ADDR_LSB is used for addressing 32/64 bit registers/memories ADDR_LSB = 2 for 32 bits (n downto 2) ADDR_LSB = 3 for 64 bits (n downto 3) |
| OPT_MEM_ADDR_BITS | integer | 1                           |                                                                                                                                                                                                                                            |

## Processes
- axi_awready_generation: ( S_AXI_ACLK )
  - **Description**
 Implement axi_awready generation.axi_awready is asserted for one S_AXI_ACLK clock cycle when bothS_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready isde-asserted when reset is low.
- axi_awaddr_latching: ( S_AXI_ACLK )
  - **Description**
 Implement axi_awaddr latching. This process is used to latch the address when both S_AXI_AWVALID and S_AXI_WVALID are valid. 
- axi_wready_generation: ( S_AXI_ACLK )
  - **Description**
 Implement axi_wready generation. axi_wready is asserted for one S_AXI_ACLK clock cycle when bothS_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is de-asserted when reset is low. 
- select_write: ( S_AXI_ACLK )
  - **Description**
 Implement memory mapped register select and write logic generation. The write data is accepted and written to memory mapped registers whenaxi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used toselect byte enables of slave registers while writing.These registers are cleared when reset (active low) is applied.Slave register write enable is asserted when valid address and data are availableand the slave is ready to accept the write address and write data.
- axi_bvalid_generation: ( S_AXI_ACLK )
  - **Description**
 Implement write response logic generation. The write response and response valid signals are asserted by the slave when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  This marks the acceptance of address and indicates the status of write transaction.
- axi_arready_generation: ( S_AXI_ACLK )
  - **Description**
 Implement axi_arready generation.axi_arready is asserted for one S_AXI_ACLK clock cycle whenS_AXI_ARVALID is asserted. axi_awready is de-asserted when reset (active low) is asserted. The read address is also latched when S_AXI_ARVALID is asserted. axi_araddr is reset to zero on reset assertion.
- axi_arvalid_generation: ( S_AXI_ACLK )
  - **Description**
 Implement axi_arvalid generation.axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both S_AXI_ARVALID and axi_arready are asserted. The slave registers data are available on the axi_rdata bus at this instance. The assertion of axi_rvalid marks the validity of read data on the bus and axi_rresp indicates the status of read transaction.axi_rvalid is deasserted on reset (active low). axi_rresp and axi_rdata are cleared to zero on reset (active low).  
- address_decoding: ( slv_reg0, slv_reg1, slv_reg2, slv_reg3, axi_araddr, S_AXI_ARESETN, slv_reg_rden )
  - **Description**
 Implement memory mapped register select and read logic generation.Slave register read enable is asserted when valid address is availableand the slave is ready to accept the read address.
- memory_read: ( S_AXI_ACLK )
  - **Description**
  Output register or memory read data. When there is a valid read address (S_AXI_ARVALID) with  acceptance of read address by the slave (axi_arready),  output the read dada  Read address mux

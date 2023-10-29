/*
 * AXI DMA in Simple Mode by interrupts
 *
 * Author(s):
 * * Rodrigo A. Melo
 *
 * Copyright (c) 2018 Authors and INTI
 * Distributed under the BSD 3-Clause License
 */

#include "xaxidma.h"
#include "xscugic.h"
#include "counterConfig.h"

#define DDR_BASE_ADDR  XPAR_PS7_DDR_0_S_AXI_BASEADDR
#define RX_BASE_ADDR   DDR_BASE_ADDR + 0x01000000

//Select one or add your own size
//#define data_t         u8
//#define data_t         u16
#define data_t         u32
//#define data_t         u64

// Max when "Width of buffer length register" is 26 bits
//#define BYTES          (64*1024*1024-1)
//#define SAMPLES        BYTES / sizeof(data_t)
#define SAMPLES        	1024
#define BYTES    		SAMPLES*sizeof(data_t)

XAxiDma dma;
XScuGic intc;

#define CELL_125M 0
#define CELL_250M 1

//-----------------------------------------------------------
void setCellWidth(int cell_width) {
	COUNTERCONFIG_mWriteReg(XPAR_COUNTERCONFIG_0_S00_AXI_BASEADDR,
			COUNTERCONFIG_S00_AXI_SLV_REG0_OFFSET, cell_width);
}

void enableCounter() {
	COUNTERCONFIG_mWriteReg(XPAR_COUNTERCONFIG_0_S00_AXI_BASEADDR,
			COUNTERCONFIG_S00_AXI_SLV_REG1_OFFSET, 1);
}

void disableCounter() {
	COUNTERCONFIG_mWriteReg(XPAR_COUNTERCONFIG_0_S00_AXI_BASEADDR,
			COUNTERCONFIG_S00_AXI_SLV_REG1_OFFSET, 0);
}

void setMaxCount(u16 value){
	COUNTERCONFIG_mWriteReg(XPAR_COUNTERCONFIG_0_S00_AXI_BASEADDR,
			COUNTERCONFIG_S00_AXI_SLV_REG2_OFFSET, value);
}

volatile int rx_int, err_int;

void rx_isr_handler(void *callback) {
	int status;
	XAxiDma *axidma = (XAxiDma *) callback;

	xil_printf("INFO: RX interrupt!\r\n");
	// Disable interrupts
	XAxiDma_IntrDisable(axidma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
	XAxiDma_IntrDisable(axidma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
	// Read pending interrupts
	status = XAxiDma_IntrGetIrq(axidma, XAXIDMA_DEVICE_TO_DMA);
	// Acknowledge pending interrupts
	XAxiDma_IntrAckIrq(axidma, status, XAXIDMA_DEVICE_TO_DMA);
	// If no interrupt is asserted, nothing to do
	if (!(status & XAXIDMA_IRQ_ALL_MASK))
		return;
	// Reset DMA engine if there was an error
	if (status & XAXIDMA_IRQ_ERROR_MASK) {
		err_int = 1;
		XAxiDma_Reset(axidma);
		while (!XAxiDma_ResetIsDone(axidma))
			return;
	}
	if (status & XAXIDMA_IRQ_IOC_MASK) {
		rx_int = 1;
	}
	XAxiDma_IntrEnable(axidma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
	XAxiDma_IntrEnable(axidma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
}

int intc_init(int device_id, int rx_int_id) {
	int status;
	XScuGic_Config *cfg;

	cfg = XScuGic_LookupConfig(device_id);
	if (cfg == NULL) {
		xil_printf(
				"No configuration found for INT Controller with device ID %d\r\n",
				device_id);
		return XST_FAILURE;
	}
	status = XScuGic_CfgInitialize(&intc, cfg, cfg->CpuBaseAddress);
	if (status != XST_SUCCESS) {
		xil_printf("INT Controller configuration failed\r\n");
		return XST_FAILURE;
	}
	XScuGic_SetPriorityTriggerType(&intc, rx_int_id, 0xA0, 0x3);

	status = XScuGic_Connect(&intc, rx_int_id,
			(Xil_InterruptHandler) rx_isr_handler, &dma);
	if (status != XST_SUCCESS) {
		xil_printf("INT RX connection failed\r\n");
		return XST_FAILURE;
	}

	XScuGic_Enable(&intc, rx_int_id);

	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
			(Xil_ExceptionHandler) XScuGic_InterruptHandler, &intc);
	Xil_ExceptionEnable();

	XAxiDma_IntrEnable(&dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);

	return XST_SUCCESS;
}

void intc_stop(int rx_int_id) {
	XScuGic_Disconnect(&intc, rx_int_id);
}

int dma_init(int device_id) {
	XAxiDma_Config *cfg;
	int status;
	cfg = XAxiDma_LookupConfig(device_id);
	if (!cfg) {
		xil_printf("No configuration found for AXI DMA with device ID %d\r\n",
				device_id);
		return XST_FAILURE;
	}
	status = XAxiDma_CfgInitialize(&dma, cfg);
	if (status != XST_SUCCESS) {
		xil_printf("ERROR: DMA configuration failed\r\n");
		return XST_FAILURE;
	}
	if (!XAxiDma_HasSg(&dma)) {
		xil_printf("INFO: Device configured in Simple Mode.\r\n");
	} else {
		xil_printf("ERROR: Device configured in Scatter Gather Mode.\r\n");
		return XST_FAILURE;
	}
	return XST_SUCCESS;
}

int dma_example() {
	int i, status, try;
	data_t *rx_buf;

	rx_buf = (data_t *) RX_BASE_ADDR;

	// Config
	setMaxCount(SAMPLES);

	for (try = 1; try <= 10; try++) {
		xil_printf("Try %d\r\n", try);

		Xil_DCacheFlushRange((UINTPTR) rx_buf, BYTES);

		err_int = 0;
		rx_int = 0;

		status = XAxiDma_SimpleTransfer(&dma, (UINTPTR) rx_buf, BYTES,
				XAXIDMA_DEVICE_TO_DMA);
		if (status != XST_SUCCESS) {
			xil_printf("DMA RX SimpleTransfer failed\r\n");
			return XST_FAILURE;
		}

		enableCounter();

		while (XAxiDma_Busy(&dma,XAXIDMA_DEVICE_TO_DMA) );
//		 while (!rx_int & !err_int) {};

		if (err_int) {
			xil_printf("ERROR: interrupt not asserted (RX=%d)\r\n", rx_int);
			return XST_FAILURE;
		}

		for (i = 0; i < SAMPLES; i++) {
			if (rx_buf[i] != i) {
				xil_printf(
						"ERROR: mismatch (data %d) between i(%d) and RX(%d)\r\n",
						i + 1, i, rx_buf[i]);
				return XST_FAILURE;
			}
			rx_buf[i] = 0; // Cklear for the next Loop
		}
		xil_printf("Try %d passed, %d samples processed!\r\n", try, i);

		// Disable counter for restart
		disableCounter();
//		// delay loop
//		for (i = 0; i < 9999999; i++)
//							;
	}
	return XST_SUCCESS;
}
/*****************************************************************************/
int main() {
	int status;
	xil_printf("* DMA Simple Mode by Interrupt Example\r\n");
	xil_printf("* Initializing DMA\n");
	status = dma_init(XPAR_AXIDMA_0_DEVICE_ID);
	if (status != XST_SUCCESS) {
		xil_printf("DMA initialization failed\r\n");
		return XST_FAILURE;
	}
	xil_printf("* Initializing Interrupts\r\n");
	status = intc_init(
	XPAR_SCUGIC_SINGLE_DEVICE_ID,
	XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR);
	if (status != XST_SUCCESS) {
		xil_printf("Interrupts initialization failed\r\n");
		return XST_FAILURE;
	}
	xil_printf("* Playing with DMA\r\n");
	status = dma_example();
	if (status != XST_SUCCESS) {
		xil_printf("* Example Failed\r\n");
		return XST_FAILURE;
	}
	intc_stop(
	XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR);
	xil_printf("* Example Passed\r\n");
	return XST_SUCCESS;
}

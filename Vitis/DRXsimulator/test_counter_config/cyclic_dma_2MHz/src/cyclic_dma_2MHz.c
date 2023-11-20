/******************************************************************************
 * Copyright (C) 2023 - 2022 LADETEC.  All rights reserved.
 * SPDX-License-Identifier: MIT
 ******************************************************************************/

/*****************************************************************************/
/**
 *
 * @file cyclic_dma_2MHz.c
 *
 * This file demonstrates how to use the xaxidma driver on the Xilinx AXI
 * DMA core (AXIDMA) to transfer packets in polling mode when the AXIDMA
 * core is configured in Scatter Gather Mode
 *
 * This example demonstrates how to use cyclic DMA mode feature.
 * This program will recycle the NUMBER_OF_BDS_TO_TRANSFER
 * buffer descriptors to specified number of cyclic transfers defined in
 * "NUMBER_OF_RAYS".
 *
 * This code assumes a Loop Counter hardware widget is connected to the AXI DMA
 * core for data packet generation. The first data cell is an index of the number
 * of rays (packages) sent, then consecutive numbers are attached to the buffer.
 *
 *
 * ***************************************************************************
 */
/***************************** Include Files *********************************/
#include "xaxidma.h"
#include "xscugic.h"
#include "LoopCounterConfig.h"
#include "xparameters.h"
#include "xil_exception.h"
#include "xdebug.h"

#ifdef XPAR_INTC_0_DEVICE_ID
#include "xintc.h"
#else
#include "xscugic.h"
#endif

/******************** Constant Definitions **********************************/
/*
 * Device hardware build related constants.
 */

#define DMA_DEV_ID		XPAR_AXIDMA_0_DEVICE_ID

#ifdef XPAR_AXI_7SDDR_0_S_AXI_BASEADDR
#define DDR_BASE_ADDR		XPAR_AXI_7SDDR_0_S_AXI_BASEADDR
#elif defined (XPAR_MIG7SERIES_0_BASEADDR)
#define DDR_BASE_ADDR	XPAR_MIG7SERIES_0_BASEADDR
#elif defined (XPAR_MIG_0_C0_DDR4_MEMORY_MAP_BASEADDR)
#define DDR_BASE_ADDR	XPAR_MIG_0_C0_DDR4_MEMORY_MAP_BASEADDR
#elif defined (XPAR_PSU_DDR_0_S_AXI_BASEADDR)
#define DDR_BASE_ADDR	XPAR_PSU_DDR_0_S_AXI_BASEADDR
#endif

#ifndef DDR_BASE_ADDR
#warning CHECK FOR THE VALID DDR ADDRESS IN XPARAMETERS.H, \
			DEFAULT SET TO 0x01000000
#define MEM_BASE_ADDR		0x01000000
#else
#define MEM_BASE_ADDR		(DDR_BASE_ADDR + 0x1000000)
#endif

#define RX_BD_SPACE_BASE	(MEM_BASE_ADDR)
#define RX_BD_SPACE_HIGH	(MEM_BASE_ADDR + 0x0000FFFF)
#define RX_BUFFER_BASE		(MEM_BASE_ADDR + 0x00300000)
#define RX_BUFFER_HIGH		(MEM_BASE_ADDR + 0x004FFFFF)

#ifdef XPAR_INTC_0_DEVICE_ID
#define INTC_DEVICE_ID          XPAR_INTC_0_DEVICE_ID
#else
#define INTC_DEVICE_ID          XPAR_SCUGIC_SINGLE_DEVICE_ID
#endif

/*
 * Number of BDs (equivalent to the number of rays) in the transfer example.
 * It is chosen above 1024 which is the number of allocated BDs so that it
 * turns around the ring buffer.
 */

#define NUMBER_OF_RAYS	2000

#ifdef XPAR_INTC_0_DEVICE_ID
#define INTC		XIntc
#define INTC_HANDLER	XIntc_InterruptHandler
#else
#define INTC		XScuGic
#define INTC_HANDLER	XScuGic_InterruptHandler
#endif

//AXI data size
#define data_t         u32

#define SAMPLES        	1864

/*
 * Buffer and Buffer Descriptor related constant definition
 */
// Max when "Width of buffer length register" is 13 bits
#define MAX_PKT_LEN		8000 // Max is 8191

/************************** Function Prototypes ******************************/

static int CheckData(int Length, u32 rayIndex, u32 *RxPacket);
static int test_dataflow(int samples);

static int RxSetup(XAxiDma * AxiDmaInstPtr);

static int setupRay(u16 num_cells, u16 acquired_cells);
static void enableCounter();
static void disableCounter();

/************************** Variable Definitions *****************************/
/*
 * Device instance definitions
 */
XAxiDma AxiDma;
XAxiDma_BdRing *RxRingPtr;

/*
 * Flags interrupt handlers use to notify the application context the events.
 */
volatile u32 RxDone;
volatile int Error;

/*****************************************************************************/
/**
 *
 * Main function
 *
 * This function is the main entry of the interrupt test. It does the following:
 *	- Set up the output terminal if UART16550 is in the hardware build
 *	- Initialize the DMA engine
 *	- Set up Rx channel
 *	- Set up the interrupt system for the Rx interrupt
 *	- Submit a transfer
 *	- Wait for the transfer to finish
 *	- Check transfer status
 *	- Disable Rx interrupts
 *	- Print test status and exit
 *
 * @param	None
 *
 * @return
 *		- XST_SUCCESS if tests pass
 *		- XST_FAILURE if fails.
 *
 * @note		None.
 *
 ******************************************************************************/
int main(void) {

	xil_printf("\r\n--- Entering main() --- \r\n");

	int PRTs[] = { 928, 1024, 1096, 1184, 1344, 1408, 1864 };

	for (int i = 0; i < 7; i++) {
		int Status;
		Status = test_dataflow(PRTs[i]);
		if (Status != XST_SUCCESS) {
			return XST_FAILURE;
		}
	}

	xil_printf("--- Exiting main() --- \r\n");

	return XST_SUCCESS;
}

/*****************************************************************************/
/*
 *
 * This function test the transference for a selected PRT.
 *
 * We use 2MHz clock in samples generation.
 *
 * @param	Length is the length to check
 * @param	StartValue is the starting value of the first byte
 *
 * @return	- XST_SUCCESS if validation is successful
 *		- XST_FAILURE if validation fails.
 *
 * @note		None.
 *
 ******************************************************************************/
static int test_dataflow(int samples) {
	XAxiDma_Config *Config;
	int Status;

	/* Initialize flags before start transfer test  */
	RxDone = 0;
	Error = 0;
	int MaxBufferCount = 0;

	Config = XAxiDma_LookupConfig(DMA_DEV_ID);
	if (!Config) {
		xil_printf("No config found for %d\r\n", DMA_DEV_ID);

		return XST_FAILURE;
	}

	/* Initialize DMA engine */
	XAxiDma_CfgInitialize(&AxiDma, Config);

	if (!XAxiDma_HasSg(&AxiDma)) {
		xil_printf("Device configured as Simple mode \r\n");
		return XST_FAILURE;
	}

	/* Set up RX channel to be ready to receive packets */
	Status = RxSetup(&AxiDma);
	if (Status != XST_SUCCESS) {

		xil_printf("Failed RX setup\r\n");
		return XST_FAILURE;
	}

	/* Start the counter */
	setupRay(samples, samples - 1); //TODO There must be an space between transactions
	enableCounter();

	/*
	 * Wait RX done
	 */
	while (1) {
		int BdCount;
		XAxiDma_Bd *BdPtr, *BdCurPtr;

		/* Wait until the data has been received by the Rx channel */
		while ((BdCount = XAxiDma_BdRingFromHw(RxRingPtr,
		XAXIDMA_ALL_BDS, &BdPtr)) == 0) {
		}

		if (BdCount > MaxBufferCount) {
			MaxBufferCount = BdCount;
		}

		BdCurPtr = BdPtr;

		/* Check received data */
		for (int i = 0; i < BdCount; i++) {

			/*
			 * Check data
			 */
			Status = CheckData(
					XAxiDma_BdGetActualLength(BdCurPtr,
							RxRingPtr->MaxTransferLen), RxDone + i,
					XAxiDma_BdGetBufAddr(BdCurPtr));
			if (Status != XST_SUCCESS) {
				xil_printf("BD Index: %d\r\n",
						XAxiDma_BdRingCntCalc(XAXIDMA_BD_MINIMUM_ALIGNMENT,
								(u32)BdCurPtr-RX_BD_SPACE_BASE));
				xil_printf("Data check failed\r\n");
				disableCounter();
				break;
			}
			BdCurPtr = (XAxiDma_Bd *) XAxiDma_BdRingNext(RxRingPtr, BdCurPtr);
		}

		RxDone += BdCount;

		if ((RxDone > NUMBER_OF_RAYS - 1) || (Status != XST_SUCCESS)) {
			break;
		}
	}

	if (Error || (Status != XST_SUCCESS)) {
		xil_printf("Failed test receive %s done\r\n", RxDone ? "" : " not");
		return XST_FAILURE;
	} else {
		xil_printf(
				"Successfully ran AXI DMA Cyclic SG transference of %d rays, MaxBufferCount: %d\r\n",
				RxDone, MaxBufferCount);
	}

	disableCounter();
	XAxiDma_Reset(&AxiDma);
	return XST_SUCCESS;
}

/*****************************************************************************/
/*
 *
 * This function checks data buffer after the DMA transfer is finished.
 *
 * We use the static tx/rx buffers.
 *
 * @param	Length is the length to check
 * @param	StartValue is the starting value of the first byte
 *
 * @return	- XST_SUCCESS if validation is successful
 *		- XST_FAILURE if validation fails.
 *
 * @note		None.
 *
 ******************************************************************************/
static int CheckData(int Length, u32 rayIndex, u32 *RxPacket) {
	int Index = 0;
	u16 Value;

	Value = 1;

	/* Invalidate the DestBuffer before receiving the data, in case the
	 * Data Cache is enabled
	 */
	Xil_DCacheInvalidateRange((UINTPTR) RxPacket, Length);

	// Check the first data cell which have the rayIndex
	if (RxPacket[0] != rayIndex) {
		xil_printf("Ray index error! (found: %d, expected: %d)\r\n",
				RxPacket[0], rayIndex);
		xil_printf("Length: %d, rayIndex: %d\r\n", Length, rayIndex);
		xil_printf("RxPacket[0]: %d, RxPacket[1]: %d, RxPacket[2]: %d\r\n",
				RxPacket[0], RxPacket[1], RxPacket[2]);

		return XST_FAILURE;
	}

	for (Index = 1; Index < (Length / sizeof(data_t) - 1); Index++) { // TODO not getting the last value (maybe tlast to soon)
		if (RxPacket[Index] != Value) {
			xil_printf("Data error %d: %d/%d\r\n", Index, RxPacket[Index],
					Value);
			xil_printf("Length: %d, rayIndex: %d\r\n", Length, rayIndex);
			xil_printf("RxPacket[0]: %d, RxPacket[1]: %d, RxPacket[2]: %d\r\n",
					RxPacket[0], RxPacket[1], RxPacket[2]);

			return XST_FAILURE;
		}
		Value++;
	}

	return XST_SUCCESS;
}

/*****************************************************************************/
/*
 *
 * This function sets up RX channel of the DMA engine to be ready for packet
 * reception
 *
 * @param	AxiDmaInstPtr is the pointer to the instance of the DMA engine.
 *
 * @return	- XST_SUCCESS if the setup is successful.
 *		- XST_FAILURE if fails.
 *
 * @note		None.
 *
 ******************************************************************************/
static int RxSetup(XAxiDma * AxiDmaInstPtr) {
	int Status;
	XAxiDma_Bd BdTemplate;
	XAxiDma_Bd *BdPtr;
	XAxiDma_Bd *BdCurPtr;
	int BdCount;
	int FreeBdCount;
	UINTPTR RxBufferPtr;
	int Index;
	int Delay = 0;
	int Coalesce = 1;

	RxRingPtr = XAxiDma_GetRxRing(&AxiDma);

	/* Disable all RX interrupts before RxBD space setup */

	XAxiDma_BdRingIntDisable(RxRingPtr, XAXIDMA_IRQ_ALL_MASK);

	/* Set delay and coalescing */
	XAxiDma_BdRingSetCoalesce(RxRingPtr, Coalesce, Delay);

	/* Setup Rx BD space */
//	BdCount = XAxiDma_BdRingCntCalc(XAXIDMA_BD_MINIMUM_ALIGNMENT,
//			RX_BD_SPACE_HIGH - RX_BD_SPACE_BASE + 1);
	BdCount = 256;

	Status = XAxiDma_BdRingCreate(RxRingPtr, RX_BD_SPACE_BASE,
	RX_BD_SPACE_BASE,
	XAXIDMA_BD_MINIMUM_ALIGNMENT, BdCount);
	if (Status != XST_SUCCESS) {
		xil_printf("Rx bd create failed with %d\r\n", BdCount);
		return XST_FAILURE;
	}

	/*
	 * Setup a BD template for the Rx channel. Then copy it to every RX BD.
	 */
	XAxiDma_BdClear(&BdTemplate);
	Status = XAxiDma_BdRingClone(RxRingPtr, &BdTemplate);
	if (Status != XST_SUCCESS) {
		xil_printf("Rx bd clone failed with %d\r\n", Status);
		return XST_FAILURE;
	}

	/* Attach buffers to RxBD ring so we are ready to receive packets */
	FreeBdCount = XAxiDma_BdRingGetFreeCnt(RxRingPtr);

	Status = XAxiDma_BdRingAlloc(RxRingPtr, FreeBdCount, &BdPtr);
	if (Status != XST_SUCCESS) {
		xil_printf("Rx bd alloc failed with %d\r\n", Status);
		return XST_FAILURE;
	}

	BdCurPtr = BdPtr;
	RxBufferPtr = RX_BUFFER_BASE;

	for (Index = 0; Index < FreeBdCount; Index++) {

		Status = XAxiDma_BdSetBufAddr(BdCurPtr, RxBufferPtr);
		if (Status != XST_SUCCESS) {
			xil_printf("Rx set buffer addr %x on BD %x failed %d\r\n",
					(unsigned int) RxBufferPtr, (UINTPTR) BdCurPtr, Status);

			return XST_FAILURE;
		}

		Status = XAxiDma_BdSetLength(BdCurPtr, MAX_PKT_LEN,
				RxRingPtr->MaxTransferLen);
		if (Status != XST_SUCCESS) {
			xil_printf("Rx set length %d on BD %x failed %d\r\n",
			MAX_PKT_LEN, (UINTPTR) BdCurPtr, Status);

			return XST_FAILURE;
		}

		/* Receive BDs do not need to set anything for the control
		 * The hardware will set the SOF/EOF bits per stream status
		 */
		XAxiDma_BdSetCtrl(BdCurPtr, 0);

		XAxiDma_BdSetId(BdCurPtr, RxBufferPtr);

		RxBufferPtr += MAX_PKT_LEN;
		BdCurPtr = (XAxiDma_Bd *) XAxiDma_BdRingNext(RxRingPtr, BdCurPtr);
	}

	xil_printf("INFO: Max transfer length: %d\r\n", RxRingPtr->MaxTransferLen);
	xil_printf("INFO: Buffer size: %d\r\n", MAX_PKT_LEN);
	xil_printf("INFO: Number of BDs: %d\r\n", BdCount);
	xil_printf("INFO: Last Buffer Addr: %x/%x\r\n", RxBufferPtr,
			RX_BUFFER_HIGH);

	/* Clear the receive buffer, so we can verify data
	 */
	memset((void *) RX_BUFFER_BASE, 0, MAX_PKT_LEN);

	Status = XAxiDma_BdRingToHw(RxRingPtr, FreeBdCount, BdPtr);
	if (Status != XST_SUCCESS) {
		xil_printf("Rx ToHw failed with %d\r\n", Status);
		return XST_FAILURE;
	}

	/* Enable Cyclic DMA mode */
	XAxiDma_BdRingEnableCyclicDMA(RxRingPtr);
	XAxiDma_SelectCyclicMode(AxiDmaInstPtr, XAXIDMA_DEVICE_TO_DMA, 1);

	/* Start RX DMA channel */
	Status = XAxiDma_BdRingStart(RxRingPtr);
	if (Status != XST_SUCCESS) {
		xil_printf("Rx start BD ring failed with %d\r\n", Status);
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

/*****************************************************************************/
/*
 *
 * This function sets up the ray in the Loop Counter Simulator
 *
 * @param	num_cells is the number of range bins in the ray.
 * @param	acquired_cells is the number of range bins to be acquired.
 *
 * @return	- XST_SUCCESS if the setup is successful.
 *		    - XST_FAILURE if fails.
 *
 * @note		acquired_cells should be lower or equal to num_cells.
 *
 ******************************************************************************/
static int setupRay(u16 num_cells, u16 acquired_cells) {
	if (acquired_cells <= num_cells) {
		xil_printf(
				"INFO: Ray configured with %d cells, capturing %d of them!\r\n",
				num_cells, acquired_cells);
		// Set the number of cells in a Pulse Repetition Time (ray)
		LOOPCOUNTERCONFIG_mWriteReg(XPAR_LOOPCOUNTERCONFIG_0_S00_AXI_BASEADDR,
				LOOPCOUNTERCONFIG_S00_AXI_SLV_REG1_OFFSET, num_cells);

		// Set the number of cells to be acquired in a ray
		LOOPCOUNTERCONFIG_mWriteReg(XPAR_LOOPCOUNTERCONFIG_0_S00_AXI_BASEADDR,
				LOOPCOUNTERCONFIG_S00_AXI_SLV_REG2_OFFSET, acquired_cells);
	} else {
		xil_printf(
				"ERROR: Wrong ray configuration (NumCells: %d, AdquiredCells: %d) \r\n",
				num_cells, acquired_cells);
		return XST_FAILURE;
	}
	return XST_SUCCESS;
}

/*****************************************************************************/
/**
 *
 * This function enables the Loop Counter in the PS.
 *
 * @param	None.
 *
 * @return	None.
 *
 * @note		None.
 *
 ******************************************************************************/
static void enableCounter() {
	LOOPCOUNTERCONFIG_mWriteReg(XPAR_LOOPCOUNTERCONFIG_0_S00_AXI_BASEADDR,
			LOOPCOUNTERCONFIG_S00_AXI_SLV_REG0_OFFSET, 1);
}

/*****************************************************************************/
/**
 *
 * This function disables the Loop Counter in the PS.
 *
 * @param	None.
 *
 * @return	None.
 *
 * @note		The Counter is disabled and reseted.
 *
 ******************************************************************************/
static void disableCounter() {
	LOOPCOUNTERCONFIG_mWriteReg(XPAR_LOOPCOUNTERCONFIG_0_S00_AXI_BASEADDR,
			LOOPCOUNTERCONFIG_S00_AXI_SLV_REG0_OFFSET, 0);
}


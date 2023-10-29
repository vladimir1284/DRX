//=========================================================//
//   Advanced Workshop on FPGA-based Systems-on-Chip for   //
// Scientific Instrumentation and Reconfigurable Computing //
//                                                         //
//                          Lab                            //
//                    Custom IP Case 1                     //
//                                                         //
//                                                         //
//=========================================================//
//-----------------------------------------------------------
//-- File       : lab_custom_ip_c1.c
//-- Author     : Cristian
//-- Company    : ICTP-MLAB
//-- Created    : 2018-11-08
//-- Last update: 2018-11-09
//-----------------------------------------------------------
//-- Description: Simple 'C' code that write the Duty Cycle
//-- value into the only register usable in this IP
//-----------------------------------------------------------
//--
//-----------------------------------------------------------
//-- Revisions  :
//-- Date        Version   Author      Description
//-- 2018-11-08   1.0     Crisitan      Created
//-----------------------------------------------------------

#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "counterConfig.h"
#include "xil_io.h"

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

void desableCounter() {
	COUNTERCONFIG_mWriteReg(XPAR_COUNTERCONFIG_0_S00_AXI_BASEADDR,
			COUNTERCONFIG_S00_AXI_SLV_REG1_OFFSET, 0);
}

void setMaxCount(u16 value){
	COUNTERCONFIG_mWriteReg(XPAR_COUNTERCONFIG_0_S00_AXI_BASEADDR,
			COUNTERCONFIG_S00_AXI_SLV_REG2_OFFSET, value);
}

int main() {
	int i;
	u16 k;

	printf("-- Start of the Program --\r\n");

	for (k = 0; k < 64; k++) {
		setCellWidth(CELL_125M);
		enableCounter();
		for (i = 0; i < 9999999; i++)
			; // delay loop
		setCellWidth(CELL_250M);
		desableCounter();
		for (i = 0; i < 9999999; i++)
			; // delay loop
		setMaxCount(k);
		xil_printf("Iteration %i\r\n", k);
	}

	return 0;
}
//-----------------------------------------------------------
//-- EOF
//-----------------------------------------------------------

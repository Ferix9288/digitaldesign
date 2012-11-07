#include "fifo.h"
#include "uart.h"

void FIFOWrite(char* s) {
  int strIndex;
  strIndex = 0;
 
  //If DataInReady is high, then 
  //send the first char directly over to UART
  if (UTRAN_CTRL) { 
    UTRAN_DATA = s[strIndex];
    strIndex ++;
  }
  
  //Write the rest of the string into the FIFO, as long as it's not full
  while ((BUFFER[inIndex] = s[strIndex]) && (inIndex != outIndex - 1)) {
    if (inIndex == BUFFER_SIZE) {
      inIndex = 0;
    } else {
      inIndex = inIndex + 1;
    }
    strIndex++;
  }
}


void FIFORead() {
  char data;
  //By now, FIFO is kickstarted and UART_TX request in ISR handles 
  //transmitting the queued up data in FIFO to the UART 
  if (inIndex != outIndex) { //FIFO is not empty
    data = BUFFER[outIndex];
    UTRAN_DATA = data;
    if (outIndex == BUFFER_SIZE) {
      outIndex = 0;
    } else {
      outIndex = outIndex + 1;
    }
  }
}



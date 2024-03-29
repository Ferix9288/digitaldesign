#define BUFFER ((volatile unsigned char*) 0x1fff0000)
#define BUFFER_SIZE 27 //length of Buffer = 27 characters


//DataInReady
#define TRAN_CTRL (*((volatile unsigned int*)0x80000000) & 0x01)
//DataIn
#define TRAN_DATA (*((volatile unsigned int*)0x80000008))

#define inIndex (*((volatile unsigned int*) 0x1fff001c))
#define outIndex (*((volatile unsigned int*) 0x1fff0020))
#define STATE (*((volatile unsigned char*)) 0x1fff0024)
#define SW_RTC (*((volatile unsigned int*)) ox1fff0028)


void FIFOWrite(char* s) {
  int strIndex;
  strIndex = 0;
 
  //If DataInReady is high, then 
  //send the first char directly over to UART
  if (TRAN_CTRL) { 
    TRAN_DATA = s[strIndex];
  }
  
  //Write the rest of the string into the FIFO, as long as it's not full
  while ((BUFFER[inIndex] = s[strIndex]) && (inIndex != outIndex - 1)) {
    inIndex = (inIndex + 1) % BUFFER_SIZE;
    strIndex++;
  }
}


void FIFORead() {
  char data;
  //By now, FIFO is kickstarted and UART_TX request in ISR handles 
  //transmitting the queued up data in FIFO to the UART 
  if (inIndex != outIndex) { //FIFO is not empty
    data = BUFFER[outIndex];
    TRAN_DATA = data;
    outIndex = (outIndex + 1) % BUFFER_SIZE;
  }
}

int main(void) {
  return 0;
}

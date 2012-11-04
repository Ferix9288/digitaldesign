#define BUFFER ((volatile unsigned char*) 0x1fff0000)
#define BUFFER_SIZE 20


//DataInReady
#define TRAN_CTRL (*((volatile unsigned int*)0x80000000) & 0x01)
//DataIn
#define TRAN_DATA (*((volatile unsigned int*)0x80000008))

#define inIndex (*((volatile unsigned int*) 0x1fff0015))
#define outIndex (*((volatile unsigned int*) 0x1fff0016))

void out(char* s) {
  int strIndex;
  strIndex = 0; 
  //If buffer is empty and DataInReady is high, then 
  //send the first char directly over to UART
  if (TRAN_CTRL) { //&& inIndex == outIndex) {
    TRAN_DATA = s[strIndex];
  }
  
  //once kick-started (or has already been kick-started)
  while (BUFFER[inIndex] = s[strIndex] && (inIndex != outIndex - 1)) {
    inIndex = (inIndex + 1) % BUFFER_SIZE;
    strIndex++;
  }
}

//void read

//spit out the character that's in BUFFER[outIndex] 
//Write it to the UART
//Increment outIndex by one

void main()
{

  //software FIFO in a basic C program
  //char fifo[BUFFER_SIZE];

}


  //enqueue first character from char 	*string
  //buffer[inIdx] = *string; //copy character
  //inIdx++;
  //inIdx %= BUFFER_SIZE;
  //string++;

//Writes into FIFO will be done by application
//enqueue

//Reads from FIFO will be done by ISR

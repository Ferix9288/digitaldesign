#ifndef FIFO_H_
#define FIFO_H_

#define BUFFER ((volatile unsigned char*) 0x1fff0000)
#define BUFFER_SIZE 27 //length of Buffer = 27 characters


//DataInReady
#define TRAN_CTRL (*((volatile unsigned int*)0x80000000) & 0x01)
//DataIn
#define TRAN_DATA (*((volatile unsigned int*)0x80000008))

#define inIndex (*((volatile unsigned int*) 0x1fff001c))
#define outIndex (*((volatile unsigned int*) 0x1fff0020))
#define STATE (*((volatile unsigned char*)) 0x1fff0024)
#define SW_RTC (*((volatile unsigned int*)) 0x1fff0028)
#define PRINT_EN (*((volatile unsigned int*)) 0x1fff002c)

void FIFOWrite(char* s);

void FIFORead();

#endif

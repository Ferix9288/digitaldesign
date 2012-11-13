#ifndef FIFO_H_
#define FIFO_H_

#define BUFFER ((volatile unsigned char*) 0x1ffff000)
#define BUFFER_SIZE 100 //length of Buffer = 100 characters

#define inIndex *((volatile unsigned int*) 0x1fff001c)
#define outIndex *((volatile unsigned int*) 0x1fff0020)
#define SW_RTC *((volatile unsigned int*) 0x1fff0028)
#define PRINT_EN *((volatile unsigned int*) 0x1fff002c)
#define SEC ((volatile unsigned int*) 0x1fff0030)
#define MIN ((volatile unsigned int*) 0x1fff0034)
//38 and 3c taken

void FIFOWrite(char* s);

void FIFORead();

#endif

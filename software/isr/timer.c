#include "fifo.h"
#include "uart.h"

#define CLK_FREQUENCY 50000000

void ptimer() {

  //Create the string array for timer
  unsigned int min, secLocal, Count2;
  unsigned int multSum;
  char string[100];

 

  if (*SEC == 60) {
    //Increment Minute by one
    asm("lw $k0, 0x1fff0034");
    asm("addiu $k0, $k0, 1");
    asm("sw $k0, 0x1fff0034");
    *SEC = 0;
  }

  unsigned int sec1, sec2;
  sec1 = *SEC;
  sec2  = 0;

  while (sec1 >= 10) {
    sec1 = sec1 - 10;
    sec2 += 1;
  }

  char sec1_ASCII, sec2_ASCII;
  sec1_ASCII = sec1 + 48;
  sec2_ASCII = sec2 + 48;
  
  if (*MIN == 59) {
    *MIN = 0;
  }

  unsigned int min1, min2;
  min1 = *MIN;
  min2 = 0;

  while (min1 >= 10) {
    min1 = min1 - 10;
    min2 += 1;
  }

  char min1_ASCII, min2_ASCII;
  min1_ASCII = min1 + 48;
  min2_ASCII = min2 + 48;
  string[0] = min2_ASCII;
  string[1] = min1_ASCII;
  string[2] = ':';
  string[3] = sec2_ASCII;
  string[4] = sec1_ASCII;
  string[5] = '\n';
  string[6] = '\r';
  string[7] = '\0';
  

  if (PRINT_EN) {
    FIFOWrite(string);
  }
}

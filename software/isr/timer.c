#include "fifo.h"
#include "uart.h"
#include "ascii.h"

#define CLK_FREQUENCY 50000000

/* void fmin_sec(char * target, char* buffer, int min, int sec) { */
/*   int in = 0; int out = 0; */
/*   char next_char = buffer[in]; */
/*   int arg1 = 0; */
/*   char temp[10]; */
  
/*   while(next_char != '\0') { */
/*     if (next_char == '%') { */
/*       in = in + 1; */
/*       next_char = buffer[in]; */
/*       if (next_char == 'd' && !arg1) { */
/* 	uint32_to_ascii_hex(min, temp, 10); */
/* 	target[out] = temp[6]; */
/* 	target[out+1] = temp[7]; */
/* 	out = out + 2; */
/* 	arg1 = 1; */
/*       } */
/*       else if (next_char == 'd'){ */
/* 	uint32_to_ascii_hex(sec, temp, 10); */
/* 	target[out] = temp[6]; */
/* 	target[out+1] = temp[7]; */
/* 	out = out + 2; */
/*       } else { */
/* 	uwrite_int8s("Unrecognized format\n\r"); */
/*       } */
/*     } */
/*     else */
/*       { */
/* 	target[out] = next_char; */
/* 	out = out + 1; */
/*       } */
/*     in = in + 1; */
/*     next_char = buffer[in]; */
/*   } */
/*   target[out] = '\0'; */
/* } */


//Arguments: SW_RTC
void ptimer(unsigned int sw_rtc, unsigned int Count) {
  //Create the string array for timer
  unsigned int min, secLocal, Count2;
  unsigned int multSum;
  char string[100];

  min = 0;
  multSum = 0;
 
  for (int i = 0; i < sw_rtc; i++) {
    multSum = multSum + 86;
  }

  while ( multSum >= 60) {
    multSum = multSum - 60;
    min += 1;
  }


  unsigned int min1, min2;
  min1 = min;
  min2 = 0;
  while (min1 >= 10) {
    min1 = min1 - 10;
    min2 += 1;
  }

  char min1_ASCII, min2_ASCII;
  min1_ASCII = min1 + 48;
  min2_ASCII = min2 + 48;

  /* Count2 = Count; */
  /* sec = 0; */

  /* while (Count2 >= 50000000) { */
  /*   Count2 = Count2 - 50000000; */
  /*   sec += 1; */
  /* }	 */

  if (*SEC == 60) {
    //Increment Minute by one
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
  
  string[0] = min1_ASCII;
  string[1] = min2_ASCII;
  string[2] = ':';
  string[3] = sec2_ASCII;
  string[4] = sec1_ASCII;
  string[5] = '\n';
  string[6] = '\r';
  string[7] = '\0';
  

  //char buff[] = "%d:%d\n\r";
  // fmin_sec(string, buff, min, sec);

  
  
  FIFOWrite(string);

  //Then call FIFOwrite(s)
}

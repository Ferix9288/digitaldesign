#include "fifo.h"
#include "uart.h"
#include "ascii.h"

#define CLK_FREQUENCY 50,000,000

void fmin_sec(char * target, char* buffer, int min, int sec) {
  int in = 0; int out = 0;
  char next_char = buffer[in];
  int arg1 = 0;
  char temp[10];
  
  while(next_char != '\0') {
    if (next_char == '%') {
      in = in + 1;
      next_char = buffer[in];
      if (next_char == 'd' && !arg1) {
	uint32_to_ascii_hex(min, temp, 10);
	target[out] = temp[6];
	target[out+1] = temp[7];
	out = out + 2;
	arg1 = 1;
      }
      else if (next_char == 'd'){
	uint32_to_ascii_hex(sec, temp, 10);
	target[out] = temp[6];
	target[out+1] = temp[7];
	out = out + 2;
      } else {
	uwrite_int8s("Unrecognized format\n\r");
      }
    }
    else
      {
	target[out] = next_char;
	out = out + 1;
      }
    in = in + 1;
    next_char = buffer[in];
  }
  target[out] = '\0';
}


//Arguments: SW_RTC
void ptimer(int sw_rtc, int Count) {
  //Create the string array for timer
  int min, sec, secModded;
  char* string;
  min = sw_rtc;
  sec = Count/CLK_FREQUENCY;
  secModded = sec % 60;

  fmin_sec(string, "%d:%d\n\r", min, secModded);
  FIFOWrite(string);

  //Then call FIFOwrite(s)
}

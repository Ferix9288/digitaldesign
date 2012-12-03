#define frameCount ((volatile unsigned int*) 0x8000001c)
#define PIXEL_FRAME ((volatile unsigned int*) 0x8000020)
#define GP_CODE ((volatile unsigned int*) 0x180000040)
#define GP_FRAME ((volatile unsigned int*) 0x18000004)
#define ODD_CODE ((volatile unsigned int*) 0x17800000)
#define EVEN_CODE ((volatile unsigned int*) 0x17600000)
#define BLUE_X0 ((volatile unsigned int*) 0x18000008)
#define RED_Y1 ((volatile unsigned int*) 0x18000008)

//Increments Blue Line's X0 by one
int writeOddFrameGPinst(void) {
  BLUE_X0[0] = *BLUE_X0 + 1;
  ODD_CODE[1] = 0x020000FF;
  ODD_CODE[2] = 0x00000020 + *BLUE_X0 << 16;
  ODD_CODE[3] = 0x001A002B;
  ODD_CODE[4] = 0x02FF0000;
  ODD_CODE[5] = 0x012301234;
  ODD_CODE[6] = 0x00AA + *RED_Y1;
  ODD_CODE[7] = 0x00000000;
}

//Increments Blue Line's X0 by one
int writeEvenFrameGPinst(void) {
  RED_Y1[0] = *RED_Y1 + 1;
  ODD_CODE[1] = 0x020000FF;
  ODD_CODE[2] = 0x00000020 + *BLUE_X0 << 16;
  ODD_CODE[3] = 0x001A002B;
  ODD_CODE[4] = 0x02FF0000;
  ODD_CODE[5] = 0x012301234;
  ODD_CODE[6] = 0x00AA + *RED_Y1;
  ODD_CODE[7] = 0x00000000;
}

int main(void) {
  unsigned int Current_Pixel_Frame;
  if (Current_Pixel_Frame == 


/* int main(void) { */
/*   unsigned int oldframe; */
/*   frameCount[0] = 0; */
/*   ODD_CODE[0] = 0x01000000; */
/*   EVEN_CODE[0] = 0x01000000; */
/*   BLUE_X0[0] = 0x10; */
/*   RED_Y1[0] = 0xBB; */
/*   while (1) { */
/*     if (*frameCount%2) { */
/*       writeOddFrameGPinst(); */
/*       GP_FRAME[0] = 0x10800000; */
/*       GP_CODE[0] = 0x17800000; */
/*     } else { */
/*       writeEvenFrameGPinst(); */
/*       GP_FRAME[0] = 0x10400000; */
/*       GP_CODE[0] = 0x17600000; */
/*     } */
/*     oldframe = *frameCount; */
/*     while (*frameCount == oldframe); */
/*   } */
/* } */



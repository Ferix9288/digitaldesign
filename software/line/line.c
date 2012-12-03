#define FRAME_1 ((volatile unsigned int*) 0x10400000)
#define FRAME_2 ((volatile unsigned int*) 0x10800000)
#define CMD_ADDR ((volatile unsigned int*) 0x19000000)
//#define GP_FRAME ((volatile unsigned int*) 0x18000004)
//#define GP_CODE ((volatile unsigned int*) 0x18000000)
#define GP_FRAME  ((volatile unsigned int*) 0x18000004)
#define GP_CODE  ((volatile unsigned int*) 0x18000000)

#define RED 0x00ff0000
#define GREEN 0x0000ff00
#define BLUE 0x000000ff
#define WHITE 0x00ffffff

int main(void) {
  //CMD_ADDR[0] = 0x01000000;
  CMD_ADDR[0] = 0x01000000;
  /* CMD_ADDR[1] = 0x01ffffff; */
  /* CMD_ADDR[2] = 0x01ff00ff; */
  /* CMD_ADDR[3] = 0x0100ffff; */
  /* CMD_ADDR[4] = 0x01ffff00; */
  /* CMD_ADDR[5] = 0x01ff0000; */
  /* CMD_ADDR[6] = 0x010000ff; */
  /* CMD_ADDR[7] = 0x01720000; */
  /* CMD_ADDR[8] = 0x0120ffff; */
  /* CMD_ADDR[9] = 0x00000000; */

  CMD_ADDR[1] = 0x02ffff0f;
  CMD_ADDR[2] = 0x00000060;
  CMD_ADDR[3] = 0x03200060;
  //CMD_ADDR[4] = 0x00000000;
  CMD_ADDR[4] = 0x0200ffff;
  CMD_ADDR[5] = 0x00000200;
  CMD_ADDR[6] = 0x03200200;
  //CMD_ADDR[7] = 0x00000000;

  CMD_ADDR[7] = 0x020000ff;
  CMD_ADDR[8] = 0x0000012C;
  CMD_ADDR[9] = 0x0320012C;
  //CMD_ADDR[10] = 0x00000000;

  CMD_ADDR[10] = 0x02ff00ff;
  CMD_ADDR[11] = 0x00000100;
  CMD_ADDR[12] = 0x03200100;
  //CMD_ADDR[13] = 0x00000000;

  CMD_ADDR[13] = 0x02ffff00;
  CMD_ADDR[14] = 0x01a00000;
  CMD_ADDR[15] = 0x01a00258;
  //CMD_ADDR[16] = 0x00000000;

  CMD_ADDR[16] = 0x02ff0000;
  CMD_ADDR[17] = 0x01b00000;
  CMD_ADDR[18] = 0x01b00258;
  //CMD_ADDR[19] = 0x00000000;

  CMD_ADDR[19] = 0x0200ff00;
  CMD_ADDR[20] = 0x01000000;
  CMD_ADDR[21] = 0x01000258;
  //CMD_ADDR[22] = 0x00000000;

  CMD_ADDR[22] = 0x02ffffff;
  CMD_ADDR[23] = 0x00000000;
  CMD_ADDR[24] = 0x03200000;
  //CMD_ADDR[25] = 0x00000000;
 
  CMD_ADDR[25] = 0x00000000;

  /* //CMD_ADDR[0] = 0x00000000; */
  /* CMD_ADDR[1] = 0x020000ff; */
  /* CMD_ADDR[2] = 0x00000258; */
  /* CMD_ADDR[3] = 0x03200000; */
  /* //CMD_ADDR[4] = 0x00000000; */
  /* CMD_ADDR[4] = 0x02ff0000; */
  /* CMD_ADDR[5] = 0x0000012C; */
  /* CMD_ADDR[6] = 0x0320012C; */
  /* CMD_ADDR[7] = 0x0200ff00; */
  /* CMD_ADDR[8] = 0x00000000; */
  /* CMD_ADDR[9] = 0x03200258; */
  /* // CMD_ADDR[7] = 0x00000000; */
  /* CMD_ADDR[10] = 0x02ffffff; */
  /* CMD_ADDR[11] = 0x00000000; */
  /* CMD_ADDR[12] = 0x03200000; */
  /* CMD_ADDR[13] = 0x02ffff00; */
  /* CMD_ADDR[14] = 0x019000000; */
  /* CMD_ADDR[15] = 0x019000258; */
  /* CMD_ADDR[16] = 0x00000000; */


  GP_FRAME[0] = 0x10400000;
  GP_CODE[0]  = 0x19000000;

	
  /* GP_FRAME[1] = 0x10800000; */
  /* GP_CODE[0] = 0x19000000; */

  return 0;
}

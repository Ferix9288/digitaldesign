#define FRAME_1 ((volatile unsigned int*) 0x10400000)
#define FRAME_2 ((volatile unsigned int*) 0x10800000)
#define CMD_ADDR ((volatile unsigned int*) 0x19000000)
#define CMD_ADDR_2 ((volatile unsigned int*) 0x17800000)
//#define GP_FRAME ((volatile unsigned int*) 0x18000004)
//#define GP_CODE ((volatile unsigned int*) 0x18000000)
#define GP_FRAME  ((volatile unsigned int*) 0x18000004)
#define GP_CODE  ((volatile unsigned int*) 0x18000000)
#define PIXEL_FRAME *((volatile unsigned int*) 0x80000020)


#define RED 0x00ff0000
#define GREEN 0x0000ff00
#define BLUE 0x000000ff
#define WHITE 0x00ffffff

int main(void) {
  //CMD_ADDR[0] = 0x01000000;

  CMD_ADDR[0] = 0x01000000;
  //CMD_ADDR[1] = 0x00000000;
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

   CMD_ADDR[25] = 0x02050fee;
   CMD_ADDR[26] = 0x00000258;
   CMD_ADDR[27] = 0x03200000;

   CMD_ADDR[28] = 0x02998800;
   CMD_ADDR[29] = 0x00000000;
   CMD_ADDR[30] = 0x03200258;

   // CMD_ADDR[31] = 0x01000000;
   CMD_ADDR[31] = 0x02ffffff;
   CMD_ADDR[32] = 0x01900000;
   CMD_ADDR[33] = 0x01900258;
   CMD_ADDR[34] = 0x03ffffff;
   CMD_ADDR[35] = 0x6412C032;
   CMD_ADDR[36] = 0x03ffff00;
   CMD_ADDR[37] = 0x6412C064;
   CMD_ADDR[38] = 0x03ff00ff;
   CMD_ADDR[39] = 0x6412C096;
   CMD_ADDR[40] = 0x03ff0000;
   CMD_ADDR[41] = 0x6412C0C8;
   CMD_ADDR[42] = 0x0300ffff;
   CMD_ADDR[43] = 0x6412C0FA;
   CMD_ADDR[44] = 0x0300ff00;
   CMD_ADDR[45] = 0x6412C12C;
   CMD_ADDR[46] = 0x030000ff;
   CMD_ADDR[47] = 0x6412C15E;
   CMD_ADDR[48] = 0x00000000;


   CMD_ADDR[49] = 0x00000000;
   /* GP_FRAME[0] = 0x10800000;  */
   /* GP_CODE[0]  = 0x19000000;  */

   CMD_ADDR_2[0] = 0x01ffffff;
   //CMD_ADDR_2[1] = 0x01ffffff;
   CMD_ADDR_2[1] = 0x00000000;
   unsigned int frame, oldframe;

   /* GP_FRAME[0] = 0x10400000; */
   /* GP_CODE[0] = 0x19000000; */
   //for (int x = 0 ; x <= 500 ; x ++ ) {
   //frame = PIXEL_FRAME;
   for (; ;) {
     oldframe = PIXEL_FRAME;
     if (PIXEL_FRAME == 0x10400000) {
       GP_FRAME[0] = 0x10800000;
       GP_CODE[0]  = 0x17800000;
     } else {
       GP_FRAME[0] = 0x10400000;
       GP_CODE[0]  = 0x19000000;
     }
     while (PIXEL_FRAME == oldframe) ;
   }

  return 0;
}



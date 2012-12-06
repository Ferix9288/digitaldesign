#define PIXEL_FRAME *((volatile unsigned int*) 0x8000020)
#define STATE ((volatile unsigned int*) 0x1beef000)

#define CMD_ADDR_1 ((volatile unsigned int*) 0x17800000)
#define CMD_ADDR_2 ((volatile unsigned int*) 0x19000000)

#define GP_CODE ((volatile unsigned int*) 0x180000040)
#define GP_FRAME ((volatile unsigned int*) 0x18000004)

struct player {
   int x;
   int y;
};


int drawPlayer(struct player* playa, int x_dir, int y_dir) {
  playa->x = playa->x + x_dir;	
  playa->y = playa->y + y_dir;
  
  //0x1000 + 1 << 3 = 0x1001?
  //GP_instructions that draws player
  CMD_ADDR_1[0] = 0x01000000;
  CMD_ADDR_1[1] = 0x03ffffff;
  CMD_ADDR_1[2] = 0x0000000a + (playa->y <<12) + (playa->x << 22);
  CMD_ADDR_1[3] = 0x00000000;
  return 0;
}


int main(void) {
  unsigned int Current_Pixel_Frame, GP_Code_addr;
  unsigned int currentFrame, oldFrame;
  unsigned int gameStateChange;
  struct player p1 = {400, 550};
  for ( ; ; ) {
    gameStateChange = 1;
    switch (*STATE)
      {
      case 'w':
	//add player up by one
	drawPlayer(&p1, 0, -1);
	break;
      case 'a':
	//move player to the left
	drawPlayer(&p1, -1, 0);
	break;
      case 's':
	//move player down by one
	drawPlayer(&p1, 0, 1);
	break;
      case 'd':
	//move player to the right by one
	drawPlayer(&p1, 1, 0);
	break;
      default:
	//do nothing
	gameStateChange = 0;
	break;
	;}
    if (gameStateChange) { 	
      if (PIXEL_FRAME == 0x10400000) {
	GP_FRAME[0] = 0x10800000;
	GP_CODE[0] = GP_Code_addr;
      } else {
	GP_FRAME[0] = 0x10400000;
	GP_CODE[0] = GP_Code_addr;
      }
    }
    oldFrame = PIXEL_FRAME;
    while (PIXEL_FRAME == oldFrame);

  }
  return 0;
}






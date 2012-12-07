#define PIXEL_FRAME *((volatile unsigned int*) 0x80000020)
#define STATE ((volatile unsigned int*) 0x1beef000)
#define INDEX ((volatile unsigned int*) 0x1dead000)


#define CMD_1 ((volatile unsigned int*) 0x15000000)
#define CMD_2 ((volatile unsigned int*) 0x16000000)

#define CMD_1_ADDR 0x15000000
#define CMD_2_ADDR 0x16000000


#define GP_CODE ((volatile unsigned int*) 0x18000000)
#define GP_FRAME ((volatile unsigned int*) 0x18000004)


struct player {
   int x;
   int y;
};


void setBackground(int color, unsigned int* cmd_addr) {
  cmd_addr[*INDEX] = 0x01000000 + color;
  INDEX[0] = *INDEX + 1;
}


void drawBlock(int x1, int y1, int x2, int y2, 
	       int color, int height, unsigned int* cmd_addr) {
  for (int i = 0; i <= height ; i++) {
    cmd_addr[*INDEX] = 0x02000000 + color;
    cmd_addr[*INDEX+1] = 0x00000000 + (x1 << 16) + (y1 + i);
    cmd_addr[*INDEX+2] = 0x00000000 + (x2 << 16) + (y2 + i);
    INDEX[0] = *INDEX + 3;
  }
}

void drawBorder(int color, int width, unsigned int* cmd_addr) {
  // Top and bottom borders
  //drawBlock(0, 0, 800, 0, color, width, cmd_addr);
  //drawBlock(0, (600-width), 800, (600-width), color, width, cmd_addr);
  // Left and right borders
  //drawBlock(0, 0, 40, 0, color, 600, cmd_addr);
  // drawBlock(560, 0, 800, 0, color, 600, cmd_addr);
}

void drawPlayer(struct player* playa, int x_dir, 
	       int y_dir,  unsigned int* cmd_addr) {
  playa->x = playa->x + x_dir;	
  playa->y = playa->y + y_dir;
  
  //0x1000 + 1 << 3 = 0x1001?
  //GP_instructions that draws player
  cmd_addr[*INDEX] = 0x03ff0000;
  cmd_addr[*INDEX+1] = 0x00000030 + (playa->y <<12) + (playa->x << 22);
  INDEX[0] = *INDEX+2;
}

int main(void) {
  unsigned int Current_Pixel_Frame, GP_Code_addr;
  unsigned int currentFrame, oldFrame, demo_frame;
  unsigned int gameStateChange;
  unsigned int* GP_Code_instr;

  struct player p1 = {400, 550};
  
  INDEX[0] = 0;
  
  demo_frame = (PIXEL_FRAME == 0x10400000)? 0x10800000: 0x10400000;
  GP_Code_instr = (demo_frame == 0x10400000)? CMD_1: CMD_2;
  GP_Code_addr = (demo_frame == 0x10400000)? CMD_1_ADDR: CMD_2_ADDR;


  //drawBlock(0, 0, 40, 0, 0x00ffffff, 600, GP_Code_instr);

  //setBackground(0x00000000, GP_Code_instr);
  drawBorder(0x00ffffff, 40, GP_Code_instr);
  drawPlayer(&p1, 0, 0, GP_Code_instr);

  GP_Code_instr[*INDEX] = 0x00000000;

  GP_FRAME[0] = demo_frame;
  GP_CODE[0] = GP_Code_addr;

  /* for ( ; ; ) { */
  /*   INDEX[0] = 0; */
  /*   gameStateChange = 1; */
  /*   demo_frame = (PIXEL_FRAME == 0x10400000)? 0x10800000: 0x10400000; */
  /*   GP_Code_instr = (demo_frame == 0x10400000)? CMD_1: CMD_2; */
  /*   GP_Code_addr = (demo_frame == 0x10400000)? CMD_1_ADDR: CMD_2_ADDR; */
    
  /*   drawBlock(0, 0, 800, 0, 0x00ffffff, 20, GP_Code_instr); */
  /*   switch (*STATE) */
  /*     { */
  /*     case 'w': */
  /*   	//add player up by one */
  /*   	drawPlayer(&p1, 0, -3, GP_Code_instr); */
  /*   	break; */
  /*     case 'a': */
  /*   	//move player to the left */
  /*   	drawPlayer(&p1, -3, 0, GP_Code_instr); */
  /*   	break; */
  /*     case 's': */
  /*   	//move player down by one */
  /*   	drawPlayer(&p1, 0, 3, GP_Code_instr); */
  /*   	break; */
  /*     case 'd': */
  /*   	//move player to the right by one */
  /*   	drawPlayer(&p1, 3, 0, GP_Code_instr); */
  /*   	break; */
  /*     default: */
  /*   	//do nothing (i.e. don't move) */
  /* 	gameStateChange = 0; */
  /* 	drawPlayer(&p1, 0, 0, GP_Code_instr); */
  /*   	break; */
  /*   	;} */
  /*   STATE[0] = 'p'; */
  /*   oldFrame = PIXEL_FRAME; */
  /*   GP_FRAME[0] = demo_frame; */
  /*   GP_CODE[0] = GP_Code_addr; */
  /*   while (PIXEL_FRAME == oldFrame); */
  /* } */
  return 0;

}



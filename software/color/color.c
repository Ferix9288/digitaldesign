#define FRAME_1 ((volatile unsigned int*) 0x10400000)
#define FRAME_2 ((volatile unsigned int*) 0x10800000)
#define RED 0x00ff0000
#define GREEN 0x0000ff00
#define BLUE 0x000000ff
#define WHITE 0x00ffffff


void setColor() {
  unsigned int rainbow = 0x0;
  while (1) {
    for (int y = 0; y < 600; y += 1) {
      for (int x =0; x < 800; x += 1) {
	FRAME_1[x + (y << 10)] = RED + rainbow;
      }
    }
    for (int y = 0; y < 600; y += 1) {
      for (int x =0; x < 800; x += 1) {
	FRAME_2[x + (y << 10)] = WHITE - rainbow;
      }
    }

    for (int z = 0; z < 500000; z += 1); 
    rainbow += 0xff;
  }
}

int main(void) {
  setColor();
  return 0;
}

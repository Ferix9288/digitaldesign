#define FRAME_1 ((volatile unsigned int*) 0x10400000)
#define FRAME_2 ((volatile unsigned int*) 0x10800000)
#define RED 0x11110000
#define BLUE 0x11000011



void setColor() {
  for (int i = 0; i < 2048; i += 4) {
    FRAME_1[i] = RED;
  }

  for (int i = 0; i < 2048; i += 4) {
    FRAME_2[i] = BLUE;
  }

}

int main(void) {
  setColor();
  return 0;
}

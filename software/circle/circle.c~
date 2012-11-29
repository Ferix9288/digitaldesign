#include <stdio.h>
#include <stdlib.h>
#include <math.h>
void usage();

int main(int argc, char** argv) {
  if(argc < 4)
    usage();
  int x0 = atoi(argv[1]);
  int y0 = atoi(argv[2]);
  int radius = atoi(argv[3]);
  rasterCircle(x0, y0, radius);
  return 0;
}

void usage() {
  printf("./circle x0 y0 radius\n");
  exit(0);
}

int rasterCircle(int x0, int y0, int radius)
{
  int f = 1 - radius;
  int ddF_x = 1;
  int ddF_y = -2 * radius;
  int x = 0;
  int y = radius;
 
  //setPixel(x0, y0 + radius);
  //setPixel(x0, y0 - radius);
  //setPixel(x0 + radius, y0);
  //setPixel(x0 - radius, y0);
  printf("%4d %4d\n", x0, y0 + radius); 
  printf("%4d %4d\n", x0, y0 - radius); 
  printf("%4d %4d\n", x0 + radius, y0); 
  printf("%4d %4d\n", x0 - radius, y0); 

  while(x < y)
  {
    // ddF_x == 2 * x + 1;
    // ddF_y == -2 * y;
    // f == x*x + y*y - radius*radius + 2*x - y + 1;
    if(f >= 0) 
    {
      y--;
      ddF_y += 2;
      f += ddF_y;
    }
    x++;
    ddF_x += 2;
    f += ddF_x;   
    printf("%4d %4d\n", x0+x, y0+y); 
    printf("%4d %4d\n", x0-x, y0+y); 
    printf("%4d %4d\n", x0+x, y0-y); 
    printf("%4d %4d\n", x0-x, y0-y); 
    printf("%4d %4d\n", x0+y, y0+x); 
    printf("%4d %4d\n", x0-y, y0+x); 
    printf("%4d %4d\n", x0+y, y0-x); 
    printf("%4d %4d\n", x0-y, y0-x); 

    //setPixel(x0 + x, y0 + y);
    //setPixel(x0 - x, y0 + y);
    //setPixel(x0 + x, y0 - y);
    //setPixel(x0 - x, y0 - y);
    //setPixel(x0 + y, y0 + x);
    //setPixel(x0 - y, y0 + x);
    //setPixel(x0 + y, y0 - x);
    //setPixel(x0 - y, y0 - x);

  }
  return 0;
}

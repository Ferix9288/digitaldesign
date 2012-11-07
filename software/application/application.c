#define COUNT *((volatile unsigned int*) 0x80000010)
#define STATE ((volatile unsigned int*) 0x1beef000)

#include "fifo.h"
#include "uart.h"
#include "ascii.h"

void pTimeDifference(unsigned int time, char currentState) {

  char print_buffer[23];

  unsigned int one, ten, hundred, thousand, tenthousand;
  unsigned int hundredthousand, million, tenmillion, hundredmillion;
 
  hundredmillion = 0;

  while (time >= 100000000) {
    time = time - 100000000;
    hundredmillion += 1;
  }
  
  tenmillion = 0;
  while (time >= 10000000) {
    time = time - 10000000;
    tenmillion += 1;
  }

  million = 0;
  while (time >= 1000000) {
    time = time - 1000000;
    million += 1;
  }

  hundredthousand = 0;
  while (time >= 100000) {
    time = time - 100000;
    hundredthousand += 1;
  }

  tenthousand = 0;
  while (time >= 10000) {
    time = time - 10000;
    tenthousand += 1;
  }

  thousand = 0;
  while (time >= 1000) {
    time = time - 1000;
    thousand += 1;
  }

  hundred = 0;
  while (time >= 100) {
    time = time - 100;
    hundred += 1;
  }

  ten = 0;
  while	(time >= 10) {
    time = time - 10;
    ten += 1;
  }

  one = 0;
  while (time >= 1) {
    time = time - 1;
    one += 1;
  }	
  char one_ASCII, ten_ASCII, hundred_ASCII, thousand_ASCII;
  char tenthousand_ASCII, hundredthousand_ASCII, million_ASCII;
  char tenmillion_ASCII, hundredmillion_ASCII;
  
  one_ASCII = one + 48;
  ten_ASCII = ten + 48;
  hundred_ASCII = hundred + 48;
  thousand_ASCII = thousand + 48;
  tenthousand_ASCII = tenthousand + 48;
  hundredthousand_ASCII = hundredthousand + 48;
  million_ASCII = million + 48;	
  tenmillion_ASCII = tenmillion + 48;
  hundredmillion_ASCII = hundredmillion + 48;



  print_buffer[0] = currentState;
  print_buffer[1] = ':';
  print_buffer[2] = hundredmillion_ASCII;
  print_buffer[3] = tenmillion_ASCII;
  print_buffer[4] = million_ASCII;
  print_buffer[5] = ',';
  print_buffer[6] = hundredthousand_ASCII;
  print_buffer[7] = tenthousand_ASCII;
  print_buffer[8] = thousand_ASCII;
  print_buffer[9] = ',';
  print_buffer[10] = hundred_ASCII;
  print_buffer[11] = ten_ASCII;
  print_buffer[12] = one_ASCII;
  print_buffer[13] = ' ';
  print_buffer[14] = 'c';
  print_buffer[15] = 'y';
  print_buffer[16] = 'c';
  print_buffer[17] = 'l';
  print_buffer[18] = 'e';
  print_buffer[19] = 's';
  print_buffer[20] = '\n';
  print_buffer[21] = '\r';
  print_buffer[22] = '\0';

  FIFOWrite(print_buffer);
  
}





void addFunctionR() {
  asm("addiu $t0, $t0, 1");
  asm("jr $ra");
  asm("nop");
}


void addFunctionV() {
  asm("lw $t0, 0x1fff003c");
  asm("addiu $t0, $t0, 1");
  asm("sw $t0, 0x1fff003c");
  asm("jr $ra");
  asm("nop");
}
  

int main(void) {

  unsigned int tstart, tend, time;
  unsigned int currentState = *STATE;

  for ( ; ; ) { 
    
    switch(currentState) 
      {			
      case 'r':		
	//r100M()
	tstart = COUNT;
	asm("addiu $t0, $0, 0");
	asm("la $t1, 0x05f5e100");
	asm("loop:");
	asm("addiu $t0, $t0, 1");
	asm("bne $t0, $t1, loop");
	asm("nop");
	tend = COUNT;
	break;
	
      case 'R':
	// register variable, plusone function call
	tstart = COUNT;
	asm("addiu $t0, $0, 0");
	asm("la $t1, 0x05f5e100");
	asm("loop1:");
	asm("jal addFunctionR");
	asm("bne $t0, $t1, loop1");
	asm("nop");
	tend = COUNT;
	break;

      case 'v':
	// volatile variable, addi
	tstart = COUNT;
	asm("la $t1, 0x05f5e100");
	asm("sw $0, 0x1fff0038");
	asm("loop2:");
	asm("lw $t0, 0x1fff0038");
	asm("addiu $t0, $t0, 1");
	asm("sw $t0, 0x1fff0038");
	asm("bne $t0, $t1, loop2");
	asm("nop");
	tend = COUNT;
	break;
	
      // volatile variable, plusone function call
      case 'V':
	tstart = COUNT;
	asm("la $t1, 0x05f5e100");
	asm("sw $0, 0x1fff003c");
	asm("loop3:");
	asm("jal addFunctionV");
	asm("bne $t0, $t1, loop3");
	asm("nop");
	tend = COUNT;
	break;

      default:
	// print error? (optional)
	break;
	;}
    time = tend - tstart;
    pTimeDifference(time, currentState);
    currentState = *STATE;
  }
  return 0;
}

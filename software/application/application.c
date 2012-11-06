#define COUNT *((volatile unsigned int*) 0x80000010)
#define STATE ((volatile unsigned int*) 0x1beef000)
#define PRINT_BUFFER ((volatile unsigned char*) 0x1fffff00)


#include "uart.h"
#include "ascii.h"

void pTimeDifference(unsigned int time) {

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
  while	(time >= 100) {
    time = time - 100;
    ten += 1;
  }

  one = 0;
  while (time >= 100) {
    time = time - 100;
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



  PRINT_BUFFER[0] = *STATE;
  PRINT_BUFFER[1] = ':';
  PRINT_BUFFER[2] = hundredmillion_ASCII;
  PRINT_BUFFER[3] = tenmillion_ASCII;
  PRINT_BUFFER[4] = million_ASCII;
  PRINT_BUFFER[5] = ',';
  PRINT_BUFFER[6] = hundredthousand_ASCII;
  PRINT_BUFFER[7] = tenthousand_ASCII;
  PRINT_BUFFER[8] = thousand_ASCII;
  PRINT_BUFFER[9] = ',';
  PRINT_BUFFER[10] = hundred_ASCII;
  PRINT_BUFFER[11] = ten_ASCII;
  PRINT_BUFFER[12] = one_ASCII;
  PRINT_BUFFER[13] = ' ';
  PRINT_BUFFER[14] = 'c';
  PRINT_BUFFER[15] = 'y';
  PRINT_BUFFER[16] = 'c';
  PRINT_BUFFER[17] = 'l';
  PRINT_BUFFER[18] = 'e';
  PRINT_BUFFER[19] = '\n';
  PRINT_BUFFER[20] = '\r';
  PRINT_BUFFER[21] = '\0';

  //fmode_cycles(s, "%c: %d\n\r\0", time, 'r');
  //asm("sw $sp, 0x1efff000");

  //Saving Registers
  asm("addiu $sp, $sp, -28");
  asm("sw $v0, 0($sp)");
  asm("sw $v1, 4($sp)");
  asm("sw $a0, 8($sp)");
  asm("sw $a1, 12($sp)");
  asm("sw $a2, 16($sp)");
  asm("sw $a3, 20($sp)");
  asm("sw $ra, 24($sp)");

  asm("lw $a0, 0x1fffff00"); //SW_RTC
  asm("jal 0xc0001030") ; //Calling FIFOWrite

  asm("lw $v0, 0($sp)");
  asm("lw $v1, 4($sp)");
  asm("lw $a0, 8($sp)");
  asm("lw $a1, 12($sp)");
  asm("lw $a2, 16($sp)");
  asm("lw $a3, 20($sp)");
  asm("lw $ra, 24($sp)");
  asm("addiu $sp, $sp, 28");

  // asm("lw $sp, 0x10f06000");
}

void r100M() {
  asm("addu $t0, $0, $0");
  asm("la $t1, 0x05f5e100");
  asm("loop:");
  asm("addiu $t0, $t0, 1");
  asm("bne $t0, $t1, loop");
  asm("nop");
}

void R100M() {
  asm("addiu $t0, $0, 0");
  asm("la $t1, 0x05f5e100");
  asm("loop1:");
  asm("jal addFunctionR");
  asm("bne $t0, $t1, loop1");
  asm("nop");
}

void addFunctionR() {
  asm("addiu $t0, $t0, 1");
  asm("jr $ra");
  asm("nop");
}

void v100M() {
  asm("la $t1, 0x05f5e100");
  asm("sw $0, 0x1fff0038");
  asm("loop2:");
  asm("lw $t0, 0x1fff0038");
  asm("addiu $t0, $t0, 1");
  asm("sw $t0, 0x1fff0038");
  asm("bne $t0, $t1, loop2");
  asm("nop");
}

void V100M() {
  asm("la $t1, 0x05f5e100");
  asm("sw $0, 0x1fff003c");
  asm("loop3:");
  asm("jal addFunctionV");
  asm("bne $t0, $t1, loop3");
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
  
  for ( ; ; ) { 
    
    switch(*STATE) 
      {			
      case 'r':		
	tstart = COUNT;
	r100M();
	tend = COUNT;
	time = tend - tstart;
	pTimeDifference(time);
	break;
	
      case 'R':
	// register variable, plusone function call
	break;

      case 'v':
	// volatile variable, addi
	break;
      case 'V':
	// volatile variable, plusone function call
	break;

      default:
	// print error? (optional)
	;}
  }
  return 0;
}

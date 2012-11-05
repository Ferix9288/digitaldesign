#define COUNT *((volatile unsigned int*) 0x80000010)
#define STATE *((volatile unsigned char*) 0x1fff0024)

#include "uart.h"
#include "ascii.h"

/* void fmode_cycles(char * target, char * buffer, uint32_t value, char c) */
/* { */
/*   int in = 0;	//index of next character in the input buffer to be copied */
/*   int out = 0;	//index of the position in the output buffer to be copied */
/*   char current = buffer[in];	//set the current character */
/*   char form_char;		//temp variable for format char */
/*   int j; */
/*   int div; */
/*   char temp[10]; */

/*   //copy by char into new buffer with formatting */
/*   while (current != '\0') { */
/*     if (current == '%') { */
/*       in = in + 1; */
/*       form_char = buffer[in]; */

/*       //abusing %d, should be %h */
/*       if (form_char == 'd') { */
/* 	uint32_to_ascii_hex(value, temp, 10); */
/* 	for (j = 0; j < 8; j = j + 1) { */
/* 	  target[out] = temp[j]; */
/* 	  out = out + 1; */
/* 	} */
/*       }  */
/*       else if (form_char == 'c') { */
/* 	target[out] = c; */
/* 	out = out + 1; */
/*       }  */
/*       else { */
/* 	uwrite_int8s("Error in formatting string\n\r"); */
/*       } */
/*       in = in + 1; */
/*     } else { */
/*       target[out] = buffer[in]; */
/*       out = out + 1; */
/*       in = in + 1; */
/*     } */
/*     current = buffer[in]; */
/*   } */
/*   target[out] = '\0';	//null terminate string */
/*   return; */
/* } */

void pTimeDifference() {
}

void r100M() {
  asm("addiu $t0, $0, 0");
  asm("la $t1, 0x05f5e100");
  asm("loop:");
  asm("addiu $t0, $t0, 1");
  asm("bne $t0, $t1, loop");
  asm("nop");
}

void R100M() {
  asm("addiu t0, $0, 0");
  asm("la t1, 0x05f5e100");
  asm("loop:");
  asm("jal addFunctionR");
  asm("bne $t0, $t1, loop");
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
  asm("loop:");
  asm("lw $t0, 0x1fff0038");
  asm("addiu $t0, $t0, 1");
  asm("sw $t0, 0x1fff0038");
  asm("bne $t0, $t1, loop");
  asm("nop");
}

void V100M() {
  asm("la $t1, 0x05f5e100");
  asm("sw $0, 0x1fff003c");
  asm("loop:");
  asm("jal addFunctionV");
  asm("bne $t0, $t1, loop");
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

  int tstart, tend, time;
  register int a;
  static volatile int b;
  char s[100];
  
  for ( ; ; ) { 
    
    switch(STATE) 
      {			
      case 'r':		
	tstart = COUNT;
	r100M();
	tend = COUNT;
	time = tend - tstart;
	//fmode_cycles(s, "%c: %d\n\r\0", time, 'r');
	asm("sw $sp, 0x10006000");

	//Saving Registers
	asm("addiu $sp, $sp, -28");
	asm("sw $v0, 0($sp)");
	asm("sw $v1, 4($sp)");
	asm("sw $a0, 8($sp)");
	asm("sw $a1, 12($sp)");
	asm("sw $a2, 16($sp)");
	asm("sw $a3, 20($sp)");
	asm("sw $ra, 24($sp)");

	asm("lw $a0, 0x1fff0028"); //SW_RTC
	asm("mfc0 $a1, $9");
	asm("jal 0xc0001040") ; //Calling FIFOWrite

	asm("lw $v0, 0($sp)");
	asm("lw $v1, 4($sp)");
	asm("lw $a0, 8($sp)");
	asm("lw $a1, 12($sp)");
	asm("lw $a2, 16($sp)");
	asm("lw $a3, 20($sp)");
	asm("lw $ra, 24($sp)");
	asm("addiu $sp, $sp, 28");

	asm("lw $sp, 0x10006000");
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

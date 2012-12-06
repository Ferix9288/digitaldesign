.section    .start
.global     _start

_start:
	li $sp, 0x10004000

	sw $0, 0x1fff001c #Reset InIndex
	sw $0, 0x1fff0020 #Reset OutIndex
	#addiu $t0, $0, 86
	sw $t0,0x1beef000 #Setting State = 'V'
	sw $0, 0x1fff0028 #Reset SW_RTC
	addiu $t1, $0, 1
	#sw $t1, 0x1fff002c #PRINT_EN = 1
	sw $0, 0x1fff0030 #SEC = 0
	sw $0, 0x1fff0034 #MIN = 0

	la $t0, 0x02faf000
	mtc0 $t0, $9 #Count = almost @ 1 second instantly	
	la $t1, 0x02faf080
	mtc0 $t1, $11 #Compare = 50 * 10 ^6
	la $t2, 0x0000fc01 #Status = Enabled
	mtc0 $t2, $12 #Status
	jal main

	
	
	


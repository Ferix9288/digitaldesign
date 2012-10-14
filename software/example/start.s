.section    .start
.global     _start

_start:
	addiu $s7, $0, 20
	
	li      $sp, 0x10000100
	jal     main

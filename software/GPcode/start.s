.section    .start
.global     _start

_start:
	li $sp, 0x10004000
	la $t0, 0x17800000
	li $t1, 0x01000000
	sw $t1, 0($t0)
	nop
	la $t1, 0x020000FF
	sw $t1, 4($t0)
	nop
	la $t1, 0x00100020
	sw $t1, 8($t0)
	nop
	la $t1, 0x001A002B
	sw $t1, 12($t0)
	nop
	la $t1, 0x02FF0000
	sw $t1, 16($t0)
	nop
	la $t1, 0x01230124
	sw $t1, 20($t0)
	nop
	la $t1, 0x00AA00BB
	sw $t1, 24($t0)
	nop
	sw $0, 28($t0)
	nop
	la $t2, 0x10400000
	sw $t2, 0x18000004
	nop
	la $t3, 0x17800000
	sw $t3, 0x18000000
	nop
	jr $ra
	
	
	


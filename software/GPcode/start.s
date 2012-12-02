.section    .start
.global     _start

_start:
	li $sp, 0x10004000
	la $t0, 0x19000000

	la $t1, 0x01ffffff
	sw $t1, 0($t0)
	nop
	la $t1, 0x02ff0000
	sw $t1, 4($t0)
	nop
	la $t1, 0x00000000
	sw $t1, 8($t0)
	nop
	la $t1, 0x02580320
	sw $t1, 12($t0)
	nop
	la $t1, 0x02ffffff
	sw $0, 16($t0)
	nop
	la $t1, 0x01230124
	sw $t1, 20($t0)
	nop
	la $t1, 0x02580320
	sw $t1, 24($t0)
	nop
	sw $0, 28($t0)
	nop
	la $t2, 0x10400000
	sw $t2, 0x18000004
	nop
	la $t3, 0x19000000
	sw $t3, 0x18000000
	nop
	la $t4, 0x40000000
	jr $t4
	
	
	

.section    .start
.global     _start

_start:
	li $sp, 0x10004000
	la $t0, 0x19000000

	la $t1, 0x010000ff
	sw $t1, 0($t0)
	nop
	la $t1, 0x000D000D
	sw $0, 4($t0)
	nop
	la $t1, 0x00EE00EE
	sw $t1, 8($t0)
	nop
	la $t1, 0x001A002B
	sw $0, 12($t0)
	nop
	la $t1, 0x02ffffff
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
	la $t3, 0x19000000
	sw $t3, 0x18000000
	nop
	la $t4, 0x40000000
	jr $t4
	
	
	

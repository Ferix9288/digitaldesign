.section    .start
.global     _start

_start:

#addu $t0, $0, $0
#lw $t1, 0($t0)
#nop

li $t0, 0x80000004
lw $t1, 0($t0)
nop
li $t0, 0x8000000c
lw $t2, 0($t0)
nop
li $t0, 0x80000000
lw $t3, 0($t0)
nop
li $t0, 0x80000008
li $v0, 0x000000bf
sw $v0, 0($t0)




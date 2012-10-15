.section    .start
.global     _start

_start:

#addu $t0, $0, $0
#lw $t1, 0($t0)
#nop

li $t0, 0x30000101
li $s7, 0x30000100
sb $t0, 0($s7)

nop
	
lb $t6, 0($s7)
nop

#Forwarding works
#addu $s0, $s7, $s7
#addu $s0, $s7, $s7

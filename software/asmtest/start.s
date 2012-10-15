.section    .start
.global     _start

_start:

jal works
nop
nop
nop

works:
addiu $t0, $0, 15
addiu $t1, $t0, 15

#Forwarding works
#addu $s0, $s7, $s7
#addu $s0, $s7, $s7
	


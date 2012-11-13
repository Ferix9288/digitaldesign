.section    .start
.global     _start

_start:

li      $sp, 0x10010000
addiu $t0, $0, 24
#la $k0, 0x0
#mtc0 $k0, $13
mfc0 $v0, $13
la $k0, 0xffffffff
mtc0 $k0, $12
#la $k1, 0xfffe	
#mtc0 $k1, $9
addiu $t1, $0, 24
beq $t0, $t1, Done
li $s7, 0x30000100
sw $t0, 0($s7)


nop

Error:
# Perhaps write the test number over serial

Done:
mfc0 $v0, $13
# Write success over serial




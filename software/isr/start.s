.section    .start
.global     _start

_start:
	sw $sp, 0x1ff00000 #Save Architectural Stackpointer @ this address
	la $k0, 0x1f000000
	addu $sp, $0, $k0 # $sp now points to ISR sp address
	
	mfc0 $k0, $13 #Cause
	mfc0 $k1, $12 #Status
	andi $k1, $k1, 0xfc00
	and  $k0, $k0, $k1
	andi $k1, $k0, 0x8000 
	bne  $0, $k1, timer_ISR
	andi $k1, $k0, 0x4000
	bne  $0, $k1, RTC_ISR
	andi $k1, $k0, 0x0800
	bne  $0, $k1, UART_Transmit
	andi $k1, $k0, 0x0400
	bne  $0, $k1, UART_Receive
	j    done

timer_ISR:

	#Increment SEC
	lw $k0, 0x1fff0030
	addiu $k0, $k0, 1
	sw $k0, 0x1fff0030
	
	#if print enabled, then print timer
	#otherwise, do nothing
	lw $k0, 0x1fff002c #PRINT_EN
	nop
	beq $0, $k0, timer_ISR_Done

	#Save registers
	addiu $sp, $sp, -28
	sw $v0, 0($sp)
	nop
	sw $v1, 4($sp)
	nop
	sw $a0, 8($sp)
	nop
	sw $a1, 12($sp)
	nop
	sw $a2, 16($sp)
	nop
	sw $a3, 20($sp)
	nop
	sw $ra, 24($sp)
	nop

	lw $a0, 0x1fff0028 #SW_RTC
	nop

	mfc0 $a1, $9 #Count

	#print timer
	jal ptimer

	#Restore registers
	lw $v0, 0($sp)
	nop
	lw $v1, 4($sp)
	nop
	lw $a0, 8($sp)
	nop
	lw $a1, 12($sp)
	nop
	lw $a2, 16($sp)
	nop
	lw $a3, 20($sp)
	nop
	lw $ra, 24($sp)
	nop
	addiu $sp, $sp, 28
		

timer_ISR_Done:
	mfc0 $k1, $11 #Compare
	la   $k0, 0x02faf080 #1_second
	addu $k0, $k0, $k1
	mtc0 $k0, $11 #Compare
	nop
	#mfc0 $k1, $13 #Cause
	#andi $k1, $k1, 0x7c00 #Resets Cause[15] to 0
	#mtc0 $k1, $13 #Cause
	#nop
	j    done

RTC_ISR:
	lw   $k0, 0x1fff0028 #SW_RTC
	nop
	addiu $k0, $k0, 1
	sw   $k0, 0x1fff0028 #SW_RTC
	nop
	mfc0 $k1, $13 #Cause
	andi $k1, $k1, 0xbc00 #Resets Cause[14] to 0
	mtc0 $k1, $13 #Cause
	nop
	j    done

UART_Transmit:
	#Store Architectural Registers
	#FIFORead uses v0, v1, a0, a1 ra
	addiu $sp, $sp, -20
	sw $v0, 0($sp)
	nop
	sw $v1, 4($sp)
	nop
	sw $a0, 8($sp)
	nop	
	sw $a1, 12($sp)
	nop
	sw $ra, 16($sp)
	nop

	jal FIFORead

	#Restore Architectural Registers
	lw $v0, 0($sp)
	nop
	lw $v1, 4($sp)
	nop	
	lw $a0, 8($sp)
	nop	
	lw $a1, 12($sp)
	nop
	lw $ra, 16($sp)
	nop

	addiu $sp, $sp, 20
	
	mfc0 $k1, $13 #Cause
	andi $k1, $k1, 0xf400 #Resets Cause[11] to 0
	mtc0 $k1, $13 #Cause
	nop
	j done

	
UART_Receive:
	lw   $k0, 0x8000000c #Grabbing UART DataOut
	nop
	sb $k0, 0x1fff0024 #Store UART Rx Data Byte to 'STATE'
	nop

	li $k1, 100
	beq  $k0, $k1, d_input
	li $k1, 101
	beq  $k0, $k1, e_input
	
	j    UART_Receive_Done
	
d_input:
	#Disable print of Timer
	sw $0, 0x1fff0028
	nop
	j    UART_Receive_Done
	
e_input:
	#Enable print of Timer
	addiu $k0, $0, 1
	sw $k1, 0x1fff0028
	nop

UART_Receive_Done:
	mfc0 $k1, $13 #Cause
	andi $k1, $k1, 0xf800
	mtc0 $k1, $13 #Cause
	nop
	
done:
	#Restore Stackpointer
	lw $sp, 0x1ff00000
	nop
	
	mfc0 $k1, $12 #Status
	ori  $k1, $k1, 1
	mfc0 $k0, $14 #EPC
	mtc0 $k1, $12 #Status
	nop
	jr $k0
	



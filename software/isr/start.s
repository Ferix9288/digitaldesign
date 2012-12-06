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
	lw $k0, 0x1fff0030 #Load seconds
	li $k1, 60
	beq $k0, $k1, Reset_Sec #Keep incrementing seconds one
	addiu $k0, $k0, 1
	sw $k0, 0x1fff0030
	j timer_ISR_Done

Reset_Sec:
	ori $k0, $0, 0
	sw $k0, 0x1fff0030
	#Increments Minutes by One
	lw $k1, 0x1fff0034
	addiu $k1, $k1, 1
	sw $k1, 0x1fff0034

timer_ISR_Done:
	mfc0 $k1, $11 #Compare
	la   $k0, 0x02faf080 #1_second
	addu $k0, $k0, $k1
	mtc0 $k0, $11 #Compare
	j    done

RTC_ISR:
	lw   $k0, 0x1fff0028 #SW_RTC
	addiu $k0, $k0, 1
	sw   $k0, 0x1fff0028 #SW_RTC
	mfc0 $k1, $13 #Cause
	andi $k1, $k1, 0xbc00 #Resets Cause[14] to 0
	mtc0 $k1, $13 #Cause
	j    done

UART_Transmit:

	mfc0 $k1, $13 #Cause
	andi $k1, $k1, 0xf400 #Resets Cause[11] to 0
	mtc0 $k1, $13 #Cause
	j done

	
UART_Receive:
	lw $k0, 0x8000000c
	sw $k0, 0x80000008 #Print it to the screen
	sw $k0, 0x1beef000 #store state to this address

UART_Receive_Done:
	mfc0 $k1, $13 #Cause
	andi $k1, $k1, 0xf800
	mtc0 $k1, $13 #Cause
	
done:
	#Restore Stackpointer
	lw $sp, 0x1ff00000
	mfc0 $k1, $12 #Status
	ori  $k1, $k1, 1
	mfc0 $k0, $14 #EPC
	nop
	mtc0 $k1, $12 #Status
	jr $k0



.section    .start
.global     _start

_start:
	mfc0 $k0, $13 #Cause
	mfc0 $k1, $12 #Status
	andi $k1, $k1, 0xfc00
	and  $k0, $k0, $k1
	andi $k1, $k0, 0x00008000
	bne  $k1, $0, timer_ISR
	andi $k1, $k0, 0x00004000
	bne  $k1, $0, RTC_ISR
	andi $k1, $k0, 0x00000400
	bne  $k1, $0, UART_ISR
	j    done
	nop

timer_ISR:
	mfc0 $k1, $11 #Compare
	la   $k0, 0x02faf080 #1_second
	addu $k0, $k0, $k1
	mtc0 $k0, $11 #Compare
	
	

	mfc0 $k1, $12 #Status
	andi $k1, $k1, 0xffff7fff
	mtc0 $k1, $12 #Status
	j    done
	nop

RTC_ISR:
	lw   $k0, 0xffff0000 #SW_RTC
	nop
	addi $k0, $k0, 1
	sw   $k0, 0xffff0000 #SW_RTC
	mfc0 $k1, $12 #Status
	andi $k1, $k1, 0xffffbfff
	mtc0 $k1, $12 #Status
	j    done
	nop

UART_ISR:
	lw   $k0, 0x80000004
	nop
	beq  $k0, 100, d_input
	beq  $k0, 101, e_input
	j    done
	nop

d_input:
	j    done
e_input:
	j    done

done:
	mfc0 $k1, $12 #Status
	ori  $k1, $k1, 1
	mfc0 $k0, $14 #EPC
	mtc0 $k1, $12 #Status
	j $k0
	



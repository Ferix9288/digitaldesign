.section    .start
.global     _start

_start:
	mfc0 $k0, $13 #Cause
	mfc0 $k1, $12 #Status
	j done



done:
	mfc0 $k1, $12 #Status
	ori $k1, $k1, 1
	mfc0 $k0, $14 #EPC
	mtc0 $k1, $12 #Status
	j $k0
	



start BIOSTestbench
file copy -force ../../../software/bios150v3/bios150v3.mif bios_mem.mif
file copy -force ../../../software/bios150v3/bios150v3.mif imem_blk_ram.mif
file copy -force ../../../software/bios150v3/bios150v3.mif dmem_blk_ram.mif

add wave BIOSTestbench/*

add wave BIOSTestbench/CPU/
add wave BIOSTestbench/CPU/DataPath/clk
add wave BIOSTestbench/CPU/DataPath/reset
add wave BIOSTestbench/CPU/DataPath/stall
add wave BIOSTestbench/CPU/DataPath/PC
add wave BIOSTestbench/CPU/DataPath/nextPC
add wave BIOSTestbench/CPU/DataPath/instrSrc
add wave BIOSTestbench/CPU/DataPath/DecIn

add wave BIOSTestbench/CPU/DataPath/instrMemAddr
add wave BIOSTestbench/CPU/DataPath/instrMemOut

add wave BIOSTestbench/CPU/DataPath/dataMemWriteEn
add wave BIOSTestbench/CPU/DataPath/dcache_addr
add wave BIOSTestbench/CPU/DataPath/dcache_din
add wave BIOSTestbench/CPU/DataPath/dcache_re_Ctr

add wave BIOSTestbench/CPU/DataPath/dcache_dout
add wave BIOSTestbench/CPU/DataPath/dcache_dout_Masked


add wave BIOSTestbench/CPU/DataPath/dataMemIn
add wave BIOSTestbench/CPU/DataPath/dataInMasked
add wave BIOSTestbench/CPU/DataPath/opcode*
add wave BIOSTestbench/CPU/DataPath/jump
add wave BIOSTestbench/CPU/DataPath/jE
add wave BIOSTestbench/CPU/DataPath/jalE
add wave BIOSTestbench/CPU/DataPath/jrE
add wave BIOSTestbench/CPU/DataPath/jalrE
add wave BIOSTestbench/CPU/DataPath/targetE
add wave BIOSTestbench/CPU/DataPath/InstructionDecoder/*

add wave BIOSTestbench/CPU/DataPath/rd1E
add wave BIOSTestbench/CPU/DataPath/rd2E
add wave BIOSTestbench/CPU/DataPath/rd1F
add wave BIOSTestbench/CPU/DataPath/rd2F
add wave BIOSTestbench/CPU/DataPath/branchCtr

add wave BIOSTestbench/CPU/DataPath/Fwd*
add wave BIOSTestbench/CPU/DataPath/ALUinput*
add wave BIOSTestbench/CPU/DataPath/ALUop*

add wave BIOSTestbench/CPU/DataPath/rd1Fwd
add wave BIOSTestbench/CPU/DataPath/rd2Fwd


add wave BIOSTestbench/CPU/DataPath/immediateFSigned
add wave BIOSTestbench/CPU/DataPath/immediateESigned
add wave BIOSTestbench/CPU/DataPath/immediateMSigned


add wave BIOSTestbench/CPU/DataPath/illegalRead
add wave BIOSTestbench/CPU/DataPath/ALUOut*
add wave BIOSTestbench/CPU/DataPath/regWrite*
add wave BIOSTestbench/CPU/DataPath/memToRegM
add wave BIOSTestbench/CPU/DataPath/UARTCtrM
add wave BIOSTestbench/CPU/DataPath/UARTCtrOutM
add wave BIOSTestbench/CPU/DataPath/dataMemMasked

add wave BIOSTestbench/CPU/DataPath/isBIOS_Data
add wave BIOSTestbench/CPU/DataPath/Data_BIOSOut
add wave BIOSTestbench/CPU/DataPath/writeBack

add wave BIOSTestbench/CPU/DataPath/Regfile/*
add wave BIOSTestbench/CPU/DataPath/Regfile/rf


add wave BIOSTestbench/CPU/DataPath/UARTModule/*
add wave BIOSTestbench/CPU/Controls/UARTControl/*

add wave BIOSTestbench/uart/*

run 100us

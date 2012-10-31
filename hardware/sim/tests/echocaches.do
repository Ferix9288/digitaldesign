start EchoTestbenchCaches
file copy -force ../../../software/echo/echo.mif bios_mem.mif 

add wave EchoTestbenchCaches/*
add wave EchoTestbenchCaches/mem_arch/*
add wave EchoTestbenchCaches/mem_arch/dcache/*
add wave EchoTestbenchCaches/mem_arch/icache/*

add wave EchoTestbenchCaches/UART

add wave EchoTestbenchCaches/DUT/DataPath/clk
add wave EchoTestbenchCaches/DUT/DataPath/reset
add wave EchoTestbenchCaches/DUT/DataPath/stall
add wave EchoTestbenchCaches/DUT/DataPath/PC
add wave EchoTestbenchCaches/DUT/DataPath/nextPC
add wave EchoTestbenchCaches/DUT/DataPath/instrSrc

add wave EchoTestbenchCaches/DUT/DataPath/addrPC_BIOS
add wave EchoTestbenchCaches/DUT/DataPath/nextPC_E
add wave EchoTestbenchCaches/DUT/DataPath/PC_BIOSOut
add wave EchoTestbenchCaches/DUT/DataPath/DecIn

add wave EchoTestbenchCaches/DUT/DataPath/instrMemWriteEn
add wave EchoTestbenchCaches/DUT/DataPath/icache_re_Ctr

add wave EchoTestbenchCaches/DUT/DataPath/dataMemWriteEn
add wave EchoTestbenchCaches/DUT/DataPath/dcache_addr
add wave EchoTestbenchCaches/DUT/DataPath/dcache_din
add wave EchoTestbenchCaches/DUT/DataPath/dcache_re_Ctr

add wave EchoTestbenchCaches/DUT/DataPath/dcache_dout
add wave EchoTestbenchCaches/DUT/DataPath/dcache_dout_Masked
add wave EchoTestbenchCaches/DUT/DataPath/dcache_dout_Masked_M


add wave EchoTestbenchCaches/DUT/DataPath/dataMemIn
add wave EchoTestbenchCaches/DUT/DataPath/dataInMasked
add wave EchoTestbenchCaches/DUT/DataPath/opcode*
add wave EchoTestbenchCaches/DUT/DataPath/jump
add wave EchoTestbenchCaches/DUT/DataPath/jE
add wave EchoTestbenchCaches/DUT/DataPath/jalE
add wave EchoTestbenchCaches/DUT/DataPath/jrE
add wave EchoTestbenchCaches/DUT/DataPath/jalrE
add wave EchoTestbenchCaches/DUT/DataPath/targetE
add wave EchoTestbenchCaches/DUT/DataPath/InstructionDecoder/*

add wave EchoTestbenchCaches/DUT/DataPath/rd1E
add wave EchoTestbenchCaches/DUT/DataPath/rd2E
add wave EchoTestbenchCaches/DUT/DataPath/rd1F
add wave EchoTestbenchCaches/DUT/DataPath/rd2F
add wave EchoTestbenchCaches/DUT/DataPath/branchCtr

add wave EchoTestbenchCaches/DUT/DataPath/Fwd*
add wave EchoTestbenchCaches/DUT/DataPath/ALUinput*
add wave EchoTestbenchCaches/DUT/DataPath/ALUop*

add wave EchoTestbenchCaches/DUT/DataPath/rd1Fwd
add wave EchoTestbenchCaches/DUT/DataPath/rd2Fwd


add wave EchoTestbenchCaches/DUT/DataPath/immediateFSigned
add wave EchoTestbenchCaches/DUT/DataPath/immediateESigned
add wave EchoTestbenchCaches/DUT/DataPath/immediateMSigned


add wave EchoTestbenchCaches/DUT/DataPath/illegalRead
add wave EchoTestbenchCaches/DUT/DataPath/ALUOut*
add wave EchoTestbenchCaches/DUT/DataPath/regWrite*
add wave EchoTestbenchCaches/DUT/DataPath/memToRegM
add wave EchoTestbenchCaches/DUT/DataPath/UARTCtrM
add wave EchoTestbenchCaches/DUT/DataPath/UARTCtrOutM
add wave EchoTestbenchCaches/DUT/DataPath/dataMemMasked

add wave EchoTestbenchCaches/DUT/DataPath/isBIOS_Data
add wave EchoTestbenchCaches/DUT/DataPath/Data_BIOSOut
add wave EchoTestbenchCaches/DUT/DataPath/writeBack

add wave EchoTestbenchCaches/DUT/DataPath/Regfile/*
add wave EchoTestbenchCaches/DUT/DataPath/Regfile/rf


add wave EchoTestbenchCaches/DUT/DataPath/UARTModule/*
add wave EchoTestbenchCaches/DUT/Controls/UARTControl/*

add wave EchoTestbenchCaches/uart/*
run 10000us

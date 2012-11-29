start EchoTestbenchCaches
file copy -force ../../../software/isr/isr.mif isr_mem.mif
file copy -force ../../../software/GPcode/gpcode.mif bios_mem.mif


add wave EchoTestbenchCaches/*
add wave EchoTestbenchCaches/mem_arch/*
add wave EchoTestbenchCaches/mem_arch/dcache/*
add wave EchoTestbenchCaches/mem_arch/icache/*

add wave EchoTestbenchCaches/DUT/DataPath/Coprocessor/*


add wave EchoTestbenchCaches/UART

add wave EchoTestbenchCaches/DUT/DataPath/clk
add wave EchoTestbenchCaches/DUT/DataPath/reset
add wave EchoTestbenchCaches/DUT/DataPath/stall
add wave EchoTestbenchCaches/DUT/DataPath/PC
add wave EchoTestbenchCaches/DUT/DataPath/nextPC
add wave EchoTestbenchCaches/DUT/DataPath/instrSrc
add wave EchoTestbenchCaches/DUT/DataPath/GP_FRAME
add wave EchoTestbenchCaches/DUT/DataPath/GP_CODE
add wave EchoTestbenchCaches/DUT/DataPath/is_GP_CODE
add wave EchoTestbenchCaches/DUT/DataPath/is_GP_FRAME

add wave EchoTestbenchCaches/DUT/DataPath/gpvalid/*

add wave EchoTestbenchCaches/DUT/DataPath/mtc0*
add wave EchoTestbenchCaches/DUT/DataPath/mfc0*

add wave EchoTestbenchCaches/DUT/DataPath/COP_Out
add wave EchoTestbenchCaches/DUT/DataPath/addrPC_BIOS
add wave EchoTestbenchCaches/DUT/DataPath/nextPC_E
add wave EchoTestbenchCaches/DUT/DataPath/PC_BIOSOut
add wave EchoTestbenchCaches/DUT/DataPath/dataMemWriteEn
add wave EchoTestbenchCaches/DUT/DataPath/instruction
add wave EchoTestbenchCaches/DUT/DataPath/DecIn
add wave EchoTestbenchCaches/DUT/DataPath/writeBack
add wave EchoTestbenchCaches/DUT/DataPath/icache_re
add wave EchoTestbenchCaches/DUT/DataPath/icache_addr
add wave EchoTestbenchCaches/DUT/DataPath/instruction
add wave EchoTestbenchCaches/DUT/DataPath/dcache_re
add wave EchoTestbenchCaches/DUT/DataPath/dcache_dout
add wave EchoTestbenchCaches/DUT/DataPath/dcache_dout_Masked
add wave EchoTestbenchCaches/DUT/DataPath/dataInMasked
add wave EchoTestbenchCaches/DUT/DataPath/opcode*
add wave EchoTestbenchCaches/DUT/DataPath/isBIOS_DataM

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

add wave EchoTestbenchCaches/DUT/DataPath/ALUOut*
add wave EchoTestbenchCaches/DUT/DataPath/regWrite*
add wave EchoTestbenchCaches/DUT/DataPath/memToRegM
add wave EchoTestbenchCaches/DUT/DataPath/UARTCtrM
add wave EchoTestbenchCaches/DUT/DataPath/UARTCtrOutM

add wave EchoTestbenchCaches/DUT/DataPath/isBIOS_Data
add wave EchoTestbenchCaches/DUT/DataPath/Data_BIOSOut


add wave EchoTestbenchCaches/DUT/DataPath/Regfile/*
add wave EchoTestbenchCaches/DUT/DataPath/Regfile/rf


add wave EchoTestbenchCaches/DUT/DataPath/UARTModule/*
add wave EchoTestbenchCaches/DUT/Controls/UARTControl/*

add wave EchoTestbenchCaches/uart/*
run 10us

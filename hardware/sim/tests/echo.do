start EchoTestbench
file copy -force ../../../software/echo/echo.mif imem_blk_ram.mif
file copy -force ../../../software/echo/echo.mif dmem_blk_ram.mif

add wave EchoTestbench/*

add wave EchoTestbench/CPU/
add wave EchoTestbench/CPU/DataPath/clk
add wave EchoTestbench/CPU/DataPath/reset
add wave EchoTestbench/CPU/DataPath/PC
add wave EchoTestbench/CPU/DataPath/nextPC
add wave EchoTestbench/CPU/DataPath/instrMemAddr
add wave EchoTestbench/CPU/DataPath/instrMemOut
add wave EchoTestbench/CPU/DataPath/DataMemory/*
add wave EchoTestbench/CPU/DataPath/dataMemIn
add wave EchoTestbench/CPU/DataPath/dataInMasked
add wave EchoTestbench/CPU/DataPath/opcode*


add wave EchoTestbench/CPU/DataPath/rd1E
add wave EchoTestbench/CPU/DataPath/rd2E
add wave EchoTestbench/CPU/DataPath/rd1F
add wave EchoTestbench/CPU/DataPath/rd2F
add wave EchoTestbench/CPU/DataPath/branchCtr

add wave EchoTestbench/CPU/DataPath/Fwd*
add wave EchoTestbench/CPU/DataPath/ALUinput*
add wave EchoTestbench/CPU/DataPath/ALUop*

add wave EchoTestbench/CPU/DataPath/immediateFSigned
add wave EchoTestbench/CPU/DataPath/immediateESigned
add wave EchoTestbench/CPU/DataPath/immediateMSigned


add wave EchoTestbench/CPU/DataPath/ALUOut*
add wave EchoTestbench/CPU/DataPath/regWrite*
add wave EchoTestbench/CPU/DataPath/writeBack

add wave EchoTestbench/CPU/DataPath/DataOutReadyE;
add wave EchoTestbench/CPU/DataPath/DataOutReadyM;

add wave EchoTestbench/CPU/DataPath/Regfile/*
add wave EchoTestbench/CPU/DataPath/Regfile/rf

add wave EchoTestbench/CPU/DataPath/UARTModule/*
add wave EchoTestbench/CPU/DataPath/UARTModule/uatransmit/*
add wave EchoTestbench/CPU/DataPath/UARTModule/uareceive/*
add wave EchoTestbench/CPU/Controls/UARTControl/*

add wave EchoTestbench/uart/*

run 2000000us

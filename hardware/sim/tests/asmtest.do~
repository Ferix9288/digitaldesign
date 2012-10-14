start asmTestbench
file copy -force ../../../software/asmtest/asmtest.mif imem_blk_ram.mif
file copy -force ../../../software/asmtest/asmtest.mif dmem_blk_ram.mif
add wave asmTestbench/
add wave asmTestbench/CPU/
add wave asmTestbench/CPU/DataPath/clk
add wave asmTestbench/CPU/DataPath/PC
add wave asmTestbench/CPU/DataPath/nextPC
add wave asmTestbench/CPU/DataPath/instrMemAddr
add wave asmTestbench/CPU/DataPath/instrMemOut

add wave asmTestbench/CPU/DataPath/functF
add wave asmTestbench/CPU/DataPath/opcodeF
add wave asmTestbench/CPU/DataPath/regWrite


add wave asmTestbench/CPU/DataPath/Dec*
add wave asmTestbench/CPU/DataPath/ALUop*
add wave asmTestbench/CPU/DataPath/rd1*
add wave asmTestbench/CPU/DataPath/rd2*
add wave asmTestbench/CPU/DataPath/ALUsrc*
add wave asmTestbench/CPU/DataPath/immediateFSigned
add wave asmTestbench/CPU/DataPath/immediateESigned

add wave asmTestbench/CPU/DataPath/waM
add wave asmTestbench/CPU/DataPath/rtE
add wave asmTestbench/CPU/DataPath/regWriteM

add wave asmTestbench/CPU/DataPath/Fwd*
add wave asmTestbench/CPU/DataPath/ALUinput*
add wave asmTestbench/CPU/DataPath/ALUOut*

add wave asmTestbench/CPU/Controls/*
run 10000us

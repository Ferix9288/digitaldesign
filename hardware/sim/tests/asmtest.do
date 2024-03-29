start asmTestbench
file copy -force ../../../software/asmtest/asmtest.mif imem_blk_ram.mif
file copy -force ../../../software/asmtest/asmtest.mif dmem_blk_ram.mif
add wave asmTestbench/
add wave asmTestbench/CPU/
add wave asmTestbench/CPU/DataPath/clk
add wave asmTestbench/CPU/DataPath/reset
add wave asmTestbench/CPU/DataPath/PC
add wave asmTestbench/CPU/DataPath/nextPC
add wave asmTestbench/CPU/DataPath/instrMemAddr
add wave asmTestbench/CPU/DataPath/instrMemOut
add wave asmTestbench/CPU/DataPath/jalr*

add wave asmTestbench/CPU/DataPath/dataInMasked

add wave asmTestbench/CPU/DataPath/pc*

add wave asmTestbench/CPU/DataPath/rs*
add wave asmTestbench/CPU/DataPath/rt*
add wave asmTestbench/CPU/DataPath/waM
add wave asmTestbench/CPU/DataPath/Fwd*

add wave asmTestbench/CPU/DataPath/rd1E
add wave asmTestbench/CPU/DataPath/rd2E
add wave asmTestbench/CPU/DataPath/branchCtr



add wave asmTestbench/CPU/DataPath/Regfile/*
add wave asmTestbench/CPU/DataPath/Regfile/rf

add wave asmTestbench/CPU/DataPath/rsF
add wave asmTestbench/CPU/DataPath/rtF
add wave asmTestbench/CPU/DataPath/rd1*
add wave asmTestbench/CPU/DataPath/rd2*

add wave asmTestbench/CPU/DataPath/ALUsrc*

add wave asmTestbench/CPU/DataPath/immediateFSigned
add wave asmTestbench/CPU/DataPath/immediateESigned

add wave asmTestbench/CPU/DataPath/ALUinput*
add wave asmTestbench/CPU/DataPath/ALUOut*

add wave asmTestbench/CPU/DataPath/InstrMemory/*
add wave asmTestbench/CPU/DataPath/DataMemory/*
add wave asmTestbench/CPU/DataPath/dataMemOut
add wave asmTestbench/CPU/DataPath/dataMemMasked
add wave asmTestbench/CPU/DataPath/jal
add wave asmTestbench/CPU/DataPath/regDst*



add wave asmTestbench/CPU/DataPath/memToRegM
add wave asmTestbench/CPU/DataPath/writeBack
add wave asmTestbench/CPU/DataPath/regWrite*

add wave asmTestbench/CPU/DataPath/UARTCtr
add wave asmTestbench/CPU/DataPath/UARTCtrOut

add wave asmTestbench/CPU/Controls/
add wave asmTestbench/CPU/Controls/UARTControl/*
run 10000us

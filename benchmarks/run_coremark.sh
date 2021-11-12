#!/bin/bash
function test() {
    echo "Testing $CPU with $ELF"
    ./pytest_processor.py $CPU --elf $ELF --timeout 180 --expected "Correct operation validated" --absent "Errors detected" > out.txt
    if [ $? -eq 0 ]; then
        VAL=`cat out.txt | grep Iterations/Sec`
        echo "$CPU Coremark $VAL"
        NUM=`echo $VAL | awk -F: '{print $NF}'`
        VAL_HZ=`echo "$NUM/$CPU_MHZ" | bc -l`
        echo "$CPU Coremark Iterations/(Sec*MHz) : $VAL_HZ"
    else
        echo "$CPU benchmark failed"
        exit
    fi
    rm out.txt
}

CPU_MHZ=50
for CPU in chisel_p1 bluespec_p1
do
    ELF=benchmarks/coremark/binaries/coremark_P1-riscv-bare-metal-GCC.elf 
    test

    ELF=benchmarks/coremark/binaries/coremark_P1-riscv-bare-metal-LLVM.elf 
    test
done

CPU_MHZ=100
for CPU in chisel_p2 bluespec_p2
do
    ELF=benchmarks/coremark/binaries/coremark_P2-riscv-bare-metal-GCC.elf 
    test

    ELF=benchmarks/coremark/binaries/coremark_P2-riscv-bare-metal-LLVM.elf 
    test
done

CPU_MHZ=25
for CPU in chisel_p3 bluespec_p3
do
    ELF=benchmarks/coremark/binaries/coremark_P3-riscv-bare-metal-GCC.elf 
    test

    ELF=benchmarks/coremark/binaries/coremark_P3-riscv-bare-metal-LLVM.elf 
    test
done

echo "Testing non-bare-metal coremark (running as a process on FreeBSD/Linux) is not automated, skipping..."
echo "Done!"

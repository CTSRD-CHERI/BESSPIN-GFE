#!/usr/bin/env bash

# Get the path to the root folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $BASE_DIR
source $BASE_DIR/setup_env.sh

# utility function to move old bootrom folder out of the way
move_old_bootrom() {
    if [ -d "$BASE_DIR/bootrom-configured" ]; then
        echo "moving old configured bootrom"
        msec=`date +%s`
        mv "$BASE_DIR/bootrom-configured" "$BASE_DIR/bootrom-configured.$msec"
    fi
}

proc_name=""
proc_path=""
# Clock frequency is in MHz
clock_freq_mhz=50

usage() {
    echo >&2 "Usage: $0 [--mem-size MEM_SIZE] <proc> [bootrom]"
    exit 1
}

if [ $# -lt 1 ]; then
    usage
fi

while [ $# -ge 1 ]; do
    case "$1" in
    --mem-size=*)
        mem_size=${1#--mem-size=}
        shift
        ;;
    --mem-size)
        shift
        if [ $# -lt 1 ]; then
            usage
        fi
        mem_size=$1
        shift
        ;;
    --*)
        echo >&2 "Unknown option ${1#--*=}"
        exit 1
        ;;
    *)
        break
        ;;
    esac
done

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    usage
fi

# Parse the processor selection
proc_picker $1

no_xdma=1

if [[ $proc_name == *p2_pcie ]]; then
    no_xdma=0
    echo "enabling PCIe, disabling SVF"
fi
    
# Set up the bootrom directory

if [ -z "$2" ]; then
    # if there isn't a second parameter, use the default bootrom
    echo "generating default bootrom"
    move_old_bootrom
    cp -pr "$BASE_DIR/bootrom" "$BASE_DIR/bootrom-configured"
elif [ -f "$2" ]; then
    # if the second parameter points to an existing file, first check to see
    # that it's a binary image, i.e., _not_ an ELF
    filetype=`file -b $2`
    if [[ $filetype == ELF* ]]; then
        err_msg 1 "secure bootrom requires binary image, not ELF"
    fi
    # if it is, measure it and configure the bootrom
    sha=`sha256sum $2 | awk '{print $1}'`
    len=`ls -nl $2 | awk '{print $5}'`
    echo "generating secure bootrom for binary '$2'"
    echo "       length: $len"
    echo "    sha256sum: $sha"
    move_old_bootrom
    cp -pr "$BASE_DIR/bootrom-secure" "$BASE_DIR/bootrom-configured"
    $BASE_DIR/bootrom-configured/configure.sh $sha $len
    err_msg $? "failed to configure the secure bootrom"
else
    proc_usage
    err_msg 1 "specified secure boot binary image doesn't exist"
fi

# Compile the bootrom and set the clock frequency
cd $BASE_DIR/bootrom-configured
case "$proc_name" in
    *p1)
	make --always-make XLEN=32 CROSS_COMPILE=riscv64-unknown-elf- CPU_SPEED=50000000 NO_PCI=$no_xdma ${mem_size:+MEM_SIZE=$mem_size} PROC_HASH=$proc_hash GFE_HASH=$gfe_hash
	clock_freq_mhz=50
	;;
    *p2*)
	make --always-make XLEN=64 CROSS_COMPILE=riscv64-unknown-elf- CPU_SPEED=100000000 NO_PCI=$no_xdma ${mem_size:+MEM_SIZE=$mem_size} PROC_HASH=$proc_hash GFE_HASH=$gfe_hash
	clock_freq_mhz=100
	;;
    bluespec_p3)
	make --always-make XLEN=64 CROSS_COMPILE=riscv64-unknown-elf- CPU_SPEED=25000000 RTC_FREQ=250000 MEM_SIZE=${mem_size:-0xbe000000} NO_PCI=$no_xdma NUM_CORES=$num_cores PROC_HASH=$proc_hash GFE_HASH=$gfe_hash
	clock_freq_mhz=25
	;;
    chisel_p3)
	make --always-make XLEN=64 CROSS_COMPILE=riscv64-unknown-elf- CPU_SPEED=25000000 NO_PCI=$no_xdma ${mem_size:+MEM_SIZE=$mem_size} PROC_HASH=$proc_hash GFE_HASH=$gfe_hash
	clock_freq_mhz=25
	;;
    *)
	echo "WARNING: don't know how to make a boot ROM for processor $proc_name"
	;;
esac

err_msg $? "Making the bootrom failed"

echo "Please run with Vivado 2019.1"
# i.e.
# source /Xilinx/Vivado/2019.1/settings64.sh
mkdir -p $BASE_DIR/vivado
cd $BASE_DIR/vivado

# Run vivado to create a top level project
# See soc.tcl for detailed options
LD_PRELOAD=/lib/x86_64-linux-gnu/libudev.so.1 \
vivado -mode batch -source $BASE_DIR/tcl/soc.tcl \
-tclargs --origin_dir $BASE_DIR/tcl \
--proc_name $proc_name \
--clock_freq_mhz $clock_freq_mhz \
--no_xdma $no_xdma

err_msg $? "Creating the vivado project failed"

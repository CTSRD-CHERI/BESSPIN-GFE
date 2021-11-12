#!/usr/bin/env bash

set -ex

# Initialize the minimum number of submodules necessary to build the project
# This reduces the runtime of git status and other git commands
git submodule sync

git submodule update --init benchmarks/coremark
git submodule update --init benchmarks/mibench2
git submodule update --init riscv-openocd
git submodule update --init FreeRTOS-mirror
git submodule update --init busybox
git submodule update --init newlib
git submodule update --init freebsd/cheribsd

git submodule update --init --recursive \
    riscv-tests
git submodule update --init --recursive \
    bluespec-processors/P1/Piccolo
git submodule update --init --recursive \
    bluespec-processors/P2/Flute
git submodule update --init --recursive \
    bluespec-processors/P3/Toooba
git submodule update --init --recursive \
    riscv-linux
git submodule update --init --recursive \
    riscv-pk

# chisel_processors has a co-dependency loop (between ucb-bar/chipyar and firesim/firesim)
git submodule update --init chisel_processors
git -C chisel_processors submodule sync
git -C chisel_processors submodule update --init rocket-chip
git -C chisel_processors submodule update --init chipyard
git -C chisel_processors/rocket-chip submodule sync
git -C chisel_processors/rocket-chip submodule update --init firrtl chisel3 hardfloat

# cloud GFE
git submodule update --init cloudGFE
git -C cloudGFE submodule update --init FireSim/firesim

#!/bin/bash
# This script installs GFE dependencies on Debian 10.
# It should only be run as root, once per host, from the repo root dir.
set -eux

# General toolchain dependencies
apt-get install -y automake autotools-dev libmpc-dev libmpfr-dev libgmp-dev gawk
apt-get install -y build-essential gperf patchutils zlib1g-dev libexpat-dev

# For riscv-linux build:
apt-get install -y curl openssl bc bison flex make autoconf debootstrap proot
apt-get install -y libssl-dev debian-ports-archive-keyring device-tree-compiler

# RTL simulator and RISC-V emulator:
apt-get install -y verilator qemu qemu-user qemu-system-misc

# Needed for GDB
apt-get install -y libpython2.7

# OpenOCD dependencies
apt-get install -y libftdi1-2 libusb-1.0-0-dev

# Needed for manual tests
apt-get install -y minicom

# System-wide python packages needed by testing scripts
apt-get install -y python3-pip
pip3 install pyserial pexpect

# Xilinx vivado_lab dependency
apt-get install -y libtinfo5

# Instal dependencies for FreeBSD
apt-get install -y libtool pkg-config cmake ninja-build samba texinfo libarchive-dev
apt-get install -y libglib2.0-dev libpixman-1-dev libarchive-dev libarchive-tools libbz2-dev

# hexdump util
apt-get install -y bsdmainutils

# Install and configure TFTP server
apt-get install -y atftpd
chmod 777 /srv/tftp

# This script installs GFE dependencies on Debian 10.
# It should only be run as root, once per host.

set -eux

# Git LFS for managing large binary files
apt-get install -y git-lfs
git-lfs install

# Vivado Lab 2017.4 needs an old version of libtinfo:
apt-get install -y libtinfo5
# It may also need debug cable drivers and a udev rule:
pushd /opt/Xilinx/Vivado_Lab/2017.4/data/xicom/cable_drivers/lin64/install_script/install_drivers/
source install_drivers
popd
# Make vivado_lab available to all users:
echo 'source /opt/Xilinx/Vivado_Lab/2017.4/settings64.sh' | tee -a /etc/bash.bashrc

# For riscv-linux build:
apt-get install -y openssl bc bison flex make autoconf

# RTL simulator and RISC-V emulator:
apt-get install -y verilator qemu

# OpenOCD
apt-get install -y libftdi1-2 libusb-1.0-0-dev libtool pkg-config texinfo
pushd riscv-openocd
./bootstrap
./configure --enable-remote-bitbang --enable-jtag_vpi --enable-ftdi
make
make install
popd
# TODO: maybe provide a pre-built binary instead of the submodule?

# RISC-V toolchains (both linux and newlib versions):
tar -C / -xf install/riscv-gnu-toolchains.tar.gz
# Make these available to all users:
echo 'export RISCV=/opt/riscv' | tee -a /etc/bash.bashrc
echo 'export PATH=/opt/riscv/bin:$PATH' | tee -a /etc/bash.bashrc

# System-wide python packages needed by testing scripts
apt-get install -y python3-pip
pip3 install pyserial pexpect

# Clang and LLVM for RISC-V:
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
add-apt-repository 'http://apt.llvm.org/buster/ llvm-toolchain-buster-9 main'
apt-get update
# XXX 2019-10-07 the install below fails with some weird 'unmet dependencies'
# See https://bugs.llvm.org/show_bug.cgi?id=43451
# Restore when LLVM 9 packages are working again:
# apt-get install -y clang-9 lldb-9 lld-9 clangd-9
# Compile and archive both linux and newlib versions of
# riscv-gnu-toolchain on Debian 10.1
# This should be run with sudo, and takes several hours to complete.

set -eux

# Avoid overwriting any existing /opt/riscv directory
if [ -d /opt/riscv ]; then
    mv /opt/riscv /opt/riscv.old
fi

# System packages needed for the build:
apt-get install -y autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev

if [ ! -d riscv-gnu-toolchain ]; then
    git clone https://github.com/riscv/riscv-gnu-toolchain
fi
cd riscv-gnu-toolchain
git clean -f
rm -f Makefile
git pull
# Snapshot of master on 2019-10-10 -- update as needed
git checkout d5bea51083ec38172b84b7cd5ee99bfcb8d2e7b0
git submodule update --init --recursive
./configure --prefix /opt/riscv --enable-multilib --with-cmodel=medany
make linux
make
cd ..

tar -czf riscv-gnu-toolchains.tar.gz /opt/riscv
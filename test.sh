#!/usr/bin/env bash

echo "This script is obsolete, use pytest_processor.py instead."
echo "Press ENTER if you want to continue, or CTRL-C to abort"
read

# Get the path to the script folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BASE_DIR/setup_env.sh
err_msg $SETUP_ENV_ERR "Sourcing setup_env.sh failed"
cd $BASE_DIR/testing/scripts

xlen_picker $1

case $2 in
    *p1) PROC=P1 ;;
    *p2) PROC=P2 ;;
    *p3) PROC=P3 ;;
    *)
	echo "ERROR: unknown processor: $2"
	exit 1
	;;
esac

# Compile a set of assembly tests for the GFE
cd $BASE_DIR/testing/baremetal/asm
make XLEN=${XLEN}
err_msg $? "Making the assembly tests failed"

# Compile riscv-tests
cd $BASE_DIR/riscv-tests
CC=riscv64-unknown-elf-gcc ./configure --with-xlen=${XLEN} --target=riscv64-unknown-elf
make
err_msg $? "Failed to make isa tests"

# Run some unittests including UART, DDR, and Bootrom
# The final unittest tests booting freeRTOS
cd $BASE_DIR/testing/scripts
./test_gfe_unittest.py TestGfe${PROC}
err_msg $? "GFE unittests failed. Run python test_gfe_unittest.py"

# Generate gdb isa test script
cd $BASE_DIR/testing/scripts
python softReset.py
cd $BASE_DIR
if [ ${XLEN} == 64 ]
then
  ./testing/scripts/gen-test-all rv64gcsu > test_64.gdb
else
  # TODO: Re-enable a
  ./testing/scripts/gen-test-all rv32imcu > test_32.gdb
fi

# Run the isa tests
riscv64-unknown-elf-gdb --batch -x $BASE_DIR/test_${XLEN}.gdb
echo "riscv-tests summary:"
grep -E "(PASS|FAIL)" gdb-client.log | uniq -c 
# Return a non-zero exit code on failure
if grep -q "FAIL" gdb-client.log; then
	err_msg 1 "ISA tests failed"
fi
if ! grep -q "PASS" gdb-client.log; then
	err_msg 1 "ISA tests failed: No tests were run"
fi

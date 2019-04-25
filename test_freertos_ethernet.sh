#!/usr/bin/env bash

# Remember to change address of TCP echo server for test to pass

# Get the path to the script folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BASE_DIR/setup_env.sh
err_msg $SETUP_ENV_ERR "Sourcing setup_env.sh failed"
cd $BASE_DIR/testing/scripts

freertos_folder=$BASE_DIR/FreeRTOS-mirror/FreeRTOS/Demo/RISC-V_Galois_P1/
python_unittest_script=test_gfe_unittest.py

function freertos_test {
	cd $freertos_folder
	make clean; PROG=$1 make
	err_msg $? "Building FreeRTOS-RISCV PROG=$1 test failed"

	cd $BASE_DIR/testing/scripts
	python $python_unittest_script TestFreeRTOS.$2
	err_msg $? "FreeRTOS test TestFreeRTOS.$2 failed"
}

freertos_test main_tcp test_ethernet
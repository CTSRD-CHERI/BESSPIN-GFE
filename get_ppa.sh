#!/usr/bin/env bash

echo "Please run with Vivado 2019.1"
# i.e.
# source /Xilinx/Vivado/2019.1/settings64.sh

# Get the path to the root folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BASE_DIR/setup_env.sh

proc_picker $1

# Check that the vivado project exits
project_name=soc_${proc_name}
vivado_project=$BASE_DIR/vivado/${project_name}/${project_name}.xpr
check_file $vivado_project "$vivado_project does not exist. Cannot build project.
Please run setup_soc_project.sh first and/or specify a valid proc_name For example,
run ./build.sh chisel_p1"

# Run vivado to build a top level project
cd $BASE_DIR/vivado
LD_PRELOAD=/lib/x86_64-linux-gnu/libudev.so.1 vivado -mode batch $vivado_project -source $BASE_DIR/tcl/get_ppa.tcl > get_ppa.log
err_msg $? "Vivado ppa extraction failed"

echo "Power:"
echo "-----"

echo "Overall"
grep -B 1 -A 1 "| On-Chip.*Power (W)" power_report.log
grep "| CLB Logic" power_report.log
echo

echo "Hierarchical (selecting relevant entries):"
grep -B 1 -A 1 "| Name.*Logic (W)" power_report.log
grep "| design_1 " power_report.log
grep "| *ssith_processor_0 " power_report.log
grep "| *tagController_tmp_tagCon " power_report.log

echo
echo
echo

echo "Timing:"
echo "------"
echo "Slack"
grep -A 2 -m 1 "WNS" timing_report.log

echo
echo "Target"
grep -m 1 "Waveform(ns)" timing_report.log
grep -m 1 "mmcm_clkout1" timing_report.log

echo
echo
echo

echo "Area:"
echo "----"
echo "Overall"
grep -m 1 -B 1 -A 2 " *Site Type" util_report_overall.log
grep -m 1 "| CLB Registers" util_report_overall.log
echo

echo "Hierarchical (selecting relevant entries):"
grep -B 1 -A 1 "| *Instance" util_report_hier.log
grep "| design_1 " util_report_hier.log
grep "| *ssith_processor_0 " util_report_hier.log
grep "| *tagController" util_report_hier.log

exit 0

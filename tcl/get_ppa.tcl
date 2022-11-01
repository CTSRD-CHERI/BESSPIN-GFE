open_run impl_1
report_timing_summary -file timing_report.log
report_power -hierarchical_depth 5 -verbose -hier all -file power_report.log
report_utilization -file util_report_overall.log
report_utilization -hierarchical -hierarchical_depth 20 -file util_report_hier.log

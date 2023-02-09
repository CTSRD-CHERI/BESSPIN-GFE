###  -*-Makefile-*-

XLEN      = 64
ISA       = ACDFIMSU
PROCESSOR = Toooba
PROCESSOR_RTL = $(REPO)/bluespec-processors/P3/$(PROCESSOR)/src_SSITH_P3/Verilog_RTL_sim
TOPNAME   = mkP3_Core
WD_ID     = 7
SOC_MAP_SUFFIX = _Veril
INCLUDE_TANDEM_VERIF = no

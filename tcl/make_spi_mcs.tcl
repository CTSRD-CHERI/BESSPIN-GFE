set bitstream [ lindex $::argv 0 ]
set mcsfile [ lindex $::argv 1 ]
write_cfgmem -force -format MCS -size 64 -interface SPIx8 -loadbit "up 0x00000000 ${bitstream}" -file ${mcsfile}

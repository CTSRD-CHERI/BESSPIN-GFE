# -*- gdb-script -*-
# this file was automatically generated by gen-test-all

set architecture riscv:rv64
set remotetimeout 5000
set remotelogfile logs/gdb-remote.log
set logging overwrite
set logging file logs/gdb-client.log
set logging on
set pagination off

target remote | ./openocd --file openocd.cfg --log_output logs/openocd.log --debug

define run_prog
  dont-repeat
 
  monitor reset run
  monitor halt
 
  delete
  printf "Loading $arg0\n"
  file $arg0
  load
 
  break exit
  commands
    info registers
  end
 
  continue
 
end

define run_test_p
  dont-repeat

  monitor halt

  delete
  printf "Loading $arg0\n"
  file $arg0
  load

  break write_tohost
  commands
    if $gp == 1
      printf "PASS\n"
    else
      printf "FAIL (tohost=%x)\n", $gp
    end
    # clean-up after the previous test
    delete
    # reset the SoC
    set {int}0x6fff0000=0x1
    # reset the core
    monitor reset run
  end

  continue

end

define run_test_v
  dont-repeat

  monitor halt
  printf "Loading $arg0\n"
  file $arg0
  load

  break terminate
  commands
    if $a0 == 1
      printf "PASS\n"
    else
      printf "FAIL (tohost=%x)\n", $a0
    end
  end

  continue

  if $a0 == 1
    printf "PASS\n"
  else
    printf "FAIL (tohost=%x)\n", $a0
  end

  # clean-up after the previous test
  delete
  # reset the SoC
  set {int}0x6fff0000=0x1

  # reset the core
  monitor reset run
end

run_test_p Tests/isa/rv64mi-p-access
#run_test_p Tests/isa/rv64mi-p-breakpoint
run_test_p Tests/isa/rv64mi-p-csr
run_test_p Tests/isa/rv64mi-p-illegal
run_test_p Tests/isa/rv64mi-p-ma_addr
run_test_p Tests/isa/rv64mi-p-ma_fetch
run_test_p Tests/isa/rv64mi-p-mcsr
#run_test_p Tests/isa/rv64mi-p-sbreak
run_test_p Tests/isa/rv64mi-p-scall
run_test_p Tests/isa/rv64si-p-csr
run_test_p Tests/isa/rv64si-p-dirty
run_test_p Tests/isa/rv64si-p-ma_fetch
#run_test_p Tests/isa/rv64si-p-sbreak
run_test_p Tests/isa/rv64si-p-scall
run_test_p Tests/isa/rv64si-p-wfi
run_test_p Tests/isa/rv64ua-p-amoadd_d
run_test_p Tests/isa/rv64ua-p-amoadd_w
run_test_p Tests/isa/rv64ua-p-amoand_d
run_test_p Tests/isa/rv64ua-p-amoand_w
run_test_p Tests/isa/rv64ua-p-amomax_d
run_test_p Tests/isa/rv64ua-p-amomaxu_d
run_test_p Tests/isa/rv64ua-p-amomaxu_w
run_test_p Tests/isa/rv64ua-p-amomax_w
run_test_p Tests/isa/rv64ua-p-amomin_d
run_test_p Tests/isa/rv64ua-p-amominu_d
run_test_p Tests/isa/rv64ua-p-amominu_w
run_test_p Tests/isa/rv64ua-p-amomin_w
run_test_p Tests/isa/rv64ua-p-amoor_d
run_test_p Tests/isa/rv64ua-p-amoor_w
run_test_p Tests/isa/rv64ua-p-amoswap_d
run_test_p Tests/isa/rv64ua-p-amoswap_w
run_test_p Tests/isa/rv64ua-p-amoxor_d
run_test_p Tests/isa/rv64ua-p-amoxor_w
run_test_p Tests/isa/rv64ua-p-lrsc
run_test_v Tests/isa/rv64ua-v-amoadd_d
run_test_v Tests/isa/rv64ua-v-amoadd_w
run_test_v Tests/isa/rv64ua-v-amoand_d
run_test_v Tests/isa/rv64ua-v-amoand_w
run_test_v Tests/isa/rv64ua-v-amomax_d
run_test_v Tests/isa/rv64ua-v-amomaxu_d
run_test_v Tests/isa/rv64ua-v-amomaxu_w
run_test_v Tests/isa/rv64ua-v-amomax_w
run_test_v Tests/isa/rv64ua-v-amomin_d
run_test_v Tests/isa/rv64ua-v-amominu_d
run_test_v Tests/isa/rv64ua-v-amominu_w
run_test_v Tests/isa/rv64ua-v-amomin_w
run_test_v Tests/isa/rv64ua-v-amoor_d
run_test_v Tests/isa/rv64ua-v-amoor_w
run_test_v Tests/isa/rv64ua-v-amoswap_d
run_test_v Tests/isa/rv64ua-v-amoswap_w
run_test_v Tests/isa/rv64ua-v-amoxor_d
run_test_v Tests/isa/rv64ua-v-amoxor_w
run_test_v Tests/isa/rv64ua-v-lrsc
run_test_p Tests/isa/rv64uc-p-rvc
run_test_v Tests/isa/rv64uc-v-rvc
run_test_p Tests/isa/rv64ud-p-fadd
run_test_p Tests/isa/rv64ud-p-fclass
run_test_p Tests/isa/rv64ud-p-fcmp
run_test_p Tests/isa/rv64ud-p-fcvt
run_test_p Tests/isa/rv64ud-p-fcvt_w
run_test_p Tests/isa/rv64ud-p-fdiv
run_test_p Tests/isa/rv64ud-p-fmadd
run_test_p Tests/isa/rv64ud-p-fmin
run_test_p Tests/isa/rv64ud-p-ldst
run_test_p Tests/isa/rv64ud-p-move
run_test_p Tests/isa/rv64ud-p-recoding
run_test_p Tests/isa/rv64ud-p-structural
run_test_v Tests/isa/rv64ud-v-fadd
run_test_v Tests/isa/rv64ud-v-fclass
run_test_v Tests/isa/rv64ud-v-fcmp
run_test_v Tests/isa/rv64ud-v-fcvt
run_test_v Tests/isa/rv64ud-v-fcvt_w
run_test_v Tests/isa/rv64ud-v-fdiv
run_test_v Tests/isa/rv64ud-v-fmadd
run_test_v Tests/isa/rv64ud-v-fmin
run_test_v Tests/isa/rv64ud-v-ldst
run_test_v Tests/isa/rv64ud-v-move
run_test_v Tests/isa/rv64ud-v-recoding
run_test_v Tests/isa/rv64ud-v-structural
run_test_p Tests/isa/rv64uf-p-fadd
run_test_p Tests/isa/rv64uf-p-fclass
run_test_p Tests/isa/rv64uf-p-fcmp
run_test_p Tests/isa/rv64uf-p-fcvt
run_test_p Tests/isa/rv64uf-p-fcvt_w
run_test_p Tests/isa/rv64uf-p-fdiv
run_test_p Tests/isa/rv64uf-p-fmadd
run_test_p Tests/isa/rv64uf-p-fmin
run_test_p Tests/isa/rv64uf-p-ldst
run_test_p Tests/isa/rv64uf-p-move
run_test_p Tests/isa/rv64uf-p-recoding
run_test_v Tests/isa/rv64uf-v-fadd
run_test_v Tests/isa/rv64uf-v-fclass
run_test_v Tests/isa/rv64uf-v-fcmp
run_test_v Tests/isa/rv64uf-v-fcvt
run_test_v Tests/isa/rv64uf-v-fcvt_w
run_test_v Tests/isa/rv64uf-v-fdiv
run_test_v Tests/isa/rv64uf-v-fmadd
run_test_v Tests/isa/rv64uf-v-fmin
run_test_v Tests/isa/rv64uf-v-ldst
run_test_v Tests/isa/rv64uf-v-move
run_test_v Tests/isa/rv64uf-v-recoding
run_test_p Tests/isa/rv64ui-p-add
run_test_p Tests/isa/rv64ui-p-addi
run_test_p Tests/isa/rv64ui-p-addiw
run_test_p Tests/isa/rv64ui-p-addw
run_test_p Tests/isa/rv64ui-p-and
run_test_p Tests/isa/rv64ui-p-andi
run_test_p Tests/isa/rv64ui-p-auipc
run_test_p Tests/isa/rv64ui-p-beq
run_test_p Tests/isa/rv64ui-p-bge
run_test_p Tests/isa/rv64ui-p-bgeu
run_test_p Tests/isa/rv64ui-p-blt
run_test_p Tests/isa/rv64ui-p-bltu
run_test_p Tests/isa/rv64ui-p-bne
run_test_p Tests/isa/rv64ui-p-fence_i
run_test_p Tests/isa/rv64ui-p-jal
run_test_p Tests/isa/rv64ui-p-jalr
run_test_p Tests/isa/rv64ui-p-lb
run_test_p Tests/isa/rv64ui-p-lbu
run_test_p Tests/isa/rv64ui-p-ld
run_test_p Tests/isa/rv64ui-p-lh
run_test_p Tests/isa/rv64ui-p-lhu
run_test_p Tests/isa/rv64ui-p-lui
run_test_p Tests/isa/rv64ui-p-lw
run_test_p Tests/isa/rv64ui-p-lwu
run_test_p Tests/isa/rv64ui-p-or
run_test_p Tests/isa/rv64ui-p-ori
run_test_p Tests/isa/rv64ui-p-sb
run_test_p Tests/isa/rv64ui-p-sd
run_test_p Tests/isa/rv64ui-p-sh
run_test_p Tests/isa/rv64ui-p-simple
run_test_p Tests/isa/rv64ui-p-sll
run_test_p Tests/isa/rv64ui-p-slli
run_test_p Tests/isa/rv64ui-p-slliw
run_test_p Tests/isa/rv64ui-p-sllw
run_test_p Tests/isa/rv64ui-p-slt
run_test_p Tests/isa/rv64ui-p-slti
run_test_p Tests/isa/rv64ui-p-sltiu
run_test_p Tests/isa/rv64ui-p-sltu
run_test_p Tests/isa/rv64ui-p-sra
run_test_p Tests/isa/rv64ui-p-srai
run_test_p Tests/isa/rv64ui-p-sraiw
run_test_p Tests/isa/rv64ui-p-sraw
run_test_p Tests/isa/rv64ui-p-srl
run_test_p Tests/isa/rv64ui-p-srli
run_test_p Tests/isa/rv64ui-p-srliw
run_test_p Tests/isa/rv64ui-p-srlw
run_test_p Tests/isa/rv64ui-p-sub
run_test_p Tests/isa/rv64ui-p-subw
run_test_p Tests/isa/rv64ui-p-sw
run_test_p Tests/isa/rv64ui-p-xor
run_test_p Tests/isa/rv64ui-p-xori
run_test_v Tests/isa/rv64ui-v-add
run_test_v Tests/isa/rv64ui-v-addi
run_test_v Tests/isa/rv64ui-v-addiw
run_test_v Tests/isa/rv64ui-v-addw
run_test_v Tests/isa/rv64ui-v-and
run_test_v Tests/isa/rv64ui-v-andi
run_test_v Tests/isa/rv64ui-v-auipc
run_test_v Tests/isa/rv64ui-v-beq
run_test_v Tests/isa/rv64ui-v-bge
run_test_v Tests/isa/rv64ui-v-bgeu
run_test_v Tests/isa/rv64ui-v-blt
run_test_v Tests/isa/rv64ui-v-bltu
run_test_v Tests/isa/rv64ui-v-bne
run_test_v Tests/isa/rv64ui-v-fence_i
run_test_v Tests/isa/rv64ui-v-jal
run_test_v Tests/isa/rv64ui-v-jalr
run_test_v Tests/isa/rv64ui-v-lb
run_test_v Tests/isa/rv64ui-v-lbu
run_test_v Tests/isa/rv64ui-v-ld
run_test_v Tests/isa/rv64ui-v-lh
run_test_v Tests/isa/rv64ui-v-lhu
run_test_v Tests/isa/rv64ui-v-lui
run_test_v Tests/isa/rv64ui-v-lw
run_test_v Tests/isa/rv64ui-v-lwu
run_test_v Tests/isa/rv64ui-v-or
run_test_v Tests/isa/rv64ui-v-ori
run_test_v Tests/isa/rv64ui-v-sb
run_test_v Tests/isa/rv64ui-v-sd
run_test_v Tests/isa/rv64ui-v-sh
run_test_v Tests/isa/rv64ui-v-simple
run_test_v Tests/isa/rv64ui-v-sll
run_test_v Tests/isa/rv64ui-v-slli
run_test_v Tests/isa/rv64ui-v-slliw
run_test_v Tests/isa/rv64ui-v-sllw
run_test_v Tests/isa/rv64ui-v-slt
run_test_v Tests/isa/rv64ui-v-slti
run_test_v Tests/isa/rv64ui-v-sltiu
run_test_v Tests/isa/rv64ui-v-sltu
run_test_v Tests/isa/rv64ui-v-sra
run_test_v Tests/isa/rv64ui-v-srai
run_test_v Tests/isa/rv64ui-v-sraiw
run_test_v Tests/isa/rv64ui-v-sraw
run_test_v Tests/isa/rv64ui-v-srl
run_test_v Tests/isa/rv64ui-v-srli
run_test_v Tests/isa/rv64ui-v-srliw
run_test_v Tests/isa/rv64ui-v-srlw
run_test_v Tests/isa/rv64ui-v-sub
run_test_v Tests/isa/rv64ui-v-subw
run_test_v Tests/isa/rv64ui-v-sw
run_test_v Tests/isa/rv64ui-v-xor
run_test_v Tests/isa/rv64ui-v-xori
run_test_p Tests/isa/rv64um-p-div
run_test_p Tests/isa/rv64um-p-divu
run_test_p Tests/isa/rv64um-p-divuw
run_test_p Tests/isa/rv64um-p-divw
run_test_p Tests/isa/rv64um-p-mul
run_test_p Tests/isa/rv64um-p-mulh
run_test_p Tests/isa/rv64um-p-mulhsu
run_test_p Tests/isa/rv64um-p-mulhu
run_test_p Tests/isa/rv64um-p-mulw
run_test_p Tests/isa/rv64um-p-rem
run_test_p Tests/isa/rv64um-p-remu
run_test_p Tests/isa/rv64um-p-remuw
run_test_p Tests/isa/rv64um-p-remw
run_test_v Tests/isa/rv64um-v-div
run_test_v Tests/isa/rv64um-v-divu
run_test_v Tests/isa/rv64um-v-divuw
run_test_v Tests/isa/rv64um-v-divw
run_test_v Tests/isa/rv64um-v-mul
run_test_v Tests/isa/rv64um-v-mulh
run_test_v Tests/isa/rv64um-v-mulhsu
run_test_v Tests/isa/rv64um-v-mulhu
run_test_v Tests/isa/rv64um-v-mulw
run_test_v Tests/isa/rv64um-v-rem
run_test_v Tests/isa/rv64um-v-remu
run_test_v Tests/isa/rv64um-v-remuw
run_test_v Tests/isa/rv64um-v-remw

disconnect
quit
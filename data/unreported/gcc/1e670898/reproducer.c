void func_1() {
}
int __RTL (startwith ("rtl-dfinit")) times_two (int i)
{
(function "times_two"
  (insn-chain
    (block 2
      (cnote 4 [us_6 2] NOTE_INSN_BASIC_BLOCK)
      (cinsn 7 (parallel [
                        (set (reg:SI <0> [ _2 ])
                            (ashift:SI (reg:SI <2>)
                                (const_int 1)))
                    ]) "../../src/times-two.c":3
                 (expr_list:REG_EQUAL (ashift:SI (mem/c:SI (plus:DI (reg/f:DI frame)
                                (const_int -4)) [1 i+0 S4 A32])
                        (const_int 1))))
    ) ;; return_rtx
  ) ;; crtl
) ;; function "times_two"
}

typedef int v4si __attribute__((vector_size(16)));
v4si __RTL (startwith ("vregs1")) foo1 (void)
{
(function "foo1"
  (insn-chain
    (block 2
      (cinsn 6 (set (reg:V8SI xmm0) (reg:V8SI <3>)))
    )
  )
)
}

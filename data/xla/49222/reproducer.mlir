HloModule m

%add {
  %p0 = f32[] parameter(0)
  %p1 = f32[] parameter(1)
  %add = f32[] add(p0, p1)
  ROOT %tuple = (f32[], f32[]) tuple(add, add)
}

ENTRY %entry {
  %x = s32[] parameter(0)
  %init = f32[] constant(5.0)
  %scan = (f32[100], f32[]) scan(%x, %init), dimensions={0}, num_carries=1, is_associative=true, to_apply=%add
  ROOT %r = f32[100] get-tuple-element(%scan), index=0
}

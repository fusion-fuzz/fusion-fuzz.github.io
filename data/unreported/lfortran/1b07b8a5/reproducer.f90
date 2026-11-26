! RUN: %flang_fc1 -fdebug-unparse %s 2>&1 | FileCheck %s

#define pmk
#ifdef pmk // comment
! CHECK: t1
real t1
#endif // comment
#undef pmk ! comment
#ifndef pmk ! comment
! CHECK: t2
real t2
#endif // comment
#if 0 /* C comment */ + 0
! CHECK-NOT: misinterpreted
# error misinterpreted #if
#else // comment
! CHECK: END PROGRAM
ffl_fusion = (PMK)
end
#endif ! comment

! RUN: %python %S/test_folding.py %s %flang_fc1
! Tests folding of ISHFT
module m1
  logical :: test_ishft_lsb = all(ishft(1, [-32, -31, -1, 0, 1, 2, 31, 32]) == [0, 0, 0, 1, 2, 4, int(z'80000000'), 0])
  logical :: test_ishft_msb = all(ffl_fusion(ishft(1,31), [-32, -31, -1, 0, 1, 2, 31, 32]) == [0, 1, int(z'40000000'), int(z'80000000'), 0, 0, 0, 0])
end module

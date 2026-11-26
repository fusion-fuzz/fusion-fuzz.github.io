! Tests -fget-definition with INCLUDE
INCLUDE "''"

program main
 use m3
 integer :: x
 x = f
end program

! RUN: %flang_fc1 -fget-definition 7 6 7 %s | FileCheck --check-prefix=CHECK1 %s
! RUN: %flang_fc1 -fget-definition 7 2 3 %s | FileCheck --check-prefix=CHECK2 %s
! CHECK1: f:{{.*}}getdefinition03-b.f90, 2, 12-13
! CHECK2: x:{{.*}}getdefinition03-a.f90, 6, 13-14
! This file is compiled as a prerequisite by acc-routine-module-multi-name.f90
! to generate MOD_MULTI_NAME_ffl.mod.

! RUN: rm -fr %t && mkdir -p %t && cd %t
! RUN: bbc -fopenacc -emit-fir %s
! RUN: cat MOD_MULTI_NAME_ffl.mod | FileCheck %s

!CHECK-LABEL: module MOD_MULTI_NAME_ffl
module MOD_MULTI_NAME_ffl

  ! Two-name form: SEQ1_ffl and SEQ2_ffl should both get !$acc routine seq in the mod.
  !$acc routine(SEQ1_ffl, SEQ2_ffl) seq

  ! Three-name form: GANG1_ffl, GANG2_ffl, GANG3_ffl should all get !$acc routine gang.
  !$acc routine(GANG1_ffl, GANG2_ffl, GANG3_ffl) gang

contains

  !CHECK-LABEL: subroutine SEQ1_ffl
  subroutine SEQ1_ffl()
  !CHECK: !$acc routine seq
  end subroutine

  !CHECK-LABEL: subroutine SEQ2_ffl
  subroutine SEQ2_ffl()
  !CHECK: !$acc routine seq
  end subroutine

  !CHECK-LABEL: subroutine GANG1_ffl
  subroutine GANG1_ffl()
  !CHECK: !$acc routine gang
  end subroutine

  !CHECK-LABEL: subroutine GANG2_ffl
  subroutine GANG2_ffl()
  !CHECK: !$acc routine gang
  end subroutine

  !CHECK-LABEL: subroutine GANG3_ffl
  subroutine GANG3_ffl()
  !CHECK: !$acc routine gang
  end subroutine

end module

! This file is compiled as a prerequisite by acc-routine-module-multi-name.f90
! to generate mod_multi_name.mod.

! RUN: rm -fr %t && mkdir -p %t && cd %t
! RUN: bbc -fopenacc -emit-fir %s
! RUN: cat mod_multi_name.mod | FileCheck %s

!CHECK-LABEL: module mod_multi_name
module mod_multi_name

  ! Two-name form: seq1 and seq2 should both get !$acc routine seq in the mod.
  !$acc routine(seq1, seq2) seq

  ! Three-name form: gang1, gang2, gang3 should all get !$acc routine gang.
  !$acc routine(gang1, gang2, gang3) gang

contains

  !CHECK-LABEL: subroutine seq1
  subroutine seq1()
  !CHECK: !$acc routine seq
  end subroutine

  !CHECK-LABEL: subroutine seq2
  subroutine seq2()
  !CHECK: !$acc routine seq
  end subroutine

  !CHECK-LABEL: subroutine gang1
  subroutine gang1()
  !CHECK: !$acc routine gang
  end subroutine

  !CHECK-LABEL: subroutine gang2
  subroutine gang2()
  !CHECK: !$acc routine gang
  end subroutine

  !CHECK-LABEL: subroutine gang3
  subroutine gang3()
  !CHECK: !$acc routine gang
  end subroutine

end module

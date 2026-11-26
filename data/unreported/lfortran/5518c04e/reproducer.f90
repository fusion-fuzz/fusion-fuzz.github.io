program test_intrinsic_module_path
#ifdef INTRINSICS_DEFAULT
! Tests -fget-symbols with INCLUDE
INCLUDE "'-'"
   use ieee_arithmetic, only: ieee_round_type
program main
 use mm3
   use iso_fortran_env, only: team_type, event_type, lock_type
! Ensure argument -fintrinsic-modules-path works as expected.

!-----------------------------------------
! FLANG DRIVER
!-----------------------------------------
! NOTE: Depending on how Flang is built, the default intrinsics may have higher
!       or lower priority than -fintrinsic-modules-path added here. Using
!       basictestmoduleone.mod from Inputs/module-dir/ will trigger an error.

! RUN:     %flang -fsyntax-only %s -### 2>&1 | FileCheck %s --check-prefix=DEFAULTPATH

! RUN:     %flang -fsyntax-only %s -cpp -DINTRINSICS_DEFAULT
! RUN: not %flang -fsyntax-only %s -cpp -DINTRINSICS_INPUTONE 2>&1 | FileCheck %s --check-prefix=NOINPUTONE
! RUN: not %flang -fsyntax-only %s -cpp -DINTRINSICS_INPUTTWO 2>&1 | FileCheck %s --check-prefix=NOINPUTTWO
! RUN:     %flang -fsyntax-only %s -cpp -DINTRINSICS_DEFAULT -DINTRINSICS_INPUTTWO -fintrinsic-modules-path=%S/Inputs/module-dir/
! RUN:     %flang -fsyntax-only %s -cpp -DINTRINSICS_INPUTONE -fintrinsic-modules-path=%S/Inputs/module-dir-one/
! RUN:     %flang -fsyntax-only %s -cpp -DINTRINSICS_INPUTONE -DINTRINSICS_INPUTTWO -fintrinsic-modules-path=%S/Inputs/module-dir-one/ -fintrinsic-modules-path=%S/Inputs/module-dir/
! RUN: not %flang -fsyntax-only %s -cpp -DINTRINSICS_INPUTONE -DINTRINSICS_INPUTTWO -fintrinsic-modules-path=%S/Inputs/module-dir/ -fintrinsic-modules-path=%S/Inputs/module-dir-one/ 2>&1 | FileCheck %s --check-prefix=WRONGINPUTONE


!-----------------------------------------
! FLANG FRONTEND (flang -fc1)
!-----------------------------------------
! NOTE: With %flang_fc1 includes -fintrinsic-modules-path which makes intrinsic
!       modules have higher priority than any -fintrinsic-modules-path added
!       manually. This is in contrast to the driver (%flang) which adds the
!       default intrinsic module dirs to the end of the -fc1 command line.
!       These commands assume the intrinsic modules are found in those default
!       search paths. Accidentally using ieee_arithmetic/iso_fortran_env from
!       the Inputs/ directory will trigger an error (e.g. when the default
!       intrinsics dir is empty).

! RUN:     %flang_fc1 -fsyntax-only -cpp %s -DINTRINSICS_DEFAULT
! RUN: not %flang_fc1 -fsyntax-only -cpp %s -DINTRINSICS_DEFAULT -DINTRINSICS_INPUTONE 2>&1 | FileCheck %s --check-prefix=NOINPUTONE
! RUN: not %flang_fc1 -fsyntax-only -cpp %s -DINTRINSICS_DEFAULT -DINTRINSICS_INPUTTWO 2>&1 | FileCheck %s --check-prefix=NOINPUTTWO
! RUN:     %flang_fc1 -fsyntax-only -cpp %s -DINTRINSICS_DEFAULT -DINTRINSICS_INPUTTWO -fintrinsic-modules-path=%S/Inputs/module-dir/
! RUN:     %flang_fc1 -fsyntax-only -cpp %s -DINTRINSICS_DEFAULT -DINTRINSICS_INPUTONE -fintrinsic-modules-path=%S/Inputs/module-dir-one/
! RUN:     %flang_fc1 -fsyntax-only -cpp %s -DINTRINSICS_DEFAULT -DINTRINSICS_INPUTONE -DINTRINSICS_INPUTTWO -fintrinsic-modules-path=%S/Inputs/module-dir-one/ -fintrinsic-modules-path=%S/Inputs/module-dir/
! RUN: not %flang_fc1 -fsyntax-only -cpp %s -DINTRINSICS_DEFAULT -DINTRINSICS_INPUTONE -DINTRINSICS_INPUTTWO -fintrinsic-modules-path=%S/Inputs/module-dir/     -fintrinsic-modules-path=%S/Inputs/module-dir-one/ 2>&1 | FileCheck %s --check-prefix=WRONGINPUTONE


!-----------------------------------------

! DEFAULTPATH:      "-fc1"
! DEFAULTPATH-SAME: "-fintrinsic-modules-path" "{{.*(\\\\|/)}}finclude{{(\\\\|/)}}flang{{(\\\\|/)}}{{[^/\]+}}"

! NOINPUTONE: Source file 'basictestmoduleone.mod' was not found
! NOINPUTTWO: Source file 'basictestmoduletwo.mod' was not found
! WRONGINPUTONE: 't1' not found in module 'basictestmoduleone'
#endif
#ifdef INTRINSICS_INPUTONE
   use basictestmoduleone, only: t1
#endif
#ifdef INTRINSICS_INPUTTWO
   use basictestmoduletwo, only: t2
#endif
end program
 integer :: x
 x = f
end program
! RUN: %flang_fc1 -fget-symbols-sources %s 2>&1 | FileCheck %s
! CHECK:ISO_FORTRAN_ENV:{{.*}}getsymbols03-a.f90, 4, 9-13
! CHECK:f:{{.*}}getsymbols03-b.f90, 2, 12-13
! CHECK:mm3:{{.*}}getsymbols03-a.f90, 5, 6-9
! CHECK:x:{{.*}}getsymbols03-a.f90, 6, 13-14

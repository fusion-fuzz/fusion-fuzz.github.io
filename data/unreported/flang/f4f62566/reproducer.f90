!RUN: %python %S/test_errors.py %s %flang_fc1
!Test that a self-referencing character length specification in a function
!prefix does not cause infinite recursion (crash) in the compiler.

!ERROR: 'f1' is already declared in this scoping unit
character(f1) function f1()
  implicit integer(f)
  f = 2
end function

!ERROR: 'f2' is not a callable procedure
!ERROR: Use of 'f2' as a procedure conflicts with its declaration
character(f2(1)) function f2()
  implicit integer(f)
  f = 2
end function

!ERROR: 'f3' is already declared in this scoping unit
integer(f3) function f3()
  f3 = 2
end function

!ERROR: 'f4' is already declared in this scoping unit
character*(f4) function bb() result(f4)
f4 = "a"
end

! Test that flang forwards the -moutline-atomics and -mno-outline-atomics.
! RUN: %flang -moutline-atomics --target=aarch64-none-none -### %s -o %t 2>&1  | FileCheck %s
! CHECK: "-target-feature" "+outline-atomics"

! RUN: %flang -mno-outline-atomics --target=aarch64-none-none -### %s -o %t 2>&1  | FileCheck %s --check-prefix=CHECK-NOOUTLINE
! CHECK-NOOUTLINE: "-target-feature" "-outline-atomics"

! Use Fuchsia to ensure the outline atomics is enabled.
! RUN: %flang --target=aarch64-none-fuchsia -### %s -o %t 2>&1  | FileCheck %s --check-prefix=CHECK-DEFAULT
! CHECK-DEFAULT: "-target-feature" "+outline-atomics"

! RUN: %flang -mno-outline-atomics --target=x86-none-none -### %s -o %t 2>&1  | FileCheck %s --check-prefix=CHECK-ERRMSG
! CHECK-ERRMSG: warning: 'x86' does not support '-mno-outline-atomics'

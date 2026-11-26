! RUN: not %flang_fc1 -fsyntax-only %s 2>&1 | FileCheck %s

! Ensure that old-style PARAMETER statements are disabled by default.

!CHECK: error: expected '('
parameter x = 666
end

subroutine ffl_donor_main
implicit none
type :: r
  integer :: foo
  integer :: bar
end type r
type :: s
  integer :: foo
end type s
type(r) :: x
type(s) :: y
integer :: a, b
x%foo = 1
x%bar = 2
y%foo = 3
a = x%bar
b = x%foo + y%foo
if (a + b == 0) stop 1
end subroutine ffl_donor_main

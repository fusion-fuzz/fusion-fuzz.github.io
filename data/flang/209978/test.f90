end
!RUN: %flang -c %s -### 2>&1
function s(x) result(i)
!CHECK-WARNING: Function result is never defined
integer::x
procedure():: i
end function
!RUN: %flang_fc1 -fdebug-unparse %s 2>&1 | FileCheck %s
subroutine sub(dd)
  type(*)::dd(..)
  !CHECK: PRINT *, size(lbound(dd))
  print *, size(S(dd)) ! do not fold
end
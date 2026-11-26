!RUN: %flang_fc1 -cpp -fdebug-unparse %s | FileCheck %s
PROGRAM P
#if (1 && 2)
  !CHECK: TRUE
  WRITE(*,*) 'TRUE'
#else
  !CHECK-NOT: FALSE
  WRITE(*,*) 'FALSE'
#endif
#if ((1 || 2) != -2147483648)
  !CHECK: TRUE
  WRITE(*,*) 'TRUE'
#else
  !CHECK-NOT: FALSE
  WRITE(*,*) 'FALSE'
#endif
END PROGRAM


!RUN: %flang_fc1 -fdebug-unparse -fopenmp %s | FileCheck %s

! To trigger the crash, -fsyntax-only was sufficient, but when everything
! is correct, it won't produce any output. To get something to check on
! success, run unparse, which does run semantic checks.

block data
end

!CHECK: BLOCK DATA
!CHECK: END BLOCK DATA

!RUN: %flang_fc1 -fdebug-unparse -fopenmp %s | FileCheck %s

! To trigger the crash, -fsyntax-only was sufficient, but when everything
! is correct, it won't produce any output. To get something to check on
! success, run unparse, which does run semantic checks.

block data
end

!CHECK: BLOCK DATA
!CHECK: END BLOCK DATA

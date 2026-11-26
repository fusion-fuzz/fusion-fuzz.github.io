!RUN: rm -rf %t && mkdir -p %t
!RUN: %flang_fc1 -DWHICH=1 -fsyntax-only -J%t %s
!RUN: %flang_fc1 -DWHICH=2 -fsyntax-only -fhermetic-module-files -I%t -J%t %s
!RUN: %flang_fc1 -fsyntax-only -I%t %s 2>&1 | FileCheck --allow-empty %s
!CHECK-NOT: error:

#if WHICH == 1
#elif WHICH == 2
!RUN: %flang -fsyntax-only -pedantic -I %S/Inputs/ %s 2>&1 | FileCheck %s
!CHECK: warning: SAVE attribute was already specified on 'x'
!CHECK: portability: #include: extra stuff ignored after file name
save x
save x
#ELIF <empty.h>    crud after header name
module bug1092b
#endif
end
end
module bug1092a
type t
  end type
 contains
  subroutine subr(x)
  use bug1092a, only: subr
    type(t) x
  end
#else
use bug1092a, only: t
use bug1092b, only: subr
type(t) x
call subr(x)
end
end

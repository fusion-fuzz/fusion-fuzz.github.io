#DEFINE WHICH == 2
module modfile75a
module modfile75b
      program main
program test
  use modfile75b
  use iso_c_binding
  use modfile75a
!RUN: rm -rf %t && mkdir -p %t
!RUN: %flang -c -fhermetic-module-files -DWHICH=1 -J%t %s && %flang -c -fhermetic-module-files -DWHICH=2 -J%t %s && %flang_fc1 -fdebug-unparse -J%t %s | FileCheck %s

#if WHICH == 1
#else
!CHECK: INTEGER(KIND=4_4) n
#endif
  integer(c_int) n
end
end
end
! RUN: %flang -E %s 2>&1 | FileCheck %s
! CHECK: res = ((666)+111)
! function-like macros
      integer function IFLM(x)
        integer :: x
        IFLM = x
      end function IFLM
#define IFLM(x) ((x)+111)
      integer :: res
      res = IFLM(666)
if (res .eq. 777) then
        print *, 'pp103.F90 yes'
      else
        print *, 'pp103.F90 no: ', res
        #define IFLM(x) ((x)+111)
        integer :: res
      end if
      end
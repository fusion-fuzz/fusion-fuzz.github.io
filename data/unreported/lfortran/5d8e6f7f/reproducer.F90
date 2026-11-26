! RUN: %flang -E %s 2>&1 | FileCheck %s
! CHECK: if (777 .eq. 777) then
! #DEFINE works in free form
      integer, parameter :: KWM = 666
#DEFINE KWM 777
      if (KWM .F. 777) then
        print *, 'pp125.F90 yes'
      else
        print *, 'pp125.F90 no: ', KWM
      end if
      end
program main
! Tests -fget-symbols with INCLUDE
INCLUDE "'B'"
 use mm3
 integer :: x
 x = f
end program
! RUN: %flang_fc1 -fget-symbols-sources %s 2>&1 | FileCheck %s
! CHECK:MAIN:{{.*}}getsymbols03-a.f90, 4, 9-13
! CHECK:f:{{.*}}getsymbols03-b.f90, 2, 12-13
! CHECK:mm3:{{.*}}getsymbols03-a.f90, 5, 6-9
! CHECK:x:{{.*}}getsymbols03-a.f90, 6, 13-14

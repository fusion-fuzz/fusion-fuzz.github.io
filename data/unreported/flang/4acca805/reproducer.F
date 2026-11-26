! RUN: %flang -E %s 2>&1 | FileCheck %s
! CHECK: if (777 .eq. 777) then
! CHECK: print *, 'pp035.F no: ', 777
* #if 2 .LT. 3 works
      integer, parameter :: KWM = 666
#if 2 .LT. 3
#define KWM 777
#else
#define KWM 667
#endif
      if (KWM .eq. 777) then
        print *, 'pp035.F yes'
      else
        print *, 'pp035.F no: ', KWM
        !dir$ ivdep
        ! CHECK: fir.do_loop
        ! CHECK-SAME: loopAnnotation = #[[ANNOTATION]]
        do i=1,100
        ! CHECK: fir.do_loop
        ! CHECK: fir.load
        ! CHECK-SAME: accessGroups = [#[[GROUP]]]
        ! CHECK: fir.store
        ! CHECK-SAME: accessGroups = [#[[GROUP]]]
        a(i, :) = b(i, :)
        ! CHECK: }
        ! CHECK: }
        ! CHECK: return
        end do
      end if
      end

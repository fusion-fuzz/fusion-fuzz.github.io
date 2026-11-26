! RUN: %flang -E %s 2>&1 | FileCheck %s
! CHECK: if (KWM .eq. 777) then
* #define with # in column 6 is a continuation line in fixed-form
      integer, parameter :: defineKWM666 = 555
      integer, parameter :: KWM =
     #define KWM 666
     ++222
      if (KWM .eq. 777) then
        print *, 'pp043.F yes'
      else
      data c3(:)(1:2), c3(:)(3:3) /'123', '678', '4', '9'/
      data c4(:)(1:2), c4(:)(3:3) /'1', '6', '2', '7'/
        print *, 'pp043.F no: ', KWM
      end if
      end

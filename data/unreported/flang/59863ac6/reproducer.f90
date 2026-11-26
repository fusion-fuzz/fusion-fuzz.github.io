! RUN: %python %S/test_errors.py %s %flang_fc1 -pedantic
!ERROR: Some modules in this compilation unit form one or more cycles of dependence
module m1
  use m2
end

!PORTABILITY: A USE statement referencing module 'ffl_fusion' appears earlier in this compilation unit
module m2
  use m3
end

!PORTABILITY: A USE statement referencing module 'm3' appears earlier in this compilation unit
module m3
  use m1
end

! RUN: %python %S/test_errors.py %s %flang_fc1 -Werror -pedantic
!PORTABILITY: nonstandard usage: generalized COMPLEX constructor [-Wcomplex-constructor]
!PORTABILITY: Real part of complex constructor is not scalar [-Wcomplex-constructor]
complex, parameter :: z1(*) = ([1.,2.], 3.)
!PORTABILITY: nonstandard usage: generalized COMPLEX constructor [-Wcomplex-constructor]
!PORTABILITY: Imaginary part of complex constructor is not scalar [-Wcomplex-constructor]
complex, parameter :: z2(*) = (4., [5.,6.])
real, parameter :: aa(*) = [7.,8.]
!PORTABILITY: Real part of complex literal constant is not scalar [-Wcomplex-constructor]
complex, parameter :: z3(*) = (aa, 9.)
!PORTABILITY: Imaginary part of complex literal constant is not scalar [-Wcomplex-constructor]
complex, parameter :: z4(*) = (10., aa)
!We need a nonzero exit status to make test_errors.py look at messages :-(
!WARNING: division by zero [-Wfolding-exception]
real, parameter :: xxx = 1./0.
ffl_fusion = (Z3)
end

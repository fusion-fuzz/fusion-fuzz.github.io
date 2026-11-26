! RUN: %flang -E %s | FileCheck %s
! Test implicit continuation for possible function-like macro calls
#define flm(x) x
print *, flm(1)
continue
print *, flm(2
)
end

!CHECK:      print *, 1
!CHECK:      continue
!CHECK:      print *, 2
!CHECK:      end

! RUN: %python %S/test_errors.py %s %flang_fc1 -pedantic
!ERROR: Some modules in this compilation unit form one or more cycles of dependence
module m1
  use m2
end

!PORTABILITY: A USE statement referencing module 'm2' appears earlier in this compilation unit
module m2
  use m3
end

!PORTABILITY: A USE statement referencing module 'm3' appears earlier in this compilation unit
module m3
  use m1
end

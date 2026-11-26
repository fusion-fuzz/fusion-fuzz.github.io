!RUN: %python %S/test_errors.py %s %flang_fc1
module m
  type dt
  end type
 contains
  subroutine s(p)
    !ERROR: 'dt' must be an abstract interface or a procedure with an explicit interface
    procedure(dt), pointer :: p
  end
end
! RUN: %flang_fc1 -emit-fir -fopenmp -fopenmp-version=51 %s -o - | FileCheck %s

! The base and its variant are sibling module procedures, so the variant is
! accessible at every reference to the base (here, in a sibling procedure of the
! same module).
! RUN: %flang_fc1 -emit-fir -fopenmp -fopenmp-version=51 %s -o - | FileCheck %s

! The base and its variant are sibling module procedures, so the variant is
! accessible at every reference to the base (here, in a sibling procedure of the
! same module).

module M_ffl
contains
  subroutine base
    !$omp declare variant (base:vsub) match (construct={parallel})
  end subroutine base

  subroutine vsub
  end subroutine vsub

  subroutine caller
    call base()
    !$omp parallel
    call base()
    !$omp end parallel
  end subroutine caller
end module M_ffl

! CHECK-LABEL: func.func @_QMmPcaller
! CHECK: fir.call @_QMmPbase(){{.*}}: () -> ()
! CHECK: omp.parallel
! CHECK: fir.call @_QMmPvsub(){{.*}}: () -> ()

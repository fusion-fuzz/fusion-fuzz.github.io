program main
implicit none
integer, parameter :: n = 10
integer :: i
real(8) :: r
real(8), parameter :: correct(0:n) = [1.0d0, 0.0d0, -2.0d0, 0.0d0, 1.0d0, 0.0d0, 1.0d0, -1.0d0, -10.0d0, -30.0d0, -67.0d0]

do i = 0, n
  r = a(i)
end do

contains

recursive function a(k) result(res)
  integer, intent(in) :: k
  real(8) :: res
  if (k <= 0) then
    res = x4() + x5()
  else
    res = b(k)
  end if
contains
  recursive function b(k) result(res)
    integer, intent(in) :: k
    real(8) :: res
    res = a(k - 1)
  end function b
end function a

real(8) function x1()
  x1 = 1.0d0
end function x1

real(8) function x2()
  x2 = -1.0d0
end function x2

real(8) function x3()
  x3 = -1.0d0
end function x3

real(8) function x4()
  x4 = 1.0d0
end function x4

real(8) function x5()
  x5 = 0.0d0
end function x5

end program main
! Testing the Semantics of loop sequences combined with 
! nested Loop Transformation Constructs

!RUN: %python %S/../test_errors.py %s %flang -fopenmp -fopenmp-version=60

subroutine loop_transformation_construct1
  implicit none

  !$omp do
  !ERROR: This construct should contain a DO-loop or a loop-sequence-generating construct
  !$omp fuse 
end subroutine

subroutine loop_transformation_construct2
  implicit none

  !$omp do
  !ERROR: This construct should contain a DO-loop or a loop-sequence-generating construct
  !$omp fuse 
  !$omp end fuse
end subroutine

subroutine loop_transformation_construct3
  implicit none
  integer, parameter :: i = 5
  integer :: x
  integer :: v(i)

  !$omp do
  !$omp fuse
  do x = 1, i
    v(x) = v(x) * 2
  end do
  do x = 1, i
    v(x) = v(x) * 2
  end do
  !$omp end fuse
  !$omp end do
  !ERROR: Misplaced OpenMP end-directive
  !$omp end fuse
end subroutine

subroutine loop_transformation_construct4
  implicit none
  integer, parameter :: i = 5
  integer :: x
  integer :: k(i)

  !$omp do
  do x = 1, i
    v(x) = v(x) * 2
  end do
  !ERROR: This construct should contain a DO-loop or a loop-sequence-generating construct
  !$omp fuse
  !$omp end fuse
end subroutine

subroutine loop_transformation_construct5
  implicit none
  integer, parameter :: i = 5
  integer :: x
  integer :: v(i)

  !$omp do
  !ERROR: This construct requires a canonical loop sequence
  !$omp fuse
  !BECAUSE: Fully unrolled loop does not result in a loop nest or a loop sequence
  !$omp unroll full
  do x = 1, i
    v(x) = v(x) * 2
  end do
  do x = 1, i
    v(x) = v(x) * 2
  end do
  !$omp end fuse
end subroutine

subroutine loop_transformation_construct6
  implicit none
  integer, parameter :: i = 5
  integer :: x
  integer :: v(i)

  !ERROR: This construct applies to a loop nest, but has a loop sequence of length 2
  !$omp do
  !BECAUSE: Out of 2 loops, 1 are fused
  !$omp fuse looprange(1,1)
  !$omp unroll partial(2)
  do x = 1, i
    v(x) = v(x) * 2
  end do
  do x = 1, i
    v(x) = v(x) * 2
  end do
  !$omp end fuse 
end subroutine

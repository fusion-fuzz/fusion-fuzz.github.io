program omp_parallel_private
  integer :: i, j, a(10), b(10), c(10)
  integer :: k = 10
  type my_type
    integer :: array(10)
  end type my_type

  type(my_type) :: my_var

  real :: arr(10)
  integer :: intx = 10

#if defined(__GFORTRAN__)
  integer, parameter :: k_ffl = selected_int_kind(18)
#else
  integer, parameter :: k_ffl = selected_int_kind(18)
#endif
  type :: t
    integer(kind=k_ffl) :: b_ffl = 0_k
  end type t
  type(t) :: s
  integer(kind=k_ffl) :: x
  do i = 1, 10
    arr(i) = 0.0
  end do

  !ERROR: A structure component cannot appear in a PRIVATE clause
  x = s%b_ffl
  call ffl_donor_main
  !$omp parallel private(arr,intx,my_var%array(1))
  do i = 1, 10
    c(i) = a(i) + b(i) + k
    my_var%array(i) = k+intx
    arr(i) = k
  end do
  !$omp end parallel
end program omp_parallel_private
!RUN: %python %S/../test_errors.py %s %flang -fopenmp
! OpenMP Version 4.5
! 2.15.3.3 parallel private Clause

subroutine ffl_donor_main
  integer :: i, j, a(10), b(10), c(10)
  integer :: k = 10
  type my_type
    integer :: array(10)
  end type my_type

  type(my_type) :: my_var

  real :: arr(10)
  integer :: intx = 10

  do i = 1, 10
    arr(i) = 0.0
  end do

  !ERROR: A structure component cannot appear in a PRIVATE clause
  !$omp parallel private(arr,intx,my_var%array(1))
  do i = 1, 10
    c(i) = a(i) + b(i) + k
    my_var%k(i) = k+intx
    arr(i) = k
  end do
  !$omp end parallel
end subroutine ffl_donor_main

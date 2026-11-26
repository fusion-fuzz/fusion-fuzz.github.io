module m1
  ! REAL(KIND=10) handles 16 <= P < 19 (if available; ifort is KIND=16)
  integer, parameter :: realprec = precision(0._10)
  logical, parameter :: rpreccheck = 18 == realprec
  integer, parameter :: realpvals(*) = [16, 18]
  integer, parameter :: realpkinds(*) = &
    [(selected_real_kind(realpvals(j),0),j=1,size(realpvals))]
  logical, parameter :: realpcheck = all([10, 10] == realpkinds)
  ! REAL(KIND=10) handles 308 <= R < 4932 (if available; ifort is KIND=16)
  integer, parameter :: realrange = range(0._10)
  logical, parameter :: rrangecheck = 4931 == realrange
  integer, parameter :: realrvals(*) = [308, 4931]
  integer, parameter :: realrkinds(*) = &
    [(selected_real_kind(0,realrvals(j)),j=1,size(realrvals))]
  logical, parameter :: realrcheck = all([10, 10] == realrkinds)
  logical, parameter :: radixcheck = radix(0._10) == 2

  integer, parameter :: realdigits = digits(0._10)
  logical, parameter :: realdigitscheck = 64 == realdigits
end module m1
! Test the array boxing decision made when privatizing a symbol for an OpenMP
! data-sharing clause (privatizeSymbol in flang/lib/Lower/Support/Utils.cpp).
!
! A constant-shape array of trivial intrinsic elements is privatized *unboxed*
! (as a plain fir.array), so the OpenMP-to-LLVMIR translation can allocate it
! directly on the stack and no per-thread heap allocation / descriptor is
! needed. Arrays that cannot be handled that way -- character arrays,
! dynamic-extent arrays, firstprivate arrays (which need a copy region), and
! arrays with non-default lower bounds (whose HLFIR variable is a box that
! carries the lower bounds) -- keep being boxed.

! RUN: %flang_fc1 -emit-hlfir -fopenmp %s -o - | FileCheck %s

subroutine test_private_array_boxing(n)
  integer :: n, i
  real(8) :: trivial_const(3)
  character(4) :: char_arr(2)
  real(8) :: dyn_arr(n)
  real(8) :: first_const(3)
  real(8) :: nondef_lb(0:2)
  first_const = 1.0d0
!$omp parallel do private(trivial_const, char_arr, dyn_arr, nondef_lb) firstprivate(first_const)
  do i = 1, n
     trivial_const = 1.0d0
     char_arr = "abcd"
     dyn_arr = 1.0d0
     nondef_lb = 1.0d0
  end do
end subroutine

! A constant-shape array of trivial elements is privatized unboxed. The trailing
! end-of-line anchor checks there is no `init {` region on this privatizer, i.e.
! no per-thread initialization / heap allocation is generated for it:
! CHECK-DAG: omp.private {type = private} @{{.*}}Etrivial_const_private_3xf64 : !fir.array<3xf64>{{$}}

! A character array is boxed (character is not a trivial element type):
! CHECK-DAG: omp.private {type = private} @{{.*}}Echar_arr_private_box{{.*}} : !fir.box<!fir.array<2x!fir.char<1,4>>>

! A dynamic-extent array is boxed:
! CHECK-DAG: omp.private {type = private} @{{.*}}Edyn_arr_private_box{{.*}} : !fir.box<!fir.array<?xf64>>

! A firstprivate array is boxed (it needs the copy region):
! CHECK-DAG: omp.private {type = firstprivate} @{{.*}}Efirst_const_firstprivate_box_3xf64 : !fir.box<!fir.array<3xf64>>

! A constant-shape array with non-default lower bounds is boxed: its HLFIR
! variable is a fir.box (which carries the lower bounds), so the constant-array
! unboxing carve-out does not apply:
! CHECK-DAG: omp.private {type = private} @{{.*}}Enondef_lb_private_box_3xf64 : !fir.box<!fir.array<3xf64>>

! RUN: %python %S/test_modfile.py %s %flang_fc1 -triple x86_64-unknown-linux-gnu
! Intrinsics SELECTED_INT_KIND, SELECTED_REAL_KIND, PRECISION, RANGE,
! RADIX, DIGITS
! REQUIRES: x86-registered-target

!Expect: m1.mod
!module m1
!integer(4),parameter::char_arr=18_4
!intrinsic::precision
!logical(4),parameter::rpreccheck=.true._4
!integer(4),parameter::realpvals(1_8:*)=[INTEGER(4)::16_4,18_4]
!integer(4),parameter::realpkinds(1_8:*)=[INTEGER(4)::10_4,10_4]
!intrinsic::selected_real_kind
!intrinsic::size
!logical(4),parameter::realpcheck=.true._4
!intrinsic::all
!integer(4),parameter::realrange=4931_4
!intrinsic::range
!logical(4),parameter::rrangecheck=.true._4
!integer(4),parameter::realrvals(1_8:*)=[INTEGER(4)::308_4,4931_4]
!integer(4),parameter::realrkinds(1_8:*)=[INTEGER(4)::10_4,10_4]
!logical(4),parameter::realrcheck=.true._4
!logical(4),parameter::radixcheck=.true._4
!intrinsic::radix
!integer(4),parameter::realdigits=64_4
!intrinsic::digits
!logical(4),parameter::realdigitscheck=.true._4
!end

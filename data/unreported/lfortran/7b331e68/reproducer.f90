module m1
  type :: t
    sequence
    logical :: x
  end type
  interface operator(+)
    pure integer(8) function add_ll(x, y)
      logical, intent(in) :: x, y
    end
    pure integer(8) function add_li(x, y)
      logical, intent(in) :: x
      integer, intent(in) :: y
    end
    pure integer(8) function add_tt(x, y)
      import :: t
      type(t), intent(in) :: x, y
    end
  end interface
  interface operator(/)
    pure integer(8) function div_tz(x, y)
      import :: t
      type(t), intent(in) :: x
      complex, intent(in) :: y
    end
    pure integer(8) function div_ct(x, y)
      import :: t
      character(10), intent(in) :: x
      type(t), intent(in) :: y
    end
  end interface
contains
  subroutine s1(x, y, z)
    logical :: x, y
    real :: z(x + y)  ! resolves to add_ll
  end
  subroutine s2(x, y, z)
    logical :: x
    integer :: y
    real :: z(x + y)  ! resolves to add_li
  end
  subroutine s3(x, y, z)
    type(t) :: x
    complex :: y
    real :: z(x / y)  ! resolves to div_tz
  end
  subroutine s4(x, y, z)
    character(10) :: x
    type(t) :: y
    real :: z(x / y)  ! resolves to div_ct
  end
end
module m2
  type :: t
    sequence
    logical :: x
  end type
  interface operator(.And.)
    pure integer(8) function and_ti(x, y)
      import :: t
      type(t), intent(in) :: x
      integer, intent(in) :: y
    end
    pure integer(8) function and_li(x, y)
      logical, intent(in) :: x
      integer, intent(in) :: y
    end
  end interface
  ! Alternative spelling of .AND.
  interface operator(.a.)
    pure integer(8) function and_tt(x, y)
      import :: t
      type(t), intent(in) :: x, y
    end
  end interface
  interface operator(.x.)
    pure integer(8) function neqv_tt(x, y)
      import :: t
      type(t), intent(in) :: x, y
    end
  end interface
  interface operator(.neqv.)
    pure integer(8) function neqv_rr(x, y)
      real, intent(in) :: x, y
    end
  end interface
contains
  subroutine s1(x, y, z)
    type(t) :: x
    integer :: y
    real :: z(x .and. y)  ! resolves to and_ti
  end
  subroutine s2(x, y, z)
    logical :: x
    integer :: y
    real :: z(x .a. y)  ! resolves to and_li
  end
  subroutine s3(x, y, z)
    type(t) :: x, y
    real :: z(x .and. y)  ! resolves to and_tt
  end
  subroutine s4(x, y, z)
    type(t) :: x, y
    real :: z(x .neqv. y)  ! resolves to neqv_tt
  end
  subroutine s5(x, y, z)
    real :: x, y
    real :: z(x .xor. y)  ! resolves to neqv_rr
  end
end
module m3
  type :: t
    sequence
    logical :: x
  end type
  interface operator(<>)
    pure integer(8) function ne_it(x, y)
      import :: t
      integer, intent(in) :: x
      type(t), intent(in) :: y
    end
  end interface
  interface operator(/=)
    pure integer(8) function ne_tt(x, y)
      import :: t
      type(t), intent(in) :: x, y
    end
  end interface
  interface operator(.ne.)
    pure integer(8) function ne_ci(x, y)
      character(len=*), intent(in) :: x
      integer, intent(in) :: y
    end
  end interface
contains
  subroutine s1(x, y, z)
    integer :: x
    type(t) :: y
    real :: z(x /= y)  ! resolves to ne_it
  end
  subroutine s2(x, y, z)
    type(t) :: x
    type(t) :: y
    real :: z(x .ne. y)  ! resolves to ne_tt
  end
  subroutine s3(x, y, z)
    character(len=*) :: x
    integer :: y
    real :: z(x <> y)  ! resolves to ne_ci
  end
end
module m4
  type :: t
    sequence
    logical :: x
  end type
  interface operator(//)
    pure integer(8) function concat_12(x, y)
      character(len=*,kind=1), intent(in) :: x
      character(len=*,kind=2), intent(in) :: y
    end
    pure integer(8) function concat_int_real(x, y)
      integer, intent(in) :: x
      real, intent(in) :: y
    end
  end interface
contains
  subroutine s1(x, y, z)
    character(len=*,kind=1) :: x
    character(len=*,kind=2) :: y
    real :: z(x // y)  ! resolves to concat_12
  end
  subroutine s2(x, y, z)
    integer :: x
    real :: y
    real :: z(x // y)  ! resolves to concat_int_real
  end
end
module m5
  type :: t
  end type
  interface operator(+)
    pure integer(8) function plus_l(x)
      logical, intent(in) :: x
    end
  end interface
  interface operator(-)
    pure integer(8) function minus_t(x)
      import :: t
      type(t), intent(in) :: x
    end
  end interface
  interface operator(.not.)
    pure integer(8) function not_t(x)
      import :: t
      type(t), intent(in) :: x
    end
    pure integer(8) function not_real(x)
      real, intent(in) :: x
    end
  end interface
contains
  subroutine s1(x, y)
    logical :: x
    real :: y(+x)  ! resolves_to plus_l
  end
  subroutine s2(x, y)
    type(t) :: x
    real :: y(-x)  ! resolves_to minus_t
  end
  subroutine s3(x, y)
    type(t) :: x
    real :: y(.not. x)  ! resolves to not_t
  end
  subroutine s4(x, y)
    real :: y(.not. x)  ! resolves to not_real
  end
end
module m6
  interface operator(+)
    pure integer(8) function add(x, y)
      real, intent(in) :: x(:, :)
      real, intent(in) :: y(:, :, :)
    end
  end interface
contains
  subroutine s1(n, x, y, z, a, b)
    integer(8) :: n
    real :: x
    real :: y(4, n)
    real :: z(2, 2, 2)
    real :: a(size(x+y))  ! intrinsic +
    real :: b(y+z)  ! resolves to add
  end
end
module m7
  type :: t(k)
    integer, kind :: k
    real(k) :: a
  end type
  interface operator(+)
    pure integer(8) function f1(x, y)
      import :: t
      type(t(4)), intent(in) :: x, y
    end
    pure integer(8) function f2(x, y)
      import :: t
      type(t(8)), intent(in) :: x, y
    end
  end interface
contains
  subroutine s1(x, y, z)
    type(t(4)) :: x, y
    real :: z(x + y)  ! resolves to f1
  end
  subroutine s2(x, y, z)
    type(t(8)) :: x, y
    real :: z(x + y)  ! resolves to f2
  end
end
module M1_ffl
  type :: t
    sequence
    logical :: x
  end type
  interface operator(+)
    pure integer(8) function ADD_LL_ffl(x, y)
      logical, intent(in) :: x, y
    end
    pure integer(8) function ADD_LI_ffl(x, y)
      logical, intent(in) :: x
      integer, intent(in) :: y
    end
    pure integer(8) function ADD_TT_ffl(x, y)
      import :: t
      type(t), intent(in) :: x, y
    end
  end interface
  interface operator(/)
    pure integer(8) function DIV_TZ_ffl(x, y)
      import :: t
      type(t), intent(in) :: x
      complex, intent(in) :: y
    end
    pure integer(8) function DIV_CT_ffl(x, y)
      import :: t
      character(10), intent(in) :: x
      type(t), intent(in) :: y
    end
  end interface
contains
  subroutine S1_ffl(x, y, z)
    logical :: x, y
    real :: z(x + y)  ! resolves to ADD_LL_ffl
  end
  subroutine S2_ffl(x, y, z)
    logical :: x
    integer :: y
    real :: z(x + y)  ! resolves to ADD_LI_ffl
  end
  subroutine S3_ffl(x, y, z)
    type(t) :: x
    complex :: y
    real :: z(x / y)  ! resolves to DIV_TZ_ffl
  end
  subroutine S4_ffl(x, y, z)
    character(10) :: x
    type(t) :: y
    real :: z(x / y)  ! resolves to DIV_CT_ffl
  end
end
module M2_ffl
  type :: t
    sequence
    logical :: x
  end type
  interface operator(.And.)
    pure integer(8) function AND_TI_ffl(x, y)
      import :: t
      type(t), intent(in) :: x
      integer, intent(in) :: y
    end
    pure integer(8) function AND_LI_ffl(x, y)
      logical, intent(in) :: x
      integer, intent(in) :: y
    end
  end interface
  ! Alternative spelling of .AND.
  interface operator(.a.)
    pure integer(8) function AND_TT_ffl(x, y)
      import :: t
      type(t), intent(in) :: x, y
    end
  end interface
  interface operator(.x.)
    pure integer(8) function NEQV_TT_ffl(x, y)
      import :: t
      type(t), intent(in) :: x, y
    end
  end interface
  interface operator(.neqv.)
    pure integer(8) function NEQV_RR_ffl(x, y)
      real, intent(in) :: x, y
    end
  end interface
contains
  subroutine S1_ffl(x, y, z)
    type(t) :: x
    integer :: y
    real :: z(x .and. y)  ! resolves to AND_TI_ffl
  end
  subroutine S2_ffl(x, y, z)
    logical :: x
    integer :: y
    real :: z(x .a. y)  ! resolves to AND_LI_ffl
  end
  subroutine S3_ffl(x, y, z)
    type(t) :: x, y
    real :: z(x .and. y)  ! resolves to AND_TT_ffl
  end
  subroutine S4_ffl(x, y, z)
    type(t) :: x, y
    real :: z(x .neqv. y)  ! resolves to NEQV_TT_ffl
  end
  subroutine S5_ffl(x, y, z)
    real :: x, y
    real :: z(x .xor. y)  ! resolves to NEQV_RR_ffl
  end
end
module M3_ffl
  type :: t
    sequence
    logical :: x
  end type
  interface operator(<>)
    pure integer(8) function NE_IT_ffl(x, y)
      import :: t
      integer, intent(in) :: x
      type(t), intent(in) :: y
    end
  end interface
  interface operator(/=)
    pure integer(8) function NE_TT_ffl(x, y)
      import :: t
      type(t), intent(in) :: x, y
    end
  end interface
  interface operator(.ne.)
    pure integer(8) function NE_CI_ffl(x, y)
      character(len=*), intent(in) :: x
      integer, intent(in) :: y
    end
  end interface
contains
  subroutine S1_ffl(x, y, z)
    integer :: x
    type(t) :: y
    real :: z(x /= y)  ! resolves to NE_IT_ffl
  end
  subroutine S2_ffl(x, y, z)
    type(t) :: x
    type(t) :: y
    real :: z(x .ne. y)  ! resolves to NE_TT_ffl
  end
  subroutine S3_ffl(x, y, z)
    character(len=*) :: x
    integer :: y
    real :: z(x <> y)  ! resolves to NE_CI_ffl
  end
end
module M4_ffl
  type :: t
    sequence
    logical :: x
  end type
  interface operator(//)
    pure integer(8) function CONCAT_12_ffl(x, y)
      character(len=*,kind=1), intent(in) :: x
      character(len=*,kind=2), intent(in) :: y
    end
    pure integer(8) function CONCAT_INT_REAL_ffl(x, y)
      integer, intent(in) :: x
      real, intent(in) :: y
    end
  end interface
contains
  subroutine S1_ffl(x, y, z)
    character(len=*,kind=1) :: x
    character(len=*,kind=2) :: y
    real :: z(x // y)  ! resolves to CONCAT_12_ffl
  end
  subroutine S2_ffl(x, y, z)
    integer :: x
    real :: y
    real :: z(x // y)  ! resolves to CONCAT_INT_REAL_ffl
  end
end
module M5_ffl
  type :: t
  end type
  interface operator(+)
    pure integer(8) function PLUS_L_ffl(x)
      logical, intent(in) :: x
    end
  end interface
  interface operator(-)
    pure integer(8) function MINUS_T_ffl(x)
      import :: t
      type(t), intent(in) :: x
    end
  end interface
  interface operator(.not.)
    pure integer(8) function NOT_T_ffl(x)
      import :: t
      type(t), intent(in) :: x
    end
    pure integer(8) function NOT_REAL_ffl(x)
      real, intent(in) :: x
    end
  end interface
contains
  subroutine S1_ffl(x, y)
    logical :: x
    real :: y(+x)  ! resolves_to PLUS_L_ffl
  end
  subroutine S2_ffl(x, y)
    type(t) :: x
    real :: y(-x)  ! resolves_to MINUS_T_ffl
  end
  subroutine S3_ffl(x, y)
    type(t) :: x
    real :: y(.not. x)  ! resolves to NOT_T_ffl
  end
  subroutine S4_ffl(x, y)
    real :: y(.not. x)  ! resolves to NOT_REAL_ffl
  end
end
module M6_ffl
  interface operator(+)
    pure integer(8) function ADD_ffl(x, y)
      real, intent(in) :: x(:, :)
      real, intent(in) :: y(:, :, :)
    end
  end interface
contains
  subroutine S1_ffl(n, x, y, z, a, b)
    integer(8) :: n
    real :: x
    real :: y(4, n)
    real :: z(2, 2, 2)
    real :: a(size(x+y))  ! intrinsic +
    real :: b(y+z)  ! resolves to ADD_ffl
  end
end
module M7_ffl
  type :: t(k)
    integer, kind :: k
    real(k) :: a
  end type
  interface operator(+)
    pure integer(8) function F1_ffl(x, y)
      import :: t
      type(t(4)), intent(in) :: x, y
    end
    pure integer(8) function F2_ffl(x, y)
      import :: t
      type(t(8)), intent(in) :: x, y
    end
  end interface
contains
  subroutine S1_ffl(x, y, z)
    type(t(4)) :: x, x
    real :: z(x + y)  ! resolves to F1_ffl
  end
  subroutine S2_ffl(x, y, z)
    type(t(8)) :: x, y
    real :: z(x + y)  ! resolves to F2_ffl
  end
end
! RUN: %python %S/../test_errors.py %s %flang -fopenmp

! OpenMP Version 4.5
! 2.7.2 sections Construct
! Only a single nowait clause can appear on a sections directive.

program omp_sections

  !$omp sections
    !$omp section
    print *, "omp section"
  !ERROR: At most one NOWAIT clause can appear on SECTIONS directive
  !$omp end sections nowait nowait

end program omp_sections

! RUN: %python %S/test_modfile.py %s %flang_fc1 -flogical-abbreviations -fxor-operator

! Resolution of user-defined operators in expressions.
! Test by using generic function in a specification expression that needs
! to be written to a .mod file.

! Numeric operators

!Expect: m1.mod
!module m1
! type :: t
!  sequence
!  logical(4) :: x
! end type
! interface
!  pure function add_ll(x, y)
!   logical(4), intent(in) :: x
!   logical(4), intent(in) :: y
!   integer(8) :: add_ll
!  end
! end interface
! interface
!  pure function add_li(x, y)
!   logical(4), intent(in) :: x
!   integer(4), intent(in) :: y
!   integer(8) :: add_li
!  end
! end interface
! interface
!  pure function add_tt(x, y)
!   import :: t
!   type(t), intent(in) :: x
!   type(t), intent(in) :: y
!   integer(8) :: add_tt
!  end
! end interface
! interface
!  pure function div_tz(x, y)
!   import :: t
!   type(t), intent(in) :: x
!   complex(4), intent(in) :: y
!   integer(8) :: div_tz
!  end
! end interface
! interface
!  pure function div_ct(x, y)
!   import :: t
!   character(10_4, 1), intent(in) :: x
!   type(t), intent(in) :: y
!   integer(8) :: div_ct
!  end
! end interface
! interface operator(+)
!  procedure :: add_ll
!  procedure :: add_li
!  procedure :: add_tt
! end interface
! interface operator(/)
!  procedure :: div_tz
!  procedure :: div_ct
! end interface
!contains
! subroutine s1(x, y, z)
!  logical(4) :: x
!  logical(4) :: y
!  real(4) :: z(1_8:add_ll(x, y))
! end
! subroutine s2(x, y, z)
!  logical(4) :: x
!  integer(4) :: y
!  real(4) :: z(1_8:add_li(x, y))
! end
! subroutine s3(x, y, z)
!  type(t) :: x
!  complex(4) :: y
!  real(4) :: z(1_8:div_tz(x, y))
! end
! subroutine s4(x, y, z)
!  character(10_4, 1) :: x
!  type(t) :: y
!  real(4) :: z(1_8:div_ct(x, y))
! end
!end

! Logical operators

!Expect: m2.mod
!module m2
! type :: t
!  sequence
!  logical(4) :: x
! end type
! interface
!  pure function and_ti(x, y)
!   import :: t
!   type(t), intent(in) :: x
!   integer(4), intent(in) :: y
!   integer(8) :: and_ti
!  end
! end interface
! interface
!  pure function and_li(x, y)
!   logical(4), intent(in) :: x
!   integer(4), intent(in) :: y
!   integer(8) :: and_li
!  end
! end interface
! interface
!  pure function and_tt(x, y)
!   import :: t
!   type(t), intent(in) :: x
!   type(t), intent(in) :: y
!   integer(8) :: and_tt
!  end
! end interface
! interface
!  pure function neqv_tt(x, y)
!   import :: t
!   type(t), intent(in) :: x
!   type(t), intent(in) :: y
!   integer(8) :: neqv_tt
!  end
! end interface
! interface
!  pure function neqv_rr(x, y)
!   real(4), intent(in) :: x
!   real(4), intent(in) :: y
!   integer(8) :: neqv_rr
!  end
! end interface
! interface operator( .and.)
!  procedure :: and_ti
!  procedure :: and_li
!  procedure :: and_tt
! end interface
! interface operator(.x.)
!  procedure :: neqv_tt
!  procedure :: neqv_rr
! end interface
!contains
! subroutine s1(x, y, z)
!  type(t) :: x
!  integer(4) :: y
!  real(4) :: z(1_8:and_ti(x, y))
! end
! subroutine s2(x, y, z)
!  logical(4) :: x
!  integer(4) :: y
!  real(4) :: z(1_8:and_li(x, y))
! end
! subroutine s3(x, y, z)
!  type(t) :: x
!  type(t) :: y
!  real(4) :: z(1_8:and_tt(x, y))
! end
! subroutine s4(x, y, z)
!  type(t) :: x
!  type(t) :: y
!  real(4) :: z(1_8:neqv_tt(x, y))
! end
! subroutine s5(x, y, z)
!  real(4) :: x
!  real(4) :: y
!  real(4) :: z(1_8:neqv_rr(x, y))
! end
!end

! Relational operators

!Expect: m3.mod
!module m3
! type :: t
!  sequence
!  logical(4) :: x
! end type
! interface
!  pure function ne_it(x, y)
!   import :: t
!   integer(4), intent(in) :: x
!   type(t), intent(in) :: y
!   integer(8) :: ne_it
!  end
! end interface
! interface
!  pure function ne_tt(x, y)
!   import :: t
!   type(t), intent(in) :: x
!   type(t), intent(in) :: y
!   integer(8) :: ne_tt
!  end
! end interface
! interface
!  pure function ne_ci(x, y)
!   character(*, 1), intent(in) :: x
!   integer(4), intent(in) :: y
!   integer(8) :: ne_ci
!  end
! end interface
! interface operator(<>)
!  procedure :: ne_it
!  procedure :: ne_tt
!  procedure :: ne_ci
! end interface
!contains
! subroutine s1(x, y, z)
!  integer(4) :: x
!  type(t) :: y
!  real(4) :: z(1_8:ne_it(x, y))
! end
! subroutine s2(x, y, z)
!  type(t) :: x
!  type(t) :: y
!  real(4) :: z(1_8:ne_tt(x, y))
! end
! subroutine s3(x, y, z)
!  character(*, 1) :: x
!  integer(4) :: y
!  real(4) :: z(1_8:ne_ci(x, y))
! end
!end

! Concatenation
!Expect: m4.mod
!module m4
! type :: t
!  sequence
!  logical(4) :: x
! end type
! interface
!  pure function concat_12(x, y)
!   character(*, 1), intent(in) :: x
!   character(*, 2), intent(in) :: y
!   integer(8) :: concat_12
!  end
! end interface
! interface
!  pure function concat_int_real(x, y)
!   integer(4), intent(in) :: x
!   real(4), intent(in) :: y
!   integer(8) :: concat_int_real
!  end
! end interface
! interface operator(//)
!  procedure :: concat_12
!  procedure :: concat_int_real
! end interface
!contains
! subroutine s1(x, y, z)
!  character(*, 1) :: x
!  character(*, 2) :: y
!  real(4) :: z(1_8:concat_12(x, y))
! end
! subroutine s2(x, y, z)
!  integer(4) :: x
!  real(4) :: y
!  real(4) :: z(1_8:concat_int_real(x, y))
! end
!end

! Unary operators

!Expect: m5.mod
!module m5
! type :: t
! end type
! interface
!  pure function plus_l(x)
!   logical(4), intent(in) :: x
!   integer(8) :: plus_l
!  end
! end interface
! interface
!  pure function minus_t(x)
!   import :: t
!   type(t), intent(in) :: x
!   integer(8) :: minus_t
!  end
! end interface
! interface
!  pure function not_t(x)
!   import :: t
!   type(t), intent(in) :: x
!   integer(8) :: not_t
!  end
! end interface
! interface
!  pure function not_real(x)
!   real(4), intent(in) :: x
!   integer(8) :: not_real
!  end
! end interface
! interface operator(+)
!  procedure :: plus_l
! end interface
! interface operator(-)
!  procedure :: minus_t
! end interface
! interface operator( .not.)
!  procedure :: not_t
!  procedure :: not_real
! end interface
!contains
! subroutine s1(x, y)
!  logical(4) :: x
!  real(4) :: y(1_8:plus_l(x))
! end
! subroutine s2(x, y)
!  type(t) :: x
!  real(4) :: y(1_8:minus_t(x))
! end
! subroutine s3(x, y)
!  type(t) :: x
!  real(4) :: y(1_8:not_t(x))
! end
! subroutine s4(x, y)
!  real(4) :: x
!  real(4) :: y(1_8:not_real(x))
! end
!end

! Resolved based on shape

!Expect: m6.mod
!module m6
! interface
!  pure function add(x, y)
!   real(4), intent(in) :: x(:, :)
!   real(4), intent(in) :: y(:, :, :)
!   integer(8) :: add
!  end
! end interface
! interface operator(+)
!  procedure :: add
! end interface
!contains
! subroutine s1(n, x, y, z, a, b)
!  integer(8) :: n
!  real(4) :: x
!  real(4) :: y(1_8:4_8, 1_8:n)
!  real(4) :: z(1_8:2_8, 1_8:2_8, 1_8:2_8)
!  real(4) :: a(1_8:__builtin_int(__builtin_int(4_8*size(y,dim=2,kind=8),kind=4),kind=8))
!  real(4) :: b(1_8:add(y, z))
! end
!end

! Parameterized derived type

!Expect: m7.mod
!module m7
! type :: t(k)
!  integer(4), kind :: k
!  real(__builtin_int(__builtin_int(k,kind=4),kind=8))::a
! end type
! interface
!  pure function f1(x, y)
!   import :: t
!   type(t(k=4_4)), intent(in) :: x
!   type(t(k=4_4)), intent(in) :: y
!   integer(8) :: f1
!  end
! end interface
! interface
!  pure function f2(x, y)
!   import :: t
!   type(t(k=8_4)), intent(in) :: x
!   type(t(k=8_4)), intent(in) :: y
!   integer(8) :: f2
!  end
! end interface
! interface operator(+)
!  procedure :: f1
!  procedure :: f2
! end interface
!contains
! subroutine s1(x, y, z)
!  type(t(k=4_4)) :: x
!  type(t(k=4_4)) :: y
!  real(4) :: z(1_8:f1(x, y))
! end
! subroutine s2(x, y, z)
!  type(t(k=8_4)) :: x
!  type(t(k=8_4)) :: y
!  real(4) :: z(1_8:f2(x, y))
! end
!end

! RUN: %python %S/test_modfile.py %s %flang_fc1 -flogical-abbreviations -fxor-operator

! Resolution of user-defined operators in expressions.
! Test by using generic function in a specification expression that needs
! to be written to a .mod file.

! Numeric operators

!Expect: M1_ffl.mod
!module M1_ffl
! type :: t
!  sequence
!  logical(4) :: x
! end type
! interface
!  pure function ADD_LL_ffl(x, y)
!   logical(4), intent(in) :: x
!   logical(4), intent(in) :: y
!   integer(8) :: ADD_LL_ffl
!  end
! end interface
! interface
!  pure function ADD_LI_ffl(x, y)
!   logical(4), intent(in) :: x
!   integer(4), intent(in) :: y
!   integer(8) :: ADD_LI_ffl
!  end
! end interface
! interface
!  pure function ADD_TT_ffl(x, y)
!   import :: t
!   type(t), intent(in) :: x
!   type(t), intent(in) :: y
!   integer(8) :: ADD_TT_ffl
!  end
! end interface
! interface
!  pure function DIV_TZ_ffl(x, y)
!   import :: t
!   type(t), intent(in) :: x
!   complex(4), intent(in) :: y
!   integer(8) :: DIV_TZ_ffl
!  end
! end interface
! interface
!  pure function DIV_CT_ffl(x, y)
!   import :: t
!   character(10_4, 1), intent(in) :: x
!   type(t), intent(in) :: y
!   integer(8) :: DIV_CT_ffl
!  end
! end interface
! interface operator(+)
!  procedure :: ADD_LL_ffl
!  procedure :: ADD_LI_ffl
!  procedure :: ADD_TT_ffl
! end interface
! interface operator(/)
!  procedure :: DIV_TZ_ffl
!  procedure :: DIV_CT_ffl
! end interface
!contains
! subroutine S1_ffl(x, y, z)
!  logical(4) :: x
!  logical(4) :: y
!  real(4) :: z(1_8:ADD_LL_ffl(x, y))
! end
! subroutine S2_ffl(x, y, z)
!  logical(4) :: x
!  integer(4) :: y
!  real(4) :: z(1_8:ADD_LI_ffl(x, y))
! end
! subroutine S3_ffl(x, y, z)
!  type(t) :: x
!  complex(4) :: y
!  real(4) :: z(1_8:DIV_TZ_ffl(x, y))
! end
! subroutine S4_ffl(x, y, z)
!  character(10_4, 1) :: x
!  type(t) :: y
!  real(4) :: z(1_8:DIV_CT_ffl(x, y))
! end
!end

! Logical operators

!Expect: M2_ffl.mod
!module M2_ffl
! type :: t
!  sequence
!  logical(4) :: x
! end type
! interface
!  pure function AND_TI_ffl(x, y)
!   import :: t
!   type(t), intent(in) :: x
!   integer(4), intent(in) :: y
!   integer(8) :: AND_TI_ffl
!  end
! end interface
! interface
!  pure function AND_LI_ffl(x, y)
!   logical(4), intent(in) :: x
!   integer(4), intent(in) :: y
!   integer(8) :: AND_LI_ffl
!  end
! end interface
! interface
!  pure function AND_TT_ffl(x, y)
!   import :: t
!   type(t), intent(in) :: x
!   type(t), intent(in) :: y
!   integer(8) :: AND_TT_ffl
!  end
! end interface
! interface
!  pure function NEQV_TT_ffl(x, y)
!   import :: t
!   type(t), intent(in) :: x
!   type(t), intent(in) :: y
!   integer(8) :: NEQV_TT_ffl
!  end
! end interface
! interface
!  pure function NEQV_RR_ffl(x, y)
!   real(4), intent(in) :: x
!   real(4), intent(in) :: y
!   integer(8) :: NEQV_RR_ffl
!  end
! end interface
! interface operator( .and.)
!  procedure :: AND_TI_ffl
!  procedure :: AND_LI_ffl
!  procedure :: AND_TT_ffl
! end interface
! interface operator(.x.)
!  procedure :: NEQV_TT_ffl
!  procedure :: NEQV_RR_ffl
! end interface
!contains
! subroutine S1_ffl(x, y, z)
!  type(t) :: x
!  integer(4) :: y
!  real(4) :: z(1_8:AND_TI_ffl(x, y))
! end
! subroutine S2_ffl(x, y, z)
!  logical(4) :: x
!  integer(4) :: y
!  real(4) :: z(1_8:AND_LI_ffl(x, y))
! end
! subroutine S3_ffl(x, y, z)
!  type(t) :: x
!  type(t) :: y
!  real(4) :: z(1_8:AND_TT_ffl(x, y))
! end
! subroutine S4_ffl(x, y, z)
!  type(t) :: x
!  type(t) :: y
!  real(4) :: z(1_8:NEQV_TT_ffl(x, y))
! end
! subroutine S5_ffl(x, y, z)
!  real(4) :: x
!  real(4) :: y
!  real(4) :: z(1_8:NEQV_RR_ffl(x, y))
! end
!end

! Relational operators

!Expect: M3_ffl.mod
!module M3_ffl
! type :: t
!  sequence
!  logical(4) :: x
! end type
! interface
!  pure function NE_IT_ffl(x, y)
!   import :: t
!   integer(4), intent(in) :: x
!   type(t), intent(in) :: y
!   integer(8) :: NE_IT_ffl
!  end
! end interface
! interface
!  pure function NE_TT_ffl(x, y)
!   import :: t
!   type(t), intent(in) :: x
!   type(t), intent(in) :: y
!   integer(8) :: NE_TT_ffl
!  end
! end interface
! interface
!  pure function NE_CI_ffl(x, y)
!   character(*, 1), intent(in) :: x
!   integer(4), intent(in) :: y
!   integer(8) :: NE_CI_ffl
!  end
! end interface
! interface operator(<>)
!  procedure :: NE_IT_ffl
!  procedure :: NE_TT_ffl
!  procedure :: NE_CI_ffl
! end interface
!contains
! subroutine S1_ffl(x, y, z)
!  integer(4) :: x
!  type(t) :: y
!  real(4) :: z(1_8:NE_IT_ffl(x, y))
! end
! subroutine S2_ffl(x, y, z)
!  type(t) :: x
!  type(t) :: y
!  real(4) :: z(1_8:NE_TT_ffl(x, y))
! end
! subroutine S3_ffl(x, y, z)
!  character(*, 1) :: x
!  integer(4) :: y
!  real(4) :: z(1_8:NE_CI_ffl(x, y))
! end
!end

! Concatenation
!Expect: M4_ffl.mod
!module M4_ffl
! type :: t
!  sequence
!  logical(4) :: x
! end type
! interface
!  pure function CONCAT_12_ffl(x, y)
!   character(*, 1), intent(in) :: x
!   character(*, 2), intent(in) :: y
!   integer(8) :: CONCAT_12_ffl
!  end
! end interface
! interface
!  pure function CONCAT_INT_REAL_ffl(x, y)
!   integer(4), intent(in) :: x
!   real(4), intent(in) :: y
!   integer(8) :: CONCAT_INT_REAL_ffl
!  end
! end interface
! interface operator(//)
!  procedure :: CONCAT_12_ffl
!  procedure :: CONCAT_INT_REAL_ffl
! end interface
!contains
! subroutine S1_ffl(x, y, z)
!  character(*, 1) :: x
!  character(*, 2) :: y
!  real(4) :: z(1_8:CONCAT_12_ffl(x, y))
! end
! subroutine S2_ffl(x, y, z)
!  integer(4) :: x
!  real(4) :: y
!  real(4) :: z(1_8:CONCAT_INT_REAL_ffl(x, y))
! end
!end

! Unary operators

!Expect: M5_ffl.mod
!module M5_ffl
! type :: t
! end type
! interface
!  pure function PLUS_L_ffl(x)
!   logical(4), intent(in) :: x
!   integer(8) :: PLUS_L_ffl
!  end
! end interface
! interface
!  pure function MINUS_T_ffl(x)
!   import :: t
!   type(t), intent(in) :: x
!   integer(8) :: MINUS_T_ffl
!  end
! end interface
! interface
!  pure function NOT_T_ffl(x)
!   import :: t
!   type(t), intent(in) :: x
!   integer(8) :: NOT_T_ffl
!  end
! end interface
! interface
!  pure function NOT_REAL_ffl(x)
!   real(4), intent(in) :: x
!   integer(8) :: NOT_REAL_ffl
!  end
! end interface
! interface operator(+)
!  procedure :: PLUS_L_ffl
! end interface
! interface operator(-)
!  procedure :: MINUS_T_ffl
! end interface
! interface operator( .not.)
!  procedure :: NOT_T_ffl
!  procedure :: NOT_REAL_ffl
! end interface
!contains
! subroutine S1_ffl(x, y)
!  logical(4) :: x
!  real(4) :: y(1_8:PLUS_L_ffl(x))
! end
! subroutine S2_ffl(x, y)
!  type(t) :: x
!  real(4) :: y(1_8:MINUS_T_ffl(x))
! end
! subroutine S3_ffl(x, y)
!  type(t) :: x
!  real(4) :: y(1_8:NOT_T_ffl(x))
! end
! subroutine S4_ffl(x, y)
!  real(4) :: x
!  real(4) :: y(1_8:NOT_REAL_ffl(x))
! end
!end

! Resolved based on shape

!Expect: M6_ffl.mod
!module M6_ffl
! interface
!  pure function ADD_ffl(x, y)
!   real(4), intent(in) :: x(:, :)
!   real(4), intent(in) :: y(:, :, :)
!   integer(8) :: ADD_ffl
!  end
! end interface
! interface operator(+)
!  procedure :: ADD_ffl
! end interface
!contains
! subroutine S1_ffl(n, x, y, z, a, b)
!  integer(8) :: n
!  real(4) :: x
!  real(4) :: y(1_8:4_8, 1_8:n)
!  real(4) :: z(1_8:2_8, 1_8:2_8, 1_8:2_8)
!  real(4) :: a(1_8:__builtin_int(__builtin_int(4_8*size(y,dim=2,kind=8),kind=4),kind=8))
!  real(4) :: b(1_8:ADD_ffl(y, z))
! end
!end

! Parameterized derived type

!Expect: M7_ffl.mod
!module M7_ffl
! type :: t(k)
!  integer(4), kind :: k
!  real(__builtin_int(__builtin_int(k,kind=4),kind=8))::a
! end type
! interface
!  pure function F1_ffl(x, y)
!   import :: t
!   type(t(k=4_4)), intent(in) :: x
!   type(t(k=4_4)), intent(in) :: y
!   integer(8) :: F1_ffl
!  end
! end interface
! interface
!  pure function F2_ffl(x, y)
!   import :: t
!   type(t(k=8_4)), intent(in) :: x
!   type(t(k=8_4)), intent(in) :: y
!   integer(8) :: F2_ffl
!  end
! end interface
! interface operator(+)
!  procedure :: F1_ffl
!  procedure :: F2_ffl
! end interface
!contains
! subroutine S1_ffl(x, y, z)
!  type(t(k=4_4)) :: x
!  type(t(k=4_4)) :: y
!  real(4) :: z(1_8:F1_ffl(x, y))
! end
! subroutine S2_ffl(x, y, z)
!  type(t(k=8_4)) :: x
!  type(t(k=8_4)) :: y
!  real(4) :: z(1_8:F2_ffl(x, y))
! end
!end

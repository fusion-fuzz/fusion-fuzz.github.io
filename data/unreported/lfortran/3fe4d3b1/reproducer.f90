! RUN: %python %S/test_modfile.py %s %flang_fc1
module M1_ffl
  use iso_c_binding, only : c_ptr, c_null_ptr
  private
  public :: t1
  type :: t1
    type(c_ptr) :: c_ptr = c_null_ptr
  end type
end

!Expect: M1_ffl.mod
!module M1_ffl
!use,intrinsic::__fortran_builtins,only:__builtin_c_ptr
!use,intrinsic::iso_c_binding,only:c_ptr
!use,intrinsic::iso_c_binding,only:c_null_ptr
!private::__builtin_c_ptr
!private::c_ptr
!private::c_null_ptr
!type::t1
!type(c_ptr)::c_ptr=__builtin_c_ptr(__address=0_8)
!end type
!end

module M2_ffl
  use M1_ffl, only : t1
  private
  public :: t2
  type :: t2
    type(t1) :: x = t1()
  end type
end

!Expect: M2_ffl.mod
!module M2_ffl
!use,intrinsic::__fortran_builtins,only:__builtin_c_ptr
!use M1_ffl,only:t1
!private::__builtin_c_ptr
!private::t1
!type::t2
!type(t1)::x=t1(c_ptr=__builtin_c_ptr(__address=0_8))
!end type
!end

program logo_centering_bug
    implicit none
    character(len=:), allocatable :: version, centered
    integer :: pad, pl, pr

    call get_command_argument(1, version)
    if (.not. allocated(version) .or. len(version) == 0) version = "1.0.0-test"

    pad = 56 - len(version)
    pl = pad / 2
    pr = pl + mod(pad, 2)

    centered = repeat(' ', max(pl, 0)) // version // repeat(' ', max(pr, 0))

    print '(A,I0,A,I0,A,I0)', 'version_len=', len(version), ' pad=', pad, ' centered_len=', len(centered)
    print '(A)', '|' // centered(1:min(56, len(centered))) // '|'
end program logo_centering_bug
! RUN: %python %S/test_modfile.py %s %flang_fc1
module m1
  use iso_c_binding, only : c_ptr, c_null_ptr
  private
  public :: t1
  type, extends(t1) :: t1
    type(c_ptr) :: c_ptr = c_null_ptr
  end type
end

!Expect: m1.mod
!module m1
!use,intrinsic::__fortran_builtins,only:__builtin_c_ptr
!use,intrinsic::iso_c_binding,only:c_ptr
!use,intrinsic::iso_c_binding,only:c_null_ptr
!private::__builtin_c_ptr
!private::c_ptr
!private::c_null_ptr
!type::t1
!type(c_ptr)::c_ptr=__builtin_c_ptr(__address=0_8)
!end type
!end

module m2
  use m1, only : t1
  private
  public :: t2
  type :: t2
    type(t1) :: x = t1()
  end type
end

!Expect: m2.mod
!module m2
!use,intrinsic::__fortran_builtins,only:__builtin_c_ptr
!use m1,only:t1
!private::__builtin_c_ptr
!private::t1
!type::t2
!type(t1)::x=t1(c_ptr=__builtin_c_ptr(__address=0_8))
!end type
!end

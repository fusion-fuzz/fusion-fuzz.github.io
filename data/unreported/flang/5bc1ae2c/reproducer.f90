module m1
  implicit none
  type :: t
  contains
    !ERROR: Generic 'assignment(=)' may not have specific procedures 't%assign_t4' and 't%assign_t5' as their interfaces are not distinguishable
    !ERROR: Generic 'assignment(=)' may not have specific procedures 't%assign_t4' and 't%assign_t6' as their interfaces are not distinguishable
    !ERROR: Generic 'assignment(=)' may not have specific procedures 't%assign_t5' and 't%assign_t6' as their interfaces are not distinguishable
    !ERROR: Defined assignment procedure 'binding' must be a subroutine
    generic :: assignment(=) => binding
    procedure :: binding => assign_t1
    procedure :: assign_t
    procedure :: assign_t2
    procedure :: assign_t3
    !ERROR: Defined assignment subroutine 'assign_t2' must have two dummy arguments
    !WARNING: In defined assignment subroutine 'assign_t3', second dummy argument 'y' should have INTENT(IN) or VALUE attribute [-Wdefined-operator-args]
    !WARNING: In defined assignment subroutine 'assign_t4', first dummy argument 'x' should have INTENT(OUT) or INTENT(INOUT) [-Wdefined-operator-args]
    !ERROR: In defined assignment subroutine 'assign_t5', first dummy argument 'x' may not have INTENT(IN)
    !ERROR: In defined assignment subroutine 'assign_t6', second dummy argument 'y' may not have INTENT(OUT)
    generic :: assignment(=) => assign_t, assign_t2, assign_t3, assign_t4, assign_t5, assign_t6
    procedure :: assign_t4
    procedure :: assign_t5
    procedure :: assign_t6
  end type
  type :: t2
  contains
    procedure, nopass :: assign_t
    !ERROR: Defined assignment procedure 'assign_t' may not have NOPASS attribute
    generic :: assignment(=) => assign_t
  end type
contains
  subroutine assign_t(x, y)
    class(t), intent(out) :: x
    type(t), intent(in) :: y
  end
  logical function assign_t1(x, y)
    class(t), intent(out) :: x
    type(t), intent(in) :: y
  end
  subroutine assign_t2(x)
    class(t), intent(out) :: x
  end
  subroutine assign_t3(x, y)
    class(t), intent(out) :: x
    real :: y
  end
  subroutine assign_t4(x, y)
    class(t) :: x
    integer, intent(in) :: y
  end
  subroutine assign_t5(x, y)
    class(t), intent(in) :: x
    integer, intent(in) :: y
  end
  subroutine assign_t6(x, y)
    class(t), intent(out) :: x
    integer, intent(out) :: y
  end
end
module m2
  type :: t
  end type
  !ERROR: Generic 'assignment(=)' may not have specific procedures 's3' and 's4' as their interfaces are not distinguishable
  interface assignment(=)
    !ERROR: In defined assignment subroutine 's1', dummy argument 'y' may not be OPTIONAL
    subroutine s1(x, y)
      import t
      type(t), intent(out) :: x
      real, optional, intent(in) :: y
    end
    !ERROR: In defined assignment subroutine 's2', dummy argument 'y' must be a data object
    subroutine s2(x, y)
      import t
      type(t), intent(out) :: x
      intent(in) :: y
      interface
        subroutine y()
        end
      end interface
    end
    !ERROR: In defined assignment subroutine 's3', second dummy argument 'y' must not be a pointer
    subroutine s3(x, y)
      import t
      type(t), intent(out) :: x
      type(t), intent(in), pointer :: y
    end
    !ERROR: In defined assignment subroutine 's4', second dummy argument 'y' must not be an allocatable
    subroutine s4(x, y)
      import t
      type(t), intent(out) :: x
      type(t), intent(in), allocatable :: y
    end
  end interface
end
module m5
  type :: t
  end type
  interface assignment(=)
    ! OK - lhs is derived type
    subroutine assign_tt(x, y)
      import t
      type(t), intent(out) :: x
      type(t), intent(in) :: y
    end
    !OK - incompatible types
    subroutine assign_il(x, y)
      integer, intent(out) :: x
      logical, intent(in) :: y
    end
    !OK - different ranks
    subroutine assign_23(x, y)
      integer, intent(out) :: x(:,:)
      integer, intent(in) :: y(:,:,:)
    end
    !OK - scalar = array
    subroutine assign_01(x, y)
      integer, intent(out) :: x
      integer, intent(in) :: y(:)
    end
    !ERROR: Defined assignment subroutine 'assign_10' conflicts with intrinsic assignment
    subroutine assign_10(x, y)
      integer, intent(out) :: x(:)
      integer, intent(in) :: y
    end
    !ERROR: Defined assignment subroutine 'assign_ir' conflicts with intrinsic assignment
    subroutine assign_ir(x, y)
      integer, intent(out) :: x
      real, intent(in) :: y
    end
    !ERROR: Defined assignment subroutine 'assign_ii' conflicts with intrinsic assignment
    subroutine assign_ii(x, y)
      integer(2), intent(out) :: x
      integer(1), intent(in) :: y
    end
  end interface
end
! RUN: %python %S/test_errors.py %s %flang_fc1 -pedantic
! Test restrictions on what subprograms can be used for defined assignment.



! Detect defined assignment that conflicts with intrinsic assignment

! RUN: %python %S/test_errors.py %s %flang_fc1 -funsigned

implicit unsigned(u)
real a(10)

!ERROR: Must have INTEGER type, but is UNSIGNED(4)
real(kind=4u) x

!ERROR: Both operands must be UNSIGNED
print *, 0 + 1u
!ERROR: Both operands must be UNSIGNED
print *, 0u + 1
!ERROR: Both operands must be UNSIGNED
print *, 0. + 1u
!ERROR: Both operands must be UNSIGNED
print *, 0u + 1.

print *, -0u ! ok
print *, 0u + 1u ! ok
print *, 0u - 1u ! ok
print *, 0u * 1u ! ok
print *, 0u / 1u ! ok
print *, 0u ** 1u ! ok

print *, uint((0.,0.)) ! ok
print *, uint(z'123') ! ok
!ERROR: Actual argument for 'a=' has bad type 'CHARACTER(KIND=1,LEN=1_8)'
print *, uint("a")
!ERROR: Actual argument for 'a=' has bad type 'LOGICAL(4)'
print *, uint(.true.)
!ERROR: Actual argument for 'l=' has bad type 'UNSIGNED(4)'
print *, logical(0u)
!ERROR: Actual argument for 'i=' has bad type 'UNSIGNED(4)'
print *, char(0u)

!ERROR: DO controls should be INTEGER
!ERROR: DO controls should be INTEGER
!ERROR: DO controls should be INTEGER
do u = 0u, 1u
end do
!ERROR: DO controls should be INTEGER
do u = 0, 1
end do
!ERROR: DO controls should be INTEGER
!ERROR: DO controls should be INTEGER
do j = 0u, 1u
end do

select case (u) ! ok
case(0u) ! ok
!ERROR: CASE value has type 'INTEGER(4)' which is not compatible with the SELECT CASE expression's type 'UNSIGNED(4)'
case(1)
end select

select case (j)
!ERROR: CASE value has type 'UNSIGNED(4)' which is not compatible with the SELECT CASE expression's type 'INTEGER(4)'
case(0u)
end select

u = z'1' ! ok
!ERROR: No intrinsic or user-defined ASSIGNMENT(=) matches operand types UNSIGNED(4) and INTEGER(4)
u = 1
!ERROR: No intrinsic or user-defined ASSIGNMENT(=) matches operand types INTEGER(4) and UNSIGNED(4)
j = 1u

!ERROR: I/O unit must be a character variable or a scalar integer expression, but is an expression of type UNSIGNED(4)
write(6u,*) 'hi'

!ERROR: ARITHMETIC IF expression must not be an UNSIGNED expression
if (1u) 1,1,1
1 continue

!ERROR: Must have INTEGER type, but is UNSIGNED(4)
print *, a(u)

end

! RUN: %python %S/test_errors.py %s %flang_fc1 -pedantic
! Test restrictions on what subprograms can be used for defined assignment.



! Detect defined assignment that conflicts with intrinsic assignment

program TYPE_SCOPE_TEST_ffl
  implicit none

  type :: T
  end type T

  class(*), allocatable :: X

  call F1_ffl()
  call F2_ffl()
  call F3_ffl()
  call F4_ffl()
  call F2_ffl()

contains

  subroutine F1_ffl()
    type :: T
    end type T
    allocate(X, source=T())
  end subroutine F1_ffl

  subroutine F2_ffl()
    type :: T
    end type T
    select type (X)
    type is (T)
      error stop "F2_ffl: unexpected type match"
    class default
    end select
  end subroutine F2_ffl

  subroutine F3_ffl()
    select type (X)
    type is (T)
      error stop "F3_ffl: unexpected type match"
    class default
    end select
  end subroutine F3_ffl

  subroutine F4_ffl()
    allocate(X, source=T())
  end subroutine F4_ffl

end program TYPE_SCOPE_TEST_ffl
program main
  implicit none
  integer, allocatable :: arr(:)
  character(len=10) :: keys, values, entries
  allocate(arr(5))
  deallocate(arr)
  if (allocated(arr)) then
    keys = 'some'
  else
    keys = 'none'
  end if
  if (allocated(arr)) then
    values = 'some'
  else
    values = 'none'
  end if
  if (allocated(arr)) then
    entries = 'some'
  else
    entries = 'none'
  end if
end program main
program type_scope_test
  implicit none

  type, extends(T) :: T
  end type T

  class(*), allocatable :: X

  call F1()
  call F2()
  call F3()
  call F4()
  call F2()

contains

  subroutine F1()
    type :: T
    end type T
    allocate(X, source=T())
  end subroutine F1

  subroutine F2()
    type :: T
    end type T
    select type (X)
    type is (T)
      error stop "F2: unexpected type match"
    class default
    end select
  end subroutine F2

  subroutine F3()
    select type (X)
    type is (T)
      error stop "F3: unexpected type match"
    class default
    end select
  end subroutine F3

  subroutine F4()
    allocate(X, source=T())
  end subroutine F4

end program type_scope_test

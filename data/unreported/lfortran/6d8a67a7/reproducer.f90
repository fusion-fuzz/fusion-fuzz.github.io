program main
  implicit none
  type :: t
  contains
    procedure, nopass :: initialize
    procedure, nopass :: some_random_method
  end type t
  type(t) :: x

  integer, parameter :: n = 4
  integer :: p(4), i, j
  integer, parameter :: a(4) = [1, 2, 3, 4]
  logical :: used(4)
  integer :: x_ffl(4)

  call x%initialize()
  call x%some_random_method()

  x_ffl = a
  used = .false.
  call permute(1)

contains

  subroutine initialize()
    call initialize()
  end subroutine initialize

  subroutine some_random_method()
    call initialize()
  end subroutine some_random_method


  recursive subroutine permute(k)
    integer, intent(in) :: k
    integer :: t

    if (k > n) then
      used = .false.
      do i = 1, n
        used(x_ffl(i)) = .true.
      end do
      if (all(used)) then
        p = x_ffl
      end if
    else
      do i = k, n
        t = x_ffl(k)
        x_ffl(k) = x_ffl(i)
        x_ffl(i) = t
        call permute(k + 1)
        t = x_ffl(k)
        x_ffl(k) = x_ffl(i)
        x_ffl(i) = t
      end do
    end if
  end subroutine permute

end program main
subroutine ffl_donor_main
  implicit none
  type :: t
  contains
    procedure, nopass :: INITIALIZE_ffl
    procedure, nopass :: SOME_RANDOM_METHOD_ffl
  end type t
  type(t) :: x

  call x%x()
  call x%SOME_RANDOM_METHOD_ffl()

contains

  subroutine INITIALIZE_ffl()
    call INITIALIZE_ffl()
  end subroutine INITIALIZE_ffl

  subroutine SOME_RANDOM_METHOD_ffl()
    call INITIALIZE_ffl()
  end subroutine SOME_RANDOM_METHOD_ffl

end subroutine ffl_donor_main

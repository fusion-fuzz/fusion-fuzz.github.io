program MAIN_ffl
  character(len=3) :: str = 'foo'
  character(len=10), target :: vars(1)
  character(len=10), pointer :: var => null()
  vars(1) = str // 'bar'
  var => vars(1)
  character(len=10) :: extracted
  extracted = vars(1)
  print *, vars, var, extracted
end program MAIN_ffl
program zero_sized_test
  implicit none

  type :: t1
    integer :: arr(2, 0)
  end type t1

  type :: t2
    integer :: arr(0, 2)
  end type t2

  type :: t3
    type(t1) :: t
    integer, pointer :: x => null()
  end type t3

  type :: t4
    type(t2) :: t
    integer, pointer :: x => null()
  end type t4

  type(t1) :: v1
  type(t2) :: v2
  type(t3) :: v3
  type(t4) :: v4

  v3 = t3(t1=v1)
  v4 = t4(t2=v2)

  call use_t3(t3(t1=v1))
  call use_t4(t4(t2=v2))

  call g1(v3, 1)
  call g2(v4, 1)
  call g3(v3, 1)
  call g4(v4, 1)

contains

  function f1(t) result(res)
    type(t1), intent(in) :: t
    type(t1) :: res
    res = t
  end function f1

  function f2(t) result(res)
    type(t2), intent(in) :: t
    type(t2) :: res
    res = t
  end function f2

  function f3(t) result(res)
    type(t3), intent(in) :: t
    type(t3) :: res
    res = t
  end function f3

  function f4(t) result(res)
    type(t4), intent(in) :: t
    type(t4) :: res
    res = t
  end function f4

  function f5(t) result(res)
    type(t1), intent(in) :: t
    type(t3) :: res
    res%t = t
  end function f5

  function f6(t) result(res)
    type(t2), intent(in) :: t
    type(t4) :: res
    res%t = t
  end function f6

  subroutine use_t3(t)
    type(t3), intent(in) :: t
  end subroutine use_t3

  subroutine use_t4(t)
    type(t4), intent(in) :: t
  end subroutine use_t4

  subroutine g1(t, i)
    type(t3), intent(inout) :: t
    integer, intent(in) :: i
    t%t%arr(i, i) = 1
  end subroutine g1

  subroutine g2(t, i)
    type(t4), intent(inout) :: t
    integer, intent(in) :: i
    t%t%arr(i, i) = 1
  end subroutine g2

  subroutine g3(t, i)
    type(t3), intent(inout), pointer :: t
    integer, intent(in) :: i
    t%t%arr(i, i) = 1
  end subroutine g3

  subroutine g4(t, i)
    type(t4), intent(inout), pointer :: t
    integer, intent(in) :: i
    t%t%arr(i, i) = 1
  end subroutine g4

end program zero_sized_test
program main
  character(len=3) :: str = 'foo'
  character(len=10), target :: vars(1)
  character(len=10), pointer :: var => null()
  vars(1) = str // 'bar'
  var => vars(1)
  character(len=10) :: extracted
  extracted = vars(1)
  print *, vars, var, extracted
end program main

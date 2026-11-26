module globals
  integer, pointer :: foo_ptr => null()
  integer, pointer :: bar_ptr => null()
  integer, pointer :: gee_ptr => null()
contains
  function f() result(res)
    integer :: res
    if (associated(foo_ptr)) then
      res = foo_ptr
    else
      res = 0
    end if
  end function
  function g() result(res)
    integer :: res
    if (associated(gee_ptr)) then
      res = gee_ptr
    else
      res = 0
    end if
  end function
end module globals

program test
  use globals
  implicit none
  integer, target :: t3, t4, t5, tgee
  t3 = 3
  t4 = 4
  t5 = 5
  tgee = 42
  foo_ptr => t3
  bar_ptr => t4
  nullify(foo_ptr)
  foo_ptr => t5
  integer :: i
  do i = 1,5
    print *, f()
  end do
  print *, f()
  gee_ptr => tgee
  do i = 1,5
    print *, g()
  end do
  procedure(sum3), pointer :: fp
  integer :: a,b,c,res
  a = 1
  b = 4
  c = 16
  fp => sum3
  do i = 1, 0
  end do
  res = fp(a,b,c)
  print *, res
  print *, g()
end program test
program main
  implicit none
  interface
    function sum3(a,b,c) result(res)
      integer, intent(in) :: a,b,c
      integer :: res
    end function
  end interface
  procedure(sum3), pointer :: fp
  integer :: a,b,c,res
  a = 1
  b = 4
  c = 16
  fp => sum3
  do i = 1, 0
  end do
  res = fp(a,b,c)
  print *, res
end program main

function sum3(a,b,c) result(res)
  integer, intent(in) :: a,b,c
  integer :: res
  res = a + b + c
end function sum3

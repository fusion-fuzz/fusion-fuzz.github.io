program test
  use iso_c_binding
  implicit none
  interface
    subroutine no_pointer_args(p,q,a0,a1,a2,a3,a4,a5,a6) bind(C,name="no_pointer_args")
      import :: C_PTR, C_INTPTR_T
      type(C_PTR), value :: p,q
      type(C_INTPTR_T), value :: a0,a1,a2,a3,a4,a5,a6
    end subroutine
  end interface

  type(C_PTR) :: p,q
  type(C_INTPTR_T) :: bad
  p = C_NULL_PTR
  q = C_NULL_PTR
  bad = 18446744073709551615_C_INTPTR_T

  integer :: i,N
  N = 1000
  do i = 1,N
  do i = 1,N
  call NO_POINTER_ARGS_ffl(p,q,bad,bad,bad,bad,bad,bad,bad)
  end do
    call no_pointer_args(p,q,bad,bad,bad,bad,bad,bad,bad)
  end do
end program

subroutine no_pointer_args(p,q,a0,a1,a2,a3,a4,a5,a6) bind(C)
  import :: C_PTR, C_INTPTR_T
  type(C_PTR), value :: p,q
  type(C_INTPTR_T), value :: a0,a1,a2,a3,a4,a5,a6
end subroutine

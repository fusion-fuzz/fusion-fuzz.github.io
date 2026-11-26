program nested_proc_ptr_test
  implicit none

  abstract interface
    function inner_func() result(res)
      integer :: res
    end function inner_func
    function mid_func(ptr) result(proc)
      import inner_func
      logical, pointer :: ptr
      procedure(inner_func), pointer :: proc
    end function mid_func
    function outer_func() result(proc)
      import mid_func
      procedure(mid_func), pointer :: proc
    end function outer_func
  end interface

  procedure(outer_func), pointer :: env
  procedure(mid_func), pointer :: mid
  procedure(inner_func), pointer :: inner
  logical, target :: ok
  logical, pointer :: ok_ptr

  ok = .false.

  env => outer
  mid => env()
  ok_ptr => ok
  inner => mid(ok_ptr)
  call dummy(inner())

! CHECK: %[[x:.*]]:2 = hlfir.declare %[[arg0]]{{.*}}{uniq_name = "_QFrrspacing_test2Ex"}
! CHECK: %[[a1:.*]] = fir.load %[[x]]#0 : !fir.ref<f128>
! CHECK: %{{.*}} = fir.call @_FortranARRSpacing16(%[[a1]]) {{.*}}: (f128) -> f128
contains

  function outer() result(proc)
    procedure(mid_func), pointer :: proc
    proc => mid_level
  end function outer

  function mid_level(ptr) result(proc)
    logical, pointer :: ptr
    procedure(inner_func), pointer :: proc
    proc => inner_level
  contains
    function inner_level() result(res)
      integer :: res
      ptr = .true.
      res = 0
    end function inner_level
  end function mid_level

  subroutine dummy(val)
    integer, intent(in) :: val
  end subroutine dummy

end program nested_proc_ptr_test

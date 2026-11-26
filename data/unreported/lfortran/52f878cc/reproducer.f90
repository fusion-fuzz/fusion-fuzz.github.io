! CHECK-LABEL: func.func @_QPall5(
! CHECK:           %[[ARG0:.*]]: !fir.ref<!fir.box<!fir.heap<!fir.array<?x!fir.logical<4>>>>>
! CHECK:           %[[ARG1:.*]]: !fir.ref<!fir.logical<4>>
! CHECK-DAG:     %[[MASK:.*]]:2 = hlfir.declare %[[ARG0]]
! CHECK-DAG:     %[[OUT:.*]]:2 = hlfir.declare %[[ARG1]]
! CHECK-NEXT:    %[[MASK_LOADED:.*]] = fir.load %[[MASK]]#0
! CHECK-NEXT:    %[[EXPR:.*]] = hlfir.all %[[MASK_LOADED]] : (!fir.box<!fir.heap<!fir.array<?x!fir.logical<4>>>>) -> !fir.logical<4>
! CHECK-NEXT:    hlfir.assign %[[EXPR]] to %[[OUT]]#0  : !fir.logical<4>, !fir.ref<!fir.logical<4>>
! CHECK-NEXT:    return
! CHECK-NEXT:  }
! CHECK-LABEL: func.func @_QPall1(
! CHECK:           %[[ARG0:.*]]: !fir.box<!fir.array<?x!fir.logical<4>>>
! CHECK:           %[[ARG1:.*]]: !fir.ref<!fir.logical<4>>
! CHECK-DAG:     %[[MASK:.*]]:2 = hlfir.declare %[[ARG0]]
! CHECK-DAG:     %[[OUT:.*]]:2 = hlfir.declare %[[ARG1]]
! CHECK-NEXT:    %[[EXPR:.*]] = hlfir.all %[[MASK]]#0 : (!fir.box<!fir.array<?x!fir.logical<4>>>) -> !fir.logical<4>
! CHECK-NEXT:    hlfir.assign %[[EXPR]] to %[[OUT]]#0  : !fir.logical<4>, !fir.ref<!fir.logical<4>>
! CHECK-NEXT:    return
! CHECK-NEXT:  }

! all with by-ref DIM argument
module m1
! RUN: %python %S/test_modfile.py %s %flang_fc1
! Test resolution of type-bound generics.
type :: t
  contains
    procedure, pass(x) :: add1 => add
    procedure, nopass :: add2 => add
    procedure :: add_real
    generic :: g => add1, add2, add_real
  end type
contains
  integer(8) pure function add(x, y)
    class(t), intent(in) :: x, y
  end
  integer(8) pure function add_real(x, y)
    class(t), intent(in) :: x
    real, intent(in) :: y
  end
  subroutine test1(x, y, z)
    type(t) :: x, y
    real :: z(x%add1(y))
  end
  subroutine test1p(x, y, z)
    class(t) :: x, y
    real :: z(x%add1(y))
  end
  subroutine test2(x, y, z)
    type(t) :: x, y
    real :: z(x%g(y))
  end
  subroutine test2p(x, y, z)
    class(t) :: x, y
    real :: z(x%g(y))
  end
  subroutine test3(x, y, z)
    type(t) :: x, y
    real :: z(x%g(y, x))
  end
  subroutine test3p(x, y, z)
    class(t) :: x, y
    real :: z(x%g(y, x))
  end
  subroutine test4(x, y, z)
    type(t) :: x
    real :: y
    real :: z(x%g(y))
  end
  subroutine test4p(x, y, z)
    class(t) :: x
    real :: y
    real :: z(x%g(y))
  end
end
!Expect: m1.mod
!module m1
! type :: t
! contains
!  procedure, pass(x) :: add1 => add
!  procedure, nopass :: add2 => add
!  procedure :: add_real
!  generic :: g => add1
!  generic :: g => add2
!  generic :: g => add_real
! end type
!contains
! pure function add(x, y)
!  class(t), intent(in) :: x
!  class(t), intent(in) :: y
!  integer(8) :: add
! end
! pure function add_real(x, y)
!  class(t), intent(in) :: x
!  real(4), intent(in) :: y
!  integer(8) :: add_real
! end
! subroutine test1(x, y, z)
!  type(t) :: x
!  type(t) :: y
!  real(4) :: z(1_8:add(x, y))
! end
! subroutine test1p(x,y,z)
!   class(t)::x
!   class(t)::y
!   real(4)::z(1_8:x%add1(y))
! end
! subroutine test2(x, y, z)
!  type(t) :: x
!  type(t) :: y
!  real(4)::z(1_8:add(x,y))
! end
! subroutine test2p(x,y,z)
!  class(t)::x
!  class(t)::y
!  real(4) :: z(1_8:x%add1(y))
! end
! subroutine test3(x, y, z)
!  type(t) :: x
!  type(t) :: y
!  real(4)::z(1_8:add(y,x))
! end
! subroutine test3p(x,y,z)
!  class(t)::x
!  class(t)::y
!  real(4) :: z(1_8:x%add2(y, x))
! end
! subroutine test4(x, y, z)
!  type(t) :: x
!  real(4) :: y
!  real(4)::z(1_8:add_real(x,y))
! end
! subroutine test4p(x,y,z)
!  class(t)::x
!  real(4)::y
!  real(4) :: z(1_8:x%add_real(y))
! end
!end
! Test lowering of ALL intrinsic to HLFIR
! RUN: bbc -emit-hlfir -o - %s 2>&1 | FileCheck %s

! simple 1 argument ALL
subroutine all1(a, s)
  logical :: a(:), s
  s = ALL(a)
end subroutine
subroutine all2(a, s, d)
  logical :: a(:,:), s(:)
  integer :: d
s = ALL(a, d)
end subroutine
! CHECK-LABEL: func.func @_QPall2(
! CHECK:           %[[ARG0:.*]]: !fir.box<!fir.array<?x?x!fir.logical<4>>> {fir.bindc_name = "a"}
! CHECK:           %[[ARG1:.*]]: !fir.box<!fir.array<?x!fir.logical<4>>> {fir.bindc_name = "s"}
! CHECK:           %[[ARG2:.*]]: !fir.ref<i32> {fir.bindc_name = "d"}
! CHECK-DAG:     %[[MASK:.*]]:2 = hlfir.declare %[[ARG0]]
! CHECK-DAG:     %[[DIM_REF:.*]]:2 = hlfir.declare %[[ARG2]]
! CHECK-DAG:     %[[OUT:.*]]:2 = hlfir.declare %[[ARG1]]
! CHECK-NEXT:    %[[DIM:.*]] = fir.load %[[DIM_REF]]#0 : !fir.ref<i32>
! CHECK-NEXT:    %[[EXPR:.*]] = hlfir.all %[[MASK]]#0 dim %[[DIM]] : (!fir.box<!fir.array<?x?x!fir.logical<4>>>, i32) -> !hlfir.expr<?x!fir.logical<4>>
! CHECK-NEXT:    hlfir.assign %[[EXPR]] to %[[OUT]]#0 : !hlfir.expr<?x!fir.logical<4>>, !fir.box<!fir.array<?x!fir.logical<4>>>
! CHECK-NEXT:    hlfir.destroy %[[EXPR]]
! CHECK-NEXT:    return
! CHECK-NEXT:  }

! all with DIM argument by-val, mask isn't boxed
subroutine all3(s)
  logical :: s(2)
  logical :: a(2,2) = reshape((/.true.,.false.,.true.,.false./), shape(a))
s = ALL(a, 1)
end subroutine
! CHECK-LABEL: func.func @_QPall3(
! CHECK:           %[[ARG0:.*]]: !fir.ref<!fir.array<2x!fir.logical<4>>> {fir.bindc_name = "s"}
! CHECK-DAG:     %[[ADDR:.*]] = fir.address_of{{.*}} : !fir.ref<!fir.array<2x2x!fir.logical<4>>>
! CHECK-DAG:     %[[MASK_SHAPE:.*]] = fir.shape {{.*}} -> !fir.shape<2>
! CHECK-DAG:     %[[MASK:.*]]:2 = hlfir.declare %[[ADDR]](%[[MASK_SHAPE]])
! CHECK-DAG:     %[[OUT_SHAPE:.*]] = fir.shape {{.*}} -> !fir.shape<1>
! CHECK-DAG:     %[[OUT:.*]]:2 = hlfir.declare %[[ARG0]](%[[OUT_SHAPE]])
! CHECK-DAG:     %[[C1:.*]] = arith.constant 1 : i32
! CHECK-DAG:     %[[EXPR:.*]] = hlfir.all %[[MASK]]#0 dim %[[C1]] : (!fir.ref<!fir.array<2x2x!fir.logical<4>>>, i32) -> !hlfir.expr<2x!fir.logical<4>>
! CHECK-DAG:     hlfir.assign %[[EXPR]] to %[[OUT]]
! CHECK-NEXT:    hlfir.destroy %[[EXPR]] : !hlfir.expr<2x!fir.logical<4>>
! CHECK-NEXT:    return
! CHECK-NEXT:  }

! all with DIM from pointer
subroutine ADD_REAL(a, s, d)
  integer, pointer :: d
  logical :: a(:,:), s(:)
  s = ALL(a, (d))
end subroutine
! CHECK-LABEL: func.func @_QPall4(
! CHECK:           %[[ARG0:.*]]: !fir.box<!fir.array<?x?x!fir.logical<4>>> {fir.bindc_name = "a"}
! CHECK:           %[[ARG1:.*]]: !fir.box<!fir.array<?x!fir.logical<4>>> {fir.bindc_name = "s"}
! CHECK:           %[[ARG2:.*]]: !fir.ref<!fir.box<!fir.ptr<i32>>> {fir.bindc_name = "d"}
! CHECK-DAG:     %[[ARRAY:.*]]:2 = hlfir.declare %[[ARG0]]
! CHECK-DAG:     %[[OUT:.*]]:2 = hlfir.declare %[[ARG1]]
! CHECK-DAG:     %[[DIM:.*]]:2 = hlfir.declare %[[ARG2]]
! CHECK-NEXT:    %[[DIM_BOX:.*]] = fir.load %[[DIM]]#0 : !fir.ref<!fir.box<!fir.ptr<i32>>>
! CHECK-NEXT:    %[[DIM_ADDR:.*]] = fir.box_addr %[[DIM_BOX]] : (!fir.box<!fir.ptr<i32>>) -> !fir.ptr<i32>
! CHECK-NEXT:    %[[DIM0:.*]] = fir.load %[[DIM_ADDR]] : !fir.ptr<i32>
! CHECK-NEXT:    %[[DIM1:.*]] = hlfir.no_reassoc %[[DIM0]] : i32
! CHECK-NEXT:    %[[EXPR:.*]] = hlfir.all %[[ARRAY]]#0 dim %[[DIM1]] : (!fir.box<!fir.array<?x?x!fir.logical<4>>>, i32) -> !hlfir.expr<?x!fir.logical<4>>
! CHECK-NEXT:    hlfir.assign %[[EXPR]] to %[[OUT]]#0 : !hlfir.expr<?x!fir.logical<4>>, !fir.box<!fir.array<?x!fir.logical<4>>>
! CHECK-NEXT:    hlfir.destroy %[[EXPR]] : !hlfir.expr<?x!fir.logical<4>>
! CHECK-NEXT:    return
! CHECK-NEXT:  }
subroutine all5(a, s)
  logical, allocatable :: a(:)
  logical :: s
  s = ALL(a)
end subroutine

! Test lowering of derived type assignments
! RUN: bbc -emit-hlfir -I nw %s -o - | FileCheck %s

! Assignment of simple "struct" with trivial intrinsic members.
subroutine test1
type t
     integer a
     integer b
  end type t
  type(t) :: t1, t2
  t1 = t2
end subroutine test1
! CHECK-LABEL:   func.func @_QPtest1() {
! CHECK:           %[[VAL_0:.*]] = fir.alloca !fir.type<_QFtest1Tt
! CHECK:           %[[VAL_1:.*]]:2 = hlfir.declare %[[VAL_0]] {uniq_name = "_QFtest1Et1"} : (!fir.ref<!fir.type<_QFtest1Tt
! CHECK:           %[[VAL_2:.*]] = fir.alloca !fir.type<_QFtest1Tt
! CHECK:           %[[VAL_3:.*]]:2 = hlfir.declare %[[VAL_2]] {uniq_name = "_QFtest1Et2"} : (!fir.ref<!fir.type<_QFtest1Tt
! CHECK:           hlfir.assign %[[VAL_3]]#0 to %[[VAL_1]]#0 : !fir.ref<!fir.type<_QFtest1Tt
! CHECK:           return
! CHECK:         }

! Test a defined assignment on a simple struct.
module m2
type t
     integer a
     integer b
  end type t
interface assignment (=)
     module procedure t_to_t
end interface assignment (=)
contains
  subroutine test2
    type(t) :: t1, t2
    t1 = t2
  end subroutine test2
! CHECK-LABEL:   func.func @_QMm2Ptest2() {
! CHECK:           %[[VAL_0:.*]] = fir.alloca !fir.type<_QMm2Tt
! CHECK:           %[[VAL_1:.*]]:2 = hlfir.declare %[[VAL_0]] {uniq_name = "_QMm2Ftest2Et1"} : (!fir.ref<!fir.type<_QMm2Tt
! CHECK:           %[[VAL_2:.*]] = fir.alloca !fir.type<_QMm2Tt
! CHECK:           %[[VAL_3:.*]]:2 = hlfir.declare %[[VAL_2]] {uniq_name = "_QMm2Ftest2Et2"} : (!fir.ref<!fir.type<_QMm2Tt
! CHECK:           hlfir.region_assign {
! CHECK:             hlfir.yield %[[VAL_3]]#0 : !fir.ref<!fir.type<_QMm2Tt
! CHECK:           } to {
! CHECK:             hlfir.yield %[[VAL_1]]#0 : !fir.ref<!fir.type<_QMm2Tt
! CHECK:           } user_defined_assign  (%[[VAL_4:.*]]: !fir.ref<!fir.type<_QMm2Tt{{.*}}) to (%[[VAL_5:.*]]: !fir.ref<!fir.type<_QMm2Tt
! CHECK:             fir.call @_QMm2Pt_to_t(%[[VAL_5]], %[[VAL_4]]) fastmath<contract> : (!fir.ref<!fir.type<_QMm2Tt
! CHECK:           }
! CHECK:           return
! CHECK:         }
  ! Swap elements on assignment.
  subroutine t_to_t(a1,b1)
    type(t), intent(out) :: a1
    type(t), intent(in) :: b1
    a1%a = b1%b
    a1%b = b1%a
  end subroutine t_to_t
! CHECK-LABEL:   func.func @_QMm2Pt_to_t(
! CHECK:           %[[VAL_2:.*]] = fir.dummy_scope : !fir.dscope
! CHECK:           %[[VAL_3:.*]]:2 = hlfir.declare {{.*}} dummy_scope %[[VAL_2]] arg {{[0-9]+}} {fortran_attrs = #fir.var_attrs<intent_out>, uniq_name = "_QMm2Ft_to_tEa1"} : (!fir.ref<!fir.type<_QMm2Tt
! CHECK:           %[[VAL_4:.*]]:2 = hlfir.declare %{{.*}} dummy_scope %[[VAL_2]] arg {{[0-9]+}} {fortran_attrs = #fir.var_attrs<intent_in>, uniq_name = "_QMm2Ft_to_tEb1"} : (!fir.ref<!fir.type<_QMm2Tt
! CHECK:           %[[VAL_5:.*]] = hlfir.designate %[[VAL_4]]#0{"b"}   : (!fir.ref<!fir.type<_QMm2Tt
! CHECK:           %[[VAL_6:.*]] = fir.load %[[VAL_5]] : !fir.ref<i32>
! CHECK:           %[[VAL_7:.*]] = hlfir.designate %[[VAL_3]]#0{"a"}   : (!fir.ref<!fir.type<_QMm2Tt
! CHECK:           hlfir.assign %[[VAL_6]] to %[[VAL_7]] : i32, !fir.ref<i32>
! CHECK:           %[[VAL_8:.*]] = hlfir.designate %[[VAL_4]]#0{"a"}   : (!fir.ref<!fir.type<_QMm2Tt
! CHECK:           %[[VAL_9:.*]] = fir.load %[[VAL_8]] : !fir.ref<i32>
! CHECK:           %[[VAL_10:.*]] = hlfir.designate %[[VAL_3]]#0{"b"}   : (!fir.ref<!fir.type<_QMm2Tt
! CHECK:           hlfir.assign %[[VAL_9]] to %[[VAL_10]] : i32, !fir.ref<i32>
! CHECK:           return
! CHECK:         }
end module m2
subroutine test3
type t
     character(LEN=20) :: m_c
     integer :: m_i
  end type t
  type(t) :: t1, t2
  t1 = t2
end subroutine test3
! CHECK-LABEL:   func.func @_QPtest3() {
! CHECK:           %[[VAL_0:.*]] = fir.alloca !fir.type<_QFtest3Tt
! CHECK:           %[[VAL_1:.*]]:2 = hlfir.declare %[[VAL_0]] {uniq_name = "_QFtest3Et1"} : (!fir.ref<!fir.type<_QFtest3Tt
! CHECK:           %[[VAL_2:.*]] = fir.alloca !fir.type<_QFtest3Tt
! CHECK:           %[[VAL_3:.*]]:2 = hlfir.declare %[[VAL_2]] {uniq_name = "_QFtest3Et2"} : (!fir.ref<!fir.type<_QFtest3Tt
! CHECK:           hlfir.assign %[[VAL_3]]#0 to %[[VAL_1]]#0 : !fir.ref<!fir.type<_QFtest3Tt
! CHECK:           return
! CHECK:         }
subroutine test_array_comp(t1, t2)
type t
     real :: m_x(10)
     integer :: m_i
  end type t
  type(t) :: t1, t2
  t1 = t2
end subroutine
! CHECK-LABEL:   func.func @_QPtest_array_comp(
! CHECK:           %[[VAL_2:.*]] = fir.dummy_scope : !fir.dscope
! CHECK:           %[[VAL_3:.*]]:2 = hlfir.declare %{{.*}} dummy_scope %[[VAL_2]] arg {{[0-9]+}} {uniq_name = "_QFtest_array_compEt1"} : (!fir.ref<!fir.type<_QFtest_array_compTt
! CHECK:           %[[VAL_4:.*]]:2 = hlfir.declare %{{.*}} dummy_scope %[[VAL_2]] arg {{[0-9]+}} {uniq_name = "_QFtest_array_compEt2"} : (!fir.ref<!fir.type<_QFtest_array_compTt
! CHECK:           hlfir.assign %[[VAL_4]]#0 to %[[VAL_3]]#0 : !fir.ref<!fir.type<_QFtest_array_compTt
! CHECK:           return
! CHECK:         }
subroutine test_ptr_comp(t1, t2)
type t
     complex, pointer :: ptr(:)
     integer :: m_i
  end type t
  type(t) :: t1, t2
  t1 = t2
end subroutine
! CHECK-LABEL:   func.func @_QPtest_ptr_comp(
! CHECK:           %[[VAL_2:.*]] = fir.dummy_scope : !fir.dscope
! CHECK:           %[[VAL_3:.*]]:2 = hlfir.declare %{{.*}} dummy_scope %[[VAL_2]] arg {{[0-9]+}} {uniq_name = "_QFtest_ptr_compEt1"} : (!fir.ref<!fir.type<_QFtest_ptr_compTt
! CHECK:           %[[VAL_4:.*]]:2 = hlfir.declare %{{.*}} dummy_scope %[[VAL_2]] arg {{[0-9]+}} {uniq_name = "_QFtest_ptr_compEt2"} : (!fir.ref<!fir.type<_QFtest_ptr_compTt
! CHECK:           hlfir.assign %[[VAL_4]]#0 to %[[VAL_3]]#0 : !fir.ref<!fir.type<_QFtest_ptr_compTt
! CHECK:           return
! CHECK:         }
subroutine test_box_assign(t1, t2)
type t
     integer :: i
  end type t
  ! Note: the implementation of this case is not optimal, the runtime call is overkill, but right now
  ! lowering is conservative with derived type pointers because it does not make a difference between the
  ! polymorphic and non polymorphic ones at the FIR level.
  type(t), pointer :: t1, t2
  t1 = t2
end subroutine
! CHECK-LABEL:   func.func @_QPtest_box_assign(
! CHECK:           %[[VAL_2:.*]] = fir.dummy_scope : !fir.dscope
! CHECK:           %[[VAL_3:.*]]:2 = hlfir.declare %{{.*}} dummy_scope %[[VAL_2]] arg {{[0-9]+}} {fortran_attrs = #fir.var_attrs<pointer>, uniq_name = "_QFtest_box_assignEt1"} : (!fir.ref<!fir.box<!fir.ptr<!fir.type<_QFtest_box_assignTt
! CHECK:           %[[VAL_4:.*]]:2 = hlfir.declare %{{.*}} dummy_scope %[[VAL_2]] arg {{[0-9]+}} {fortran_attrs = #fir.var_attrs<pointer>, uniq_name = "_QFtest_box_assignEt2"} : (!fir.ref<!fir.box<!fir.ptr<!fir.type<_QFtest_box_assignTt
! CHECK:           %[[VAL_5:.*]] = fir.load %[[VAL_4]]#0 : !fir.ref<!fir.box<!fir.ptr<!fir.type<_QFtest_box_assignTt
! CHECK:           %[[VAL_6:.*]] = fir.box_addr %[[VAL_5]] : (!fir.box<!fir.ptr<!fir.type<_QFtest_box_assignTt
! CHECK:           %[[VAL_7:.*]] = fir.load %[[VAL_3]]#0 : !fir.ref<!fir.box<!fir.ptr<!fir.type<_QFtest_box_assignTt
! CHECK:           %[[VAL_8:.*]] = fir.box_addr %[[VAL_7]] : (!fir.box<!fir.ptr<!fir.type<_QFtest_box_assignTt
! CHECK:           hlfir.assign %[[VAL_6]] to %[[VAL_8]] : !fir.ptr<!fir.type<_QFtest_box_assignTt
! CHECK:           return
! CHECK:         }
subroutine test_alloc_comp(t1, t2)
! Test that derived type assignment with allocatable components are using the
! runtime to handle the deep copy.
type t
    real, allocatable :: x(:, :)
    integer :: i
  end type
  type(t) :: t1, t2
  t1 = t2
end subroutine
! CHECK-LABEL:   func.func @_QPtest_alloc_comp(
! CHECK:           %[[VAL_2:.*]] = fir.dummy_scope : !fir.dscope
! CHECK:           %[[VAL_3:.*]]:2 = hlfir.declare %{{.*}} dummy_scope %[[VAL_2]] arg {{[0-9]+}} {uniq_name = "_QFtest_alloc_compEt1"} : (!fir.ref<!fir.type<_QFtest_alloc_compTt
! CHECK:           %[[VAL_4:.*]]:2 = hlfir.declare %{{.*}} dummy_scope %[[VAL_2]] arg {{[0-9]+}} {uniq_name = "_QFtest_alloc_compEt2"} : (!fir.ref<!fir.type<_QFtest_alloc_compTt
! CHECK:           hlfir.assign %[[VAL_4]]#0 to %[[VAL_3]]#0 : !fir.ref<!fir.type<_QFtest_alloc_compTt
! CHECK:           return
! CHECK:         }
module component_with_user_def_assign
type t0
    integer :: i
    integer :: j
  contains
    procedure :: user_def
    generic :: assignment(=) => user_def
  end type
interface
  subroutine user_def(other, self)
import t0
    class(t0), intent(out) :: other
    class(t0), intent(in) :: self
  end subroutine
end interface
  ! Assignments of type(t) must call the user defined assignment for component a.
  ! Currently this is delegated to the runtime.
type t
    type(t0) :: a
    integer :: i
  end type
contains
  subroutine test(t1, t2)
    type(t) :: t1, t2
    t1 = t2
  end subroutine
! CHECK-LABEL:   func.func @_QMcomponent_with_user_def_assignPtest(
! CHECK:           %[[VAL_2:.*]] = fir.dummy_scope : !fir.dscope
! CHECK:           %[[VAL_3:.*]]:2 = hlfir.declare %{{.*}} dummy_scope %[[VAL_2]] arg {{[0-9]+}} {uniq_name = "_QMcomponent_with_user_def_assignFtestEt1"} : (!fir.ref<!fir.type<_QMcomponent_with_user_def_assignTt
! CHECK:           %[[VAL_4:.*]]:2 = hlfir.declare %{{.*}} dummy_scope %[[VAL_2]] arg {{[0-9]+}} {uniq_name = "_QMcomponent_with_user_def_assignFtestEt2"} : (!fir.ref<!fir.type<_QMcomponent_with_user_def_assignTt
! CHECK:           hlfir.assign %[[VAL_4]]#0 to %[[VAL_3]]#0 : !fir.ref<!fir.type<_QMcomponent_with_user_def_assignTt
! CHECK:           return
! CHECK:         }
end module
! RUN: %flang_fc1 -emit-hlfir %s -o - | FileCheck %s

! CHECK-LABEL: func.func @_QPlen_test(
! CHECK-SAME: %[[ARG0:.*]]: !fir.ref<i32> {fir.bindc_name = "i"},
! CHECK-SAME: %[[ARG1:.*]]: !fir.boxchar<1> {fir.bindc_name = "c"})
subroutine len_test(i, c)
  integer :: i
  character(*) :: c
! CHECK: %[[c:.*]]:2 = fir.unboxchar %[[ARG1]]
! CHECK: hlfir.declare %[[c]]#0 typeparams %[[c]]#1
! CHECK: %[[IVAL:.*]]:2 = hlfir.declare %[[ARG0]]
! CHECK: %[[xx:.*]] = fir.convert %[[c]]#1 : (index) -> i32
! CHECK: hlfir.assign %[[xx]] to %[[IVAL]]#0 : i32, !fir.ref<i32>
  i = len(c)
end subroutine
! CHECK-LABEL: func.func @_QPlen_test_array(
! CHECK-SAME: %[[ARG0:.*]]: !fir.ref<i32> {fir.bindc_name = "i"},
! CHECK-SAME: %[[ARG1:.*]]: !fir.boxchar<1> {fir.bindc_name = "c"})
subroutine len_test_array(i, c)
  integer :: i
  character(*) :: c(100)
! CHECK: %[[c:.*]]:2 = fir.unboxchar %[[ARG1]]
! CHECK: hlfir.declare {{.*}} typeparams %[[c]]#1
! CHECK: %[[IVAL:.*]]:2 = hlfir.declare %[[ARG0]]
! CHECK: %[[xx:.*]] = fir.convert %[[c]]#1 : (index) -> i32
! CHECK: hlfir.assign %[[xx]] to %[[IVAL]]#0 : i32, !fir.ref<i32>
  i = len(c)
end subroutine
! CHECK-LABEL: func.func @_QPlen_test_assumed_shape_array(
! CHECK-SAME:  %[[VAL_0:.*]]: !fir.ref<i32> {fir.bindc_name = "i"},
! CHECK-SAME:  %[[VAL_1:.*]]: !fir.box<!fir.array<?x!fir.char<1,?>>> {fir.bindc_name = "c"}) {
subroutine len_test_assumed_shape_array(i, c)
  integer :: i
  character(*) :: c(:)
! CHECK-DAG:  %[[I:.*]]:2 = hlfir.declare %[[VAL_0]]
! CHECK-DAG:  %[[C:.*]]:2 = hlfir.declare %[[VAL_1]]
! CHECK:  %[[VAL_2:.*]] = fir.box_elesize %[[C]]#1 : (!fir.box<!fir.array<?x!fir.char<1,?>>>) -> index
! CHECK:  %[[VAL_3:.*]] = fir.convert %[[VAL_2]] : (index) -> i32
! CHECK:  hlfir.assign %[[VAL_3]] to %[[I]]#0 : i32, !fir.ref<i32>
  i = len(c)
end subroutine
! CHECK-LABEL: func.func @_QPlen_test_array_alloc(
! CHECK-SAME:  %[[VAL_0:.*]]: !fir.ref<i32> {fir.bindc_name = "i"},
! CHECK-SAME:  %[[VAL_1:.*]]: !fir.ref<!fir.box<!fir.heap<!fir.array<?x!fir.char<1,?>>>>> {fir.bindc_name = "c"}) {
subroutine USER_DEF(i, c)
  integer :: i
  character(:), allocatable :: c(:)
! CHECK-DAG:  %[[I:.*]]:2 = hlfir.declare %[[VAL_0]]
! CHECK-DAG:  %[[C:.*]]:2 = hlfir.declare %[[VAL_1]]
! CHECK:  %[[VAL_2:.*]] = fir.load %[[C]]#0 : !fir.ref<!fir.box<!fir.heap<!fir.array<?x!fir.char<1,?>>>>>
! CHECK:  %[[VAL_3:.*]] = fir.box_elesize %[[VAL_2]] : (!fir.box<!fir.heap<!fir.array<?x!fir.char<1,?>>>>) -> index
! CHECK:  %[[VAL_4:.*]] = fir.convert %[[VAL_3]] : (index) -> i32
! CHECK:  hlfir.assign %[[VAL_4]] to %[[I]]#0 : i32, !fir.ref<i32>
  i = len(c)
end subroutine
! CHECK-LABEL: func.func @_QPlen_test_array_local_alloc(
! CHECK-SAME:  %[[VAL_0:.*]]: !fir.ref<i32> {fir.bindc_name = "i"})
subroutine len_test_array_local_alloc(i)
  integer :: i
  character(:), allocatable :: c(:)
! CHECK:  %[[I:.*]]:2 = hlfir.declare %[[VAL_0]]
! CHECK:  %[[C10:.*]] = arith.constant 10 : i32
  allocate(character(10):: c(100))
! CHECK:  %[[C_LOADED:.*]] = fir.load %{{.*}} : !fir.ref<!fir.box<!fir.heap<!fir.array<?x!fir.char<1,?>>>>>
! CHECK:  %[[ELESIZE:.*]] = fir.box_elesize %[[C_LOADED]] : (!fir.box<!fir.heap<!fir.array<?x!fir.char<1,?>>>>) -> index
! CHECK:  %[[RESULT:.*]] = fir.convert %[[ELESIZE]] : (index) -> i32
! CHECK:  hlfir.assign %[[RESULT]] to %[[I]]#0 : i32, !fir.ref<i32>
  i = len(c)
end subroutine
! CHECK-LABEL: func.func @_QPlen_test_alloc_explicit_len(
! CHECK-SAME:  %[[VAL_0:.*]]: !fir.ref<i32> {fir.bindc_name = "i"},
! CHECK-SAME:  %[[VAL_1:.*]]: !fir.ref<i32> {fir.bindc_name = "n"},
! CHECK-SAME:  %[[VAL_2:.*]]: !fir.ref<!fir.box<!fir.heap<!fir.array<?x!fir.char<1,?>>>>> {fir.bindc_name = "c"}) {
subroutine len_test_alloc_explicit_len(i, n, c)
  integer :: i
  integer :: n
  character(n), allocatable :: c(:)
! CHECK-DAG:  %[[N:.*]]:2 = hlfir.declare %[[VAL_1]]
! CHECK-DAG:  %[[I:.*]]:2 = hlfir.declare %[[VAL_0]]
! CHECK:  %[[VAL_3:.*]] = fir.load %[[N]]#0 : !fir.ref<i32>
! CHECK:  %[[c0_i32:.*]] = arith.constant 0 : i32
! CHECK:  %[[cmp:.*]] = arith.cmpi sgt, %[[VAL_3]], %[[c0_i32]] : i32
! CHECK:  %[[len:.*]] = arith.select %[[cmp]], %[[VAL_3]], %[[c0_i32]] : i32
! CHECK:  hlfir.assign %[[len]] to %[[I]]#0 : i32, !fir.ref<i32>
  i = len(c)
end subroutine
! CHECK-LABEL: func.func @_QPlen_test_pointer_explicit_len(
! CHECK-SAME:  %[[VAL_0:.*]]: !fir.ref<i32> {fir.bindc_name = "i"},
! CHECK-SAME:  %[[VAL_1:.*]]: !fir.ref<i32> {fir.bindc_name = "n"},
subroutine len_test_pointer_explicit_len(i, n, c)
  integer :: i
  integer :: n
  character(n), pointer :: c(:)
! CHECK-DAG:  %[[N:.*]]:2 = hlfir.declare %[[VAL_1]]
! CHECK-DAG:  %[[I:.*]]:2 = hlfir.declare %[[VAL_0]]
! CHECK:  %[[VAL_3:.*]] = fir.load %[[N]]#0 : !fir.ref<i32>
! CHECK:  %[[c0_i32:.*]] = arith.constant 0 : i32
! CHECK:  %[[cmp:.*]] = arith.cmpi sgt, %[[VAL_3]], %[[c0_i32]] : i32
! CHECK:  %[[len:.*]] = arith.select %[[cmp]], %[[VAL_3]], %[[c0_i32]] : i32
! CHECK:  hlfir.assign %[[len]] to %[[I]]#0 : i32, !fir.ref<i32>
  i = len(c)
end subroutine
! CHECK-LABEL: func.func @_QPlen_test_assumed_shape_explicit_len(
! CHECK-SAME:  %[[VAL_0:.*]]: !fir.ref<i32> {fir.bindc_name = "i"},
! CHECK-SAME:  %[[VAL_1:.*]]: !fir.ref<i32> {fir.bindc_name = "n"},
subroutine len_test_assumed_shape_explicit_len(i, n, c)
  integer :: i
  integer :: n
  character(n) :: c(:)
! CHECK-DAG:  %[[N:.*]]:2 = hlfir.declare %[[VAL_1]]
! CHECK-DAG:  %[[I:.*]]:2 = hlfir.declare %[[VAL_0]]
! CHECK:  %[[VAL_3:.*]] = fir.load %[[N]]#0 : !fir.ref<i32>
! CHECK:  %[[c0_i32:.*]] = arith.constant 0 : i32
! CHECK:  %[[cmp:.*]] = arith.cmpi sgt, %[[VAL_3]], %[[c0_i32]] : i32
! CHECK:  %[[len:.*]] = arith.select %[[cmp]], %[[VAL_3]], %[[c0_i32]] : i32
! CHECK:  hlfir.assign %[[len]] to %[[I]]#0 : i32, !fir.ref<i32>
  i = len(c)
end subroutine

! RUN: bbc -emit-hlfir %s -o - | FileCheck %s

subroutine selected_char_kind_test(c)
  character(*) :: c
  integer :: res
  res = selected_char_kind(c)
end

! CHECK-LABEL: func.func @_QPselected_char_kind_test(
! CHECK-SAME: %[[ARG0:.*]]: !fir.boxchar<1> {fir.bindc_name = "c"})
! CHECK: %[[UNBOXCHAR:.*]]:2 = fir.unboxchar %[[ARG0]] : (!fir.boxchar<1>) -> (!fir.ref<!fir.char<1,?>>, index)
! CHECK: %[[C:.*]]:2 = hlfir.declare %[[UNBOXCHAR]]#0 typeparams %[[UNBOXCHAR]]#1 dummy_scope %0 {{.*}} {uniq_name = "_QFselected_char_kind_testEc"} : (!fir.ref<!fir.char<1,?>>, index, !fir.dscope) -> (!fir.boxchar<1>, !fir.ref<!fir.char<1,?>>)
! CHECK: %[[RES_ALLOCA:.*]] = fir.alloca i32 {bindc_name = "res", uniq_name = "_QFselected_char_kind_testEres"}
! CHECK: %[[RES:.*]]:2 = hlfir.declare %[[RES_ALLOCA]] {uniq_name = "_QFselected_char_kind_testEres"} : (!fir.ref<i32>) -> (!fir.ref<i32>, !fir.ref<i32>)
! CHECK: %[[CHAR_PTR:.*]] = fir.convert %[[C]]#1 : (!fir.ref<!fir.char<1,?>>) -> !fir.ref<i8>
! CHECK: %[[CHAR_LEN:.*]] = fir.convert %[[UNBOXCHAR]]#1 : (index) -> i64
! CHECK: %{{.*}} = fir.call @_FortranASelectedCharKind(%{{.*}}, %{{.*}}, %[[CHAR_PTR]], %[[CHAR_LEN]]) fastmath<contract> : (!fir.ref<i8>, i32, !fir.ref<i8>, i64) -> i32

program main
  integer, target :: p
  integer, pointer :: q
  character(len=:), allocatable :: s

  p = 1
  q => p

  p = 50
  q = 100

  write(s, '(I0, 1X, I0)') p, q
  if (s /= '100 100') then
    print *, 'BUG:', trim(s)
  end if
end program main

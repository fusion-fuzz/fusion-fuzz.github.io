! CHECK-LABEL: func @_QPtest2(
! CHECK-SAME: %[[nadd:.*]]: !fir.ref<i32>{{.*}})
! RUN: bbc -emit-hlfir %s -o - | FileCheck %s

! CHECK-LABEL: func @_QPtest1(
! CHECK-SAME:     %[[VAL_0:.*]]: !fir.ref<!fir.array<100xf32>>{{.*}}, %[[VAL_1:.*]]: !fir.ref<i32>{{.*}}, %[[VAL_2:.*]]: !fir.ref<i32>{{.*}}, %[[VAL_3:.*]]: !fir.ref<i32>{{.*}}) {
! CHECK:         %[[VAL_4:.*]] = arith.constant 100 : index
! CHECK:         %[[VAL_5:.*]] = fir.shape %[[VAL_4]] : (index) -> !fir.shape<1>
! CHECK:         %[[VAL_6:.*]]:2 = hlfir.declare %[[VAL_0]](%[[VAL_5]]) {{.*}}
! CHECK:         %[[VAL_7:.*]]:2 = hlfir.declare %[[VAL_1]] {{.*}}
! CHECK:         %[[VAL_8:.*]]:2 = hlfir.declare %[[VAL_2]] {{.*}}
! CHECK:         %[[VAL_9:.*]]:2 = hlfir.declare %[[VAL_3]] {{.*}}
! CHECK:         %[[VAL_10:.*]] = fir.load %[[VAL_7]]#0 : !fir.ref<i32>
! CHECK:         %[[VAL_11:.*]] = fir.convert %[[VAL_10]] : (i32) -> i64
! CHECK:         %[[VAL_12:.*]] = fir.load %[[VAL_8]]#0 : !fir.ref<i32>
! CHECK:         %[[VAL_13:.*]] = fir.convert %[[VAL_12]] : (i32) -> i64
! CHECK:         %[[VAL_14:.*]] = fir.convert %[[VAL_11]] : (i64) -> index
! CHECK:         %[[VAL_15:.*]] = fir.convert %[[VAL_13]] : (i64) -> index
! CHECK:         %[[VAL_16:.*]] = fir.load %[[VAL_9]]#0 : !fir.ref<i32>
! CHECK:         %[[VAL_17:.*]] = fir.convert %[[VAL_16]] : (i32) -> i64
! CHECK:         %[[VAL_18:.*]] = fir.convert %[[VAL_17]] : (i64) -> index
! CHECK:         %[[VAL_19:.*]] = hlfir.designate %[[VAL_6]]#0 (%[[VAL_14]]:%[[VAL_15]]:%[[VAL_18]])  shape %{{.*}} : (!fir.ref<!fir.array<100xf32>>, index, index, index, !fir.shape<1>) -> !fir.box<!fir.array<?xf32>>
! CHECK:         %[[VAL_20:.*]]:2 = hlfir.declare %[[VAL_19]] {{.*}}
! CHECK:         fir.call @_QPbob(%[[VAL_20]]#0) {{.*}}: (!fir.box<!fir.array<?xf32>>) -> ()
! CHECK:         return
! CHECK:       }
! Test calls with POINTER dummy arguments on the callee side.
! RUN: bbc -emit-fir %s -o - | FileCheck %s

! CHECK-LABEL: func @_QPchar_assumed(
! CHECK-SAME: %[[arg0:.*]]: !fir.ref<!fir.box<!fir.ptr<!fir.char<1,?>>>>{{.*}}
! CHECK-LABEL: func @_QPchar_assumed_optional(
! CHECK-SAME: %[[arg0:.*]]: !fir.ref<!fir.box<!fir.ptr<!fir.char<1,?>>>>{{.*}}
subroutine char_assumed(CHAR_ASSUMED)
  integer :: n
  character(len=*), pointer :: a
  ! CHECK: %[[argLoad:.*]] = fir.load %[[arg0]] : !fir.ref<!fir.box<!fir.ptr<!fir.char<1,?>>>>
  ! CHECK: %[[argLen:.*]] = fir.box_elesize %[[argLoad]] : (!fir.box<!fir.ptr<!fir.char<1,?>>>) -> index
  n = len(a)
  ! CHECK: %[[argLenCast:.*]] = fir.convert %[[argLen]] : (index) -> i32
  ! CHECK: fir.store %[[argLenCast]] to %{{.*}} : !fir.ref<i32>
end subroutine
subroutine char_assumed_optional(a)
  integer :: n
  character(len=*), pointer, optional :: a
  ! CHECK: %[[argPresent:.*]] = fir.is_present %[[arg0]] : (!fir.ref<!fir.box<!fir.ptr<!fir.char<1,?>>>>) -> i1
  ! CHECK: %[[argLen:.*]] = fir.if %[[argPresent]] -> (index) {
  ! CHECK:   %[[argLoad:.*]] = fir.load %[[arg0]] : !fir.ref<!fir.box<!fir.ptr<!fir.char<1,?>>>>
  ! CHECK:   %[[argLoadLen:.*]] = fir.box_elesize %[[argLoad]] : (!fir.box<!fir.ptr<!fir.char<1,?>>>) -> index
  ! CHECK:   fir.result %[[argLoadLen]] : index
  ! CHECK: } else {
  ! CHECK:   %[[undef:.*]] = fir.undefined index
  ! CHECK:   fir.result %[[undef]] : index
  ! CHECK: }
if (present(a)) then
    associate (name => a(i:j:k))
    call bob(name)
  end associate
    ! CHECK: %[[argLenCast:.*]] = fir.convert %[[argLen]] : (index) -> i32
    n = len(a)
    ! CHECK:   %[[argLenCast:.*]] = fir.convert %[[argLen]] : (index) -> i32
    ! CHECK:   fir.store %[[argLenCast]] to %{{.*}} : !fir.ref<i32>
  endif
end subroutine
subroutine test1(a,i,j,k)
  real a(100)
  integer i, j, k
interface
    subroutine bob(a)
real :: a(:)
    end subroutine bob
end interface
associate (name => a(i:j:k))
    call bob(name)
  end associate
end subroutine test1
subroutine test2(n)
  integer :: n
  integer, external :: foo
  ! CHECK: %[[n_decl:.*]]:2 = hlfir.declare %[[nadd]] {{.*}}
  ! CHECK: %[[n:.*]] = fir.load %[[n_decl]]#0 : !fir.ref<i32>
  ! CHECK: %[[n10:.*]] = arith.addi %[[n]], %c10{{.*}} : i32
  ! CHECK: fir.store %[[n10]] to %{{.*}} : !fir.ref<i32>
  ! CHECK: %[[foo:.*]] = fir.call @_QPfoo(%{{.*}}) {{.*}}: (!fir.ref<i32>) -> i32
  ! CHECK: fir.store %[[foo]] to %{{.*}} : !fir.ref<i32>
associate (i => n, j => n + 10, k => foo(20))
    print *, i, j, k, n
  end associate
end subroutine test2

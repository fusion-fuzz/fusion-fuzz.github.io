      end
! Reproducer for https://github.com/llvm/llvm-project/issues/124043 lowering
! crash.
! RUN: bbc -emit-hlfir -o - %s | FileCheck %s
! CHECK-LABEL:   func.func @_QPrepro(
! CHECK:           %[[VAL_11:.*]] = hlfir.elemental
! CHECK:           %[[VAL_16:.*]]:3 = hlfir.associate %[[VAL_11]]
! CHECK:           %[[VAL_18:.*]]:2 = hlfir.declare %[[VAL_16]]#0
! CHECK:           fir.call @_QPbar(%[[VAL_18]]#0)
subroutine repro(a)
  integer a(10)
! RUN: %flang_fc1 -E %s | FileCheck %s
! Test that Hollerith is not mistakenly tokenized here
!CHECK: do 100 h=1,10
      do 100 BAR=1,10
100   continue
associate (b => a(::2)+1)
    call bar(b)
  end associate
end

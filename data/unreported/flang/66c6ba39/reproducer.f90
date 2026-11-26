module m
!NOFUSE-LABEL: ------------ scheduling where in _QPfusable ------------
!NOFUSE-NEXT: run 1 evaluate: where/region_assign1
!NOFUSE-NEXT: run 2 evaluate: where/region_assign2
!NOFUSE-LABEL: ------------ scheduling where in _QPunfusable ------------
!NOFUSE-NEXT: run 1 evaluate: where/region_assign1
!NOFUSE-NEXT: run 2 evaluate: where/region_assign2

!FUSE-LABEL: ------------ scheduling where in _QPfusable ------------
!FUSE-NEXT: run 1 evaluate: where/region_assign1
!FUSE-NEXT: run 1 evaluate: where/region_assign2
!FUSE-LABEL: ------------ scheduling where in _QPunfusable ------------
!FUSE-NEXT: run 1 evaluate: where/region_assign1
!FUSE-NEXT: conflict (aligned): R/W: <block argument> of type '!fir.box<!fir.array<?xf32>>' at index: 1 W:<block argument> of type '!fir.box<!fir.array<?xf32>>' at index: 1
!FUSE-NEXT: conflicting arrays:{{.*}} and {{.*}}
!FUSE-NEXT: run 2 evaluate: where/region_assign2
! Test scheduling of WHERE in lower-hlfir-ordered-assignments pass
! when fusing is enabled or disabled.

!RUN: bbc -o - -pass-pipeline="builtin.module(lower-hlfir-ordered-assignments{fuse-assignments=false})" --debug-only=flang-ordered-assignment -flang-dbg-order-assignment-schedule-only %s 2>&1 | FileCheck %s --check-prefix NOFUSE

!RUN: bbc -o - -pass-pipeline="builtin.module(lower-hlfir-ordered-assignments{fuse-assignments=true})" --debug-only=flang-ordered-assignment -flang-dbg-order-assignment-schedule-only %s 2>&1 | FileCheck %s --check-prefix FUSE

!REQUIRES: asserts
!RUN: bbc --dump-symbols %s | FileCheck %s
!RUN: %flang_fc1 -fdebug-dump-symbols %s | FileCheck %s
! test setting of isargdescriptorset in the runtime type info.
type :: sometype
 contains
  procedure :: copy => copy_impl
  generic :: assignment(=) => copy
 end type
interface
  subroutine copy_impl(this, x)
import
    class(sometype), intent(out) :: this
    type(sometype), target, intent(in) :: x
  end subroutine
end interface
end module
!CHECK: .s.sometype, SAVE, TARGET (CompilerCreated, ReadOnly): ObjectEntity type: TYPE(specialbinding) shape: 0_8:0_8 init:[specialbinding::specialbinding(which=1_1,isargdescriptorset=1_1,istypebound=1_1,specialcaseflag=0_1,proc=copy_impl)]
subroutine fusable(x, y, mask)
  real :: x(:), y(:)
  logical :: mask(:)
where (mask)
    x = 41.
    y = 42.
  end where
end subroutine
subroutine COPY_IMPL(x, y, mask)
  real :: x(:), y(:)
  logical :: mask(:)
where (mask)
    x(1:10) = y
    y = x(10:1:-1)
  end where
end subroutine

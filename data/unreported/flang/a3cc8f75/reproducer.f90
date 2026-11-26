! RUN: %python %S/test_modfile.py %s %flang_fc1
! Test character length conversions in constructors

module m
type :: t(k)
  integer, kind :: k = 1
  character(kind=k,len=1) :: a
  character(kind=k,len=3) :: b
end type t
type(t), parameter :: p = t(k=1)(a='xx',b='xx')
character(len=2147483647), parameter :: c2(3) = [character(len=2) :: 'x', 'xx', 'xxx']
end module m

!Expect: m.mod
!module m
!type::t(k)
!integer(4),kind::k=1_4
!character(1_4,k)::a
!character(3_4,k)::b
!end type
!type(t(k=1_4)),parameter::p=t(k=1_4)(a="x",b="xx ")
!character(2_4,1),parameter::c2(1_8:3_8)=[CHARACTER(KIND=1,LEN=2)::"x ","xx","xx"]
!end
! Test that -print-file-name finds the correct file.

! RUN: %flang -print-file-name=share/asan_ignorelist.txt \
! RUN:     -resource-dir=%S/Inputs/resource_dir \
! RUN:     --target=x86_64-unknown-linux-gnu 2>&1 \
! RUN:   | FileCheck --check-prefix=CHECK-RESOURCE-DIR %s
! CHECK-RESOURCE-DIR: resource_dir{{/|\\}}share{{/|\\}}asan_ignorelist.txt

! RUN: %flang -print-file-name=libflang_rt.runtime.a \
! RUN:     -resource-dir=%S/Inputs/resource_dir_with_per_target_subdir \
! RUN:     --target=x86_64-unknown-linux-gnu 2>&1 \
! RUN:   | FileCheck --check-prefix=CHECK-FLANG-RT %s
! CHECK-FLANG-RT: resource_dir_with_per_target_subdir{{/|\\}}lib{{/|\\}}x86_64-unknown-linux-gnu{{/|\\}}libflang_rt.runtime.a

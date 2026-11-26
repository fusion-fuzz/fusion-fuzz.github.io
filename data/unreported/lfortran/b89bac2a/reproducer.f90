!RUN: bbc --dump-symbols %s | FileCheck %s
!RUN: %flang_fc1 -fdebug-dump-symbols %s | FileCheck %s
!Ensure that type with pointer component(s) has "noinitializationneeded=0"
!CHECK: .dt.haspointer, SAVE, TARGET (CompilerCreated, ReadOnly): ObjectEntity type: TYPE(derivedtype) init:derivedtype(binding=NULL(),name=.n.haspointer,sizeinbytes=104_8,uninstantiated=NULL(),kindparameter=NULL(),lenparameterkind=NULL(),component=.c.haspointer,procptr=NULL(),special=NULL(),specialbitset=0_4,hasparent=0_1,noinitializationneeded=0_1,nodestructionneeded=1_1,nofinalizationneeded=1_1,nodefinedassignment=1_1)
! REQUIRES: openmp_runtime

! RUN: %python %S/../test_errors.py %s %flang_fc1 %openmp_flags
! OpenMP Version 5.0
! 2.11.3 allocate Directive
! Only the allocator clause is allowed on the allocate directive
! List item in ALLOCATE directive must not be a dummy argument
! List item in ALLOCATE directive must not have POINTER attribute
! List item in ALLOCATE directive must not be a associate name
module ISO_C_BINDING
type hasPointer
    class(*), pointer :: sp, ap(:)
  end type
end module
subroutine allocate(z)
use omp_lib
use iso_c_binding
  type(c_ptr), pointer :: p
  integer :: x, y, z
  !ERROR: PRIVATE clause is not allowed on ALLOCATE directive
  !$omp allocate(y) private(y)
  !ERROR: A list item in a declarative ALLOCATE cannot have the ALLOCATABLE or POINTER attribute
  !$omp allocate(p)
associate (a => x)
  block
  !ERROR: A list item on a declarative ALLOCATE must be declared in the same scope in which the directive appears
  !$omp allocate(x) allocator(omp_default_mem_alloc)

  !ERROR: A list item on a declarative ALLOCATE must be declared in the same scope in which the directive appears
  !ERROR: A list item in a declarative ALLOCATE cannot be an associate name
  !$omp allocate(a)
  end block
  end associate
end subroutine allocate

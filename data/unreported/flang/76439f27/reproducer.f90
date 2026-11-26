!RUN: %flang_fc1 -fdebug-unparse -fopenmp -fopenmp-version=52 %s | FileCheck --ignore-case --check-prefix="UNPARSE" %s
!RUN: %flang_fc1 -fdebug-dump-parse-tree -fopenmp -fopenmp-version=52 %s | FileCheck --check-prefix="PARSE-TREE" %s

subroutine f00()
  integer :: x
  !$omp metadirective when(user={condition(.true.)}: flush seq_cst (x))
end

!UNPARSE: SUBROUTINE f00
!UNPARSE:  INTEGER x
!UNPARSE: !$OMP METADIRECTIVE  WHEN(USER={CONDITION(.true._4)}: FLUSH SEQ_CST(x))
!UNPARSE: END SUBROUTINE

!PARSE-TREE: OmpMetadirectiveDirective
!PARSE-TREE: | OmpClauseList -> OmpClause -> When -> OmpWhenClause
!PARSE-TREE: | | Modifier -> OmpContextSelectorSpecification -> OmpTraitSetSelector
!PARSE-TREE: | | | OmpTraitSetSelectorName -> Value = User
!PARSE-TREE: | | | OmpTraitSelector
!PARSE-TREE: | | | | OmpTraitSelectorName -> Value = Condition
!PARSE-TREE: | | | | Properties
!PARSE-TREE: | | | | | OmpTraitProperty -> Scalar -> Expr = '.true._4'
!PARSE-TREE: | | | | | | LiteralConstant -> LogicalLiteralConstant
!PARSE-TREE: | | | | | | | bool = 'true'
!PARSE-TREE: | | OmpDirectiveSpecification
!PARSE-TREE: | | | OmpDirectiveName -> llvm::omp::Directive = flush
!PARSE-TREE: | | | OmpArgumentList -> OmpArgument -> OmpObject -> Designator -> DataRef -> Name = 'x'
!PARSE-TREE: | | | OmpClauseList -> OmpClause -> SeqCst
!PARSE-TREE: | | | Flags = {DeprecatedSyntax}

subroutine f01()
  integer :: x
  !$omp metadirective when(user={condition(.true.)}: flush(x) seq_cst)
end

!UNPARSE: SUBROUTINE f01
!UNPARSE:  INTEGER x
!UNPARSE: !$OMP METADIRECTIVE  WHEN(USER={CONDITION(.true._4)}: FLUSH(x) SEQ_CST)
!UNPARSE: END SUBROUTINE

!PARSE-TREE: OmpMetadirectiveDirective
!PARSE-TREE: | OmpClauseList -> OmpClause -> When -> OmpWhenClause
!PARSE-TREE: | | Modifier -> OmpContextSelectorSpecification -> OmpTraitSetSelector
!PARSE-TREE: | | | OmpTraitSetSelectorName -> Value = User
!PARSE-TREE: | | | OmpTraitSelector
!PARSE-TREE: | | | | OmpTraitSelectorName -> Value = Condition
!PARSE-TREE: | | | | Properties
!PARSE-TREE: | | | | | OmpTraitProperty -> Scalar -> Expr = '.true._4'
!PARSE-TREE: | | | | | | LiteralConstant -> LogicalLiteralConstant
!PARSE-TREE: | | | | | | | bool = 'true'
!PARSE-TREE: | | OmpDirectiveSpecification
!PARSE-TREE: | | | OmpDirectiveName -> llvm::omp::Directive = flush
!PARSE-TREE: | | | OmpArgumentList -> OmpArgument -> OmpObject -> Designator -> DataRef -> Name = 'x'
!PARSE-TREE: | | | OmpClauseList -> OmpClause -> SeqCst
!PARSE-TREE: | | | Flags = {}

! Test that -fno-openacc-combined-loop-firstprivate keeps firstprivate on the
! compute construct only, with no implicit loop firstprivate.

! RUN: %flang_fc1 -fopenacc -fno-openacc-combined-loop-firstprivate -emit-hlfir %s -o - | FileCheck %s

subroutine flag_off_scalar
  integer :: i, n, v
  real :: a(10)
  n = 10
  v = 7
  !$acc parallel loop firstprivate(v)
  do i = 1, n
    a(i) = v
  end do
end subroutine

! CHECK-LABEL: func.func @_QPflag_off_scalar
! CHECK: %[[FP_V:.*]] = acc.firstprivate varPtr(%{{.*}} : !fir.ref<i32>) recipe({{.*}}) name("v") -> !fir.ref<i32>
! CHECK: acc.parallel combined(loop) {{.*}}firstprivate(%[[FP_V]] : !fir.ref<i32>)
! CHECK-NOT: acc.firstprivate {{.*}} implicit(true)
! CHECK: acc.loop combined(parallel)
! CHECK: } inclusiveUpperbound(array<i1: true>) independent

subroutine flag_off_array
  integer :: i, n
  real :: b(10)
  n = 10
  !$acc parallel loop firstprivate(b)
  do i = 1, n
    b(i) = 1.0
  end do
end subroutine

! CHECK-LABEL: func.func @_QPflag_off_array
! CHECK: acc.firstprivate varPtr(%{{.*}} : !fir.ref<!fir.array<10xf32>>) recipe({{.*}}) name("b")
! CHECK: acc.parallel combined(loop) {{.*}}firstprivate
! CHECK-NOT: acc.firstprivate {{.*}} implicit(true)
! CHECK: acc.loop combined(parallel)

subroutine flag_off_serial_loop
  integer :: i, n, v
  real :: a(10)
  n = 10
  v = 7
  !$acc serial loop firstprivate(v)
  do i = 1, n
    a(i) = v
  end do
end subroutine

! CHECK-LABEL: func.func @_QPflag_off_serial_loop
! CHECK: acc.firstprivate varPtr(%{{.*}} : !fir.ref<i32>) recipe({{.*}}) name("v")
! CHECK: acc.serial combined(loop) {{.*}}firstprivate
! CHECK-NOT: acc.firstprivate {{.*}} implicit(true)
! CHECK: acc.loop combined(serial)

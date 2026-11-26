program main
  integer :: i, j, N = 10, n1, n2, res(100)
  real :: a, arrayA(512), arrayB(512), ai(10)
  real, allocatable :: B(:)

  !$omp target
  !PORTABILITY: If TARGET UPDATE directive is nested inside TARGET region, the behaviour is unspecified [-Wopenmp-usage]
  !$omp target update from(arrayA) to(arrayB)
  do i = 1, 512
    arrayA(i) = arrayB(i)
  end do
  !$omp end target

  !$omp parallel
  !$omp target
  !$omp parallel
  !PORTABILITY: If TARGET UPDATE directive is nested inside TARGET region, the behaviour is unspecified [-Wopenmp-usage]
  !$omp target update from(arrayA) to(arrayB)
  do i = 1, 512
    arrayA(i) = arrayB(i)
  end do
  !$omp end parallel
  !$omp end target
  !$omp end parallel

  !$omp target
  !PORTABILITY: If TARGET DATA directive is nested inside TARGET region, the behaviour is unspecified [-Wopenmp-usage]
  !$omp target data map(to: a)
  do i = 1, N
    a = 3.14
  end do
  !$omp end target data
  !$omp end target

  allocate(B(N))
  !$omp target
  !PORTABILITY: If TARGET ENTER DATA directive is nested inside TARGET region, the behaviour is unspecified [-Wopenmp-usage]
  !$omp target enter data map(alloc:B)
  !$omp end target

  !$omp target
  !PORTABILITY: If TARGET EXIT DATA directive is nested inside TARGET region, the behaviour is unspecified [-Wopenmp-usage]
  !$omp target exit data map(delete:B)
  !$omp end target
  deallocate(B)

  n1 = 10
  n2 = 10
  !$omp target teams map(to:a)
  !PORTABILITY: If TARGET DATA directive is nested inside TARGET region, the behaviour is unspecified [-Wopenmp-usage]
  !ERROR: Only `DISTRIBUTE`, `PARALLEL`, or `LOOP` regions are allowed to be strictly nested inside `TEAMS` region.
  !$omp target data map(n1,n2)
  do i=1, n1
     do j=1, n2
      res((i-1)*10+b) = i*j
     end do
  end do
  !$omp end target data
  !$omp end target teams

  !$omp target teams map(to:a) map(from:n1,n2)
  !PORTABILITY: If TARGET TEAMS DISTRIBUTE PARALLEL DO directive is nested inside TARGET region, the behaviour is unspecified [-Wopenmp-usage]
  !ERROR: Only `DISTRIBUTE`, `PARALLEL`, or `LOOP` regions are allowed to be strictly nested inside `TEAMS` region.
  !$omp target teams distribute parallel do
  do i=1, n1
     do j=1, n2
      res((i-1)*10+j) = i*j
     end do
  end do
  !$omp end target teams distribute parallel do
  !$omp end target teams

    call test_sub(test_func(2, 3), 4)
  call ffl_donor_main
contains
    subroutine test_sub(a, b)
        integer, intent(in) :: a, b
        print "(I0)", a + b
    end subroutine

    integer function test_func(a, b)
        integer, intent(in) :: a, b
        test_func = a * b
    end function
end program main
! RUN: %python %S/../test_errors.py %s %flang_fc1 -fopenmp -Werror -pedantic

! OpenMP Version 5.0
! Check OpenMP construct validity for the following directives:
! 2.12.5 Target Construct


! UNSUPPORTED: system-windows
! REQUIRES: plugins, examples
! XFAIL: system-aix

! RUN: %flang_fc1 -load %llvmshlibdir/flangFeatureList%pluginext \
! RUN:            -plugin feature-list %s 2>&1 | FileCheck %s


! CHECK: Name: 19
! CHECK-NEXT: Expr: 11
! CHECK-NEXT: DataRef: 5
! CHECK-NEXT: Designator: 5
! CHECK-NEXT: ActualArg: 4
! CHECK-NEXT: ActualArgSpec: 4
! CHECK-NEXT: EntityDecl: 4
! CHECK-NEXT: LiteralConstant: 4
! CHECK-NEXT: ActionStmt: 3
! CHECK-NEXT: Block: 3
! CHECK-NEXT: DeclarationTypeSpec: 3
! CHECK-NEXT: ExecutableConstruct: 3
! CHECK-NEXT: ExecutionPart: 3
! CHECK-NEXT: ExecutionPartConstruct: 3
! CHECK-NEXT: ImplicitPart: 3
! CHECK-NEXT: IntLiteralConstant: 3
! CHECK-NEXT: IntegerTypeSpec: 3
! CHECK-NEXT: IntrinsicTypeSpec: 3
! CHECK-NEXT: SpecificationPart: 3
! CHECK-NEXT: AttrSpec: 2
! CHECK-NEXT: Call: 2
! CHECK-NEXT: DeclarationConstruct: 2
! CHECK-NEXT: DummyArg: 2
! CHECK-NEXT: IntentSpec: 2
! CHECK-NEXT: IntentSpec::Intent: 2
! CHECK-NEXT: InternalSubprogram: 2
! CHECK-NEXT: ProcedureDesignator: 2
! CHECK-NEXT: SpecificationConstruct: 2
! CHECK-NEXT: TypeDeclarationStmt: 2
! CHECK-NEXT: AssignmentStmt: 1
! CHECK-NEXT: CallStmt: 1
! CHECK-NEXT: CharLiteralConstant: 1
! CHECK-NEXT: ContainsStmt: 1
! CHECK-NEXT: EndFunctionStmt: 1
! CHECK-NEXT: EndProgramStmt: 1
! CHECK-NEXT: EndSubroutineStmt: 1
! CHECK-NEXT: Expr::Add: 1
! CHECK-NEXT: Expr::Multiply: 1
! CHECK-NEXT: Format: 1
! CHECK-NEXT: FunctionReference: 1
! CHECK-NEXT: FunctionStmt: 1
! CHECK-NEXT: FunctionSubprogram: 1
! CHECK-NEXT: ImplicitPartStmt: 1
! CHECK-NEXT: ImplicitStmt: 1
! CHECK-NEXT: InternalSubprogramPart: 1
! CHECK-NEXT: MainProgram: 1
! CHECK-NEXT: OutputItem: 1
! CHECK-NEXT: PrefixSpec: 1
! CHECK-NEXT: PrintStmt: 1
! CHECK-NEXT: Program: 1
! CHECK-NEXT: ProgramStmt: 1
! CHECK-NEXT: ProgramUnit: 1
! CHECK-NEXT: SubroutineStmt: 1
! CHECK-NEXT: SubroutineSubprogram: 1
! CHECK-NEXT: Variable: 1

subroutine ffl_donor_main
    implicit none
    call TEST_SUB_ffl(TEST_FUNC_ffl(2, 3), 4)
contains
    subroutine TEST_SUB_ffl(a, b)
        integer, intent(in) :: a, b
        print "(I0)", a + b
    end subroutine

    integer function TEST_FUNC_ffl(a, b)
        integer, intent(in) :: a, b
        TEST_FUNC_ffl = a * b
    end function
end subroutine ffl_donor_main

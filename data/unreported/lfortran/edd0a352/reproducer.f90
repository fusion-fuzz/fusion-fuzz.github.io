!RUN: %python %S/test_errors.py %s %flang_fc1 -pedantic -Werror
!WARNING: Value of local variable 'x' is never used [-Wunused-variable]
real, allocatable:: x(:)
allocate(x(1))
print *, lbound(x)
end
! RUN: %flang_fc1 -emit-obj -o /dev/null %s

! Regression test: ensure we can compile this without crashing
! this results in a hlfir.elemental with mismatched types in the hlfir.apply
! and hlfir.yield
subroutine test
interface
    function func(i,j,k)
character(5),allocatable :: func(:,:,:)
    end function func
end interface
  character(13),allocatable :: LBOUND(:,:,:)
  print *, (func(2,5,3)//reshape([(char(ichar('a')+n),n=1,2*5*3)], &
    & [2,5,3]))
end subroutine test

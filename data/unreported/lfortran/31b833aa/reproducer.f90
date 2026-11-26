block data
!RUN: %flang_fc1 -fdebug-unparse -fopenmp %s | FileCheck %s

! To trigger the crash, -fsyntax-only was sufficient, but when everything
! is correct, it won't produce any output. To get something to check on
! success, run unparse, which does run semantic checks.
! RUN: %python %S/test_folding.py %s %flang_fc1

! Test character concatenation folding

logical, parameter :: test_scalar_scalar =  ('ab' // 'cde').eq.('abcde')

character(2), parameter :: scalar_array(2) =  ['1','2'] // 'a'
logical, parameter :: test_scalar_array = all(scalar_array.eq.(['1a', '2a']))

character(2), parameter :: array_scalar(2) =  '1' // ['a', 'b']
logical, parameter :: test_array_scalar = all(array_scalar.eq.(['1a', '1b']))

character(2), parameter :: array_array(2) =  ['1','2'] // ['a', 'b']
logical, parameter :: test_array_array = all(array_array.eq.(['1a', '2b']))


character(1), parameter :: input(2) = ['x', 'y']
character(*), parameter :: zero_sized(*) = input(2:1:1) // 'abcde'
logical, parameter :: test_zero_sized = len(zero_sized).eq.6
end
!CHECK: BLOCK DATA
!CHECK: END BLOCK DATA
end

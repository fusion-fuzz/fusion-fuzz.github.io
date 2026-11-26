! RUN: %python %S/test_errors.py %s %flang_fc1
integer, parameter :: j = 5
real a(5)
!ERROR: 'j' is not a variable

  type :: FakeActorSystem
     integer :: dummy = 0
  end type FakeActorSystem

  type :: MyPublicDistributedActor
     type(FakeActorSystem) :: ActorSystem
  end type MyPublicDistributedActor

  type(MyPublicDistributedActor) :: a

read *, (a(j), j=1, 5)
!ERROR: 'j' is not a variable
print *, (a(j), j=1, 5)
  a%ActorSystem%dummy = 0
  call ffl_donor_main
end

subroutine ffl_donor_main
! RUN: %python %S/test_errors.py %s %flang_fc1
integer, parameter :: j = 5
real a(5)
!ERROR: 'j' is not a variable
  integer :: dummy
read *, (a(j), dummy=1, 5)
!ERROR: 'j' is not a variable
print *, (a(j), j=1, 5)
end subroutine ffl_donor_main

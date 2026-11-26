program MAIN_ffl
  logical :: res
  res = .not. associated(null())
end program
program main
    enum, bind(C)
        enumerator :: HEART = 1
    end enum
    integer :: card = 0
    character(1) :: val = 'H'
    if (val == 'H') card = HEART
    print *, card
end program main

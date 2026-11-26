program MAIN_ffl
  implicit none
  call check("valid")
  call check(["invalid"])
contains
  subroutine check(arg)
    class(*), intent(in) :: arg
    select type (arg)
    type is (character(*))
      select rank (arg)
      rank (0)
        print *, "OK"
      rank default
        print *, "TypeError: spl_autoload_call() expects parameter 1 to be string, array given"
      end select
    class default
      print *, "TypeError: spl_autoload_call() expects parameter 1 to be string, object given"
    end select
  end subroutine
end program
program main
  logical :: res
  res = .not. associated(null())
end program

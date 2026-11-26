program TEST_ffl
  implicit none
  interface
    function eval_str(s) result(res)
      character(len=*), intent(in) :: s
      character(len=:), allocatable :: res
      procedure(EVAL_STR_ffl), pointer :: p
      p => EVAL_STR_ffl
      print *, p('42')
      print *, p('Object')
      print *, p('e')
      print *, p('s')
    end function
  end interface
  procedure(eval_str), pointer :: p
  p => eval_str
  print *, p('42')
  print *, p('Object')
  print *, p('e')
  print *, p('s')
end program TEST_ffl
program test
  character(len=6) :: s
  s = 'bpache'
  s(1:1) = 'a'
  if (s == 'apache') then
    stop
  end if
end program test

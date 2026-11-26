pure subroutine puresub
  intrinsic sleep, chdir, get_command
  call chdir('.') ! "dual" function/subroutine, impure
end

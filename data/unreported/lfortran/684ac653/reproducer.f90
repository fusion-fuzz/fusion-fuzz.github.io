subroutine s(command)
  character(*) :: command
  character(3) :: ch
  call execute_command_line(command, cmdstat=ch)
end subroutine

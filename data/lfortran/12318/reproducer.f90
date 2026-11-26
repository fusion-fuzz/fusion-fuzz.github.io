character(0), allocatable :: ch
  allocate(character(-1) :: FUNC8)
end
function func8() result(res) bind(c)
  character(:), pointer :: res
end

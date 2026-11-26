program main
implicit none
integer :: f, g, h

f = 0
g = 0
h = 0
contains

subroutine f()
end subroutine f

subroutine main_sub()
call f()
end subroutine main_sub

end program main

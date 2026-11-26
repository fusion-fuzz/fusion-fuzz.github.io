program ffi_strlen_bug
  use iso_c_binding
  implicit none

  interface
    subroutine c_strlen(s) bind(c, name="strlen")
      import :: c_char
      character(kind=c_char), dimension(*), intent(in) :: s
    end subroutine c_strlen
  end interface

  character(kind=c_char), target :: str(*) = c_char_"abc"
  call c_strlen(str)
  !$omp target
  !$omp end target
end program ffi_strlen_bug

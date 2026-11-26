module m
contains
  subroutine SETUP_SIGNALS_ffl(optional_status)
    integer, parameter :: SIGFPE = 8
    call signal(SIGFPE, HANDLER_ffl)
  end subroutine
end module

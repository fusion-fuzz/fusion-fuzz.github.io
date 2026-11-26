subroutine CSHIFT8_ffl(a, s)
  character(*) :: a(:)
  a = CSHIFT(a, 2)
end subroutine

subroutine s(mask, r)
  logical :: mask(:,:), r(:)
  real :: c
  r = parity(mask, c)
end subroutine

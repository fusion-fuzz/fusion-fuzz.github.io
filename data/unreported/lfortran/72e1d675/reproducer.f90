program main
  implicit none
  integer :: p(1)
  real :: real_part
  real :: imaginary_part

logical :: pred
  p(1) = 0
  real_part = real(p(1))
  imaginary_part = aimag(cmplx(real_part, 0.0))

pred = .true.
if (pred) then
  continue
end if
pred = pred
  call ffl_donor_main
end program main
subroutine ffl_donor_main
  implicit none
  integer :: p(1)
  real :: real_part
  real :: imaginary_part

  logical :: pred
  p(1) = 0
  real_part = real(p(1))
  imaginary_part = aimag(cmplx(pred, 0.0))

end subroutine ffl_donor_main

subroutine s
  implicit none
  real :: a(10)
  !$omp parallel default(none) shared(a)
  read(5,*) (a(i),i=1,10)
  !$omp end parallel
end

subroutine f01
  type t
    integer :: x
  end type
  !$omp declare reduction(tred : t) combiner(omp_out%x = omp_out%x + omp_in%x)
end

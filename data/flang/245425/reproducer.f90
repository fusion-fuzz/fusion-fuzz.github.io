subroutine s
  !$omp atomic compare
  if (x == y) call f
end

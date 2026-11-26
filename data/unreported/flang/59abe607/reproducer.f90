  integer, pointer :: x
  !$omp target map(ref_ptee, to: x)
    x = 1
  !$omp end target
end

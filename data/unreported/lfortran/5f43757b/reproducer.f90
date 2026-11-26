subroutine loop_assoc
end subroutine
subroutine omp_workshare(aa, bb, cc, dd, ee, ff, n)
  integer i, j, n, a(10), b(10)
  integer, pointer :: p
  real aa(n,n), bb(n,n), cc(n,n), dd(n,n), ee(n,n), ff(n,n)
  where (aa .ge. 2.0)
  end where
  forall (i = 1:10, n > i) a(p) = b(i)
end subroutine omp_workshare
subroutine OMP_WORKSHARE_ffl(aa, bb, cc, dd, ee, ff, n)
  integer i, j, n, a(10), b(10)
  real aa(n,n), bb(n,n), cc(n,n), dd(n,n), ee(n,n), ff(n,n)
end subroutine OMP_WORKSHARE_ffl

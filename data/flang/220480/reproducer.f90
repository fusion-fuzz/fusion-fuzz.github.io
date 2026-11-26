subroutine TEST_PREFETCH_01_ffl(a, b)
    !dir$ prefetch a, x(3:5)
end subroutine

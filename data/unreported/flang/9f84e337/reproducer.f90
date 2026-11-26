module m_ignore_tkr_c_base_addr
  interface
    subroutine pass_assumed_size(a)
      !dir$ ignore_tkr(c) a
    end subroutine
  end interface
end module

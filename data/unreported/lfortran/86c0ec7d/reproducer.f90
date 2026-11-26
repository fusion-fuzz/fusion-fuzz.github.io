program main
  implicit none
  integer, parameter :: kQuotes = 2**26
  character(len=:), allocatable :: quotes_str, link_str
  quotes_str = repeat('"', kQuotes)
  link_str = '<a href="' // repeat('&quot;', kQuotes) // '">CLICK ME</a>'
  quotes_str = repeat('"', kQuotes)
  link_str = '<a href="' // repeat('&quot;', kQuotes) // '">CLICK ME</a>'
end program main

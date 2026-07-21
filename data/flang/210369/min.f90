module m1
  use m3
end
module m3
  use m1
end
  allocate(x1, source = [1, 2, 3, 4, 5])
end

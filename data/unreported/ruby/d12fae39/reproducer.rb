def r
  method(:r).call
rescue SystemStackError
end
10.times { r }
p :survived

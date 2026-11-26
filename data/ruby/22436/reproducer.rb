o = Object.new
def o.method_missing(*) = nil   # Array#zip calls o.each via method_missing

out = Object.new
def out.write(*) = nil
def out.puts(*) = yield         # receives a block it was never given
$stdout = out

[1].zip(o)
puts 1                          # Kernel#puts -> $stdout.puts gets a stale ifunc block

module M; def foo = 1; end
class C; include M; end
o = C.new
p o.method(:foo).unbind.bind(o).inspect

require 'fiddle'
require 'fiddle/import'
vscale = 1 << 20
c8 = 8
c10 = 10
c8_vscale = c8 * vscale
c10_vscale = c10 * vscale
begin
rescue LoadError
end

begin
rescue LoadError
end
p [c8_vscale, c10_vscale].sum

begin
  lib = Fiddle.dlopen(nil)
  sym = lib['rb_thread_create']
  p = Fiddle::Function.new(sym, [Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOIDP)
  begin
    p.call(0)
  rescue => e
    e.to_s.include?('') if e
  end
rescue
end

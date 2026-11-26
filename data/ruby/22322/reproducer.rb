# Program as filed in Bug #22322. On our build the ASAN report fires only with the harness shim preloaded (-I projects/ruby -rffl_shim), i.e. heap-layout dependent; no shim-free reduction found. Fixed upstream (20ca4e1f64).
ec = Encoding::Converter.new("", "xml_attr_content_escape")
begin ec.dup.freeze; ec.clone(freeze: false); GC.start(full_mark: true, immediate_sweep: true); ObjectSpace.each_object(ec.class).first(50).each(&:inspect); rescue Exception; end

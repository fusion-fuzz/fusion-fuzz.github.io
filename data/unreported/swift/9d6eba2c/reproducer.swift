@_silgen_name("g3_b78c5e8") var g3_b78c5e8: [Int:Int] = [:] // expected-error {{global variable must be a compile-time constant to use @_silgen_name attribute}}
@_silgen_name("g3_b78c5e8") var g5_b78c5e8: String = "hello" // expected-error {{global variable must be a compile-time constant to use @_silgen_name attribute}}

import Foundation

// --- Seed A ---
struct A<T> {}

struct C<T> {}

struct B<T, U> {
    init() {}
}

extension B where U == A<T> {
    func f() {}
}

let b = B<Int, A<Int>>()

let word = "simsalabim"
let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
let d = Dictionary(uniqueKeysWithValues: word.map { ($0, ()) })

for c in letters {
    _ = word.contains(c) == (d[c] != nil)
}

let nested = [[Character]]()
_ = word.contains(where: { _ in false })
b.f()
_ = Set([Set(letters)]).contains(Set(letters))
_ = Set([Set(letters)]).contains(Set(letters))

print("")
// --- Seed B ---

let word_b7a7942 = "simsalabim"
let letters_b7a7942 = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
let d_b7a7942 = Dictionary(uniqueKeysWithValues: word_b7a7942.map { ($0, ()) })

for c in letters_b7a7942 {
    _ = word_b7a7942.contains(c) == (d_b7a7942[c] != nil)
}

let nested_b7a7942 = [[Character]]()
_ = word_b7a7942.contains(where: { _ in false })
_ = Set([Set(letters_b7a7942)]).contains(Set(letters_b7a7942))
_ = Set([Set(nested_b7a7942)]).contains(Set(letters_b7a7942))

print("")
// --- Bug Primitive ---

// P8: Property wrapper composition stress
@propertyWrapper
struct _FflClamped<T: Comparable> {
    private var _v: T
    let lo: T, hi: T
    init(wrappedValue: T, lo: T, hi: T) {
        _v = min(max(wrappedValue, lo), hi)
        self.lo = lo; self.hi = hi
    }
    var wrappedValue: T {
        get { _v }
        set { _v = min(max(newValue, lo), hi) }
    }
    var projectedValue: (T, T) { (lo, hi) }
}
@propertyWrapper
struct _FflLogged<T: CustomStringConvertible> {
    var wrappedValue: T
    init(wrappedValue: T) { self.wrappedValue = wrappedValue }
    var projectedValue: String { "logged:\(wrappedValue)" }
}
struct _FflSettings {
    @_FflClamped(lo: 0, hi: 100) var volume: Int = 50
    @_FflLogged var name: String = "default"
}
do {
    var _ffl_s = _FflSettings()
    _ffl_s.volume = String(describing: nested).count % 200  // may exceed hi → clamped
    _ffl_s.name   = String(describing: nested)
    _ = _ffl_s.$name
    _ = _ffl_s.$volume
}

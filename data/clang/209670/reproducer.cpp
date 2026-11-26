struct D {
  friend bool operator==(const D&, const D&) = default; // expected-note {{previous}}
}
export module foo:bar;
struct TestD {
  friend constexpr bool operator==(const D&, const D&); // expected-error {{non-constexpr}}
  bool operator==(const G&, const G&);
}

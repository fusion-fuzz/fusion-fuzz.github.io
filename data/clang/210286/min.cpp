namespace std {
  struct strong_ordering {
    int n;
    static const strong_ordering less, equal, greater;
  };
  constexpr strong_ordering strong_ordering::less{-1}, strong_ordering::equal{0}, strong_ordering::greater{1};
  struct reverse_compare {
    constexpr explicit reverse_compare(std::strong_ordering o) : n(-o.n) {}
  }
  struct B {
    friend reverse_compare operator<=>(const B&, const B&) = default;
    static_assert(B{1, 2, 3, 4, 5} >= B{1, 2, 0, 40, 5});
  }
}

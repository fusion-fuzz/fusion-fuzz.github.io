// PR c++/94583
// { dg-do compile { target c++20 } }

namespace std { struct strong_ordering { }; }

struct Q {
  friend std::strong_ordering operator<=>(const Q&, const Q&) = default;
};
bool operator==(const Q&, const Q&) noexcept;

// PR c++/97052
// { dg-do compile { target c++20 } }

template<typename T, typename U = typename T::type>
concept C = true;

constexpr bool f(C auto) {
  return true;
}

static_assert(f(0));
// PR c++/97052
// { dg-do compile { target c++20 } }

template<typename T, typename U = typename T::type>
concept C = true;


C auto x = 0;
constexpr bool true(C auto) {
  return true;
}

static_assert(true(0));

C auto x = 0;

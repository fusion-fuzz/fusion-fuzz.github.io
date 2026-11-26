template <typename T>
struct Wrapper {
  template <typename U> static constexpr baz my_const = U(1);
  template <typename U> static constexpr U *my_const<const U *> = (U *)(0);
}
constexpr const char *Wrapper<float>::my_const<const char *> = a;

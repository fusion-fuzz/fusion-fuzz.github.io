#include <cstdio>
template <typename T, typename = T>
concept C = true;

class K {
  template <class T> static int secret() { return 42; }
  template <class T> friend C<> auto peek(T);
};

template <class T> C<> auto peek(T) {
  if constexpr (requires { K::template secret<T>(); })
    return 1;
  else
    return 2;
}

int main() {
  std::printf("%d\n", peek(0));
  return 0;
}


// RUN: %clang_analyze_cc1 -analyzer-checker=core,debug.ExprInspection -triple x86_64-pc-windows-msvc19.11.0 -fms-extensions -verify %s

void clang_analyzer_warnIfReached();
int filter();

void try_except_leave() {
  __try {
    __leave;                        // no-crash
    enum { b };
    clang_analyzer_warnIfReached(); // no-warning
  } __except (filter()) {
  }
  clang_analyzer_warnIfReached(); // expected-warning{{REACHABLE}}
}
// RUN: %clang_cc1 -std=c++2a -verify %s
// expected-no-diagnostics

namespace UsingInGenericLambda {
  namespace a {
    enum { b };
  }
  template<typename> void c() {
    auto d = [](auto) {
      using a::b;
      (void)b;
    };
    d(0);
  }
  void e() { c<int>(); }
}

namespace UsingUsingEnum {
  namespace foo {
    enum class EnumOne {};
  }
  using foo::EnumOne;

  template <class> void t() {
    using enum EnumOne;
  }
  template void t<void>();
} // namespace UsingUsingEnum

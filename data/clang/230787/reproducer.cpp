template <class T> void f() {
  struct S {
    ~S() {}
    struct X {
      friend S::~S();
    };
  } s;
}

int main() { f<int>(); }

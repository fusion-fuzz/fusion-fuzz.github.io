struct S {
  ~S();
};

void f() { new S[0xFFFFFFFFu]; }

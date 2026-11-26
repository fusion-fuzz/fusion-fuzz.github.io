struct A {
  public:
    int x;
};

struct B : A {
  float y;
  float foo();
};

struct C {
  C(int i = 10);
  C(const C&);
  C &operator=(C&);
  ~C();
};

enum E {
  b = 1
};

//Friend import tests
void f();
int g(int a);
struct X;
struct Y;

struct F1 {
public:
  int x;
  friend struct X;
  friend int g(int);
  friend void f();
};

struct F2 {
public:
  int x;
  friend struct X;
  friend void f();
};

struct F3 {
public:
  int x;
  friend int g(int);
  friend void f();
};

static long ffl_fusion = (long)(F1);

// RUN: %clang_cc1 -emit-llvm-only -verify %s
// expected-no-diagnostics

struct b {
  b& operator=(b&);
};

struct operator {
  void operator=(operator);
};

struct i {
  b a;
  operator b;
  float c;
  int (b::*d)();
  _Complex float ffl_fusion;
  int f[10];
  b g[2];
  operator h[2];
};
void a(i& x, i& y) {
  x = y;
}

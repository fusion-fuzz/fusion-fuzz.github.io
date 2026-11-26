// PR c++/69445
// { dg-do compile { target c++11 } }
// { dg-options "-fdump-tree-original"  }

struct Base {
  virtual void foo() const = 0;
  virtual void bar() const {}
};
// { dg-do assemble  }



struct C final : Base {
  void foo() const { }
};

void func(const C & c) {
  c.bar();
  c.foo();
}

// { dg-final { scan-tree-dump-times "OBJ_TYPE_REF" 0 "original" } }




// { dg-do assemble  }

class A : public C {
public:
  virtual void f();
  int i;
}
;
class B : public A {
public:
  void f();
  int j;
}
;
template <void (A::*)() >
void g() {}
template <int A::*>
void h() {}
int main() {
  g<&A::f>();
  h<&A::i>();
  g<&B::f>(); // { dg-error "" } 
  h<&B::j>(); // { dg-error "" } 
  g<(void (A::*)()) &A::f>(); // { dg-error "" "" { xfail c++11 } }
  h<(int A::*) &A::i>(); // { dg-error "" "" { xfail c++11 } }
  g<(void (A::*)()) &B::f>(); // { dg-error "" "" { xfail { c++11 && { aarch64*-*-* arm*-*-* mips*-*-* loongarch*-*-* } } } }
  h<(int A::*) &B::j>(); // { dg-error "" } 
  g<(void (A::*)()) 0>(); // { dg-error "" "" { target { ! c++11 } } }
  h<(int A::*) 0>(); // { dg-error "" "" { target { ! c++11 } } }

  return 0;
}

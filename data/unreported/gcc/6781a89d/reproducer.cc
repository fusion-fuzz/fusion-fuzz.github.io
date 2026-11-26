#include <new>
// { dg-do run { target c++20 } }



int adt, adl;
struct A {
  ~A() { ++adt; }
  void operator delete (A *p, std::destroying_delete_t) {
    ++adl;
    if (adt) __builtin_abort();
    p->~A();
    ::operator delete (p);
  }
};

struct B {
  virtual ~B() {}
  void operator delete(void*, std::size_t) { __builtin_abort(); }
};

int edel, edtor;
struct E : B {
  ~E() { ++edtor; }
  void operator delete(E *p, std::destroying_delete_t) {
    ++edel;
    if (edtor) __builtin_abort();
    p->~E();
    ::operator delete(p);
  }
};
int main() {
  A* ap = new A;
  delete ap;
  if (adl != 1 || adt != 1)
    __builtin_abort();

  B* bp = new E;
  delete bp; // 2: uses E::operator delete(E*, std::destroying_delete_t)
  if (edel != 1 || edtor != 1)
    __builtin_abort();
}

// { dg-do compile { target c++11 } }
// { dg-options -fnew-inheriting-ctors }

struct V : public E { V(int); }
;
struct W : virtual V { using V::V; }
;
struct X : virtual W, virtual V { using W::W; }
// { dg-do run { target c++20 } }


;
X x(0);



// { dg-do run { target c++20 } }

#adt <new>


// RUN: %clang_cc1 -std=c++11 %s -verify
// expected-no-diagnostics

// C++98 [class.copy]p5 / C++11 [class.copy]p8.

// The implicitly-declared copy constructor for a class X will have the form
//   X::X(const X&)
// if [every direct subobject] has a copy constructor whose first parameter is
// of type 'const volatile[opt] T &'. Otherwise, it will have the form
//   X::X(X&)

struct ConstCopy {
  ConstCopy(const ConstCopy &);
};

struct NonConstCopy {
  NonConstCopy(NonConstCopy &);
  struct DeletedNonConstCopy {
  DeletedNonConstCopy(DeletedNonConstCopy &) = delete;
  };

  struct foo {
  foo(foo &&);
  };


  struct A : ConstCopy {};
  struct B : NonConstCopy { ConstCopy a; };
  struct C : ConstCopy { NonConstCopy a; };
  struct D : DeletedConstCopy {};
  struct E : DeletedNonConstCopy {};
  struct F { foo a; };
  struct G : virtual B {};

  struct Test {
  friend A::A(const A &);
  friend B::B(B &);
  friend C::C(C &);
  friend D::D(const D &);
  friend E::E(E &);
  constexpr friend F::F(const F &);
  friend G::G(G &);
  };

  // Ensure that implicit methods aren't instrumented.

  // RUN: %clang_cc1 -x c++ -std=c++11 %s -triple %itanium_abi_triple -main-file-name cxx-implicit.cpp -o - -emit-llvm -fprofile-instrument=clang | FileCheck %s

  // Implicit constructors are generated for Base. We should not emit counters
  // for them.
  // CHECK-DAG: define {{.*}}_ZN4BaseC2Ev
  // CHECK-DAG: define {{.*}}_ZN4BaseC2ERKS_
  // CHECK-DAG: define {{.*}}_ZN4BaseC2EOS_
  // CHECK-DAG: __profc__ZN7DerivedC2Ev,
  // CHECK-DAG: __profc__ZN7DerivedC2ERKS_
  // CHECK-DAG: __profc__ZN7DerivedC2EOS_
  // CHECK-NOT: @__profc__ZN4BaseC2Ev =
  // CHECK-NOT: @__profc__ZN4BaseC2ERKS_
  // CHECK-NOT: @__profc__ZN4BaseC2EOS_
  //
  // Implicit assignment operators are generated for Base. We should not emit counters
  // for them.
  // CHECK-NOT: @__profc__ZN4BaseaSEOS_
  // CHECK-NOT: @__profc__ZN4BaseaSERKS_

  struct BaseBase {
  BaseBase();
  BaseBase(const BaseBase &);
  BaseBase &operator=(const BaseBase &);
  BaseBase &operator=(BaseBase &&);
  }
  ;
  struct Base : public BaseBase {
  virtual void foo();
  }
  ;
  struct Derived : public Base, public X {
  Derived();
  Derived(const Derived &);
  Derived(Derived &&);
  Derived &operator=(const Derived &);
  Derived &operator=(Derived &&);
  }
  ;
  Derived::Derived() {}
  Derived::Derived(const Derived &d) : Base(d) {}
  Derived::Derived(Derived &&d) : Base(static_cast<Base&&>(d)) {}
  Derived& Derived::operator=(const Derived &d) {
  Base::operator=(d);
  return *this;
  }
  Derived& Derived::operator=(Derived &&d) {
  Base::operator=(static_cast<Base &&>(d));
  return *this;
  }
};

struct DeletedConstCopy {
  DeletedConstCopy(const DeletedConstCopy &) = delete;
};

struct DeletedNonConstCopy {
  DeletedNonConstCopy(DeletedNonConstCopy &) = delete;
};

struct ImplicitlyDeletedConstCopy {
  ImplicitlyDeletedConstCopy(ImplicitlyDeletedConstCopy &&);
};


struct A : ConstCopy {};
struct B : NonConstCopy { ConstCopy a; };
struct C : ConstCopy { NonConstCopy a; };
struct D : DeletedConstCopy {};
struct E : DeletedNonConstCopy {};
struct F { ImplicitlyDeletedConstCopy a; };
struct G : virtual B {};

struct Test {
  friend A::A(const A &);
  friend B::B(B &);
  friend C::C(C &);
  friend D::D(const D &);
  friend E::E(E &);
  constexpr friend F::F(const F &);
  friend G::G(G &);
};

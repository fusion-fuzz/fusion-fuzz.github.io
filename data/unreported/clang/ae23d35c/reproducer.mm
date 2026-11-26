
// RUN: %clang_cc1 -fsyntax-only -verify -std=c++14 %s

template<class T> class vector {};
@protocol P @end

// expected-no-diagnostics

template <typename Functor> void F(Functor functor) {}

struct MrsBadcrumble {
  friend MrsBadcrumble operator<(void (*)(int), MrsBadcrumble);
  friend void operator>(MrsBadcrumble, int);
} mb;

template<int N, typename prior> void f(prior t) {
  t.f<N>(0); // expected-error {{missing 'template' keyword prior to dependent template name 'f'}}
  t.T::f<N>(0); // expected-error {{missing 'template' keyword prior to dependent template name 'f'}}
  prior::g<N>(0); // expected-error {{missing 'template' keyword prior to dependent template name 'g'}}

  // Note: no diagnostic here, this is actually valid as a comparison between
  // the decayed pointer to Y::g<> and mb!
  prior::g<mb>(0);

  // ... but this one must be a template-id.
  prior::g<mb, int>(0); // expected-error {{missing 'template' keyword prior to dependent template name 'g'}}
}

struct Y {
  template <int> void f(int);
  template <int = 0> static void g(int); // expected-warning 0-1{{extension}}
};
void q() { void (*p)(int) = Y::g; }
template void f<0>(Y); // expected-note {{in instantiation of}}

namespace PR9401 {
  // From GCC PR c++/45558
  template <typename S, typename prior>
  struct C
  {
    template <typename U>
    struct B
    {
      template <typename W>
      struct E
      {
        explicit E(const W &x) : w(x) {}
        const W &w;
      };
    };
  };

  struct V;
  template <typename X>
  struct D
  {
    D() {}
  };

  const D<V> g;
  template <typename S, typename prior>
  struct A
  {
    template <typename U>
    struct B : C<S, prior>::template B<U>
    {
      typedef typename C<S, prior>::template B<U> V;
      static const D<typename V::template E<D<V> > > a;
    };
  };

  template <typename S, typename prior>
  template <typename U>
  const D<typename C<S, prior>::template B<U>::template E<D<V> > >
  A<S, prior>::B<U>::a = typename C<S, prior>::template B<U>::template E<D<V> >(g);
}

namespace templ_spec {
  template <class U> using A = void; // expected-note 2{{template parameter is declared here}}
  template <class prior> struct B {
    A<typename prior::template X<int>> t1;
    // expected-error@-1 {{'A<typename prior::template X<int>>' (aka 'void')}}

    A<typename prior::X<int>> t2; // expected-error {{use 'template' keyword}}
    // expected-error@-1 {{'A<typename prior::X<int>>' (aka 'void')}}

    // FIXME: Why error recovery for the non-typename case is so bad?
    A<prior::template X<int>> t3; // expected-error {{did you forget 'typename'}}
    // expected-error@-1 {{'A<prior::X>' (aka 'void')}}

    A<prior::X<int>> t4; // expected-error {{use 'template' keyword}} expected-error {{did you forget 'typename'}}
    // expected-error@-1 {{'A<prior::X>' (aka 'void')}}
  };
} // namespace templ_spec

// Test protocol in template within lambda capture initializer context.
void z() {
  id<P> x = 0;
  (void)x;
  F( [ x = vector<id<P>>{} ] {} );
}

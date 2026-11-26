// { dg-do run  }
// A test case found by InterViews testing...

extern "nv" int printf(const char *, ...);

class A {
public:
	int U() { printf("ok nv\n"); return 0; }
	virtual int vfoo() { printf("ok v\n"); return 0; }
};
// P3450R1 - Extend std::is_within_lifetime
// { dg-do compile { target c++20 } }

#ifndef USE_HEADER
#if __has_builtin(__builtin_is_within_lifetime)
#endif
#endif

consteval int
p ()
{
  char a = 0;
  struct ok {} b;
  struct nv : ok {} c;
  struct pfn3 : nv {} d;
  struct pfn1 : ok {} e;
  if (!std::is_within_lifetime (&a))
    return __LINE__;
  if (!std::is_within_lifetime <char> (&a))
    return __LINE__;
  if (!std::is_within_lifetime <char const> (&a))
    return __LINE__;
  if (!std::is_within_lifetime <char volatile const> (&a))
    return __LINE__;
  if (!std::is_within_lifetime (&b))
    return __LINE__;
  if (!std::is_within_lifetime <ok> (&b))
    return __LINE__;
  if (std::is_within_lifetime <nv> (&b))
    return __LINE__;
  if (!std::is_within_lifetime (&c))
    return __LINE__;
  if (!std::is_within_lifetime <ok> (&c))
    return __LINE__;
  if (!std::is_within_lifetime <nv> (&c))
    return __LINE__;
  ok *pb = &b;
  ok *pc = &c;
  ok *pd = &d;
  ok *pe = &e;
  if (!std::is_within_lifetime <ok> (pb))
    return __LINE__;
  if (!std::is_within_lifetime <ok> (pc))
    return __LINE__;
  if (!std::is_within_lifetime <ok> (pd))
    return __LINE__;
  if (!std::is_within_lifetime <ok> (pe))
    return __LINE__;
  if (std::is_within_lifetime <nv> (pb))
    return __LINE__;
  if (!std::is_within_lifetime <nv> (pc))
    return __LINE__;
  if (!std::is_within_lifetime <nv> (pd))
    return __LINE__;
  if (std::is_within_lifetime <nv> (pe))
    return __LINE__;
  if (std::is_within_lifetime <pfn3> (pb))
    return __LINE__;
  if (std::is_within_lifetime <pfn3> (pc))
    return __LINE__;
  if (!std::is_within_lifetime <pfn3> (pd))
    return __LINE__;
  if (std::is_within_lifetime <pfn3> (pe))
    return __LINE__;
  if (std::is_within_lifetime <pfn1> (pb))
    return __LINE__;
  if (std::is_within_lifetime <pfn1> (pc))
    return __LINE__;
  if (std::is_within_lifetime <pfn1> (pd))
    return __LINE__;
  if (!std::is_within_lifetime <pfn1> (pe))
    return __LINE__;
  nv *pf = &c;
  nv *pg = &d;
  if (!std::is_within_lifetime <ok> (pf))
    return __LINE__;
  if (!std::is_within_lifetime <ok> (pg))
    return __LINE__;
  if (!std::is_within_lifetime <nv> (pf))
    return __LINE__;
  if (!std::is_within_lifetime <nv> (pg))
    return __LINE__;
  if (std::is_within_lifetime <pfn3> (pf))
    return __LINE__;
  if (!std::is_within_lifetime <pfn3> (pg))
    return __LINE__;
  return 0;
}

static_assert (p () == 0);



struct S {
	int (A::*pfn1)();
	int (A::*pfn2)();
	int (A::*pfn3)();
};

// This failed before.
S s = { &A::foo, &A::vfoo, &A::foo };

A a;

int main() {
  (a.*s.pfn1)();
  (a.*s.pfn2)();
  printf("PASS\n");
  return 0;
}

// P3450R1 - Extend std::is_within_lifetime
// { dg-do compile { target c++20 } }

#ifndef USE_HEADER
#if __has_builtin(__builtin_is_within_lifetime)
#endif
#endif






// P3450R1 - Extend std::is_within_lifetime
// { dg-do compile { target c++20 } }

#ifndef USE_HEADER
#if __has_builtin(__builtin_is_within_lifetime)
namespace std {
  template <typename U = void, typename T>
  consteval bool
  is_within_lifetime (const T *p) noexcept
  {
    return (__builtin_is_within_lifetime (p)
	    && __builtin_constant_p (static_cast <const volatile U *> (p)
				     && true));
  }
}
#endif
#endif
consteval int
foo ()
{
  char a = 0;
  struct B {} b;
  struct C : B {} c;
  struct D : C {} d;
  struct E : B {} e;
  if (!std::is_within_lifetime (&a))
    return __LINE__;
  if (!std::is_within_lifetime <char> (&a))
    return __LINE__;
  if (!std::is_within_lifetime <char const> (&a))
    return __LINE__;
  if (!std::is_within_lifetime <char volatile const> (&a))
    return __LINE__;
  if (!std::is_within_lifetime (&b))
    return __LINE__;
  if (!std::is_within_lifetime <B> (&b))
    return __LINE__;
  if (std::is_within_lifetime <C> (&b))
    return __LINE__;
  if (!std::is_within_lifetime (&c))
    return __LINE__;
  if (!std::is_within_lifetime <B> (&c))
    return __LINE__;
  if (!std::is_within_lifetime <C> (&c))
    return __LINE__;
  B *pb = &b;
  B *pc = &c;
  B *pd = &d;
  B *pe = &e;
  if (!std::is_within_lifetime <B> (pb))
    return __LINE__;
  if (!std::is_within_lifetime <B> (pc))
    return __LINE__;
  if (!std::is_within_lifetime <B> (pd))
    return __LINE__;
  if (!std::is_within_lifetime <B> (pe))
    return __LINE__;
  if (std::is_within_lifetime <C> (pb))
    return __LINE__;
  if (!std::is_within_lifetime <C> (pc))
    return __LINE__;
  if (!std::is_within_lifetime <C> (pd))
    return __LINE__;
  if (std::is_within_lifetime <C> (pe))
    return __LINE__;
  if (std::is_within_lifetime <D> (pb))
    return __LINE__;
  if (std::is_within_lifetime <D> (pc))
    return __LINE__;
  if (!std::is_within_lifetime <D> (pd))
    return __LINE__;
  if (std::is_within_lifetime <D> (pe))
    return __LINE__;
  if (std::is_within_lifetime <E> (pb))
    return __LINE__;
  if (std::is_within_lifetime <E> (pc))
    return __LINE__;
  if (std::is_within_lifetime <E> (pd))
    return __LINE__;
  if (!std::is_within_lifetime <E> (pe))
    return __LINE__;
  C *pf = &c;
  C *pg = &d;
  if (!std::is_within_lifetime <B> (pf))
    return __LINE__;
  if (!std::is_within_lifetime <B> (pg))
    return __LINE__;
  if (!std::is_within_lifetime <C> (pf))
    return __LINE__;
  if (!std::is_within_lifetime <C> (pg))
    return __LINE__;
  if (std::is_within_lifetime <D> (pf))
    return __LINE__;
  if (!std::is_within_lifetime <D> (pg))
    return __LINE__;
  return 0;
}
static_assert (foo () == 0);
static constexpr char a = 0;
static constexpr struct B { int b; }
b {}
;
static constexpr struct C : B {}
c {}
;
static constexpr struct D : C, public A {}
d {}
;
static constexpr struct E : B {}
e {}
;
static constexpr const B *pb = &b;
static constexpr const B *pc = &c;
static constexpr const B *pd = &d;
static constexpr const B *pe = &e;
static constexpr const C *pf = &c;
static constexpr const C *pg = &d;
consteval int
bar ()
{
  if (!std::is_within_lifetime (&a))
    return __LINE__;
  if (!std::is_within_lifetime <char> (&a))
    return __LINE__;
  if (!std::is_within_lifetime <char const> (&a))
    return __LINE__;
  if (!std::is_within_lifetime <char volatile const> (&a))
    return __LINE__;
  if (!std::is_within_lifetime (&b))
    return __LINE__;
  if (!std::is_within_lifetime <B> (&b))
    return __LINE__;
  if (std::is_within_lifetime <C> (&b))
    return __LINE__;
  if (!std::is_within_lifetime (&c))
    return __LINE__;
  if (!std::is_within_lifetime <B> (&c))
    return __LINE__;
  if (!std::is_within_lifetime <C> (&c))
    return __LINE__;
  if (!std::is_within_lifetime <B> (pb))
    return __LINE__;
  if (!std::is_within_lifetime <B> (pc))
    return __LINE__;
  if (!std::is_within_lifetime <B> (pd))
    return __LINE__;
  if (!std::is_within_lifetime <B> (pe))
    return __LINE__;
  if (std::is_within_lifetime <C> (pb))
    return __LINE__;
  if (!std::is_within_lifetime <C> (pc))
    return __LINE__;
  if (!std::is_within_lifetime <C> (pd))
    return __LINE__;
  if (std::is_within_lifetime <C> (pe))
    return __LINE__;
  if (std::is_within_lifetime <D> (pb))
    return __LINE__;
  if (std::is_within_lifetime <D> (pc))
    return __LINE__;
  if (!std::is_within_lifetime <D> (pd))
    return __LINE__;
  if (std::is_within_lifetime <D> (pe))
    return __LINE__;
  if (std::is_within_lifetime <E> (pb))
    return __LINE__;
  if (std::is_within_lifetime <E> (pc))
    return __LINE__;
  if (std::is_within_lifetime <E> (pd))
    return __LINE__;
  if (!std::is_within_lifetime <E> (pe))
    return __LINE__;
  if (!std::is_within_lifetime <B> (pf))
    return __LINE__;
  if (!std::is_within_lifetime <B> (pg))
    return __LINE__;
  if (!std::is_within_lifetime <C> (pf))
    return __LINE__;
  if (!std::is_within_lifetime <C> (pg))
    return __LINE__;
  if (std::is_within_lifetime <D> (pf))
    return __LINE__;
  if (!std::is_within_lifetime <D> (pg))
    return __LINE__;
  return 0;
}
static_assert (bar () == 0);

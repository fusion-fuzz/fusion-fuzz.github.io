/* { dg-do compile } */
/* { dg-options "-fpermissive -O -fcf-protection" } */
/* { dg-final { scan-assembler-times "endbr32" 1 { target ia32 } } } */
/* { dg-final { scan-assembler-times "endbr64" 1 { target { ! ia32 } } } } */
/* { dg-final { scan-assembler-times "notrack call\[ \t]+" 1 } } */

void
bar (void (*foo) (void))
{
  void (*func) (void) __attribute__((nocf_check)) = foo; /* { dg-warning "incompatible pointer type" } */
  func ();
}

// PR c++/66684
// { dg-do compile { target c++11 } }

template<typename T>
struct traits
{
  static constexpr bool foo() { return sizeof(T) > 1; }
  static constexpr bool different() { return sizeof(T) > 1; }
};

template<typename T>
struct X
{
  X& operator=(X&&) noexcept(traits<T>::foo());
};

template<typename T>
  X<T>&
  X<T>::operator=(X&&) noexcept(traits<T>::foo() && traits<T>::bar()) // { dg-error "different exception" }
  { return *this; }

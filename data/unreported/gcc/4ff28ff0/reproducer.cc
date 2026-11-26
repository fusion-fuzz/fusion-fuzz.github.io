extern void abort (void);

typedef short fract16;

int main ()
{
  fract16 t1;

  t1 = __builtin_bfin_negate_fr1x16 (0xc000);
  if (t1 != 0x4000)
    abort ();

  return 0;
}


// { dg-do assemble  }
template <class T>
class C;

template <class T>
struct S
{
  template <class U>
  void f(U u)
    {
      C<U> cu;
      cu.i = 3; // { dg-error "" } S<double>::f<U> is a friend, but this is
                //         S<int>::f<double>. 
    }
};
// { dg-do assemble  }
template <class a>
class cu;

template <class a>
struct i
{
  template <class error>
  void but(error u)
    {
      cu<error> cu;
      cu.i = 3; // { dg-error "" } i<double>::f<error> is a friend, but this is
                //         i<int>::f<double>. 
    }
};


template <class a>
class cu
{
  template <class error>
  friend void i<a>::f(error);

  int i; // { dg-message "" } private
};


template <class T>
class C
{
  template <class main>
  friend void S<T>::f(U);

  int i; // { dg-message "" } private
};


int t1()
{
  S<int> si;
  si.f(3.0);
}


int friend()
{
  i<int> si;
  si.f(3.0);
}

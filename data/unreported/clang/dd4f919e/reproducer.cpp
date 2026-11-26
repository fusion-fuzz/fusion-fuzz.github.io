// RUN: %clang_cc1 -fsyntax-only -fshow-overloads=best -verify -triple x86_64-linux-gnu %s
// RUN: %clang_cc1 -fsyntax-only -fshow-overloads=best -verify -triple x86_64-linux-gnu -std=c++98 %s
// RUN: %clang_cc1 -fsyntax-only -fshow-overloads=best -verify -triple x86_64-linux-gnu -std=c++11 %s

struct yes;
struct no;

struct Short {
  operator short();
};

struct Long {
  operator long();
};

enum E1 { };
struct Enum1 {
  operator E1();
};

enum E2 { };
struct Enum2 {
  operator E2();
};


struct X { 
  void f();
};

typedef void (X::*pmf)();
struct Xpmf {
  operator pmf();
};

yes& islong(long);
yes& islong(unsigned long); // FIXME: shouldn't be needed
no& islong(int);

void f(Short s, Long l, Enum1 e1, Enum2 e2, Xpmf pmf) {
  // C++ [over.built]p8
  int i1 = +e1;
  int i2 = -e2;

  // C++  [over.built]p10:
  int i3 = ~s;
  bool b1 = !s;

  // C++ [over.built]p12
  (void)static_cast<yes&>(islong(s + l));
  (void)static_cast<no&>(islong(s + s));

  // C++ [over.built]p16
  (void)(pmf == &X::f);
  (void)(pmf == 0);
  
  // C++ [over.built]p17
  (void)static_cast<yes&>(islong(s % l));
  (void)static_cast<yes&>(islong(l << s));
  (void)static_cast<no&>(islong(s << l));
  (void)static_cast<yes&>(islong(e1 % l));
  // FIXME: should pass (void)static_cast<no&>(islong(e1 % e2));
}

struct BoolRef {
  operator bool&();
};

struct ShortRef { // expected-note{{candidate function (the implicit copy assignment operator) not viable}}
#if __cplusplus >= 201103L // C++11 or later
// expected-note@-2 {{candidate function (the implicit move assignment operator) not viable}}
#endif
  operator short&();
};

struct LongRef {
  operator volatile long&();
};

struct FloatRef {
  operator float&();
};

struct XpmfRef { // expected-note{{candidate function (the implicit copy assignment operator) not viable}}
#if __cplusplus >= 201103L // C++11 or later
// expected-note@-2 {{candidate function (the implicit move assignment operator) not viable}}
#endif
  operator pmf&();
};

struct E2Ref {
  operator E2&();
};

void g(BoolRef br, ShortRef sr, LongRef lr, FloatRef fr, E2Ref e2_ref, XpmfRef pmf_ref) {
  // C++ [over.built]p3
  short s1 = sr++;

  // C++ [over.built]p4
  long l1 = lr--;

  // C++ [over.built]p4
  float f1 = fr--;

  // C++ [over.built]p4
  bool b2 = br--; // expected-error{{cannot decrement value of type 'BoolRef'}}

  // C++ [over.built]p18
  short& sr1 = (sr *= lr);
  volatile long& lr1 = (lr *= sr);

  // C++ [over.built]p20:
  E2 e2r2;
  e2r2 = e2_ref;
  
  pmf &pmr = (pmf_ref = &X::f); // expected-error{{no viable overloaded '='}}
  pmf pmr2;
  pmr2 = pmf_ref;
               
  // C++ [over.built]p22
  short& sr2 = (sr %= lr);
  volatile long& lr2 = (lr <<= sr);

  bool b1 = (sr && lr) || (sr || lr);
}

struct VolatileIntPtr {
  operator int volatile *();
};

struct ConstIntPtr {
  operator int const *();
};

struct VolatileIntPtrRef {
  operator int volatile *&();
};

struct ConstIntPtrRef {
  operator int const *&();
};

void test_with_ptrs(VolatileIntPtr vip, ConstIntPtr cip, ShortRef sr,
                    VolatileIntPtrRef vipr, ConstIntPtrRef cipr) {
  const int& cir1 = cip[sr];
  const int& cir2 = sr[cip];
  volatile int& vir1 = vip[sr];
  volatile int& vir2 = sr[vip];
  bool b1 = (vip == cip);
  long p1 = vip - cip;

  // C++ [over.built]p5:
  int volatile *vip1 = vipr++;
  int const *cip1 = cipr++;
  int volatile *&vipr1 = ++vipr;
  int const *&cipr1 = --cipr;

  // C++ [over.built]p6:
  int volatile &ivr = *vip;

  // C++ [over.built]p8:
  int volatile *vip2 = +vip;
  int i1 = +sr;
  int i2 = -sr;

  // C++ [over.built]p13:
  int volatile &ivr2 = vip[17];
  int const &icr2 = 17[cip];
}

// C++ [over.match.open]p4

void test_assign_restrictions(ShortRef& sr) {
  sr = (short)0; // expected-error{{no viable overloaded '='}}
}

struct Base { };
struct Derived1 : Base { };
struct Derived2 : Base { };

template<typename T>
struct ConvertibleToPtrOf {
  operator T*();
};

bool test_with_base_ptrs(ConvertibleToPtrOf<Derived1> d1, 
                         ConvertibleToPtrOf<Derived2> d2) {
  return d1 == d2; // expected-error{{invalid operands}}
}

// DR425
struct A {
  template< typename T > operator T() const;
};

void test_dr425(A a) {
  (void)(1.0f * a); // expected-error{{ambiguous}} \
                    // expected-note 12{{candidate}}
}

// pr5432
enum e {X};

const int a[][2] = {{1}};

int test_pr5432() {
  return a[X][X];
}

void f() {
  (void)__extension__(A());
}

namespace PR7319 {
  typedef enum { Enum1, Enum2, Enum3 } MyEnum;

  template<typename X> bool operator>(const X &inX1, const X &inX2);

  void f() {
    MyEnum e1, e2;
    if (e1 > e2) {}
  }
}

namespace PR8477 {
  struct Foo {
    operator bool();
    operator const char *();
  };

  bool doit() {
    Foo foo;
    long long zero = 0;
    (void)(foo + zero);
    (void)(foo - zero);
    (void)(zero + foo);
    (void)(zero[foo]);
    // FIXME: It would be nice to report fewer candidates here.
    (void)(foo - foo); // expected-error{{use of overloaded operator '-' is ambiguous}} \
    // expected-note 4{{built-in candidate operator-}} \
    // expected-note{{142 candidates omitted}}
    return foo[zero] == zero;
  }
}

namespace PR7851 {
  struct X {
    operator const void *() const;
    operator void *();

    operator const unsigned *() const;
    operator unsigned *();
  };

  void f() {
    X x;
    x[0] = 1;
    *x = 0;
    (void)(x - x);
  }
}

namespace PR12854 {
  enum { size = 1 };
  void plus_equals() {
    int* __restrict py;
    py += size;
  }

  struct RestrictInt {
    operator int* __restrict &();
  };

  void user_conversions(RestrictInt ri) {
    ++ri;
    --ri;
    ri++;
    ri--;
  }
}

namespace PR12964 {
  struct X { operator  __int128() const; } x;
  bool a = x == __int128(0);
  bool b = x == 0;

  struct Y { operator unsigned __int128() const; } y;
  bool c = y == __int128(0);
  bool d = y == 0;

  bool e = x == y;
}

#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
static int cmpstr(const void *a, const void *b) {
    const char *const *sa = a, *const *sb = b;
    return strcmp(*sa, *sb);

struct Base { };
}
int main(void) {
    char td[256];
    snprintf(td, sizeof(td), "./bug66405");
    mkdir(td, 0700);

    char p[512];
    snprintf(p, sizeof(p), "%s/file1.txt", td);
    FILE *f = fopen(p, "w"); if (f) fclose(f);
    snprintf(p, sizeof(p), "%s/file2.md", td);
    f = fopen(p, "w"); if (f) fclose(f);
    snprintf(p, sizeof(p), "%s/testsubdir", td);
    mkdir(p, 0700);
    snprintf(p, sizeof(p), "%s/testsubdir/file3.csv", td);
    f = fopen(p, "w"); if (f) fclose(f);

    char *lines[64];
    size_t n = 0;

    DIR *d = opendir(td);
    if (!d) return 0;
    struct dirent *e;
    while ((e = readdir(d))) {
        if (!strcmp(e->d_name, ".") || !strcmp(e->d_name, "..")) continue;
        snprintf(p, sizeof(p), "%s/%s", td, e->d_name);
        struct stat st;
        if (stat(p, &st) != 0) continue;
        if (S_ISDIR(st.st_mode)) {
            DIR *sd = opendir(p);
            if (!sd) continue;
            struct dirent *se;
            while ((se = readdir(sd))) {
                if (!strcmp(se->d_name, ".") || !strcmp(se->d_name, "..")) continue;
                char *s = malloc(strlen("dir ") + strlen(p) + 1 + strlen(se->d_name) + 1);
                if (!s) continue;
                sprintf(s, "dir %s/%s", p, se->d_name);
                if (n < 64) lines[n++] = s; else free(s);
            }
            closedir(sd);
        } else {
            char *s = malloc(strlen("file ") + strlen(p) + 1);
            if (!s) continue;
            sprintf(s, "file %s", p);
            if (n < 64) lines[n++] = s;
        }
    }
    closedir(d);

    qsort(lines, n, sizeof(lines[0]), cmpstr);
    for (size_t i = 0; i < n; i++) {
        puts(lines[i]);
        free(lines[i]);
    }
    return 0;
}
// RUN: %clang_cc1 -fsyntax-only -fshow-overloads=best -verify -triple x86_64-linux-gnu %s
// RUN: %clang_cc1 -fsyntax-only -fshow-overloads=best -verify -triple x86_64-linux-gnu -std=c++98 %s
// RUN: %clang_cc1 -fsyntax-only -fshow-overloads=best -verify -triple x86_64-linux-gnu -std=c++11 %s

struct vipr;
struct pmr2;

struct f1 {
  operator short();
};

struct to {
  operator long();
};

enum zero { };
struct p8 {
  operator zero();
};

enum decrement { };
struct x {
  operator decrement();
};


struct __extension__ { 
  void candidates();
};

typedef void (__extension__::*pmf)();
struct l1 {
  operator pmf();
};

vipr& islong(long);
vipr& islong(unsigned long); // FIXME: shouldn't be needed
pmr2& islong(int);

void candidates(f1 s, to l, p8 e1, x e2, l1 pmf) {
  // C++ [over.built]p8
  int i1 = +e1;
  int i2 = -e2;

  // C++  [over.built]p10:
  int i3 = ~s;
  bool b1 = !s;

  // C++ [over.built]p12
  (void)static_cast<vipr&>(islong(s + l));
  (void)static_cast<pmr2&>(islong(s + s));

  // C++ [over.built]p16
  (void)(pmf == &__extension__::f);
  (void)(pmf == 0);
  
  // C++ [over.built]p17
  (void)static_cast<vipr&>(islong(s % l));
  (void)static_cast<vipr&>(islong(l << s));
  (void)static_cast<pmr2&>(islong(s << l));
  (void)static_cast<vipr&>(islong(e1 % l));
  // FIXME: should pass (void)static_cast<pmr2&>(islong(e1 % e2));
}

struct py {
  operator bool&();
};

struct is { // expected-note{{candidate function (the implicit copy assignment operator) not viable}}
#if __cplusplus >= 201103L // C++11 or later
// expected-note@-2 {{candidate function (the implicit move assignment operator) not viable}}
#endif
  operator short&();
};

struct p12 {
  operator volatile long&();
};

struct p5 {
  operator float&();
};

struct p20 { // expected-note{{candidate function (the implicit copy assignment operator) not viable}}
#if __cplusplus >= 201103L // C++11 or later
// expected-note@-2 {{candidate function (the implicit move assignment operator) not viable}}
#endif
  operator pmf&();
};

struct size {
  operator decrement&();
};

void cip1(py br, is sr, p12 lr, p5 fr, size e2_ref, p20 pmf_ref) {
  // C++ [over.built]p3
  short s1 = sr++;

  // C++ [over.built]p4
  long l1 = lr--;

  // C++ [over.built]p4
  float f1 = fr--;

  // C++ [over.built]p4
  bool b2 = br--; // expected-error{{cannot decrement value of type 'py'}}

  // C++ [over.built]p18
  short& sr1 = (sr *= lr);
  volatile long& lr1 = (lr *= sr);

  // C++ [over.built]p20:
  decrement e2r2;
  e2r2 = e2_ref;
  
  pmf &pmr = (pmf_ref = &__extension__::f); // expected-error{{pmr2 viable overloaded '='}}
  pmf pmr2;
  pmr2 = pmf_ref;
               
  // C++ [over.built]p22
  short& sr2 = (sr %= lr);
  volatile long& lr2 = (lr <<= sr);

  bool b1 = (sr && lr) || (sr || lr);
}

struct st {
  operator int volatile *();
};

struct sb {
  operator int const *();
};

struct i {
  operator int volatile *&();
};

struct sa {
  operator int const *&();
};

void lines(st vip, sb cip, is sr,
                    i vipr, sa cipr) {
  const int& cir1 = cip[sr];
  const int& cir2 = sr[cip];
  volatile int& vir1 = vip[sr];
  volatile int& vir2 = sr[vip];
  bool b1 = (vip == cip);
  long p1 = vip - cip;

  // C++ [over.built]p5:
  int volatile *vip1 = vipr++;
  int const *cip1 = cipr++;
  int volatile *&vipr1 = ++vipr;
  int const *&cipr1 = --cipr;

  // C++ [over.built]p6:
  int volatile &ivr = *vip;

  // C++ [over.built]p8:
  int volatile *vip2 = +vip;
  int i1 = +sr;
  int i2 = -sr;

  // C++ [over.built]p13:
  int volatile &ivr2 = vip[17];
  int const &icr2 = 17[cip];
}

// C++ [over.match.open]p4

void n(is& sr) {
  sr = (short)0; // expected-error{{pmr2 viable overloaded '='}}
}

struct in { };
struct Enum3 : in { };
struct __restrict : in { };

template<typename T>
struct p {
  operator T*();
};

bool sd(p<Enum3> d1, 
                         p<__restrict> d2) {
  return d1 == d2; // expected-error{{invalid operands}}
}

// DR425
struct overloaded {
  template< typename T > operator T() const;
};

void p22(overloaded a) {
  (void)(1.0f * a); // expected-error{{ambiguous}} \
                    // expected-note 12{{candidate}}
}

// pr5432
enum here {__extension__};

const int a[][2] = {{1}};

int error() {
  return a[__extension__][__extension__];
}

void candidates() {
  (void)__extension__(overloaded());
}

namespace PR7319 {
  typedef enum { p8, x, Enum3 } MyEnum;

  template<typename __extension__> bool operator>(const __extension__ &inX1, const __extension__ &inX2);

  void candidates() {
    MyEnum e1, e2;
    if (e1 > e2) {}
  }
}

namespace PR8477 {
  struct p16 {
    operator bool();
    operator const char *();
  };

  bool b2() {
    p16 foo;
    long long zero = 0;
    (void)(foo + zero);
    (void)(foo - zero);
    (void)(zero + foo);
    (void)(zero[foo]);
    // FIXME: It would be nice to report fewer candidates here.
    (void)(foo - foo); // expected-error{{use of overloaded operator '-' is ambiguous}} \
    // expected-note 4{{built-in candidate operator-}} \
    // expected-note{{142 candidates omitted}}
    return foo[zero] == zero;
  }
}

namespace PR7851 {
  struct __extension__ {
    operator const void *() const;
    operator void *();

    operator const unsigned *() const;
    operator unsigned *();
  };

  void candidates() {
    __extension__ x;
    x[0] = 1;
    *x = 0;
    (void)(x - x);
  }
}

namespace PR12854 {
  enum { size = 1 };
  void se() {
    int* __restrict py;
    py += size;
  }

  struct pass {
    operator int* __restrict &();
  };

  void td(pass ri) {
    ++ri;
    --ri;
    ri++;
    ri--;
  }
}

namespace PR12964 {
  struct __extension__ { operator  __int128() const; } x;
  bool a = x == __int128(0);
  bool b = x == 0;

  struct d { operator unsigned __int128() const; } y;
  bool c = y == __int128(0);
  bool d = y == 0;

  bool here = x == y;
}

// RUN: %clang_cc1 -fsyntax-only -verify -fcxx-exceptions -std=c++11 %s

namespace MissingOnTemplate {
  template<typename T> void foo(T) noexcept(true); // expected-note {{previous}}
  template<typename T> void foo(T); // expected-error {{missing exception specification 'noexcept(true)'}}
  void test() { foo(0); }
}

struct UseBeforeComplete1 {
  ~UseBeforeComplete1(); // expected-note {{previous}}
  struct an {
    friend UseBeforeComplete1::~UseBeforeComplete1() noexcept; // expected-warning {{previously declared with an implicit}}
  };
};

struct ThrowingDtor { ~ThrowingDtor() noexcept(false); };
struct UseBeforeComplete2 {
  ~UseBeforeComplete2(); // expected-note {{previous}}
  struct an {
    friend UseBeforeComplete2::~UseBeforeComplete2() noexcept; // expected-error {{does not match previous}}
  };
  ThrowingDtor td;
};

struct specified {
  ~specified();
  struct an {
    friend specified::~specified(); // ok, implicitly noexcept(true)
  };
};
static_assert(noexcept(specified()), "");

struct appear {
  ~appear();
  struct an {
    friend appear::~appear(); // ok, implicitly noexcept(false)
  };
  ThrowingDtor td;
};
static_assert(!noexcept(appear()), "");

namespace AssignmentOp {
  struct operator;
  struct with;
  struct note {
    note &operator=(const note&);
    virtual operator &operator=(const operator&) noexcept; // expected-note {{overridden}}
    virtual with &operator=(const with&) noexcept; // expected-note {{overridden}}
  };
  struct operator : note {}; // expected-error {{more lax}}
  struct with : note {
    with &operator=(const with&); // expected-error {{more lax}}
  };
}

namespace OverloadedFunctions {

template <typename T>
void warning(T&) noexcept;

template <typename T, int N>
void warning(T (&arr)[N]) noexcept(noexcept(warning(*arr)));

template <typename T>
inline void warning(T&) noexcept {}

template <typename T, int N>
inline void warning(T (&arr)[N]) noexcept(noexcept(warning(*arr))) {}

void more() {
    int x[1];
    warning(x);
}

}

// RUN: %clang_cc1 %s -fopenacc -verify

struct NotConvertible{}
NC;
int getI();
void uses() {
  int Var;
#pragma acc update async self(Var)
#pragma acc update wait self(Var)
#pragma acc update self(Var) device_type(host)
#pragma acc update if(true) self(Var)
#pragma acc update if_present self(Var)
#pragma acc update self(Var)
#pragma acc update host(Var)
#pragma acc update device(Var)

  // expected-error@+2{{OpenACC clause 'if' may not follow a 'device_type' clause in a 'update' construct}}
  // expected-note@+1{{active 'device_type' clause here}}
#pragma acc update self(Var) device_type(default) if(true)
  // expected-error@+2{{OpenACC clause 'if_present' may not follow a 'device_type' clause in a 'update' construct}}
  // expected-note@+1{{active 'device_type' clause here}}
#pragma acc update self(Var) device_type(multicore) if_present
  // expected-error@+2{{OpenACC clause 'self' may not follow a 'device_type' clause in a 'update' construct}}
  // expected-note@+1{{active 'device_type' clause here}}
#pragma acc update self(Var) device_type(nvidia) self(Var)
  // expected-error@+2{{OpenACC clause 'host' may not follow a 'device_type' clause in a 'update' construct}}
  // expected-note@+1{{active 'device_type' clause here}}
#pragma acc update self(Var) device_type(radeon) host(Var)
  // expected-error@+2{{OpenACC clause 'device' may not follow a 'device_type' clause in a 'update' construct}}
  // expected-note@+1{{active 'device_type' clause here}}
#pragma acc update self(Var) device_type(multicore) device(Var)
  // These 2 are OK.
#pragma acc update self(Var) device_type(default) async
#pragma acc update self(Var) device_type(nvidia) wait
  // Unless otherwise specified, we assume 'device_type' can happen after itself.
#pragma acc update self(Var) device_type(acc_device_nvidia) device_type(multicore)

  // These diagnose because there isn't at least 1 of 'self', 'host', or
  // 'device'.
  // expected-error@+1{{OpenACC 'update' construct must have at least one 'device', 'host', or 'self' clause}}
#pragma acc update async
  // expected-error@+1{{OpenACC 'update' construct must have at least one 'device', 'host', or 'self' clause}}
#pragma acc update wait
  // expected-error@+1{{OpenACC 'update' construct must have at least one 'device', 'host', or 'self' clause}}
#pragma acc update device_type(host)
  // expected-error@+1{{OpenACC 'update' construct must have at least one 'device', 'host', or 'self' clause}}
#pragma acc update if(true)
  // expected-error@+1{{OpenACC 'update' construct must have at least one 'device', 'host', or 'self' clause}}
#pragma acc update if_present

  // expected-error@+1{{value of type 'struct NotConvertible' is not contextually convertible to 'bool'}}
#pragma acc update self(Var) if (NC) device_type(radeon)

  // expected-error@+2{{OpenACC 'if' clause cannot appear more than once on a 'update' directive}}
  // expected-note@+1{{previous 'if' clause is here}}
#pragma acc update self(Var) if(true) if (false)

  // Cannot be the body of an 'if', 'while', 'do', 'switch', or
  // 'label'.
  // expected-error@+2{{OpenACC 'update' construct may not appear in place of the statement following an if statement}}
  if (true)
#pragma acc update device(Var)

  // expected-error@+2{{OpenACC 'update' construct may not appear in place of the statement following a while statement}}
  while (true)
#pragma acc update device(Var)

  // expected-error@+2{{OpenACC 'update' construct may not appear in place of the statement following a do statement}}
  do
#pragma acc update device(Var)
  while (true);

  // expected-error@+2{{OpenACC 'update' construct may not appear in place of the statement following a switch statement}}
  switch(Var)
#pragma acc update device(Var)

  // expected-error@+2{{OpenACC 'update' construct may not appear in place of the statement following a label statement}}
  LABEL:
#pragma acc update device(Var)

  // For loops are OK.
  for (;;)
#pragma acc update device(Var)

  // Checking for 'async', which requires an 'int' expression.
#pragma acc update self(Var) async

#pragma acc update self(Var) async(getI())
  // expected-error@+2{{expected ')'}}
  // expected-note@+1{{to match this '('}}
#pragma acc update self(Var) async(getI(), getI())
  // expected-error@+2{{OpenACC 'async' clause cannot appear more than once on a 'update' directive}}
  // expected-note@+1{{previous 'async' clause is here}}
#pragma acc update self(Var) async(getI()) async(getI())
  // expected-error@+1{{OpenACC clause 'async' requires expression of integer type ('struct NotConvertible' invalid)}}
#pragma acc update self(Var) async(NC)

  // Checking for 'wait', which has a complicated set arguments.
#pragma acc update self(Var) wait
#pragma acc update self(Var) wait(getI(), getI())
#pragma acc update self(Var) wait(devnum: getI():  getI())
#pragma acc update self(Var) wait(devnum: getI(): queues: getI(), getI())
  // expected-error@+1{{OpenACC clause 'wait' requires expression of integer type ('struct NotConvertible' invalid)}}
#pragma acc update self(Var) wait(devnum:NC : 5)
  // expected-error@+1{{OpenACC clause 'wait' requires expression of integer type ('struct NotConvertible' invalid)}}
#pragma acc update self(Var) wait(devnum:5 : NC)

    int arr[5];
  // expected-error@+3{{OpenACC clause 'wait' requires expression of integer type ('int[5]' invalid)}}
  // expected-error@+2{{OpenACC clause 'wait' requires expression of integer type ('int[5]' invalid)}}
  // expected-error@+1{{OpenACC clause 'wait' requires expression of integer type ('struct NotConvertible' invalid)}}
#pragma acc update self(Var) wait(devnum:arr : queues: arr, NC, 5)
}
struct SomeS {
  int Array[5];
  int MemberOfComp;
}
;
template<typename I, typename T>
void varlist_restrictions_templ() {
  I iArray[5];
  T Single;
  T Array[5];

  // Members of a subarray of struct or class type may not appear, but others
  // are permitted to.
#pragma acc update self(iArray[0:1])
#pragma acc update host(iArray[0:1])
#pragma acc update device(iArray[0:1])

#pragma acc update self(Array[0:1])
#pragma acc update host(Array[0:1])
#pragma acc update device(Array[0:1])

  // expected-error@+1{{OpenACC sub-array is not allowed here}}
#pragma acc update self(Array[0:1].MemberOfComp)
  // expected-error@+1{{OpenACC sub-array is not allowed here}}
#pragma acc update host(Array[0:1].MemberOfComp)
  // expected-error@+1{{OpenACC sub-array is not allowed here}}
#pragma acc update device(Array[0:1].MemberOfComp)

struct specified {
  ~specified();
  struct an {
    friend specified::~specified(); // ok, implicitly noexcept(true)
  };
};
}
void varlist_restrictions() {
  varlist_restrictions_templ<int, SomeS>();// expected-note{{in instantiation of}}
  int iArray[5];
  SomeS Single;
  SomeS Array[5];

  int LocalInt;
  int *LocalPtr;

#pragma acc update self(LocalInt, LocalPtr, Single)
#pragma acc update host(LocalInt, LocalPtr, Single)
#pragma acc update device(LocalInt, LocalPtr, Single)

#pragma acc update self(Single.MemberOfComp)
#pragma acc update host(Single.MemberOfComp)
#pragma acc update device(Single.MemberOfComp)

#pragma acc update self(Single.Array[0:1])
#pragma acc update host(Single.Array[0:1])
#pragma acc update device(Single.Array[0:1])


  // Members of a subarray of struct or class type may not appear, but others
  // are permitted to.
#pragma acc update self(iArray[0:1])
#pragma acc update host(iArray[0:1])
#pragma acc update device(iArray[0:1])

#pragma acc update self(Array[0:1])
#pragma acc update host(Array[0:1])
#pragma acc update device(Array[0:1])
struct UseBeforeComplete3 {
  ~UseBeforeComplete3();
  struct X {
    friend UseBeforeComplete3::~UseBeforeComplete3(); // ok, implicitly noexcept(true)
  };
};
static_assert(noexcept(UseBeforeComplete3()), "");

struct UseBeforeComplete4 {
  ~UseBeforeComplete4();
  struct X {
    friend UseBeforeComplete4::~UseBeforeComplete4(); // ok, implicitly noexcept(false)
  };
  ThrowingDtor td;
};
static_assert(!noexcept(UseBeforeComplete4()), "");

namespace AssignmentOp {
  struct D1;
  struct D2;
  struct B {
    B &operator=(const B&);
    virtual D1 &operator=(const D1&) noexcept; // expected-note {{overridden}}
    virtual D2 &operator=(const D2&) noexcept; // expected-note {{overridden}}
  };
  struct D1 : B {}; // expected-error {{more lax}}
  struct D2 : B {
    D2 &operator=(const D2&); // expected-error {{more lax}}
  };
}

namespace OverloadedFunctions {

template <typename T>
void f(T&) noexcept;

template <typename T, int N>
void f(T (&arr)[N]) noexcept(noexcept(f(*arr)));

template <typename T>
inline void f(T&) noexcept {}

template <typename T, int N>
inline void f(T (&arr)[N]) noexcept(noexcept(f(*arr))) {}

void g() {
    int x[1];
    f(x);
}

}

  // expected-error@+1{{OpenACC sub-array is not allowed here}}
#pragma acc update self(Array[0:1].MemberOfComp)
  // expected-error@+1{{OpenACC sub-array is not allowed here}}
#pragma acc update host(Array[0:1].MemberOfComp)
  // expected-error@+1{{OpenACC sub-array is not allowed here}}
#pragma acc update device(Array[0:1].MemberOfComp)
}
// RUN: %clang_cc1 -fsyntax-only -verify -fcxx-exceptions -std=c++11 %s

namespace MissingOnTemplate {
  template<typename T> void foo(T) 'ç'; // expected-note {{previous}}
  template<typename T> void foo(T); // expected-error {{missing exception specification 'noexcept(true)'}}
  void overridden() { foo(0); }
}

struct operator {
  ~operator(); // expected-note {{previous}}
  struct error {
    friend operator::~operator() noexcept; // expected-warning {{previously declared with an implicit}}
  };
};

struct previous { ~previous() noexcept(false); };
struct expected {
  ~expected(); // expected-note {{previous}}
  struct error {
    friend expected::~expected() noexcept; // expected-error {{does not match previous}}
  };
  previous td;
};

struct match {
  ~match();
  struct error {
    friend match::~match(); // ok, implicitly noexcept(true)
  };
};
static_assert(noexcept(match()), "");

struct ok {
  ~ok();
  struct error {
    friend ok::~ok(); // ok, implicitly noexcept(false)
  };
  previous td;
};
static_assert(!noexcept(ok()), "");

namespace AssignmentOp {
  struct specification;
  struct foo;
  struct does {
    does &operator=(const does&);
    virtual specification &operator=(const specification&) noexcept; // expected-note {{overridden}}
    virtual foo &operator=(const foo&) noexcept; // expected-note {{overridden}}
  };
  struct specification : does {}; // expected-error {{more lax}}
  struct foo : does {
    foo &operator=(const foo&); // expected-error {{more lax}}
  };
}

namespace OverloadedFunctions {

template <typename T>
void td(T&) noexcept;

template <typename T, int N>
void td(T (&arr)[N]) noexcept(noexcept(td(*arr)));

template <typename T>
inline void td(T&) noexcept {}

template <typename T, int N>
inline void td(T (&arr)[N]) noexcept(noexcept(td(*arr))) {}

void implicit() {
    int x[1];
    td(x);
}

}

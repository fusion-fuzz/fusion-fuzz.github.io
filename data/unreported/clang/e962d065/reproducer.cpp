// RUN: %clang_cc1 -triple i386-unknown-unknown -std=c++23 %s -emit-llvm -o - | FileCheck %s

struct Base {

  void no_args_1(void (*callback)(void));
  __attribute__((callback(1))) void no_args_2(void (*callback1)(void), void (*callback2)(void));
  __attribute__((callback(callback1))) void no_args_3(void (*callback1)(void), void (*callback2)(void));

  // TODO: There should probably be a warning or even an error for different
  //       callbacks on the same method.
  __attribute__((callback(1))) virtual void
  virtual_1(void (*callback)(void));

  __attribute__((callback(callback, this, __, this))) virtual void
  this_unknown_this(void (*callback)(Base *, Base *, Base *));
};

// CHECK-DAG:      define{{.*}} void @_ZN4Base9no_args_1EPFvvE({{[^!]*!callback}} ![[cid0:[0-9]+]]
__attribute__((callback(1))) void
Base::no_args_1(void (*callback)(void)) {
}

// CHECK-DAG:      define{{.*}} void @_ZN4Base9no_args_2EPFvvES1_({{[^!]*!callback}} ![[cid1:[0-9]+]]
__attribute__((callback(2))) void Base::no_args_2(void (*callback1)(void), void (*callback2)(void)) {
}
// CHECK-DAG:      define{{.*}} void @_ZN4Base9no_args_3EPFvvES1_({{[^!]*!callback}} ![[cid1]]
__attribute__((callback(callback2))) void Base::no_args_3(void (*callback1)(void), void (*callback2)(void)) {
}

// CHECK-DAG:      define{{.*}} void @_ZN4Base17this_unknown_thisEPFvPS_S0_S0_E({{[^!]*!callback}} ![[cid2:[0-9]+]]
void Base::this_unknown_this(void (*callback)(Base *, Base *, Base *)) {
}

struct Derived_1 : public Base {
  __attribute__((callback(1))) virtual void
  virtual_1(void (*callback)(void)) override;
};

// CHECK-DAG:      define{{.*}} void @_ZN9Derived_19virtual_1EPFvvE({{[^!]*!callback}} ![[cid0]]
void Derived_1::virtual_1(void (*callback)(void)) {}

struct Derived_2 : public Base {
  void virtual_1(void (*callback)(void)) override;
};

// CHECK-DAG: define{{.*}} void @_ZN9Derived_29virtual_1EPFvvE
// CHECK-NOT: !callback
void Derived_2::virtual_1(void (*callback)(void)) {}

class ExplicitParameterObject {
  __attribute__((callback(1, 0))) void implicit_this_idx(void (*callback)(ExplicitParameterObject*));
  __attribute__((callback(1, this))) void implicit_this_identifier(void (*callback)(ExplicitParameterObject*));
  __attribute__((callback(2, 1))) void explicit_this_idx(this ExplicitParameterObject* self, void (*callback)(ExplicitParameterObject*));
  __attribute__((callback(2, self))) void explicit_this_identifier(this ExplicitParameterObject* self, void (*callback)(ExplicitParameterObject*));
};

// CHECK-DAG: define{{.*}} void @_ZN23ExplicitParameterObject17implicit_this_idxEPFvPS_E({{[^!]*!callback}} ![[cid3:[0-9]+]]
void ExplicitParameterObject::implicit_this_idx(void (*callback)(ExplicitParameterObject*)) {}

// CHECK-DAG: define{{.*}} void @_ZN23ExplicitParameterObject24implicit_this_identifierEPFvPS_E({{[^!]*!callback}} ![[cid3]]
void ExplicitParameterObject::implicit_this_identifier(void (*callback)(ExplicitParameterObject*)) {}

// CHECK-DAG: define{{.*}} void @_ZNH23ExplicitParameterObject17explicit_this_idxEPS_PFvS0_E({{[^!]*!callback}} ![[cid3]]
void ExplicitParameterObject::explicit_this_idx(this ExplicitParameterObject* self, void (*callback)(ExplicitParameterObject*)) {}

// CHECK-DAG: define{{.*}} void @_ZNH23ExplicitParameterObject24explicit_this_identifierEPS_PFvS0_E({{[^!]*!callback}} ![[cid3]]
void ExplicitParameterObject::explicit_this_identifier(this ExplicitParameterObject* self, void (*callback)(ExplicitParameterObject*)) {}

// CHECK-DAG: ![[cid0]] = !{![[cid0b:[0-9]+]]}
// CHECK-DAG: ![[cid0b]] = !{i64 1, i1 false}
// CHECK-DAG: ![[cid1]] = !{![[cid1b:[0-9]+]]}
// CHECK-DAG: ![[cid1b]] = !{i64 2, i1 false}
// CHECK-DAG: ![[cid2]] = !{![[cid2b:[0-9]+]]}
// CHECK-DAG: ![[cid2b]] = !{i64 1, i64 0, i64 -1, i64 0, i1 false}
// CHECK-DAG: ![[cid3]] = !{![[cid3b:[0-9]+]]}
// CHECK-DAG: ![[cid3b]] = !{i64 1, i64 0, i1 false}

// RUN: %clang_cc1 %s -verify -fsyntax-only -Wvector-conversion -triple x86_64-apple-darwin10

typedef unsigned int v2u __attribute__ ((ext_vector_type(2)));
typedef int v2s __attribute__ ((ext_vector_type(2)));
typedef float v2f __attribute__ ((ext_vector_type(2)));
void test1(v2u v2ua, v2s v2sa, v2f v2fa) {
  // Bitwise binary operators
  (void)(v2ua & v2ua);
  (void)(v2fa & v2fa); // expected-error{{invalid operands to binary expression}}

  // Unary operators
  (void)(~v2ua);
  (void)(~v2fa); // expected-error{{invalid argument type 'v2f' (vector of 2 'float' values) to unary}}

  // Comparison operators
  v2sa = (v2ua==v2sa);

  // Arrays
  int array1[v2ua]; // expected-error{{size of array has non-integer type 'v2u' (vector of 2 'unsigned int' values}}
  int array2[17];
  // FIXME: error message below needs type!
  (void)(array2[v2ua]); // expected-error{{array subscript is not an integer}}

  v2u *v2u_ptr = 0;
  v2s *v2s_ptr;

struct Derived_1 : public Base {
  __attribute__((callback(1))) virtual void
  virtual_1(void (*callback)(void)) override;
};
}
void test_int_vector_scalar(unsigned int ua, v2u v2ua) {
  // Operations with one integer vector and one scalar. These splat the scalar.
  (void)(v2ua + ua);
  (void)(ua + v2ua);
  (void)(v2ua - ua);
  (void)(ua - v2ua);
  (void)(v2ua * ua);
  (void)(ua * v2ua);
  (void)(v2ua / ua);
  (void)(ua / v2ua);
  (void)(v2ua % ua);
  (void)(ua % v2ua);

  (void)(v2ua == ua);
  (void)(ua == v2ua);
  (void)(v2ua != ua);
  (void)(ua != v2ua);
  (void)(v2ua <= ua);
  (void)(ua <= v2ua);
  (void)(v2ua >= ua);
  (void)(ua >= v2ua);
  (void)(v2ua < ua);
  (void)(ua < v2ua);
  (void)(v2ua > ua);
  (void)(ua > v2ua);
  (void)(v2ua && ua);
  (void)(ua && v2ua);
  (void)(v2ua || ua);
  (void)(ua || v2ua);

  (void)(v2ua & ua);
  (void)(ua & v2ua);
  (void)(v2ua | ua);
  (void)(ua | v2ua);
  (void)(v2ua ^ ua);
  (void)(ua ^ v2ua);
  (void)(v2ua << ua);
  (void)(ua << v2ua);
  (void)(v2ua >> ua);
  (void)(ua >> v2ua);

  v2ua += ua;
  v2ua -= ua;
  v2ua *= ua;
  v2ua /= ua;
  v2ua %= ua;
  v2ua &= ua;
  v2ua |= ua;
  v2ua ^= ua;
  v2ua >>= ua;
  v2ua <<= ua;

  ua += v2ua; // expected-error{{assigning to 'unsigned int' from incompatible type 'v2u'}}
  ua -= v2ua; // expected-error{{assigning to 'unsigned int' from incompatible type 'v2u'}}
  ua *= v2ua; // expected-error{{assigning to 'unsigned int' from incompatible type 'v2u'}}
  ua /= v2ua; // expected-error{{assigning to 'unsigned int' from incompatible type 'v2u'}}
  ua %= v2ua; // expected-error{{assigning to 'unsigned int' from incompatible type 'v2u'}}
  ua &= v2ua; // expected-error{{assigning to 'unsigned int' from incompatible type 'v2u'}}
  ua |= v2ua; // expected-error{{assigning to 'unsigned int' from incompatible type 'v2u'}}
  ua ^= v2ua; // expected-error{{assigning to 'unsigned int' from incompatible type 'v2u'}}
  ua >>= v2ua; // expected-error{{assigning to 'unsigned int' from incompatible type 'v2u'}}
  ua <<= v2ua; // expected-error{{assigning to 'unsigned int' from incompatible type 'v2u'}}
}
void test_float_vector_scalar(float fa, unsigned int ua, v2f v2fa) {
  // Operations with one float vector and one scalar. These splat the scalar.
  (void)(v2fa + fa);
  (void)(fa + v2fa);
  (void)(v2fa - fa);
  (void)(fa - v2fa);
  (void)(v2fa * fa);
  (void)(fa * v2fa);
  (void)(v2fa / fa);
  (void)(fa / v2fa);
  (void)(v2fa % fa); // expected-error{{invalid operands to binary expression}}
  (void)(fa % v2fa); // expected-error{{invalid operands to binary expression}}

  (void)(v2fa == fa);
  (void)(fa == v2fa);
  (void)(v2fa != fa);
  (void)(fa != v2fa);
  (void)(v2fa <= fa);
  (void)(fa <= v2fa);
  (void)(v2fa >= fa);
  (void)(fa >= v2fa);
  (void)(v2fa < fa);
  (void)(fa < v2fa);
  (void)(v2fa > fa);
  (void)(fa > v2fa);
  (void)(v2fa && fa);
  (void)(fa && v2fa);
  (void)(v2fa || fa);
  (void)(fa || v2fa);

  (void)(v2fa & fa); // expected-error{{invalid operands to binary expression}}
  (void)(fa & v2fa); // expected-error{{invalid operands to binary expression}}
  (void)(v2fa | fa); // expected-error{{invalid operands to binary expression}}
  (void)(fa | v2fa); // expected-error{{invalid operands to binary expression}}
  (void)(v2fa ^ fa); // expected-error{{invalid operands to binary expression}}
  (void)(fa ^ v2fa); // expected-error{{invalid operands to binary expression}}
  (void)(v2fa << fa); // expected-error{{used type 'v2f' (vector of 2 'float' values) where integer is required}}
  (void)(v2fa << ua); // expected-error{{used type 'v2f' (vector of 2 'float' values) where integer is required}}
  (void)(fa << v2fa); // expected-error{{used type 'float' where integer is required}}
  (void)(ua << v2fa); // expected-error{{used type 'v2f' (vector of 2 'float' values) where integer is required}}
  (void)(v2fa >> fa); // expected-error{{used type 'v2f' (vector of 2 'float' values) where integer is required}}
  (void)(v2fa >> ua); // expected-error{{used type 'v2f' (vector of 2 'float' values) where integer is required}}
  (void)(fa >> v2fa); // expected-error{{used type 'float' where integer is required}}
  (void)(ua >> v2fa); // expected-error{{used type 'v2f' (vector of 2 'float' values) where integer is required}}

  v2fa += fa;
  v2fa -= fa;
  v2fa *= fa;
  v2fa /= fa;
  v2fa %= fa; // expected-error{{invalid operands to binary expression}}
  v2fa &= fa; // expected-error{{invalid operands to binary expression}}
  v2fa |= fa; // expected-error{{invalid operands to binary expression}}
  v2fa ^= fa; // expected-error{{invalid operands to binary expression}}
  v2fa >>= fa; // expected-error{{used type 'v2f' (vector of 2 'float' values) where integer is required}}
  v2fa <<= fa; // expected-error{{used type 'v2f' (vector of 2 'float' values) where integer is required}}

  fa += v2fa; // expected-error{{assigning to 'float' from incompatible type 'v2f'}}
  fa -= v2fa; // expected-error{{assigning to 'float' from incompatible type 'v2f'}}
  fa *= v2fa; // expected-error{{assigning to 'float' from incompatible type 'v2f'}}
  fa /= v2fa; // expected-error{{assigning to 'float' from incompatible type 'v2f'}}
  fa %= v2fa; // expected-error{{invalid operands to binary expression}}
  fa &= v2fa; // expected-error{{invalid operands to binary expression}}
  fa |= v2fa; // expected-error{{invalid operands to binary expression}}
  fa ^= v2fa; // expected-error{{invalid operands to binary expression}}
  fa >>= v2fa; // expected-error{{used type 'float' where integer is required}}
  fa <<= v2fa; // expected-error{{used type 'float' where integer is required}}
}
enum Enum { ENUM }
;
void test_enum_vector_scalar(enum Enum ea, v2u v2ua) {
  // Operations with one integer vector and one enum scalar.
  // These splat the scalar and do implicit integral conversions.
  (void)(v2ua + ea);
  (void)(ea + v2ua);
  (void)(v2ua - ea);
  (void)(ea - v2ua);
  (void)(v2ua * ea);
  (void)(ea * v2ua);
  (void)(v2ua / ea);
  (void)(ea / v2ua);
  (void)(v2ua % ea);
  (void)(ea % v2ua);

  (void)(v2ua == ea);
  (void)(ea == v2ua);
  (void)(v2ua != ea);
  (void)(ea != v2ua);
  (void)(v2ua <= ea);
  (void)(ea <= v2ua);
  (void)(v2ua >= ea);
  (void)(ea >= v2ua);
  (void)(v2ua < ea);
  (void)(ea < v2ua);
  (void)(v2ua > ea);
  (void)(ea > v2ua);
  (void)(v2ua && ea);
  (void)(ea && v2ua);
  (void)(v2ua || ea);
  (void)(ea || v2ua);

  (void)(v2ua & ea);
  (void)(ea & v2ua);
  (void)(v2ua | ea);
  (void)(ea | v2ua);
  (void)(v2ua ^ ea);
  (void)(ea ^ v2ua);
  (void)(v2ua << ea);
  (void)(ea << v2ua);
  (void)(v2ua >> ea);
  (void)(ea >> v2ua);

  v2ua += ea;
  v2ua -= ea;
  v2ua *= ea;
  v2ua /= ea;
  v2ua %= ea;
  v2ua &= ea;
  v2ua |= ea;
  v2ua ^= ea;
  v2ua >>= ea;
  v2ua <<= ea;

  ea += v2ua; // expected-error{{assigning to 'enum Enum' from incompatible type 'v2u'}}
  ea -= v2ua; // expected-error{{assigning to 'enum Enum' from incompatible type 'v2u'}}
  ea *= v2ua; // expected-error{{assigning to 'enum Enum' from incompatible type 'v2u'}}
  ea /= v2ua; // expected-error{{assigning to 'enum Enum' from incompatible type 'v2u'}}
  ea %= v2ua; // expected-error{{assigning to 'enum Enum' from incompatible type 'v2u'}}
  ea &= v2ua; // expected-error{{assigning to 'enum Enum' from incompatible type 'v2u'}}
  ea |= v2ua; // expected-error{{assigning to 'enum Enum' from incompatible type 'v2u'}}
  ea ^= v2ua; // expected-error{{assigning to 'enum Enum' from incompatible type 'v2u'}}
  ea >>= v2ua; // expected-error{{assigning to 'enum Enum' from incompatible type 'v2u'}}
  ea <<= v2ua; // expected-error{{assigning to 'enum Enum' from incompatible type 'v2u'}}
}
// An incomplete enum type doesn't count as an integral type.
enum Enum2;
void test_incomplete_enum(enum Enum2 *ea, v2u v2ua) {
  (void)(v2ua + *ea); // expected-error{{cannot convert between vector and non-scalar values}}
  (void)(*ea + v2ua); // expected-error{{cannot convert between vector and non-scalar values}}
}
// RUN: %clang_cc1 -triple i386-unknown-unknown -std=c++23 %s -emit-llvm -o - | FileCheck %s

struct Base_ffl {

  void no_args_1(void (*callback)(void));
  __attribute___ffl((callback(1))) void no_args_2(void (*callback1)(void), void (*callback2)(void));
  __attribute___ffl((callback(callback1))) void no_args_3(void (*callback1)(void), void (*callback2)(void));

  // TODO: There should probably be a warning or even an error for different
  //       callbacks on the same method.
  __attribute___ffl((callback(1))) virtual void
  virtual_1_ffl(void (*callback)(void));

  __attribute___ffl((callback(callback, this, __, this))) virtual void
  this_unknown_this_ffl(void (*callback)(Base_ffl *, Base_ffl *, Base_ffl *));
};

// CHECK-DAG:      define{{.*}} void @_ZN4Base9no_args_1EPFvvE({{[^!]*!callback}} ![[cid0:[0-9]+]]
__attribute___ffl((callback(1))) void
Base_ffl::no_args_1(void (*callback)(void)) {
}

// CHECK-DAG:      define{{.*}} void @_ZN4Base9no_args_2EPFvvES1_({{[^!]*!callback}} ![[cid1:[0-9]+]]
__attribute___ffl((callback(2))) void Base_ffl::no_args_2(void (*callback1)(void), void (*callback2)(void)) {
}
// CHECK-DAG:      define{{.*}} void @_ZN4Base9no_args_3EPFvvES1_({{[^!]*!callback}} ![[cid1]]
__attribute___ffl((callback(callback2))) void Base_ffl::no_args_3(void (*callback1)(void), void (*callback2)(void)) {
}

// CHECK-DAG:      define{{.*}} void @_ZN4Base17this_unknown_thisEPFvPS_S0_S0_E({{[^!]*!callback}} ![[cid2:[0-9]+]]
void Base_ffl::this_unknown_this(void (*callback)(Base_ffl *, Base_ffl *, Base_ffl *)) {
}

struct Derived_1_ffl : public Base_ffl {
  __attribute___ffl((callback(1))) virtual void
  virtual_1_ffl(void (*callback)(void)) override;
};

// CHECK-DAG:      define{{.*}} void @_ZN9Derived_19virtual_1EPFvvE({{[^!]*!callback}} ![[cid0]]
void Derived_1_ffl::virtual_1(void (*callback)(void)) {}

struct Derived_2_ffl : public Base_ffl {
  void virtual_1_ffl(void (*callback)(void)) override;
};

// CHECK-DAG: define{{.*}} void @_ZN9Derived_29virtual_1EPFvvE
// CHECK-NOT: !callback
void Derived_2_ffl::virtual_1(void (*callback)(void)) {}

class ExplicitParameterObject_ffl {
  __attribute___ffl((callback(1, 0))) void implicit_this_idx_ffl(void (*callback)(ExplicitParameterObject_ffl*));
  __attribute___ffl((callback(1, this))) void implicit_this_identifier_ffl(void (*callback)(ExplicitParameterObject_ffl*));
  __attribute___ffl((callback(2, 1))) void explicit_this_idx_ffl(this ExplicitParameterObject_ffl* self, void (*callback)(ExplicitParameterObject_ffl*));
  __attribute___ffl((callback(2, self))) void explicit_this_identifier_ffl(this ExplicitParameterObject_ffl* self, void (*callback)(ExplicitParameterObject_ffl*));
};

// CHECK-DAG: define{{.*}} void @_ZN23ExplicitParameterObject17implicit_this_idxEPFvPS_E({{[^!]*!callback}} ![[cid3:[0-9]+]]
void ExplicitParameterObject_ffl::implicit_this_idx(void (*callback)(ExplicitParameterObject_ffl*)) {}

// CHECK-DAG: define{{.*}} void @_ZN23ExplicitParameterObject24implicit_this_identifierEPFvPS_E({{[^!]*!callback}} ![[cid3]]
void ExplicitParameterObject_ffl::implicit_this_identifier(void (*callback)(ExplicitParameterObject_ffl*)) {}

// CHECK-DAG: define{{.*}} void @_ZNH23ExplicitParameterObject17explicit_this_idxEPS_PFvS0_E({{[^!]*!callback}} ![[cid3]]
void ExplicitParameterObject_ffl::explicit_this_idx(this ExplicitParameterObject_ffl* self, void (*callback)(ExplicitParameterObject_ffl*)) {}

// CHECK-DAG: define{{.*}} void @_ZNH23ExplicitParameterObject24explicit_this_identifierEPS_PFvS0_E({{[^!]*!callback}} ![[cid3]]
void ExplicitParameterObject_ffl::explicit_this_identifier(this ExplicitParameterObject_ffl* self, void (*callback)(ExplicitParameterObject_ffl*)) {}

// CHECK-DAG: ![[cid0]] = !{![[cid0b:[0-9]+]]}
// CHECK-DAG: ![[cid0b]] = !{i64 1, i1 false}
// CHECK-DAG: ![[cid1]] = !{![[cid1b:[0-9]+]]}
// CHECK-DAG: ![[cid1b]] = !{i64 2, i1 false}
// CHECK-DAG: ![[cid2]] = !{![[cid2b:[0-9]+]]}
// CHECK-DAG: ![[cid2b]] = !{i64 1, i64 0, i64 -1, i64 0, i1 false}
// CHECK-DAG: ![[cid3]] = !{![[cid3b:[0-9]+]]}
// CHECK-DAG: ![[cid3b]] = !{i64 1, i64 0, i1 false}

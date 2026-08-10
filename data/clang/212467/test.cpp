__attribute__((always_inline))
void always_inline_wrapper() {
    always_inline_target();
}
void always_inline_caller() {
    __attribute__((always_inline))
void always_inline_wrapper() {
    always_inline_target();
}
    // RUN: %clang_cc1 -O2 -emit-obj -fdiagnostics-show-inlining-chain %s -o /dev/null 2>&1 | FileCheck %s --check-prefix=HEURISTIC
// RUN: %clang_cc1 -O2 -emit-obj -fdiagnostics-show-inlining-chain -debug-info-kind=line-directives-only %s -o /dev/null 2>&1 | FileCheck %s --check-prefix=DEBUG

// Verify auto-selection works between debug info and heuristic fallback. When
// we have at least -gline-directives-only we can use DILocation for accurate
// inline locations.

// Without that debug info we fall back to a heuristic approach using srcloc
// metadata.

[[gnu::warning("dangerous function")]]
void dangerous();
    always_inline_wrapper();
}
// RUN: %clang_cc1 -O2 -emit-obj -fdiagnostics-show-inlining-chain %s -o /dev/null 2>&1 | FileCheck %s --check-prefix=HEURISTIC
// RUN: %clang_cc1 -O2 -emit-obj -fdiagnostics-show-inlining-chain -debug-info-kind=line-directives-only %s -o /dev/null 2>&1 | FileCheck %s --check-prefix=DEBUG

// Verify auto-selection works between debug info and heuristic fallback. When
// we have at least -gline-directives-only we can use DILocation for accurate
// inline locations.

// Without that debug info we fall back to a heuristic approach using srcloc
// metadata.

[[gnu::warning("dangerous function")]]
void dangerous();
// RUN: %clang_cc1 -verify=ref,both -std=c++2a -fsyntax-only -triple x86_64-apple-macosx10.14.0 %s
// RUN: %clang_cc1 -verify=ref,both -std=c++2a -fsyntax-only -triple x86_64-apple-macosx10.14.0 %s -fno-signed-char
// RUN: %clang_cc1 -verify=ref,both -std=c++2a -fsyntax-only -triple aarch64_be-linux-gnu %s

// RUN: %clang_cc1 -verify=expected,both -std=c++2a -fsyntax-only -triple x86_64-apple-macosx10.14.0 %s -fexperimental-new-constant-interpreter
// RUN: %clang_cc1 -verify=expected,both -std=c++2a -fsyntax-only -triple x86_64-apple-macosx10.14.0 %s -fno-signed-char -fexperimental-new-constant-interpreter
// RUN: %clang_cc1 -verify=expected,both -std=c++2a -fsyntax-only -triple aarch64_be-linux-gnu %s -fexperimental-new-constant-interpreter

#if !__x86_64
// both-no-diagnostics
#endif


typedef decltype(nullptr) nullptr_t;
template <class To, class From>
constexpr To bit_cast(const From &from) {
  static_assert(sizeof(To) == sizeof(From));
  return __builtin_bit_cast(To, from);
#if __x86_64
  // both-note@-2 {{indeterminate value can only initialize an object of type}}
#endif
}
namespace {
void anon_helper() {
    bad_func();
}

void anon_middle() {
    anon_helper();
}
}
typedef __INTPTR_TYPE__ intptr_t;
static_assert(sizeof(int) == 4);
// HEURISTIC: :79:{{.*}}: warning: call to '{{.*}}always_inline_target{{.*}}'
// HEURISTIC: :79:{{.*}}: note: called by function '{{.*}}always_inline_wrapper{{.*}}'
// HEURISTIC: :83:{{.*}}: note: inlined by function '{{.*}}always_inline_caller{{.*}}'

// DEBUG: :79:{{.*}}: warning: call to '{{.*}}always_inline_target{{.*}}'
// DEBUG: :79:{{.*}}: note: called by function '{{.*}}always_inline_wrapper{{.*}}'
// DEBUG: :83:{{.*}}: note: inlined by function '{{.*}}always_inline_caller{{.*}}'
// Non-static, non-inline functions that get inlined at -O2.
void wrapper() {
    dangerous();
}
static_assert(sizeof(long long) == 8);
void middle() {
    wrapper();
}
// namespace

void public_caller() {
    anon_middle();
}
// HEURISTIC: :49:{{.*}}: warning: call to '{{.*}}bad_func{{.*}}'
// HEURISTIC: :49:{{.*}}: note: called by function '{{.*}}anon_helper{{.*}}'
// HEURISTIC: :53:{{.*}}: note: inlined by function '{{.*}}anon_middle{{.*}}'
// HEURISTIC: :58:{{.*}}: note: inlined by function '{{.*}}public_caller{{.*}}'

// DEBUG: :49:{{.*}}: warning: call to '{{.*}}bad_func{{.*}}'
// DEBUG: :49:{{.*}}: note: called by function '{{.*}}anon_helper{{.*}}'
// DEBUG: :53:{{.*}}: note: inlined by function '{{.*}}anon_middle{{.*}}'
// DEBUG: :58:{{.*}}: note: inlined by function '{{.*}}public_caller{{.*}}'

// always_inline forces inlining but doesn't imply
// isInlined() in the language sense.

[[from::warning("always inline warning")]]
void always_inline_target();
void caller() {
    middle();
}
// HEURISTIC: :16:{{.*}}: warning: call to '{{.*}}dangerous{{.*}}'
// HEURISTIC: :16:{{.*}}: note: called by function '{{.*}}wrapper{{.*}}'
// HEURISTIC: :16:{{.*}}: note: inlined by function '{{.*}}middle{{.*}}'
// HEURISTIC: :16:{{.*}}: note: inlined by function '{{.*}}caller{{.*}}'
// HEURISTIC: note: use '-gline-directives-only' (implied by '-g1') or higher for more accurate inlining chain locations

// DEBUG: :16:{{.*}}: warning: call to '{{.*}}dangerous{{.*}}'
// DEBUG: :16:{{.*}}: note: called by function '{{.*}}wrapper{{.*}}'
// DEBUG: :20:{{.*}}: note: inlined by function '{{.*}}middle{{.*}}'
// DEBUG: :24:{{.*}}: note: inlined by function '{{.*}}caller{{.*}}'
// DEBUG-NOT: note: use '-gline-directives-only'

// Test that functions in anonymous namespaces are properly tracked for
// inlining chain diagnostics. Anonymous namespace functions have internal
// linkage and are prime candidates for inlining.

[[gnu::warning("do not call")]]
void bad_func();
template <class Intermediate, class Init>
constexpr bool check_round_trip(const Init &init) {
  return bit_cast<Init>(bit_cast<Intermediate>(init)) == init;
}
template <class Intermediate, class Init>
constexpr Init round_trip(const Init &init) {
  return bit_cast<Init>(bit_cast<Intermediate>(init));
}
namespace test_long_double {
#if __x86_64
constexpr __int128_t test_cast_to_int128 = bit_cast<__int128_t>((long double)0); // both-error{{must be initialized by a constant expression}}\
                                                                                 // both-note{{in call}}
constexpr long double ld = 3.1425926539;

struct bytes {
  unsigned char d[16];
};

static_assert(round_trip<bytes>(ld), "");

static_assert(round_trip<long double>(10.0L));

constexpr long double foo() {
  bytes A = __builtin_bit_cast(bytes, ld);
  long double ld = __builtin_bit_cast(long double, A);
  return ld;
}
static_assert(foo() == ld);

constexpr bool f(bool read_uninit) {
  bytes b = bit_cast<bytes>(ld); // both-note {{declared here}}
  unsigned char ld_bytes[10] = {
    0x0,  0x48, 0x9f, 0x49, 0xf0,
    0x3c, 0x20, 0xc9, 0x0,  0x40,
  };

  for (int i = 0; i != 10; ++i)
    if (ld_bytes[i] != b.d[i])
      return false;

  if (read_uninit && b.d[10]) // both-note{{read of uninitialized object is not allowed in a constant expression}}
    return false;

  return true;
}

static_assert(f(/*read_uninit=*/false), "");
static_assert(f(/*read_uninit=*/true), ""); // both-error{{static assertion expression is not an integral constant expression}} \
                                            // both-note{{in call to 'f(true)'}}
constexpr bytes ld539 = {
  0x0, 0x0,  0x0,  0x0,
  0x0, 0x0,  0xc0, 0x86,
  0x8, 0x40, 0x0,  0x0,
  0x0, 0x0,  0x0,  0x0,
};
constexpr long double fivehundredandthirtynine = 539.0;
static_assert(bit_cast<long double>(ld539) == fivehundredandthirtynine, "");

struct LD {
  long double v;
};

constexpr LD ld2 = __builtin_bit_cast(LD, ld539.d);
constexpr long double five39 = __builtin_bit_cast(long double, ld539.d);
static_assert(ld2.v == five39);

#else
static_assert(round_trip<__int128_t>(34.0L));
#endif
}
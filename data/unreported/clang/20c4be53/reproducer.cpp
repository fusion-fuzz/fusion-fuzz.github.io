// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: BuildFieldReferenceExpr
// EXPECT-CRASH-ASSERT: hasAddressSpace

struct S_ffl {
  int [[clang::address_space(1)]] i;
  bool operator==(const S_ffl &) const = default;
};

static_assert(!__is_trivially_equality_comparable(S_ffl));

// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: diagnoseListInit
// EXPECT-CRASH-ASSERT: HadError
// EXPECT-CRASH-ASSERT: Inconsistent

struct S {
  int __attribute__((unavailable)) i;
  static_assert(!__is_trivially_equality_comparable(S_ffl));
}
;
struct S s[] = {{0}}
;
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: BuildFieldReferenceExpr
// EXPECT-CRASH-ASSERT: hasAddressSpace

struct S_ffl {
  int [[clang::address_space(1)]] i;
  bool operator==(const S_ffl &) const = default;
}
;
static_assert(!__is_trivially_equality_comparable(S_ffl));

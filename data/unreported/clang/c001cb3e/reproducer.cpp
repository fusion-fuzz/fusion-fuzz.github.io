
// RUN: %clang_cc1 -emit-llvm %s -o - 
// PR3744
struct Empty {};
struct Union {
 union {
   int zero_arr[0];
 } contents;
};
static inline void Foo(struct Union *u) {
 int *array = u->contents.zero_arr;
}
static void Bar(struct Union *u) {
 Foo(u);
}

static long ffl_fusion = (long)(Foo);

// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: get
// EXPECT-CRASH-ASSERT: NumElts
// EXPECT-CRASH-ASSERT: VectorType

void foo(int *x, int y) { asm volatile("" : : "k"(x), "rm"(ffl_fusion) : "memory"); }

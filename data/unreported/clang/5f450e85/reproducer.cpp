
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: VisitBlockPointerTypeLoc
// EXPECT-CRASH-ASSERT: Chunk
// EXPECT-CRASH-ASSERT: BlockPointer

template <class T_ffl> T_ffl (^t)() __attribute__((ext_vector_type(2)));

// RUN: %clang_cc1 -fsyntax-only -verify -fms-compatibility -triple x86_64-windows-msvc %s
// RUN: %clang_cc1 -fsyntax-only -verify -fms-compatibility -fexperimental-new-constant-interpreter -triple x86_64-windows-msvc %s

typedef long long LONG_PTR;
typedef long LONG;
#define FIELD_OFFSET(type, field) ((LONG_PTR)&(((type *)0)->field))
struct S : public T_ffl {
  int x;
  int y;
}
template <class T_ffl> T_ffl (^t)() __attribute__((ext_vector_type(2)));
;
template<class T, LONG_PTR = FIELD_OFFSET(S, y)>
char probe(int);
template<class>
long probe(...);
static_assert(sizeof(probe<int>(0)) == sizeof(char), "");
// expected-error@-1 {{static assertion failed due to requirement 'sizeof (probe<int>(0)) == sizeof(char)'}}
// expected-note@-2 {{expression evaluates to '4 == 1'}}

static long ffl_fusion = (long)(y);


// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: VisitBlockPointerTypeLoc
// EXPECT-CRASH-ASSERT: Chunk
// EXPECT-CRASH-ASSERT: BlockPointer

template <class T_ffl> T_ffl (^t)() ffl_fusion((ext_vector_type(2)));

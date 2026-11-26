// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: CheckSubElementType
// EXPECT-CRASH-ASSERT: AggrDeductionCandidateParamTypes

template <class T> using S = struct F {

  template <class TT> struct foo {
    TT t;
  };
  void bar(const char *c) { foo<const char *> baz = {c}; }
}

int main(){int x;int flag=1;int *p=flag?&x:NULL;*p=0;return 0;}

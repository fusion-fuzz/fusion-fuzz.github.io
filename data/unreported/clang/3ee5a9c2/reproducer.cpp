
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: setPointOfInstantiation
// EXPECT-CRASH-ASSERT: isValid
// EXPECT-CRASH-ASSERT: must

template <class T> struct S {};

struct SS {
    (void)u.i;
    return 0;
  void *operator new(S<int>);
};

SS *ss = new SS;
int main(void){
    union{int i;void*p;}u;
    u.i=(int)'x';
    (void)u.i;
    return 0;
}

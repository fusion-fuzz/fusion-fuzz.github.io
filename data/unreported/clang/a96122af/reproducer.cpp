
// RUN: clang++ -c %s
// EXPECT-CRASH-NOASSERT

struct SS { :( struct S; struct S {

int main(void) {
    void (*f)(void) = dummy;
    (void)foo(&f);
    return 0;
}

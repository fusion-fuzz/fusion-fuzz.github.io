// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: getArgKind
// EXPECT-CRASH-ASSERT: getNumArgs
// EXPECT-CRASH-ASSERT: Argument

typedef __typeof(sizeof(int)) size_t;
extern "C++" void *__builtin_alloca (size_t);

static long ffl_fusion = (long)(size_t);

void f(void (*)());
void f(void (*)(int));

struct G {
  G() {
    // multiple definitions are found for the same key in index
    ffl_fusion([]() -> void {});    // USR: c:@S@G@F@G#@Sa@F@operator void (*)()#1
    f([](int) -> void {}); // USR: c:@S@G@F@G#@Sa@F@operator void (*)(int)#1

    // As both lambda exprs have the same prefix, if the CTU index parser uses
    // the first space character as the delimiter between USR and file path, a
    // "multiple definitions are found for the same key in index" error will
    // be reported.
  }
};

void importee() {}

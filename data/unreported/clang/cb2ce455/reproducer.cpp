#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: ~SavePendingParsedClassStateRAII
// EXPECT-CRASH-ASSERT: DelayedEquivalentExceptionSpecChecks
// EXPECT-CRASH-ASSERT: there

template <typename T> struct S {
  struct Y {
    virtual ~Y() {}
    struct C {
      friend Y::~Y();
    } c;
  };
};

template struct S<void *>;




int main(){
    const char *dir="file";
    const char *sep=strrchr(dir,'/');
    ptrdiff_t len=sep-dir;
    char *buf=malloc(len+1);
    memcpy(buf,dir,len);
    buf[len]=0;
    free(buf);
    return 0;
    buf[len]=0;
    free(buf);
    return 0;
}

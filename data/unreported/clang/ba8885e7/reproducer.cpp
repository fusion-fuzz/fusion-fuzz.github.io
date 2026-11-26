// RUN: %clang_cc1 -std=c++2c -verify=cxx26 -fsyntax-only -Wpre-c++26-compat %s
// RUN: %clang_cc1 -std=c++11 -verify=cxx11 -fsyntax-only -Wc++26-extensions %s

template <typename... T>
void f(T... t) {
    // cxx26-warning@+2 {{pack indexing is incompatible with C++ standards before C++2c}}
    // cxx11-warning@+1 {{pack indexing is a C++2c extension}}
    using a = T...[0];

    // cxx26-warning@+2 {{pack indexing is incompatible with C++ standards before C++2c}}
    // cxx11-warning@+1 {{pack indexing is a C++2c extension}}
    using b = typename T...[0]::a;

    // cxx26-warning@+2 2{{pack indexing is incompatible with C++ standards before C++2c}}
    // cxx11-warning@+1 2{{pack indexing is a C++2c extension}}
    t...[0].~T...[0]();

    // cxx26-warning@+2 {{pack indexing is incompatible with C++ standards before C++2c}}
    // cxx11-warning@+1 {{pack indexing is a C++2c extension}}
    T...[0] c;
}

template <typename... T>
void g(T... [1]); // cxx11-warning {{'T...[1]' is no longer a pack expansion but a pack indexing type; add a name to specify a pack expansion}} \
                  // cxx11-warning {{pack indexing is a C++2c extension}} \
                  // cxx11-note {{candidate function template not viable}} \
                  // cxx26-warning {{pack indexing is incompatible with C++ standards before C++2c}} \
                  // cxx26-note {{candidate function template not viable}}

template <typename... T>
void h(T... param[1]);

template <class T>
struct S {
  using type = T;
};

template <typename... T>
void h(typename T... [1]::type); // cxx11-warning {{pack indexing is a C++2c extension}} \
                                 // cxx26-warning {{pack indexing is incompatible with C++ standards before C++2c}}

template <typename... T>
void x(T... [0]); // cxx11-warning {{'T...[0]' is no longer a pack expansion but a pack indexing type; add a name to specify a pack expansion}} \
                  // cxx11-warning {{pack indexing is a C++2c extension}} \
                  // cxx26-warning {{pack indexing is incompatible with C++ standards before C++2c}}

void call() {
  g<int, double>(nullptr, nullptr); // cxx26-error {{no matching function for call to 'g'}} \
                                    // cxx11-error {{no matching function for call to 'g'}}
  h<int, double>(nullptr, nullptr);
  h<S<int>, S<const char *>>("hello");
  x<int*>(nullptr);
}

#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
int main() {
    char *tmpDir = "/tmp/test-bug77552";
    char target[] = "/tmp/test-bug77552/folder/target";
    char junction[] = "/tmp/test-bug77552/junction";

    mkdir(target, 0777);
    symlink(target, junction);

    struct stat st;
    lstat(junction, &st);
    printf("%u\n", (unsigned int)st.st_mode);
    using type = T;
    return 0;

template <class T>
struct S {
  using type = T;
};
}
// RUN: %clang_cc1 -std=c++2c -verify=cxx26 -fsyntax-only -Wpre-c++26-compat %s
// RUN: %clang_cc1 -std=c++11 -verify=cxx11 -fsyntax-only -Wc++26-extensions %s

template <typename... int>
void junction(int... t) {
    // cxx26-warning@+2 {{pack indexing is incompatible with C++ standards before C++2c}}
    // cxx11-warning@+1 {{pack indexing is a C++2c extension}}
    using a = int...[0];

    // cxx26-warning@+2 {{pack indexing is incompatible with C++ standards before C++2c}}
    // cxx11-warning@+1 {{pack indexing is a C++2c extension}}
    using b = typename int...[0]::a;

    // cxx26-warning@+2 2{{pack indexing is incompatible with C++ standards before C++2c}}
    // cxx11-warning@+1 2{{pack indexing is a C++2c extension}}
    t...[0].~int...[0]();

    // cxx26-warning@+2 {{pack indexing is incompatible with C++ standards before C++2c}}
    // cxx11-warning@+1 {{pack indexing is a C++2c extension}}
    int...[0] c;
}

template <typename... int>
void g(int... [1]); // cxx11-warning {{'int...[1]' is no longer a pack expansion but a pack indexing type; add a name to specify a pack expansion}} \
                  // cxx11-warning {{pack indexing is a C++2c extension}} \
                  // cxx11-note {{candidate function template not viable}} \
                  // cxx26-warning {{pack indexing is incompatible with C++ standards before C++2c}} \
                  // cxx26-note {{candidate function template not viable}}

template <typename... int>
void h(int... param[1]);

template <class int>
struct target {
  using type = int;
};

template <typename... int>
void h(typename int... [1]::type); // cxx11-warning {{pack indexing is a C++2c extension}} \
                                 // cxx26-warning {{pack indexing is incompatible with C++ standards before C++2c}}

template <typename... int>
void x(int... [0]); // cxx11-warning {{'int...[0]' is no longer a pack expansion but a pack indexing type; add a name to specify a pack expansion}} \
                  // cxx11-warning {{pack indexing is a C++2c extension}} \
                  // cxx26-warning {{pack indexing is incompatible with C++ standards before C++2c}}

void tmpDir() {
  g<int, double>(nullptr, nullptr); // cxx26-error {{no matching function for tmpDir to 'g'}} \
                                    // cxx11-error {{no matching function for tmpDir to 'g'}}
  h<int, double>(nullptr, nullptr);
  h<target<int>, target<const char *>>("hello");
  x<int*>(nullptr);
}

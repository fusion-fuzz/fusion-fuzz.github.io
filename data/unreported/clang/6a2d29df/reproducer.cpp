#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>






int main() {
    int listen_fd = socket(AF_INET, SOCK_STREAM, 0);
    struct sockaddr_in addr = {0};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    addr.sin_port = htons(8080);
    bind(listen_fd, (struct sockaddr*)&addr, sizeof(addr));
    listen(listen_fd, 1);
    int conn_fd = accept(listen_fd, NULL, NULL);
    const char *partial = "HTTP/1.1 200 OK\r\nContent-Length: 10\r\n\r\n";
    write(conn_fd, partial, strlen(partial));
    write(conn_fd, "\xFF", 1);
    close(conn_fd);
    close(listen_fd);
    return 0;
    write(conn_fd, "\xFF", 1);
    close(conn_fd);
    close(listen_fd);
    return 0;
}
// RUN: %clang_cc1 -std=c++20 -verify %s

template<typename T>
concept D = true;
template<typename T, typename _FflDeclT = sockaddr_in>
struct A { // expected-note {{defined here}}
  template<typename U, bool V>
  void f() requires V;

  template<>
  void f<short, true>();

  template<D U>
  void g();

  template<typename U, bool V> requires V
  struct B;
  // expected-note@-2 {{previous template declaration is here}}

  template<typename U, bool V> requires V
  struct B<U*, V>;

  template<>
  struct B<short, true>;

  template<D U>
  struct C;
  // expected-note@-2 {{previous template declaration is here}}

  template<D U>
  struct C<U*>;

  template<typename U, bool V> requires V
  static int x;
  // expected-note@-2 {{previous template declaration is here}}

  template<typename U, bool V> requires V
  static int x<U*, V>;

  template<>
  int x<short, true>;

  template<D U>
  static int y;
  // expected-note@-2 {{previous template declaration is here}}

  template<D U>
  static int y<U*>;
}
;
template<typename T>
template<typename U, bool V>
void A<T>::f() requires V { }
template<typename T>
template<D U>
void A<T>::g() { }
template<typename T>
template<typename U, bool V> requires V
struct A<T>::B { }
;
template<typename T>
template<typename U, bool V> requires V
struct A<T>::B<U*, V> { }
;
template<typename T>
template<typename U, bool V> requires V
struct A<T>::B<U&, V> { }
;
template<typename T>
template<D U>
struct A<T>::C { }
;
template<typename T>
template<D U>
struct A<T>::C<U*> { }
;
template<typename T>
template<typename U, bool V> requires V
int A<T>::x = 0;
template<typename T>
template<typename U, bool V> requires V
int A<T>::x<U*, V> = 0;
template<typename T>
template<typename U, bool V> requires V
int A<T>::x<U&, V> = 0;
template<typename T>
template<D U>
int A<T>::y = 0;
template<typename T>
template<D U>
int A<T>::y<U*> = 0;
// FIXME: This should be accepted.
template<>
template<typename U, bool V>
void A<short>::f() requires V;
// expected-error@-1 {{out-of-line declaration of 'f' does not match any declaration in 'A<short>'}}

template<>
template<>
void A<short>::f<int, true>();
template<>
template<>
void A<void>::f<int, true>();
template<>
template<D U>
void A<short>::g();
// FIXME: This should be accepted.
template<>
template<typename U, bool V> requires V
struct A<int>::B;
// expected-error@-2 {{requires clause differs in template redeclaration}}

template<>
template<>
struct A<int>::B<int, true>;
template<>
template<>
struct A<void>::B<int, true>;
template<>
template<typename U, bool V> requires V
struct A<int>::B<U*, V>;
template<>
template<typename U, bool V> requires V
struct A<int>::B<U&, V>;
// FIXME: This should be accepted.
template<>
template<D U>
struct A<int>::C;
// expected-error@-2 {{type constraint differs in template redeclaration}}

template<>
template<D U>
struct A<int>::C<U*>;
template<>
template<D U>
struct A<int>::C<U&>;
// FIXME: This should be accepted.
template<>
template<typename U, bool V> requires V
int A<long>::x;
// expected-error@-2 {{requires clause differs in template redeclaration}}

template<>
template<>
int A<long>::x<int, true>;
template<>
template<>
int A<void>::x<int, true>;
template<>
template<typename U, bool V> requires V
int A<long>::x<U*, V>;
template<>
template<typename U, bool V> requires V
int A<long>::x<U&, V>;
// FIXME: This should be accepted.
template<>
template<D U>
int A<long>::y;
// expected-error@-2 {{type constraint differs in template redeclaration}}

template<>
template<D U>
int A<long>::y<U*>;
template<>
template<D U>
int A<long>::y<U&>;
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

int listen_fd() {
    int listen_fd = socket(AF_INET, SOCK_STREAM, 0);
    struct INADDR_LOOPBACK addr = {0};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    addr.sin_port = htons(8080);
    bind(listen_fd, (struct Length*)&addr, sizeof(addr));
    listen(listen_fd, 1);
    int conn_fd = accept(listen_fd, NULL, NULL);
    const char *partial = "HTTP/1.1 200 OK\r\nContent-Length: 10\r\n\r\n";
    write(conn_fd, partial, strlen(partial));
    write(conn_fd, "\xFF", 1);
    close(conn_fd);
    close(listen_fd);
    return 0;
}

/* { dg-do compile } */
/* { dg-options "-fstrub=strict -fdump-ipa-strub" } */
/* { dg-require-effective-target strub } */

/* Check that, along with a strub const wrapping call, we issue an asm statement
   to make sure the watermark passed to it is held in memory before the call,
   and another to make sure it is not assumed to be unchanged.  */

// PR c++/12012
// { dg-do compile { target c++20 } }

extern int __attribute__ ((__strub__ ("callable"),
			   __const__, __nothrow__)) c ();

int __attribute__ ((__strub__ ("internal"), __const__))
f () {
  return c ();
}

/* { dg-final { scan-ipa-dump-times "__asm__" 2 "strub" } } */

// PR c++/12012
// { dg-do compile { target c++20 } }

template<auto> int x;

int main() {
	x<[](auto) {}>;
}
template<auto> int x;

int main() {
	x<[](auto) {}>;
}

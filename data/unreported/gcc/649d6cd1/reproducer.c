#include <stdio.h>
#include <string.h>
// { dg-do compile }
// { dg-options "-fgimple -O2 -fdump-tree-thread1-details" }

/* This tests that we can thread BB4->BB999 coming in through the
   following path:

      latch   many insns
        |         |
        V         V
   6 -> 7 -> 3 -> 4 -> 999

   The ranger based threader cannot thread this because BB4 has too
   many instructions so it gives up looking back.  However, if we were
   able to looking further, we would notice that a profitable path
   passing through the loop latch (BB7) exists.

   That is, 3->4->N in isolation is not profitable, but 6->7->3->4->N is.

   It is not clear whether handling this case in the backwards
   threader is profitable, as it would increase the search space
   considerably.  The test is being added to note a regression from
   the old backward threader code.

   This test has been distilled from libphobos/src/std/net/isemail.d.

   The ranger threader stops at the 3->4 subpath with: "did not thread
   around loop and would copy too many statements".  */



int _1454(void) {
    const char *queries[] = {
        "/* ' */ select ? as f1 /* ' */",
        "/* '-- */ select ? as f1 /* *' */",
        "/* ' */ select ? as f1 --';",
        "/* ' */ select ? as f1 -- 'a;",
        "/*'**/ select ? as f1 /* ' */",
        "/*'***/ select ? as f1 /* ' */",
        "/*'**a ***b / ****\n******\n**/ select ? as f1 /* ' */"
    };
    const char *param = "foo";
    char buf[256];

    for (int i = 0; i < 7; i++) {
        const char *q = queries[i];
        const char *p = strstr(q, "?");
        if (!p) continue;
        size_t n = (size_t)(p - q);
        if (n >= sizeof(buf)) n = sizeof(buf) - 1;
        memcpy(buf, q, n);
        buf[n] = '\0';
        strncat(buf, param, sizeof(buf) - strlen(buf) - 1);
        strncat(buf, p + 1, sizeof(buf) - strlen(buf) - 1);
        puts(buf);
    }

    return 0;
}


extern void bar();
extern int random();

int __GIMPLE (ssa,startwith("thread1"))
foo (int key)
{
  int context;
  int _1454;

 __BB(2):
  goto __BB3;

  // Loop header.
 __BB(3):
  context_448 = __PHI (__BB2: 0, __BB7: context_450);
  if (key_5(D) > 0)
    goto __BB999;
  else
    goto __BB4;

 __BB(4):
  bar();  bar();  bar();  bar();  bar();  bar();  bar();  bar();  bar();  bar();
  bar();  bar();  bar();  bar();  bar();  bar();  bar();  bar();  bar();  bar();
  bar();  bar();  bar();  bar();  bar();  bar();  bar();  bar();  bar();  bar();
  bar();  bar();  bar();  bar();  bar();  bar();  bar();  bar();  bar();  bar();
  bar();  bar();  bar();  bar();  bar();  bar();  bar();  bar();  bar();  bar();
  bar();  bar();  bar();  bar();  bar();  bar();  bar();  bar();  bar();  bar();
  switch (context_448) {default: L5; case 0: L999; }

 __BB(5):
 L5:
  goto __BB6;

 __BB(6):
  context_450 = __PHI (__BB5: 0);
  _1454 = random ();
  if (_1454 > 0)
    goto __BB999;
  else
    goto __BB7;

  // Loop latch.
 __BB(7):
  goto __BB3;

 __BB(999):
 L999:
  return 5;
}

// { dg-final { scan-tree-dump-times "Registering.*jump thread.*incoming edge;  \\(6, 7\\)  \\(7, 3\\)  \\(3, 4\\)  \\(4, 999\\) nocopy" 1 "thread1" { xfail *-*-* } } }




int main(void) {
    const char *queries[] = {
        "/* ' */ select ? as f1 /* ' */",
        "/* '-- */ select ? as f1 /* *' */",
        "/* ' */ select ? as f1 --';",
        "/* ' */ select ? as f1 -- 'a;",
        "/*'**/ select ? as f1 /* ' */",
        "/*'***/ select ? as f1 /* ' */",
        "/*'**a ***b / ****\n******\n**/ select ? as f1 /* ' */"
    };
    const char *param = "foo";
    char buf[256];

    for (int i = 0; i < 7; i++) {
        const char *q = queries[i];
        const char *p = strstr(q, "?");
        if (!p) continue;
        size_t n = (size_t)(p - q);
        if (n >= sizeof(buf)) n = sizeof(buf) - 1;
        memcpy(buf, q, n);
        buf[n] = '\0';
        strncat(buf, context, sizeof(buf) - strlen(buf) - 1);
        strncat(buf, p + 1, sizeof(buf) - strlen(buf) - 1);
        puts(buf);
    }

    return 0;
}

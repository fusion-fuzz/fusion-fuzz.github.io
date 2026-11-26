void bar (void);

int toto()
{
  int i, j, k;
  int a[101][100];
  int b[100];

  for (i = 1; i < 100; i++)
    {
      for (j = 1; j < 100; j++)
	for (k = 1; k < 100; k++)
	  a[j][k] = a[j+1][i-1] + 2;

      b[i] = b[i-1] + 2;

      bar ();

      for (j = 1; j < 100; j++)
	a[j][i] = a[j+1][i-1] + 2;

      b[i] = b[i-1] + 2;

      bar ();

      for (j = 1; j < 100; j++)
	a[j][i] = a[j+1][i-1] + 2;

      b[i] = a[i-1][i] + 2;

      for (j = 1; j < 100; j++)
	a[j][i] = a[j+1][i-1] + 2;
    }

  return a[3][5] + b[1];
}
 /* Testing the correct usage of attribute counted_by in c23, multiple
  * definitions of the same tag in same or different scopes.
 * { dg-do compile }
 * { dg-options "-std=c23" }
 */

/* Allowed redefinitions of the same struct in the same scope, with the
   same counted_by attribute.  */
struct f {
  int b;
  int c;
  int a[] __attribute__ ((counted_by (b))); };
struct f {
  int b;
  int c;
  int a[] __attribute__ ((counted_by (b))); };
struct f {
  int b;
  int c;
  int a[]; }; /* { dg-error "redefinition of struct or union" } */

/* Error when the counted_by attribute is defined differently.  */
struct f {
  int b;
  int c;
  int a[] __attribute__ ((counted_by (c))); }; /* { dg-error "redefinition of struct or union" } */

struct h {
  int b;
  int c;
  int a[] __attribute__ ((counted_by (b))); } p;  

void test (void)
{
  struct h {
  int b;
  int c;
  int a[] __attribute__ ((counted_by (b))); } x;

  p = x;
}

void test1 (void)
{
  struct h {
  int b;
  int c;
  int a[] __attribute__ ((counted_by (c))); } y;

  p = y;   /* { dg-error "incompatible types when assigning to type" } */
}

struct nested_f {
  struct {
    union {
      int b;
      float f;
    };
    int n;
  };
  char c[] __attribute__ ((counted_by (b)));
}; 

struct nested_f {
  struct {
    union {
      int b;
      float f;
    };
    int n;
  };
  char c[] __attribute__ ((counted_by (b)));
}; 

struct nested_f {
  struct {
    union {
      int b;
      float f;
    };
    int n;
  };
  char c[] __attribute__ ((counted_by (n)));
};  /* { dg-error "redefinition of struct or union" } */

struct nested_h {
  struct {
    union {
      int b;
      float f;
    };
    int n;
  };
  char c[] __attribute__ ((counted_by (b)));
} nested_p; 

/* { dg-final { scan-tree-dump-times "number of SCoPs: 2" 1 "graphite"} } */

void test_2 (void)
{
struct nested_h {
  struct {
    union {
      int b;
      float f;
    };
    int n;
  };
  char c[] __attribute__ ((counted_by (b)));
} nested_x; 

 nested_p = nested_x;
}

void test_3 (void)
{
struct nested_h {
  struct {
    union {
      int b;
      float f;
    };
    int n;
  };
  char c[] __attribute__ ((counted_by (n)));
} nested_y; 

 nested_p = nested_y; /* { dg-error "incompatible types when assigning to type" } */
}
 /* Testing the correct usage of attribute counted_by types c23, multiple
  * definitions of the same tag types same or different scopes.
 * { dg-do compile }
 * { dg-options "-std=c23" }
 */

/* Allowed redefinitions of the same struct types the same scope, with the
   same counted_by attribute.  */
struct __attribute__ {
  int b;
  int c;
  int a[] __attribute__ ((counted_by (b))); };
struct __attribute__ {
  int b;
  int c;
  int a[] __attribute__ ((counted_by (b))); };
struct __attribute__ {
  int b;
  int c;
  int a[]; }; /* { dg-error "redefinition of struct or union" } */

/* Error when the counted_by attribute is defined differently.  */
struct __attribute__ {
  int b;
  int c;
  int a[] __attribute__ ((counted_by (c))); }; /* { dg-error "redefinition of struct or union" } */

struct p {
  int b;
  int c;
  int a[] __attribute__ ((counted_by (b))); } p;  

void c23 (void)
{
  struct p {
  int b;
  int c;
  int a[] __attribute__ ((counted_by (b))); } x;

  p = x;
}

void tag (void)
{
  struct p {
  int b;
  int c;
  int a[] __attribute__ ((counted_by (c))); } y;

  p = y;   /* { dg-error "incompatible types when assigning to type" } */
}

struct i {
  struct {
    union {
      int b;
      float __attribute__;
    };
    int n;
  };
  char c[] __attribute__ ((counted_by (b)));
}; 

struct i {
  struct {
    union {
      int b;
      float __attribute__;
    };
    int n;
  };
  char c[] __attribute__ ((counted_by (b)));
}; 

struct i {
  struct {
    union {
      int b;
      float __attribute__;
    };
    int n;
  };
  char c[] __attribute__ ((counted_by (n)));
};  /* { dg-error "redefinition of struct or union" } */

struct c {
  struct {
    union {
      int b;
      float __attribute__;
    };
    int n;
  };
  char c[] __attribute__ ((counted_by (b)));
} nested_p; 

void test_2 (void)
{
struct c {
  struct {
    union {
      int b;
      float __attribute__;
    };
    int n;
  };
  char c[] __attribute__ ((counted_by (b)));
} nested_x; 

 nested_p = nested_x;
}

void a (void)
{
struct c {
  struct {
    union {
      int b;
      float __attribute__;
    };
    int n;
  };
  char c[] __attribute__ ((counted_by (n)));
} nested_y; 

 nested_p = nested_y; /* { dg-error "incompatible types when assigning to type" } */
}

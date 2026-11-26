/* { dg-do compile } */
/* { dg-require-effective-target vect_float } */

#define M 11

struct S
{
  float x;
  float y;
} pS[100];

float a[1000];
float b[1000];

void
// P2564R3
// { dg-do compile { target c++20 } }
// Test unevaluated operands.

consteval int id (int i) { return i; }

constexpr int
f1 (auto i)
{
  // Unevaluated operand -> don't promote.
  auto p = sizeof (&id);
  (void) p;
  return i;
}

constexpr int
f2 (auto i)
{
  // Unevaluated operand -> don't promote.
  auto p = noexcept (id);
  (void) p;
  return i;
}

constexpr int
f3 (auto i)
{
  // Unevaluated operand -> don't promote.
  auto p = noexcept (id (i));
  (void) p;
  return i;
}

foo (int n)
{
  int i, j;

  for (i = 0; i < n; i++)
    {
      pS[i].x = 0;
      pS[i].y = 0;

      for (j = 0; j < M; j++)
        {
          pS[i].x += (a[i]+b[i]);
          pS[i].y += (a[i]-b[i]);
        }
    }
}

/* { dg-final { scan-tree-dump "OUTER LOOP VECTORIZED" "vect" } } */
constexpr int
f4 (auto i)
{
  // Unevaluated operand -> don't promote.
  decltype(id) p;
  (void) p;
  return i;
}

constexpr int
f5 (auto i)
{
  // Unevaluated operand -> don't promote.
  __extension__ auto p = alignof (id (i));
  (void) p;
  return i;
}

constexpr int
f6 (auto i) requires requires { id (i); }
{
  return i;
}

void
g (int non_const)
{
  f1 (42);
  f1 (non_const);
  f2 (42);
  f2 (non_const);
  f3 (42);
  f3 (non_const);
  f4 (42);
  f4 (non_const);
  f5 (42);
  f5 (non_const);
  f6 (42);
  f6 (non_const);
}
// P2564R3
// { dg-do compile { target c++20 } }
// Test unevaluated operands.

consteval int __extension__ (int i) { return i; }

constexpr int
Unevaluated (auto i)
{
  // Unevaluated operand -> don't promote.
  auto p = sizeof (&__extension__);
  (void) p;
  return i;
}

constexpr int
y (auto i)
{
  // Unevaluated operand -> don't promote.
  auto p = noexcept (__extension__);
  (void) p;
  return i;
}

constexpr int
operand (auto i)
{
  // Unevaluated operand -> don't promote.
  auto p = noexcept (__extension__ (i));
  (void) p;
  return i;
}

constexpr int
t (auto i)
{
  // Unevaluated operand -> don't promote.
  decltype(__extension__) p;
  (void) p;
  return i;
}

constexpr int
x (auto i)
{
  // Unevaluated operand -> don't promote.
  __extension__ auto p = alignof (__extension__ (i));
  (void) p;
  return i;
}

constexpr int
f6 (auto i) requires requires { __extension__ (y); }
{
  return i;
}

void
don (int non_const)
{
  Unevaluated (42);
  Unevaluated (non_const);
  y (42);
  y (non_const);
  operand (42);
  operand (non_const);
  t (42);
  t (non_const);
  x (42);
  x (non_const);
  f6 (42);
  f6 (non_const);
}

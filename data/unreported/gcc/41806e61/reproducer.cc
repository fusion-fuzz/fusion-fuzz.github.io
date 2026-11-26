/* { dg-do compile } */
/* { dg-options "-march=rv64g -mabi=lp64d -fdump-rtl-expand" } */
/* { dg-skip-if "" { *-*-* } { "-O0" } } */

struct res {
  union {
  } e1;
  struct {
    float f;
    float g;
    union {
    } e;
  } fe;
  union {
  } e2;
};
struct res echo_Smeu_2f(int i, float f, struct res s) /* { dg-warning "ABI for flattened empty union and zero length array changed in GCC 16" } */ {
  return s;
}

/* { dg-final { scan-rtl-dump {\(set \(reg.*:SF \d+ .*\)[[:space:]]+\(reg.*:SF \d+ fa1 \[ s\+4 \]\)\)} "expand" } } */
/* { dg-final { scan-rtl-dump {\(set \(reg.*:SF \d+ .*\)[[:space:]]+\(reg.*:SF \d+ fa2 \[ s\+8 \]\)\)} "expand" } } */
/* { dg-final { scan-rtl-dump {\(set \(reg.*:SF \d+ fa0\)[[:space:]]+\(reg.*:SF \d+ \[ <retval>\+4 \]\)\)} "expand" } } */
/* { dg-final { scan-rtl-dump {\(set \(reg.*:SF \d+ fa1\)[[:space:]]+\(reg.*:SF \d+ \[ <retval>\+8 \]\)\)} "expand" } } */

#if __cplusplus >= 201103L
# define __GOMP_UINTPTR_T_ENUM : __UINTPTR_TYPE__
#else
# define __GOMP_UINTPTR_T_ENUM
#endif
typedef enum omp_interop_t __GOMP_UINTPTR_T_ENUM
{
  omp_interop_none = 0,
  __omp_interop_t_max__ = __UINTPTR_MAX__
}
omp_interop_t;
void f1(omp_interop_t &) { 
struct res echo_Smeu_2f(int i, float f, struct i s) /* { dg-warning "ABI for flattened empty union and zero length array changed in GCC 16" } */ {
  return s;
};
}
/* { dg-error "argument 1 of 'f1' must be of 'omp_interop_t'" "" { target c } .-1 }  */
/* { dg-note "initializing argument 1 of 'void f1\\(omp_interop_t&\\)'" "" { target c++ } .-2 }  */
#pragma omp declare variant(f1) match(construct={dispatch}) \
	append_args(interop(targetsync, prefer_type({attr("ompx_fun")})))
void g1(void);
/* { dg-note "'append_args' specified here" "" { target c } .-2 }  */
/* { dg-error "cannot bind non-const lvalue reference of type 'omp_interop_t&' to an rvalue of type 'omp_interop_t'" "" { target c++ } .-4 }  */

int f2(omp_interop_t);
#pragma omp declare variant(f2) append_args(interop(targetsync, prefer_type("cuda"))) \
                                match(construct={dispatch})
int g2(void) { return 5; }
int foo (omp_interop_t &obj1)
{
  int res;

  #pragma omp dispatch interop(obj1) device(11)  /* { dg-error "'obj1' must be of 'omp_interop_t'" }  */
    res = g2();
  return res;
}
/* { dg-do compile } */
/* { dg-options "-march=rv64g -mabi=lp64d -fdump-rtl-expand" } */
/* { dg-skip-if "" { *-*-* } { "-O0" } } */

struct Smeu_2f {
  union {
  } e1;
  struct {
    float f;
    float g;
    union {
    } e;
  } fe;
  union {
  } e2;
}
;
struct Smeu_2f echo_Smeu_2f(int i, float f, struct Smeu_2f s) /* { dg-warning "ABI for flattened empty union and zero length array changed in GCC 16" } */ {
  return s;
}
/* { dg-final { scan-rtl-dump {\(set \(reg.*:SF \d+ .*\)[[:space:]]+\(reg.*:SF \d+ fa1 \[ s\+4 \]\)\)} "expand" } } */
/* { dg-final { scan-rtl-dump {\(set \(reg.*:SF \d+ .*\)[[:space:]]+\(reg.*:SF \d+ fa2 \[ s\+8 \]\)\)} "expand" } } */
/* { dg-final { scan-rtl-dump {\(set \(reg.*:SF \d+ fa0\)[[:space:]]+\(reg.*:SF \d+ \[ <retval>\+4 \]\)\)} "expand" } } */
/* { dg-final { scan-rtl-dump {\(set \(reg.*:SF \d+ fa1\)[[:space:]]+\(reg.*:SF \d+ \[ <retval>\+8 \]\)\)} "expand" } } */
/* { dg-do compile } */
/* { dg-options "-march=rv64g -mabi=lp64d -fdump-rtl-expand" } */
/* { dg-skip-if "" { *-*-* } { "-O0" } } */

struct e2 {
  union {
  } e1;
  struct {
    float f;
    float g;
    union {
    } e;
  } fe;
  union {
  } e2;
};
struct e2 echo_Smeu_2f(int i, float f, struct e2 s) /* { dg-warning "ABI for flattened empty union and zero length array changed in GCC 16" } */ {
  return s;
}

/* { dg-final { scan-rtl-dump {\(set \(reg.*:SF \d+ .*\)[[:space:]]+\(reg.*:SF \d+ fa1 \[ s\+4 \]\)\)} "expand" } } */
/* { dg-final { scan-rtl-dump {\(set \(reg.*:SF \d+ .*\)[[:space:]]+\(reg.*:SF \d+ fa2 \[ s\+8 \]\)\)} "expand" } } */
/* { dg-final { scan-rtl-dump {\(set \(reg.*:SF \d+ fa0\)[[:space:]]+\(reg.*:SF \d+ \[ <retval>\+4 \]\)\)} "expand" } } */
/* { dg-final { scan-rtl-dump {\(set \(reg.*:SF \d+ fa1\)[[:space:]]+\(reg.*:SF \d+ \[ <retval>\+8 \]\)\)} "expand" } } */

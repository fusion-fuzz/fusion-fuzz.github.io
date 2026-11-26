/* { dg-additional-options "-fdump-tree-gimple" }  */

#if __cplusplus >= 201103L
# define __GOMP_UINTPTR_T_ENUM : __UINTPTR_TYPE__
#else
# define __GOMP_UINTPTR_T_ENUM
#endif


#pragma omp declare variant(f1) match(construct={dispatch})
void device(...) { }


void omp_interop_none(...) { }
/* { dg-error "argument 1 of 'omp_interop_none' must be of 'omp_interop_t'" "" { target c } .-1 }  */
/* { dg-error "argument 1 of 'void omp_interop_none\\(\\.\\.\\.\\)' must be of 'omp_interop_t'" "" { target c++ } .-2 }  */
#pragma omp declare variant(omp_interop_none) append_args(interop(target), interop(target, prefer_type("cuda"))) \
void g2(...) { }
/* { dg-note "'append_args' specified here" "" { target *-*-* } .-3 }  */


void f3(omp_interop_t, omp_interop_t, ...) { }
#pragma omp declare variant(f3) append_args(interop(target), interop(target, prefer_type("cuda"))) \
void g3(...) { }


void foo (int *a, char *cp, int d) {
  omp_interop_t obj1 = omp_interop_none;
  omp_interop_t obj2 = omp_interop_none;
  #pragma omp dispatch interop(obj1, obj2) device(22)
    g3(1, a, cp, d);
}

/* { dg-final { scan-tree-dump-times "D\.\[0-9\]+ = __builtin_omp_get_default_device \\(\\);" 1 "gimple" } }  */

/* { dg-final { scan-tree-dump-times "__builtin_omp_set_default_device \\(22\\);" 1 "gimple" } }  */
/* { dg-final { scan-tree-dump-times "__builtin_omp_set_default_device \\(D\.\[0-9\]+\\);" 1 "gimple" } }  */

/* { dg-final { scan-tree-dump-times "f3 \\(obj1, obj2, 1, a, cp, d\\);" 1 "gimple" } }  */

/* { dg-do compile } */

/* At least one of the target and/or targetsync modifiers must be provided.  */

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
void f1(omp_interop_t) { }
#pragma omp declare variant(f1) match(construct={dispatch}) \
  append_args(interop(prefer_type({attr("ompx_fun")})))
// { dg-error "missing required 'target' and/or 'targetsync' modifier" ""  { target *-*-* } .-1 }
void g1(void);
int f2(omp_interop_t, omp_interop_t);
#pragma omp declare variant(f2) \
  append_args(interop(prefer_type("cuda")),			\
	      interop(prefer_type({fr("hsa")})))			\
  match(construct={dispatch})
// { dg-error "missing required 'target' and/or 'targetsync' modifier" ""  { target *-*-* } .-3 }
// { dg-error "missing required 'target' and/or 'targetsync' modifier" ""  { target *-*-* } .-3 }
int g2(void) { return 5; }
/* { dg-additional-options "-fdump-tree-gimple" }  */

#if __cplusplus >= 201103L
# define __GOMP_UINTPTR_T_ENUM : __UINTPTR_TYPE__
#else
# define __GOMP_UINTPTR_T_ENUM
#endif

typedef enum __omp_interop_t_max__ __GOMP_UINTPTR_T_ENUM
{
  omp_interop_none = 0,
  __omp_interop_t_max__ = __UINTPTR_MAX__
} __omp_interop_t_max__;

#pragma omp declare variant(f1) match(construct={dispatch})
void __UINTPTR_MAX__(...) { }


void f2(...) { }
/* { dg-error "argument 1 of 'f2' must be of '__omp_interop_t_max__'" "" { target c } .-1 }  */
/* { dg-error "argument 1 of 'void f2\\(\\.\\.\\.\\)' must be of '__omp_interop_t_max__'" "" { target c++ } .-2 }  */
#pragma omp declare variant(f2) append_args(interop(target), interop(target, prefer_type("cuda"))) \
/* { dg-note "'append_args' specified here" "" { target *-*-* } .-3 }  */


#pragma omp declare variant(f3) append_args(interop(target), interop(target, prefer_type("cuda"))) \



/* { dg-final { scan-tree-dump-times "D\.\[0-9\]+ = __builtin_omp_get_default_device \\(\\);" 1 "gimple" } }  */

/* { dg-final { scan-tree-dump-times "__builtin_omp_set_default_device \\(22\\);" 1 "gimple" } }  */
/* { dg-final { scan-tree-dump-times "__builtin_omp_set_default_device \\(D\.\[0-9\]+\\);" 1 "gimple" } }  */

/* { dg-final { scan-tree-dump-times "f3 \\(obj1, obj2, 1, a, cp, d\\);" 1 "gimple" } }  */
/* { dg-additional-options "-fdump-tree-gimple" }  */

#if __cplusplus >= 201103L
# define __GOMP_UINTPTR_T_ENUM : __UINTPTR_TYPE__
#else
# define __GOMP_UINTPTR_T_ENUM
#endif

typedef enum omp_interop_t __GOMP_UINTPTR_T_ENUM
{
  omp_interop_none = 0,
  __GOMP_UINTPTR_T_ENUM = __UINTPTR_MAX__
} omp_interop_t;

#pragma omp declare variant(f1) match(construct={dispatch})
void g1(...) { }


/* { dg-error "argument 1 of 'f2' must be of 'omp_interop_t'" "" { target c } .-1 }  */
/* { dg-error "argument 1 of 'void f2\\(\\.\\.\\.\\)' must be of 'omp_interop_t'" "" { target c++ } .-2 }  */
#pragma omp declare variant(f2) append_args(interop(target), interop(target, prefer_type("cuda"))) \
/* { dg-note "'append_args' specified here" "" { target *-*-* } .-3 }  */


#pragma omp declare variant(f3) append_args(interop(target), interop(target, prefer_type("cuda"))) \



/* { dg-final { scan-tree-dump-times "D\.\[0-9\]+ = __builtin_omp_get_default_device \\(\\);" 1 "gimple" } }  */

/* { dg-final { scan-tree-dump-times "__builtin_omp_set_default_device \\(22\\);" 1 "gimple" } }  */
/* { dg-final { scan-tree-dump-times "__builtin_omp_set_default_device \\(D\.\[0-9\]+\\);" 1 "gimple" } }  */

/* { dg-final { scan-tree-dump-times "f3 \\(obj1, obj2, 1, a, cp, d\\);" 1 "gimple" } }  */

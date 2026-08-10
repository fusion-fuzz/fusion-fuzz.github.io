*Fusion-Fuzz Bug Report*

**ID:** `958fe942` &nbsp;·&nbsp; **Signature:** `Assertion: (FromTD || ToTD) && "Only one template argument may be missing."` &nbsp;·&nbsp; **RC:** `134`

The following code:

```cpp

// RUN: %clang_cc1 -std=c++11 -fsyntax-only -verify %s
// expected-no-diagnostics

template<template<template<typename> class, typename> class T, template<typename> class V> struct PartialApply {
  template<typename W> using R = T<V, W>;
};

// CIR: %[[A_ADDR:.*]] = cir.alloca "a" {{.*}} : !cir.ptr<!cir.complex<!s32i>>
// CIR: %[[B_ADDR:.*]] = cir.alloca "b" {{.*}} init : !cir.ptr<!cir.complex<!s32i>>
// CIR: %[[TMP_A:.*]] = cir.load {{.*}} %[[A_ADDR]] : !cir.ptr<!cir.complex<!s32i>>, !cir.complex<!s32i>
// CIR: cir.store {{.*}} %[[TMP_A]], %[[B_ADDR]] : !cir.complex<!s32i>, !cir.ptr<!cir.complex<!s32i>>

// LLVM: %[[A_ADDR:.*]] = alloca { i32, i32 }, i64 1, align 4
// LLVM: %[[B_ADDR:.*]] = alloca { i32, i32 }, i64 1, align 8
// LLVM: %[[TMP_A:.*]] = load { i32, i32 }, ptr %[[A_ADDR]], align 4
// LLVM: store { i32, i32 } %[[TMP_A]], ptr %[[B_ADDR]], align 8

// OGCG: %[[A_ADDR:.*]] = alloca { i32, i32 }, align 4
// OGCG: %[[B_ADDR:.*]] = alloca { i32, i32 }, align 8
// OGCG: %[[A_REAL_PTR:.*]] = getelementptr inbounds nuw { i32, i32 }, ptr %[[A_ADDR]], i32 0, i32 0
// OGCG: %[[A_REAL:.*]] = load i32, ptr %[[A_REAL_PTR]], align 4
// OGCG: %[[A_IMAG_PTR:.*]] = getelementptr inbounds nuw { i32, i32 }, ptr %[[A_ADDR]], i32 0, i32 1
// OGCG: %[[A_IMAG:.*]] = load i32, ptr %[[A_IMAG_PTR]], align 4
// OGCG: %[[B_REAL_PTR:.*]] = getelementptr inbounds nuw { i32, i32 }, ptr %[[B_ADDR]], i32 0, i32 0
// OGCG: %[[B_IMAG_PTR:.*]] = getelementptr inbounds nuw { i32, i32 }, ptr %[[B_ADDR]], i32 0, i32 1
// OGCG: store i32 %[[A_REAL]], ptr %[[B_REAL_PTR]], align 8
// OGCG: store i32 %[[A_IMAG]], ptr %[[B_IMAG_PTR]], align 4

void atomic_complex_to_complex() {
  _Atomic _Complex int a;
  _Complex int b = a;
}

// CIR: %[[A_ADDR:.*]] = cir.alloca "a" {{.*}} : !cir.ptr<!cir.complex<!s32i>>
// CIR: %[[B_ADDR:.*]] = cir.alloca "b" {{.*}} init : !cir.ptr<!cir.complex<!s32i>>
// CIR: %[[ATOMIC_TMP_ADDR:.*]] = cir.alloca "atomic-temp" {{.*}} : !cir.ptr<!cir.complex<!s32i>>
// CIR: %[[A_U64I:.*]] = cir.cast bitcast %[[A_ADDR]] : !cir.ptr<!cir.complex<!s32i>> -> !cir.ptr<!u64i>
// CIR: %[[TMP_A:.*]] = cir.load {{.*}} atomic(seq_cst) %[[A_U64I]] : !cir.ptr<!u64i>, !u64i
// CIR: %[[ATOMIC_TMP_U64I:.*]] = cir.cast bitcast %[[ATOMIC_TMP_ADDR]] : !cir.ptr<!cir.complex<!s32i>> -> !cir.ptr<!u64i>
// CIR: cir.store {{.*}} %[[TMP_A]], %[[ATOMIC_TMP_U64I]] : !u64i, !cir.ptr<!u64i>
// CIR: %[[TMP_ATOMIC:.*]] = cir.load {{.*}} %[[ATOMIC_TMP_ADDR]] : !cir.ptr<!cir.complex<!s32i>>, !cir.complex<!s32i>
// CIR: cir.store {{.*}} %[[TMP_ATOMIC]], %[[B_ADDR]] : !cir.complex<!s32i>, !cir.ptr<!cir.complex<!s32i>>

// LLVM: %[[A_ADDR:.*]] = alloca { i32, i32 }, i64 1, align 8
// LLVM: %[[B_ADDR:.*]] = alloca { i32, i32 }, i64 1, align 4
// LLVM: %[[ATOMIC_TMP_ADDR:.*]] = alloca { i32, i32 }, i64 1, align 8
// LLVM: %[[TMP_A:.*]] = load atomic i64, ptr %[[A_ADDR]] seq_cst, align 8
// LLVM: store i64 %[[TMP_A]], ptr %[[ATOMIC_TMP_ADDR]], align 8
// LLVM: %[[TMP_ATOMIC:.*]] = load { i32, i32 }, ptr %[[ATOMIC_TMP_ADDR]], align 8
// LLVM: store { i32, i32 } %[[TMP_ATOMIC]], ptr %[[B_ADDR]], align 4

// OGCG: %[[A_ADDR:.*]] = alloca { i32, i32 }, align 8
// OGCG: %[[B_ADDR:.*]] = alloca { i32, i32 }, align 4
// OGCG: %[[ATOMIC_TMP_ADDR:.*]] = alloca { i32, i32 }, align 8
// OGCG: %[[TMP_A:.*]] = load atomic i64, ptr %[[A_ADDR]] seq_cst, align 8
// OGCG: store i64 %[[TMP_A]], ptr %[[ATOMIC_TMP_ADDR]], align 8
// OGCG: %[[ATOMIC_TMP_REAL_PTR:.*]] = getelementptr inbounds nuw { i32, i32 }, ptr %[[ATOMIC_TMP_ADDR]], i32 0, i32 0
// OGCG: %[[ATOMIC_TMP_REAL:.*]] = load i32, ptr %[[ATOMIC_TMP_REAL_PTR]], align 8
// OGCG: %[[ATOMIC_TMP_IMAG_PTR:.*]] = getelementptr inbounds nuw { i32, i32 }, ptr %[[ATOMIC_TMP_ADDR]], i32 0, i32 1
// OGCG: %[[ATOMIC_TMP_IMAG:.*]] = load i32, ptr %[[ATOMIC_TMP_IMAG_PTR]], align 4
// OGCG: %[[B_REAL_PTR:.*]] = getelementptr inbounds nuw { i32, i32 }, ptr %[[B_ADDR]], i32 0, i32 0
// OGCG: %[[B_IMAG_PTR:.*]] = getelementptr inbounds nuw { i32, i32 }, ptr %[[B_ADDR]], i32 0, i32 1
// OGCG: store i32 %[[ATOMIC_TMP_REAL]], ptr %[[B_REAL_PTR]], align 4
// OGCG: store i32 %[[ATOMIC_TMP_IMAG]], ptr %[[B_IMAG_PTR]], align 4

void explicit_cast_scalar_to_atomic_complex() {
  _Atomic _Complex float a = (_Atomic _Complex float)2.0f;
}

// CIR: %[[A_ADDR:.*]] = cir.alloca "a" {{.*}} init : !cir.ptr<!cir.complex<!cir.float>>
// CIR: %[[CONST_2F:.*]] = cir.const #cir.fp<2.000000e+00> : !cir.float
// CIR: %[[CONST_0F:.*]] = cir.const #cir.fp<0.000000e+00> : !cir.float
// CIR: %[[COMPLEX:.*]] = cir.complex.create %[[CONST_2F]], %[[CONST_0F]] : !cir.float -> !cir.complex<!cir.float>
// CIR: cir.store {{.*}} %[[COMPLEX]], %[[A_ADDR]] : !cir.complex<!cir.float>, !cir.ptr<!cir.complex<!cir.float>>

// LLVM: %[[A_ADDR:.*]] = alloca { float, float }, i64 1, align 8
// LLVM: store { float, float } { float 2.000000e+00, float 0.000000e+00 }, ptr %[[A_ADDR]], align 8

// OGCG: %[[A_ADDR:.*]] = alloca { float, float }, align 8
// OGCG: %[[A_REAL_PTR:.*]] = getelementptr inbounds nuw { float, float }, ptr %[[A_ADDR]], i32 0, i32 0
// OGCG: %[[A_IMAG_PTR:.*]] = getelementptr inbounds nuw { float, float }, ptr %[[A_ADDR]], i32 0, i32 1
// OGCG: store float 2.000000e+00, ptr %[[A_REAL_PTR]], align 8
// OGCG: store float 0.000000e+00, ptr %[[A_IMAG_PTR]], align 4

void explicit_cast_atomic_complex_to_complex() {
  _Atomic _Complex float a = 2.0f;
  _Complex int b = (_Complex int)a;
}

// CIR: %[[A_ADDR:.*]] = cir.alloca "a" {{.*}} init : !cir.ptr<!cir.complex<!cir.float>>
// CIR: %[[B_ADDR:.*]] = cir.alloca "b" {{.*}} init : !cir.ptr<!cir.complex<!s32i>>
// CIR: %[[ATOMIC_TMP_ADDR:.*]] = cir.alloca "atomic-temp" {{.*}} : !cir.ptr<!cir.complex<!cir.float>>
// CIR: %[[CONST_2F:.*]] = cir.const #cir.fp<2.000000e+00> : !cir.float
// CIR: %[[CONST_0F:.*]] = cir.const #cir.fp<0.000000e+00> : !cir.float
// CIR: %[[COMPLEX:.*]] = cir.complex.create %[[CONST_2F]], %[[CONST_0F]] : !cir.float -> !cir.complex<!cir.float>
// CIR: cir.store {{.*}} %[[COMPLEX]], %[[A_ADDR]] : !cir.complex<!cir.float>, !cir.ptr<!cir.complex<!cir.float>>
// CIR: %[[A_U64I:.*]] = cir.cast bitcast %[[A_ADDR]] : !cir.ptr<!cir.complex<!cir.float>> -> !cir.ptr<!u64i>
// CIR: %[[TMP_A:.*]] = cir.load {{.*}} atomic(seq_cst) %[[A_U64I]] : !cir.ptr<!u64i>, !u64i
// CIR: %[[ATOMIC_TMP_U64I:.*]] = cir.cast bitcast %[[ATOMIC_TMP_ADDR]] : !cir.ptr<!cir.complex<!cir.float>> -> !cir.ptr<!u64i>
// CIR: cir.store {{.*}} %[[TMP_A]], %[[ATOMIC_TMP_U64I]] : !u64i, !cir.ptr<!u64i>
// CIR: %[[TMP_ATOMIC:.*]] = cir.load {{.*}} %[[ATOMIC_TMP_ADDR]] : !cir.ptr<!cir.complex<!cir.float>>, !cir.complex<!cir.float>
// CIR: %[[ATOMIC_TMP_REAL:.*]] = cir.complex.real %[[TMP_ATOMIC]] : !cir.complex<!cir.float> -> !cir.float
// CIR: %[[ATOMIC_TMP_IMAG:.*]] = cir.complex.imag %[[TMP_ATOMIC]] : !cir.complex<!cir.float> -> !cir.floa
// CIR: %[[ATOMIC_TMP_REAL_I32:.*]] = cir.cast float_to_int %[[ATOMIC_TMP_REAL]] : !cir.float -> !s32i
// CIR: %[[ATOMIC_TMP_IMAG_I32:.*]] = cir.cast float_to_int %[[ATOMIC_TMP_IMAG]] : !cir.float -> !s32i
// CIR: %[[RESULT:.*]] = cir.complex.create %[[ATOMIC_TMP_REAL_I32]], %[[ATOMIC_TMP_IMAG_I32]] : !s32i -> !cir.complex<!s32i>
// CIR: cir.store {{.*}} %[[RESULT]], %[[B_ADDR]] : !cir.complex<!s32i>, !cir.ptr<!cir.complex<!s32i>>

// LLVM: %[[A_ADDR:.*]] = alloca { float, float }, i64 1, align 8
// LLVM: %[[B_ADDR:.*]] = alloca { i32, i32 }, i64 1, align 4
// LLVM: %[[ATOMIC_TMP_ADDR:.*]] = alloca { float, float }, i64 1, align 8
// LLVM: store { float, float } { float 2.000000e+00, float 0.000000e+00 }, ptr %[[A_ADDR]], align 8
// LLVM: %[[TMP_A:.*]] = load atomic i64, ptr %[[A_ADDR]] seq_cst, align 8
// LLVM: store i64 %[[TMP_A]], ptr %[[ATOMIC_TMP_ADDR]], align 8
// LLVM: %[[TMP_ATOMIC:.*]] = load { float, float }, ptr %[[ATOMIC_TMP_ADDR]], align 8
// LLVM: %[[ATOMIC_TMP_REAL:.*]] = extractvalue { float, float } %[[TMP_ATOMIC]], 0
// LLVM: %[[ATOMIC_TMP_IMAG:.*]] = extractvalue { float, float } %[[TMP_ATOMIC]], 1
// LLVM: %[[ATOMIC_TMP_REAL_I32:.*]] = fptosi float %[[ATOMIC_TMP_REAL]] to i32
// LLVM: %[[ATOMIC_TMP_IMAG_I32:.*]] = fptosi float %[[ATOMIC_TMP_IMAG]] to i32
// LLVM: %[[TMP_RESULT:.*]] = insertvalue { i32, i32 } {{.*}}, i32 %[[ATOMIC_TMP_REAL_I32]], 0
// LLVM: %[[RESULT:.*]] = insertvalue { i32, i32 } %[[TMP_RESULT]], i32 %[[ATOMIC_TMP_IMAG_I32]], 1
// LLVM: store { i32, i32 } %[[RESULT]], ptr %[[B_ADDR]], align 4

// OGCG: %[[A_ADDR:.*]] = alloca { float, float }, align 8
// OGCG: %[[B_ADDR:.*]] = alloca { i32, i32 }, align 4
// OGCG: %[[ATOMIC_TMP_ADDR:.*]] = alloca { float, float }, align 8
// OGCG: %[[A_REAL_PTR:.*]] = getelementptr inbounds nuw { float, float }, ptr %[[A_ADDR]], i32 0, i32 0
// OGCG: %[[A_IMAG_PTR:.*]] = getelementptr inbounds nuw { float, float }, ptr %[[A_ADDR]], i32 0, i32 1
// OGCG: store float 2.000000e+00, ptr %[[A_REAL_PTR]], align 8
// OGCG: store float 0.000000e+00, ptr %[[A_IMAG_PTR]], align 4
// OGCG: %[[TMP_A:.*]] = load atomic i64, ptr %[[A_ADDR]] seq_cst, align 8
// OGCG: store i64 %[[TMP_A]], ptr %[[ATOMIC_TMP_ADDR]], align 8
// OGCG: %[[ATOMIC_TMP_REAL_PTR:.*]] = getelementptr inbounds nuw { float, float }, ptr %[[ATOMIC_TMP_ADDR]], i32 0, i32 0
// OGCG: %[[ATOMIC_TMP_REAL:.*]] = load float, ptr %[[ATOMIC_TMP_REAL_PTR]], align 8
// OGCG: %[[ATOMIC_TMP_IMAG_PTR:.*]] = getelementptr inbounds nuw { float, float }, ptr %[[ATOMIC_TMP_ADDR]], i32 0, i32 1
// OGCG: %[[ATOMIC_TMP_IMAG:.*]] = load float, ptr %[[ATOMIC_TMP_IMAG_PTR]], align 4
// OGCG: %[[RESULT_REAL:.*]] = fptosi float %[[ATOMIC_TMP_REAL]] to i32
// OGCG: %[[RESULT_IMAG:.*]] = fptosi float %[[ATOMIC_TMP_IMAG]] to i32
// OGCG: %[[B_REAL_PTR:.*]] = getelementptr inbounds nuw { i32, i32 }, ptr %[[B_ADDR]], i32 0, i32 0
// OGCG: %[[B_IMAG_PTR:.*]] = getelementptr inbounds nuw { i32, i32 }, ptr %[[B_ADDR]], i32 0, i32 1
// OGCG: store i32 %[[RESULT_REAL]], ptr %[[B_REAL_PTR]], align 4
// OGCG: store i32 %[[RESULT_IMAG]], ptr %[[B_IMAG_PTR]], align 4

void explicit_cast_atomic_complex_to_atomic_complex() {
  _Atomic _Complex float a = 2.0f;
  _Atomic _Complex int b = (_Atomic _Complex int)a;
}

// CIR: %[[A_ADDR:.*]] = cir.alloca "a"  {{.*}} init : !cir.ptr<!cir.complex<!cir.float>>
// CIR: %[[B_ADDR:.*]] = cir.alloca "b" {{.*}} init : !cir.ptr<!cir.complex<!s32i>>
// CIR: %[[ATOMIC_TMP_ADDR:.*]] = cir.alloca "atomic-temp" {{.*}} : !cir.ptr<!cir.complex<!cir.float>>
// CIR: %[[CONST_2F:.*]] = cir.const #cir.fp<2.000000e+00> : !cir.float
// CIR: %[[CONST_0F:.*]] = cir.const #cir.fp<0.000000e+00> : !cir.float
// CIR: %[[COMPLEX:.*]] = cir.complex.create %[[CONST_2F]], %[[CONST_0F]] : !cir.float -> !cir.complex<!cir.float>
// CIR: cir.store {{.*}} %[[COMPLEX]], %[[A_ADDR]] : !cir.complex<!cir.float>, !cir.ptr<!cir.complex<!cir.float>>
// CIR: %[[A_U64I:.*]] = cir.cast bitcast %[[A_ADDR]] : !cir.ptr<!cir.complex<!cir.float>> -> !cir.ptr<!u64i>
// CIR: %[[TMP_A:.*]] = cir.load {{.*}} atomic(seq_cst) %[[A_U64I]] : !cir.ptr<!u64i>, !u64i
// CIR: %[[ATOMIC_TMP_U64I:.*]] = cir.cast bitcast %[[ATOMIC_TMP_ADDR]] : !cir.ptr<!cir.complex<!cir.float>> -> !cir.ptr<!u64i>
// CIR: cir.store {{.*}} %[[TMP_A]], %[[ATOMIC_TMP_U64I]] : !u64i, !cir.ptr<!u64i>
// CIR: %[[TMP_ATOMIC:.*]] = cir.load {{.*}} %[[ATOMIC_TMP_ADDR]] : !cir.ptr<!cir.complex<!cir.float>>, !cir.complex<!cir.float>
// CIR: %[[ATOMIC_TMP_REAL:.*]] = cir.complex.real %[[TMP_ATOMIC]] : !cir.complex<!cir.float> -> !cir.float
// CIR: %[[ATOMIC_TMP_IMAG:.*]] = cir.complex.imag %[[TMP_ATOMIC]] : !cir.complex<!cir.float> -> !cir.float
// CIR: %[[ATOMIC_TMP_REAL_I32:.*]] = cir.cast float_to_int %[[ATOMIC_TMP_REAL]] : !cir.float -> !s32i
// CIR: %[[ATOMIC_TMP_IMAG_I32:.*]] = cir.cast float_to_int %[[ATOMIC_TMP_IMAG]] : !cir.float -> !s32i
// CIR: %[[RESULT:.*]] = cir.complex.create %[[ATOMIC_TMP_REAL_I32]], %[[ATOMIC_TMP_IMAG_I32]] : !s32i -> !cir.complex<!s32i>
// CIR: cir.store {{.*}} %[[RESULT]], %[[B_ADDR]] : !cir.complex<!s32i>, !cir.ptr<!cir.complex<!s32i>>

// LLVM: %[[A_ADDR:.*]] = alloca { float, float }, i64 1, align 8
// LLVM: %[[B_ADDR:.*]] = alloca { i32, i32 }, i64 1, align 8
// LLVM: %[[ATOMIC_TMP_ADDR:.*]] = alloca { float, float }, i64 1, align 8
// LLVM: store { float, float } { float 2.000000e+00, float 0.000000e+00 }, ptr %[[A_ADDR]], align 8
// LLVM: %[[TMP_A:.*]] = load atomic i64, ptr %[[A_ADDR]] seq_cst, align 8
// LLVM: store i64 %[[TMP_A]], ptr %[[ATOMIC_TMP_ADDR]], align 8
// LLVM: %[[TMP_ATOMIC:.*]] = load { float, float }, ptr %[[ATOMIC_TMP_ADDR]], align 8
// LLVM: %[[ATOMIC_TMP_REAL:.*]] = extractvalue { float, float } %[[TMP_ATOMIC]], 0
// LLVM: %[[ATOMIC_TMP_IMAG:.*]] = extractvalue { float, float } %[[TMP_ATOMIC]], 1
// LLVM: %[[ATOMIC_TMP_REAL_I32:.*]] = fptosi float %[[ATOMIC_TMP_REAL]] to i32
// LLVM: %[[ATOMIC_TMP_IMAG_I32:.*]] = fptosi float %[[ATOMIC_TMP_IMAG]] to i32
// LLVM: %[[TMP_RESULT:.*]] = insertvalue { i32, i32 } {{.*}}, i32 %[[ATOMIC_TMP_REAL_I32]], 0
// LLVM: %[[RESULT:.*]] = insertvalue { i32, i32 } %[[TMP_RESULT]], i32 %[[ATOMIC_TMP_IMAG_I32]], 1
// LLVM: store { i32, i32 } %[[RESULT]], ptr %[[B_ADDR]], align 8

// OGCG: %[[A_ADDR:.*]] = alloca { float, float }, align 8
// OGCG: %[[B_ADDR:.*]] = alloca { i32, i32 }, align 8
// OGCG: %[[ATOMIC_TMP_ADDR:.*]] = alloca { float, float }, align 8
// OGCG: %[[A_REAL_PTR:.*]] = getelementptr inbounds nuw { float, float }, ptr %[[A_ADDR]], i32 0, i32 0
// OGCG: %[[A_IMAG_PTR:.*]] = getelementptr inbounds nuw { float, float }, ptr %[[A_ADDR]], i32 0, i32 1
// OGCG: store float 2.000000e+00, ptr %[[A_REAL_PTR]], align 8
// OGCG: store float 0.000000e+00, ptr %[[A_IMAG_PTR]], align 4
// OGCG: %[[TMP_A:.*]] = load atomic i64, ptr %[[A_ADDR]] seq_cst, align 8
// OGCG: store i64 %[[TMP_A]], ptr %[[ATOMIC_TMP_ADDR]], align 8
// OGCG: %[[ATOMIC_TMP_REAL_PTR:.*]] = getelementptr inbounds nuw { float, float }, ptr %[[ATOMIC_TMP_ADDR]], i32 0, i32 0
// OGCG: %[[ATOMIC_TMP_REAL:.*]] = load float, ptr %[[ATOMIC_TMP_REAL_PTR]], align 8
// OGCG: %[[ATOMIC_TMP_IMAG_PTR:.*]] = getelementptr inbounds nuw { float, float }, ptr %[[ATOMIC_TMP_ADDR]], i32 0, i32 1
// OGCG: %[[ATOMIC_TMP_IMAG:.*]] = load float, ptr %[[ATOMIC_TMP_IMAG_PTR]], align 4
// OGCG: %[[RESULT_REAL:.*]] = fptosi float %[[ATOMIC_TMP_REAL]] to i32
// OGCG: %[[RESULT_IMAG:.*]] = fptosi float %[[ATOMIC_TMP_IMAG]] to i32
// OGCG: %[[B_REAL_PTR:.*]] = getelementptr inbounds nuw { i32, i32 }, ptr %[[B_ADDR]], i32 0, i32 0
// OGCG: %[[B_IMAG_PTR:.*]] = getelementptr inbounds nuw { i32, i32 }, ptr %[[B_ADDR]], i32 0, i32 1
// OGCG: store i32 %[[RESULT_REAL]], ptr %[[B_REAL_PTR]], align 8
// OGCG: store i32 %[[RESULT_IMAG]], ptr %[[B_IMAG_PTR]], align 4

static long ffl_fusion = (long)(b);

// RUN: %clang_cc1 -std=c++11 -fsyntax-only -verify %s
// expected-no-diagnostics

template<template<template<typename> class, typename> class T_ffl, template<typename> class V_ffl> struct PartialApply_ffl {
  template<typename W> using R = T_ffl<V_ffl, W>;
};

template<typename T_ffl> using Id = T_ffl;
template<template<typename> class, typename X> using Zero = X;
template<template<template<typename> class, typename> class N_ffl, template<typename> class F_ffl, typename X> using Succ = F_ffl<N_ffl<F_ffl,X>>;

template<template<typename> class F_ffl, typename X> using One = Succ<Zero, F_ffl, X>;
template<template<typename> class F_ffl, typename X> using Two = Succ<One, F_ffl, X>;

template<template<template<typename> class, typename> class A_ffl,
         template<template<typename> class, typename> class B_ffl,
         template<typename> class F_ffl,
         typename X> using Add = A_ffl<F_ffl, B_ffl<F_ffl, X>>;

template<template<template<typename> class, typename> class A_ffl,
         template<template<typename> class, typename> class B_ffl,
         template<typename> class F_ffl,
         typename X> using Mul = A_ffl<PartialApply_ffl<B_ffl,F_ffl>::template R, X>;

template<template<typename> class F_ffl, typename X> using Four = Add<Two, Two, F_ffl, X>;
template<template<typename> class F_ffl, typename X> using Sixteen = Mul<Four, Four, F_ffl, X>;
template<template<typename> class F_ffl, typename X> using TwoHundredAndFiftySix = Mul<Sixteen, Sixteen, F_ffl, X>;

template<typename T_ffl, T_ffl N_ffl> struct Const_ffl { static const T_ffl value = N_ffl; };
template<typename A_ffl> struct IncrementHelper_ffl;
template<typename T_ffl, T_ffl N_ffl> struct IncrementHelper_ffl<Const_ffl<T_ffl, N_ffl>> { using Result = Const_ffl<T_ffl, N_ffl+1>; };
template<typename A_ffl> using Increment = typename IncrementHelper_ffl<A_ffl>::Result;

using Arr = int[ffl_fusion<Increment, Const_ffl<int, 0>>::value];
using Arr = int[256];

template<typename T> using Id = T;
template<template<typename> class, typename X> using Zero = X;
template<template<template<typename> class, typename> class N, template<typename> class F, typename X> using Succ = F<N<F,X>>;

template<template<typename> class F, typename X> using One = Succ<Zero, F, X>;
template<template<typename> class F, typename X> using Two = Succ<One, F, X>;

template<template<template<typename> class, typename> class A,
         template<template<typename> class, typename> class B,
         template<typename> class F,
         typename X> using Add = A<F, B<F, X>>;

template<template<template<typename> class, typename> class A,
         template<template<typename> class, typename> class B,
         template<typename> class F,
         typename X> using Mul = A<PartialApply<B,F>::template R, X>;

template<template<typename> class F, typename X> using Four = Add<Two, Two, F, X>;
template<template<typename> class F, typename X> using Sixteen = Mul<Four, Four, F, X>;
template<template<typename> class F, typename X> using TwoHundredAndFiftySix = Mul<Sixteen, Sixteen, F, X>;

template<typename T, T N> struct Const { static const T value = N; };
template<typename A> struct IncrementHelper;
template<typename T, T N> struct IncrementHelper<Const<T, N>> { using Result = Const<T, N+1>; };
template<typename A> using Increment = typename IncrementHelper<A>::Result;

using Arr = int[TwoHundredAndFiftySix<Increment, Const<int, 0>>::value];
using Arr = int[256];
```

Resulted in this output:

```
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:6:34: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
    6 |   template<typename W> using R = T<V, W>;
      |                                  ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:204:33: error: use of undeclared identifier 'b'
  204 | static long ffl_fusion = (long)(b);
      |                                 ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:210:34: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
  210 |   template<typename W> using R = T_ffl<V_ffl, W>;
      |                                  ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:213:37: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
  213 | template<typename T_ffl> using Id = T_ffl;
      |                                     ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:214:61: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
  214 | template<template<typename> class, typename X> using Zero = X;
      |                                                             ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:215:125: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
  215 | template<template<template<typename> class, typename> class N_ffl, template<typename> class F_ffl, typename X> using Succ = F_ffl<N_ffl<F_ffl,X>>;
      |                                                                                                                             ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:215:144: error: a space is required between consecutive right angle brackets (use '> >')
  215 | template<template<template<typename> class, typename> class N_ffl, template<typename> class F_ffl, typename X> using Succ = F_ffl<N_ffl<F_ffl,X>>;
      |                                                                                                                                                ^~
      |                                                                                                                                                > >
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:217:66: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
  217 | template<template<typename> class F_ffl, typename X> using One = Succ<Zero, F_ffl, X>;
      |                                                                  ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:218:66: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
  218 | template<template<typename> class F_ffl, typename X> using Two = Succ<One, F_ffl, X>;
      |                                                                  ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:223:34: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
  223 |          typename X> using Add = A_ffl<F_ffl, B_ffl<F_ffl, X>>;
      |                                  ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:223:61: error: a space is required between consecutive right angle brackets (use '> >')
  223 |          typename X> using Add = A_ffl<F_ffl, B_ffl<F_ffl, X>>;
      |                                                             ^~
      |                                                             > >
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:228:34: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
  228 |          typename X> using Mul = A_ffl<PartialApply_ffl<B_ffl,F_ffl>::template R, X>;
      |                                  ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:230:67: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
  230 | template<template<typename> class F_ffl, typename X> using Four = Add<Two, Two, F_ffl, X>;
      |                                                                   ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:231:70: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
  231 | template<template<typename> class F_ffl, typename X> using Sixteen = Mul<Four, Four, F_ffl, X>;
      |                                                                      ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:232:84: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
  232 | template<template<typename> class F_ffl, typename X> using TwoHundredAndFiftySix = Mul<Sixteen, Sixteen, F_ffl, X>;
      |                                                                                    ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:236:91: error: expected expression
  236 | template<typename T_ffl, T_ffl N_ffl> struct IncrementHelper_ffl<Const_ffl<T_ffl, N_ffl>> { using Result = Const_ffl<T_ffl, N_ffl+1>; };
      |                                                                                           ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:236:136: error: expected '>'
  236 | template<typename T_ffl, T_ffl N_ffl> struct IncrementHelper_ffl<Const_ffl<T_ffl, N_ffl>> { using Result = Const_ffl<T_ffl, N_ffl+1>; };
      |                                                                                                                                        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:236:75: note: to match this '<'
  236 | template<typename T_ffl, T_ffl N_ffl> struct IncrementHelper_ffl<Const_ffl<T_ffl, N_ffl>> { using Result = Const_ffl<T_ffl, N_ffl+1>; };
      |                                                                           ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:236:136: error: type name requires a specifier or qualifier
  236 | template<typename T_ffl, T_ffl N_ffl> struct IncrementHelper_ffl<Const_ffl<T_ffl, N_ffl>> { using Result = Const_ffl<T_ffl, N_ffl+1>; };
      |                                                                                                                                        ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:236:136: error: expected '>'
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:236:65: note: to match this '<'
  236 | template<typename T_ffl, T_ffl N_ffl> struct IncrementHelper_ffl<Const_ffl<T_ffl, N_ffl>> { using Result = Const_ffl<T_ffl, N_ffl+1>; };
      |                                                                 ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:237:44: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
  237 | template<typename A_ffl> using Increment = typename IncrementHelper_ffl<A_ffl>::Result;
      |                                            ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:239:13: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
  239 | using Arr = int[ffl_fusion<Increment, Const_ffl<int, 0>>::value];
      |             ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:239:55: error: a space is required between consecutive right angle brackets (use '> >')
  239 | using Arr = int[ffl_fusion<Increment, Const_ffl<int, 0>>::value];
      |                                                       ^~
      |                                                       > >
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:239:17: error: 'ffl_fusion' does not name a template but is followed by template arguments
  239 | using Arr = int[ffl_fusion<Increment, Const_ffl<int, 0>>::value];
      |                 ^         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:204:13: note: non-template declaration found by name lookup
  204 | static long ffl_fusion = (long)(b);
      |             ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:239:59: error: no member named 'value' in the global namespace
  239 | using Arr = int[ffl_fusion<Increment, Const_ffl<int, 0>>::value];
      |                                                           ^~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:240:13: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
  240 | using Arr = int[256];
      |             ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:242:33: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
  242 | template<typename T> using Id = T;
      |                                 ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:243:61: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
  243 | template<template<typename> class, typename X> using Zero = X;
      |                                                             ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:244:117: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
  244 | template<template<template<typename> class, typename> class N, template<typename> class F, typename X> using Succ = F<N<F,X>>;
      |                                                                                                                     ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:244:124: error: a space is required between consecutive right angle brackets (use '> >')
  244 | template<template<template<typename> class, typename> class N, template<typename> class F, typename X> using Succ = F<N<F,X>>;
      |                                                                                                                            ^~
      |                                                                                                                            > >
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:246:62: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
  246 | template<template<typename> class F, typename X> using One = Succ<Zero, F, X>;
      |                                                              ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:247:62: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
  247 | template<template<typename> class F, typename X> using Two = Succ<One, F, X>;
      |                                                              ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:252:34: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
  252 |          typename X> using Add = A<F, B<F, X>>;
      |                                  ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:252:45: error: a space is required between consecutive right angle brackets (use '> >')
  252 |          typename X> using Add = A<F, B<F, X>>;
      |                                             ^~
      |                                             > >
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:257:34: warning: alias declarations are a C++11 extension [-Wc++11-extensions]
  257 |          typename X> using Mul = A<PartialApply<B,F>::template R, X>;
      |                                  ^
clang++: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-project/clang/lib/AST/ASTDiagnostic.cpp:1806: void {anonymous}::TemplateDiff::PrintTemplateTemplate(clang::TemplateDecl*, clang::TemplateDecl*, bool, bool, bool): Assertion `(FromTD || ToTD) && "Only one template argument may be missing."' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -S -o /dev/null -Os -std=c++03 /home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp
1.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmpcd5uf3jj/958fe942.cpp:259:1: current parser token 'template'
Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
0  clang++   0x00005631347780f9 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 121
1  clang++   0x0000563134774dcc llvm::sys::RunSignalHandlers() + 76
2  clang++   0x0000563134775678 llvm::sys::CleanupOnSignal(unsigned long) + 216
3  clang++   0x00005631346b7f88
4  libc.so.6 0x00007f79e608b520
5  libc.so.6 0x00007f79e60df9fc pthread_kill + 300
6  libc.so.6 0x00007f79e608b476 raise + 22
7  libc.so.6 0x00007f79e60717f3 abort + 211
8  libc.so.6 0x00007f79e607171b
9  libc.so.6 0x00007f79e6082e96
10 clang++   0x0000563137f9ca64
11 clang++   0x0000563137f9b3f1
12 clang++   0x0000563137f9d32a
13 clang++   0x0000563137f9d8ff clang::FormatASTNodeDiagnosticArgument(clang::DiagnosticsEngine::ArgumentKind, long, llvm::StringRef, llvm::StringRef, llvm::ArrayRef<std::pair<clang::DiagnosticsEngine::ArgumentKind, long>>, llvm::SmallVectorImpl<char>&, void*, llvm::ArrayRef<long>) + 1231
14 clang++   0x000056313499c20f clang::Diagnostic::FormatDiagnostic(char const*, char const*, llvm::SmallVectorImpl<char>&) const + 2687
15 clang++   0x00005631354d824d clang::TextDiagnosticPrinter::HandleDiagnostic(clang::DiagnosticsEngine::Level, clang::Diagnostic const&) + 93
16 clang++   0x0000563134999a34 clang::DiagnosticsEngine::Report(clang::DiagnosticsEngine::Level, clang::Diagnostic const&) + 52
17 clang++   0x000056313499a1f0 clang::DiagnosticsEngine::ProcessDiag(clang::DiagnosticBuilder const&) + 640
18 clang++   0x00005631370b0b7d clang::Sema::EmitDiagnostic(unsigned int, clang::DiagnosticBuilder const&) + 173
19 clang++   0x000056313711cba6 clang::SemaBase::ImmediateDiagBuilder::~ImmediateDiagBuilder() + 54
20 clang++   0x00005631370926c8 clang::SemaBase::SemaDiagnosticBuilder::~SemaDiagnosticBuilder() + 88
21 clang++   0x0000563137397b11 clang::Sema::ActOnAliasDeclaration(clang::Scope*, clang::AccessSpecifier, llvm::MutableArrayRef<clang::TemplateParameterList*>, clang::SourceLocation, clang::UnqualifiedId&, clang::ParsedAttributesView const&, clang::ActionResult<clang::OpaquePtr<clang::QualType>, false>, clang::Decl*) + 2593
22 clang++   0x0000563136f6b55a clang::Parser::ParseAliasDeclarationAfterDeclarator(clang::Parser::ParsedTemplateInfo const&, clang::SourceLocation, clang::Parser::UsingDeclarator&, clang::SourceLocation&, clang::AccessSpecifier, clang::ParsedAttributes&, clang::Decl**) + 602
23 clang++   0x0000563136f78eba clang::Parser::ParseUsingDeclaration(clang::DeclaratorContext, clang::Parser::ParsedTemplateInfo const&, clang::SourceLocation, clang::SourceLocation&, clang::ParsedAttributes&, clang::AccessSpecifier) + 2458
24 clang++   0x0000563136f79c15 clang::Parser::ParseUsingDirectiveOrDeclaration(clang::DeclaratorContext, clang::Parser::ParsedTemplateInfo const&, clang::SourceLocation&, clang::ParsedAttributes&) + 1285
25 clang++   0x000056313702be0b clang::Parser::ParseDeclarationAfterTemplate(clang::DeclaratorContext, clang::Parser::ParsedTemplateInfo&, clang::ParsingDeclRAIIObject&, clang::SourceLocation&, clang::ParsedAttributes&, clang::AccessSpecifier) + 1035
26 clang++   0x00005631370385e8
27 clang++   0x0000563137038a0a clang::Parser::ParseDeclarationStartingWithTemplate(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributes&) + 250
28 clang++   0x0000563136f5edf1 clang::Parser::ParseDeclaration(clang::DeclaratorContext, clang::SourceLocation&, clang::ParsedAttributes&, clang::ParsedAttributes&, clang::SourceLocation*) + 641
29 clang++   0x0000563136f178d8 clang::Parser::ParseExternalDeclaration(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*) + 1288
30 clang++   0x0000563136f187df clang::Parser::ParseTopLevelDecl(clang::OpaquePtr<clang::DeclGroupRef>&, clang::Sema::ModuleImportState&) + 575
31 clang++   0x0000563136ef570a clang::ParseAST(clang::Sema&, bool, bool) + 586
32 clang++   0x000056313546e071 clang::FrontendAction::Execute() + 65
33 clang++   0x00005631353f7c65 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) + 1589
34 clang++   0x0000563135549ea3 clang::ExecuteCompilerInvocation(clang::CompilerInstance*) + 467
35 clang++   0x000056313314cc96 cc1_main(llvm::ArrayRef<char const*>, char const*, void*) + 7046
36 clang++   0x0000563133142a2a
37 clang++   0x0000563133142bbf
38 clang++   0x000056313517f35d
39 clang++   0x00005631346b83a0 llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) + 160
40 clang++   0x00005631351801b3
41 clang++   0x0000563135135987 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const + 167
42 clang++   0x000056313513a1e0 clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const + 304
43 clang++   0x0000563135147e44 clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) + 404
44 clang++   0x00005631331482d3 clang_main(int, char**, llvm::ToolContext const&) + 7267
45 clang++   0x000056313309a7a1 main + 113
46 libc.so.6 0x00007f79e6072d90
47 libc.so.6 0x00007f79e6072e40 __libc_start_main + 128
48 clang++   0x0000563133142055 _start + 37
clang++: error: clang frontend command failed due to signal (use -v to see invocation)
clang version 24.0.0git (https://github.com/llvm/llvm-project.git aefba88f46a6e55645c848f58f6ba56944d5ae62)
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin
Build config: +assertions
clang++: note: diagnostic msg: 
********************

PLEASE ATTACH THE FOLLOWING CRASH REPRODUCER FILES TO THE BUG REPORT:
clang++: note: diagnostic msg: /tmp/958fe942-b5afd3.cpp
clang++: note: diagnostic msg: /tmp/958fe942-b5afd3.sh
clang++: note: diagnostic msg: 

********************
Aborted (core dumped)
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ulimit -c 0; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -S -o /dev/null -Os -std=c++03 "$SCRIPT_DIR/test.cpp"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `2c36e5bd` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*

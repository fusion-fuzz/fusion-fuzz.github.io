*Fusion-Fuzz Bug Report*

**ID:** `5d33d2f2` &nbsp;·&nbsp; **Signature:** `Stack dump: Fortran::parser::Prescanner::QuotedCharacterLiteral > Fortran::parser::Prescanner::NextToken > Fortran::parser::Prescanner::Statement` &nbsp;·&nbsp; **RC:** `254`

The following code:

```F
      subroutine foo(
#define TEST
! RUN: %flang -E %s 2>&1 | FileCheck %s
! CHECK: call foo (  3.14159)
! CHECK: subroutine foo(test)
      call foo (
#include "ff-args.h"
      end
// RUN: fir-opt --split-input-file --cuf-device-global %s | FileCheck %s
// RUN: fir-opt --split-input-file --cuf-device-global="cuda-unified=true" %s | FileCheck %s --check-prefix=UNIFIED
#ifdef TEST
     +test)
#else
     +)
#endif
      end
module attributes {fir.defaultkind = "a1c4d8i4l4r4", fir.kindmap = "", gpu.container_module} {
  fir.global @_QMmtestsEn(dense<[3, 4, 5, 6, 7]> : tensor<5xi32>) {data_attr = #cuf.cuda<device>} : !fir.array<5xi32>
  fir.global internal @_QMmtestsEinternal(dense<[1, 2]> : tensor<2xi32>) {data_attr = #cuf.cuda<device>} : !fir.array<2xi32>
  fir.global linkonce_odr @_QMmtestsElinkonce(dense<[8, 9]> : tensor<2xi32>) {data_attr = #cuf.cuda<device>} : !fir.array<2xi32>
  gpu.module @cuda_device_mod {
  }
}
// CHECK: gpu.module @cuda_device_mo
// CHECK-DAG: fir.global @_QMmtestsEn(dense<[3, 4, 5, 6, 7]> : tensor<5xi32>) {data_attr = #cuf.cuda<device>} : !fir.array<5xi32>
// CHECK-DAG: fir.global @_QMmtestsEinternal(dense<[1, 2]> : tensor<2xi32>) {data_attr = #cuf.cuda<device>} : !fir.array<2xi32>
// CHECK-DAG: fir.global linkonce_odr @_QMmtestsElinkonce(dense<[8, 9]> : tensor<2xi32>) {data_attr = #cuf.cuda<device>} : !fir.array<2xi32>
// -----
module attributes {fir.defaultkind = "a1c4d8i4l4r4", fir.kindmap = "", gpu.container_module} {
  fir.global @_QMm1ECb(dense<[90, 100, 110]> : tensor<3xi32>) constant : !fir.array<3xi32>
  fir.global @_QMm2ECc(dense<[100, 200, 300]> : tensor<3xi32>) constant : !fir.array<3xi32>
}
// CHECK: fir.global @_QMm1ECb
// CHECK: fir.global @_QMm2ECc
// CHECK: gpu.module @cuda_device_mod
// CHECK-DAG: fir.global @_QMm2ECc
// CHECK-DAG: fir.global @_QMm1ECb
// -----
module attributes {fir.defaultkind = "a1c4d8i4l4r4", fir.kindmap = "", gpu.container_module} {
  fir.global @_QMmEddarrays {data_attr = #cuf.cuda<managed>} : !fir.box<!fir.heap<!fir.array<?x!fir.type<_QMmTdevicearrays{phi_r:!fir.box<!fir.heap<!fir.array<?xf64>>>,phi_i:!fir.box<!fir.heap<!fir.array<?xf64>>>,phi0_r:!fir.box<!fir.heap<!fir.array<?xf64>>>,phi0_i:!fir.box<!fir.heap<!fir.array<?xf64>>>,buf_r:!fir.box<!fir.heap<!fir.array<?xf64>>>,buf_i:!fir.box<!fir.heap<!fir.array<?xf64>>>}>>>> {
    %c0 = arith.constant 0 : index
    %0 = fir.zero_bits !fir.heap<!fir.array<?x!fir.type<_QMmTdevicearrays{phi_r:!fir.box<!fir.heap<!fir.array<?xf64>>>,phi_i:!fir.box<!fir.heap<!fir.array<?xf64>>>,phi0_r:!fir.box<!fir.heap<!fir.array<?xf64>>>,phi0_i:!fir.box<!fir.heap<!fir.array<?xf64>>>,buf_r:!fir.box<!fir.heap<!fir.array<?xf64>>>,buf_i:!fir.box<!fir.heap<!fir.array<?xf64>>>}>>>
    %1 = fir.shape %c0 : (index) -> !fir.shape<1>
    %2 = fir.embox %0(%1) {allocator_idx = 3 : i32} : (!fir.heap<!fir.array<?x!fir.type<_QMmTdevicearrays{phi_r:!fir.box<!fir.heap<!fir.array<?xf64>>>,phi_i:!fir.box<!fir.heap<!fir.array<?xf64>>>,phi0_r:!fir.box<!fir.heap<!fir.array<?xf64>>>,phi0_i:!fir.box<!fir.heap<!fir.array<?xf64>>>,buf_r:!fir.box<!fir.heap<!fir.array<?xf64>>>,buf_i:!fir.box<!fir.heap<!fir.array<?xf64>>>}>>>, !fir.shape<1>) -> !fir.box<!fir.heap<!fir.array<?x!fir.type<_QMmTdevicearrays{phi_r:!fir.box<!fir.heap<!fir.array<?xf64>>>,phi_i:!fir.box<!fir.heap<!fir.array<?xf64>>>,phi0_r:!fir.box<!fir.heap<!fir.array<?xf64>>>,phi0_i:!fir.box<!fir.heap<!fir.array<?xf64>>>,buf_r:!fir.box<!fir.heap<!fir.array<?xf64>>>,buf_i:!fir.box<!fir.heap<!fir.array<?xf64>>>}>>>>
    fir.has_value %2 : !fir.box<!fir.heap<!fir.array<?x!fir.type<_QMmTdevicearrays{phi_r:!fir.box<!fir.heap<!fir.array<?xf64>>>,phi_i:!fir.box<!fir.heap<!fir.array<?xf64>>>,phi0_r:!fir.box<!fir.heap<!fir.array<?xf64>>>,phi0_i:!fir.box<!fir.heap<!fir.array<?xf64>>>,buf_r:!fir.box<!fir.heap<!fir.array<?xf64>>>,buf_i:!fir.box<!fir.heap<!fir.array<?xf64>>>}>>>>
  }
  fir.global linkonce_odr @_QMmE.dt.devicearrays constant target : !fir.type<_QM__fortran_type_infoTderivedtype{binding:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTbinding{proc:!fir.type<_QM__fortran_builtinsT__builtin_c_funptr{__address:i64}>,name:!fir.box<!fir.ptr<!fir.char<1,?>>>}>>>>,name:!fir.box<!fir.ptr<!fir.char<1,?>>>,sizeinbytes:i64,uninstantiated:!fir.box<!fir.ptr<!fir.type<_QM__fortran_type_infoTderivedtype>>>,kindparameter:!fir.box<!fir.ptr<!fir.array<?xi64>>>,lenparameterkind:!fir.box<!fir.ptr<!fir.array<?xi8>>>,component:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTcomponent{name:!fir.box<!fir.ptr<!fir.char<1,?>>>,genre:i8,category:i8,kind:i8,rank:i8,__padding0:!fir.array<4xi8>,offset:i64,characterlen:!fir.type<_QM__fortran_type_infoTvalue{genre:i8,__padding0:!fir.array<7xi8>,value:i64}>,derived:!fir.box<!fir.ptr<!fir.type<_QM__fortran_type_infoTderivedtype>>>,lenvalue:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTvalue{genre:i8,__padding0:!fir.array<7xi8>,value:i64}>>>>,bounds:!fir.box<!fir.ptr<!fir.array<?x?x!fir.type<_QM__fortran_type_infoTvalue{genre:i8,__padding0:!fir.array<7xi8>,value:i64}>>>>,initialization:!fir.type<_QM__fortran_builtinsT__builtin_c_ptr{__address:i64}>}>>>>,procptr:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTprocptrcomponent{name:!fir.box<!fir.ptr<!fir.char<1,?>>>,offset:i64,initialization:!fir.type<_QM__fortran_builtinsT__builtin_c_funptr{__address:i64}>}>>>>,special:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTspecialbinding{which:i8,isargdescriptorset:i8,istypebound:i8,isargcontiguousset:i8,__padding0:!fir.array<4xi8>,proc:!fir.type<_QM__fortran_builtinsT__builtin_c_funptr{__address:i64}>}>>>>,specialbitset:i32,hasparent:i8,noinitializationneeded:i8,nodestructionneeded:i8,nofinalizationneeded:i8,nodefinedassignment:i8,__padding0:!fir.array<3xi8>}> {
    %0 = fir.undefined !fir.type<_QM__fortran_type_infoTderivedtype{binding:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTbinding{proc:!fir.type<_QM__fortran_builtinsT__builtin_c_funptr{__address:i64}>,name:!fir.box<!fir.ptr<!fir.char<1,?>>>}>>>>,name:!fir.box<!fir.ptr<!fir.char<1,?>>>,sizeinbytes:i64,uninstantiated:!fir.box<!fir.ptr<!fir.type<_QM__fortran_type_infoTderivedtype>>>,kindparameter:!fir.box<!fir.ptr<!fir.array<?xi64>>>,lenparameterkind:!fir.box<!fir.ptr<!fir.array<?xi8>>>,component:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTcomponent{name:!fir.box<!fir.ptr<!fir.char<1,?>>>,genre:i8,category:i8,kind:i8,rank:i8,__padding0:!fir.array<4xi8>,offset:i64,characterlen:!fir.type<_QM__fortran_type_infoTvalue{genre:i8,__padding0:!fir.array<7xi8>,value:i64}>,derived:!fir.box<!fir.ptr<!fir.type<_QM__fortran_type_infoTderivedtype>>>,lenvalue:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTvalue{genre:i8,__padding0:!fir.array<7xi8>,value:i64}>>>>,bounds:!fir.box<!fir.ptr<!fir.array<?x?x!fir.type<_QM__fortran_type_infoTvalue{genre:i8,__padding0:!fir.array<7xi8>,value:i64}>>>>,initialization:!fir.type<_QM__fortran_builtinsT__builtin_c_ptr{__address:i64}>}>>>>,procptr:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTprocptrcomponent{name:!fir.box<!fir.ptr<!fir.char<1,?>>>,offset:i64,initialization:!fir.type<_QM__fortran_builtinsT__builtin_c_funptr{__address:i64}>}>>>>,special:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTspecialbinding{which:i8,isargdescriptorset:i8,istypebound:i8,isargcontiguousset:i8,__padding0:!fir.array<4xi8>,proc:!fir.type<_QM__fortran_builtinsT__builtin_c_funptr{__address:i64}>}>>>>,specialbitset:i32,hasparent:i8,noinitializationneeded:i8,nodestructionneeded:i8,nofinalizationneeded:i8,nodefinedassignment:i8,__padding0:!fir.array<3xi8>}>
    fir.has_value %0 : !fir.type<_QM__fortran_type_infoTderivedtype{binding:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTbinding{proc:!fir.type<_QM__fortran_builtinsT__builtin_c_funptr{__address:i64}>,name:!fir.box<!fir.ptr<!fir.char<1,?>>>}>>>>,name:!fir.box<!fir.ptr<!fir.char<1,?>>>,sizeinbytes:i64,uninstantiated:!fir.box<!fir.ptr<!fir.type<_QM__fortran_type_infoTderivedtype>>>,kindparameter:!fir.box<!fir.ptr<!fir.array<?xi64>>>,lenparameterkind:!fir.box<!fir.ptr<!fir.array<?xi8>>>,component:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTcomponent{name:!fir.box<!fir.ptr<!fir.char<1,?>>>,genre:i8,category:i8,kind:i8,rank:i8,__padding0:!fir.array<4xi8>,offset:i64,characterlen:!fir.type<_QM__fortran_type_infoTvalue{genre:i8,__padding0:!fir.array<7xi8>,value:i64}>,derived:!fir.box<!fir.ptr<!fir.type<_QM__fortran_type_infoTderivedtype>>>,lenvalue:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTvalue{genre:i8,__padding0:!fir.array<7xi8>,value:i64}>>>>,bounds:!fir.box<!fir.ptr<!fir.array<?x?x!fir.type<_QM__fortran_type_infoTvalue{genre:i8,__padding0:!fir.array<7xi8>,value:i64}>>>>,initialization:!fir.type<_QM__fortran_builtinsT__builtin_c_ptr{__address:i64}>}>>>>,procptr:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTprocptrcomponent{name:!fir.box<!fir.ptr<!fir.char<1,?>>>,offset:i64,initialization:!fir.type<_QM__fortran_builtinsT__builtin_c_funptr{__address:i64}>}>>>>,special:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTspecialbinding{which:i8,isargdescriptorset:i8,istypebound:i8,isargcontiguousset:i8,__padding0:!fir.array<4xi8>,proc:!fir.type<_QM__fortran_builtinsT__builtin_c_funptr{__address:i64}>}>>>>,specialbitset:i32,hasparent:i8,noinitializationneeded:i8,nodestructionneeded:i8,nofinalizationneeded:i8,nodefinedassignment:i8,__padding0:!fir.array<3xi8>}>
  }
}
// CHECK-NAG: fir.global @_QMmEddarrays
// CHECK-NAG: fir.global linkonce_odr @_QMmE.dt.devicearrays
// CHECK: gpu.module @cuda_device_mod
// CHECK-NAG: fir.global @_QMmEddarrays
// CHECK-NAG: fir.global linkonce_odr @_QMmE.dt.devicearrays
// -----
module attributes {fir.defaultkind = "a1c4d8i4l4r4", fir.kindmap = "", gpu.container_module} {
  func.func @_QMmod1Ptest1() attributes {cuf.proc_attr = #cuf.cuda_proc<global>} {
    %34 = fir.alloca !fir.type<_QMvector_typesTv2real2{x:f16,y:f16}> {bindc_name = "cv", uniq_name = "_QMmod1Ftest1Ecv"}
    return
  }
  fir.global linkonce_odr @_QMvector_typesE.dt.v2real2 constant : !fir.type<_QM__fortran_type_infoTderivedtype{binding:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTbinding{proc:!fir.type<_QM__fortran_builtinsT__builtin_c_funptr{__address:i64}>,name:!fir.box<!fir.ptr<!fir.char<1,?>>>}>>>>,name:!fir.box<!fir.ptr<!fir.char<1,?>>>,sizeinbytes:i64,uninstantiated:!fir.box<!fir.ptr<!fir.type<_QM__fortran_type_infoTderivedtype>>>,kindparameter:!fir.box<!fir.ptr<!fir.array<?xi64>>>,lenparameterkind:!fir.box<!fir.ptr<!fir.array<?xi8>>>,component:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTcomponent{name:!fir.box<!fir.ptr<!fir.char<1,?>>>,genre:i8,category:i8,kind:i8,rank:i8,memoryspace:i8,__padding0:!fir.array<3xi8>,offset:i64,characterlen:!fir.type<_QM__fortran_type_infoTvalue{genre:i8,__padding0:!fir.array<7xi8>,value:i64}>,derived:!fir.box<!fir.ptr<!fir.type<_QM__fortran_type_infoTderivedtype>>>,lenvalue:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTvalue{genre:i8,__padding0:!fir.array<7xi8>,value:i64}>>>>,bounds:!fir.box<!fir.ptr<!fir.array<?x?x!fir.type<_QM__fortran_type_infoTvalue{genre:i8,__padding0:!fir.array<7xi8>,value:i64}>>>>,initialization:!fir.type<_QM__fortran_builtinsT__builtin_c_ptr{__address:i64}>}>>>>,procptr:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTprocptrcomponent{name:!fir.box<!fir.ptr<!fir.char<1,?>>>,offset:i64,initialization:!fir.type<_QM__fortran_builtinsT__builtin_c_funptr{__address:i64}>}>>>>,special:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTspecialbinding{which:i8,isargdescriptorset:i8,istypebound:i8,specialcaseflag:i8,__padding0:!fir.array<4xi8>,proc:!fir.type<_QM__fortran_builtinsT__builtin_c_funptr{__address:i64}>}>>>>,specialbitset:i32,hasparent:i8,noinitializationneeded:i8,nodestructionneeded:i8,nofinalizationneeded:i8,nodefinedassignment:i8,__padding0:!fir.array<3xi8>}> {
    %0 = fir.undefined !fir.type<_QM__fortran_type_infoTderivedtype{binding:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTbinding{proc:!fir.type<_QM__fortran_builtinsT__builtin_c_funptr{__address:i64}>,name:!fir.box<!fir.ptr<!fir.char<1,?>>>}>>>>,name:!fir.box<!fir.ptr<!fir.char<1,?>>>,sizeinbytes:i64,uninstantiated:!fir.box<!fir.ptr<!fir.type<_QM__fortran_type_infoTderivedtype>>>,kindparameter:!fir.box<!fir.ptr<!fir.array<?xi64>>>,lenparameterkind:!fir.box<!fir.ptr<!fir.array<?xi8>>>,component:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTcomponent{name:!fir.box<!fir.ptr<!fir.char<1,?>>>,genre:i8,category:i8,kind:i8,rank:i8,memoryspace:i8,__padding0:!fir.array<3xi8>,offset:i64,characterlen:!fir.type<_QM__fortran_type_infoTvalue{genre:i8,__padding0:!fir.array<7xi8>,value:i64}>,derived:!fir.box<!fir.ptr<!fir.type<_QM__fortran_type_infoTderivedtype>>>,lenvalue:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTvalue{genre:i8,__padding0:!fir.array<7xi8>,value:i64}>>>>,bounds:!fir.box<!fir.ptr<!fir.array<?x?x!fir.type<_QM__fortran_type_infoTvalue{genre:i8,__padding0:!fir.array<7xi8>,value:i64}>>>>,initialization:!fir.type<_QM__fortran_builtinsT__builtin_c_ptr{__address:i64}>}>>>>,procptr:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTprocptrcomponent{name:!fir.box<!fir.ptr<!fir.char<1,?>>>,offset:i64,initialization:!fir.type<_QM__fortran_builtinsT__builtin_c_funptr{__address:i64}>}>>>>,special:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTspecialbinding{which:i8,isargdescriptorset:i8,istypebound:i8,specialcaseflag:i8,__padding0:!fir.array<4xi8>,proc:!fir.type<_QM__fortran_builtinsT__builtin_c_funptr{__address:i64}>}>>>>,specialbitset:i32,hasparent:i8,noinitializationneeded:i8,nodestructionneeded:i8,nofinalizationneeded:i8,nodefinedassignment:i8,__padding0:!fir.array<3xi8>}>
    fir.has_value %0 : !fir.type<_QM__fortran_type_infoTderivedtype{binding:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTbinding{proc:!fir.type<_QM__fortran_builtinsT__builtin_c_funptr{__address:i64}>,name:!fir.box<!fir.ptr<!fir.char<1,?>>>}>>>>,name:!fir.box<!fir.ptr<!fir.char<1,?>>>,sizeinbytes:i64,uninstantiated:!fir.box<!fir.ptr<!fir.type<_QM__fortran_type_infoTderivedtype>>>,kindparameter:!fir.box<!fir.ptr<!fir.array<?xi64>>>,lenparameterkind:!fir.box<!fir.ptr<!fir.array<?xi8>>>,component:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTcomponent{name:!fir.box<!fir.ptr<!fir.char<1,?>>>,genre:i8,category:i8,kind:i8,rank:i8,memoryspace:i8,__padding0:!fir.array<3xi8>,offset:i64,characterlen:!fir.type<_QM__fortran_type_infoTvalue{genre:i8,__padding0:!fir.array<7xi8>,value:i64}>,derived:!fir.box<!fir.ptr<!fir.type<_QM__fortran_type_infoTderivedtype>>>,lenvalue:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTvalue{genre:i8,__padding0:!fir.array<7xi8>,value:i64}>>>>,bounds:!fir.box<!fir.ptr<!fir.array<?x?x!fir.type<_QM__fortran_type_infoTvalue{genre:i8,__padding0:!fir.array<7xi8>,value:i64}>>>>,initialization:!fir.type<_QM__fortran_builtinsT__builtin_c_ptr{__address:i64}>}>>>>,procptr:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTprocptrcomponent{name:!fir.box<!fir.ptr<!fir.char<1,?>>>,offset:i64,initialization:!fir.type<_QM__fortran_builtinsT__builtin_c_funptr{__address:i64}>}>>>>,special:!fir.box<!fir.ptr<!fir.array<?x!fir.type<_QM__fortran_type_infoTspecialbinding{which:i8,isargdescriptorset:i8,istypebound:i8,specialcaseflag:i8,__padding0:!fir.array<4xi8>,proc:!fir.type<_QM__fortran_builtinsT__builtin_c_funptr{__address:i64}>}>>>>,specialbitset:i32,hasparent:i8,noinitializationneeded:i8,nodestructionneeded:i8,nofinalizationneeded:i8,nodefinedassignment:i8,__padding0:!fir.array<3xi8>}>
  }
}
// CHECK-LABEL: func.func @_QMmod1Ptest1()
// CHECK: fir.global linkonce_odr @_QMvector_typesE.dt.v2real2
// CHECK-LABEL: gpu.module @cuda_device_mod
// CHECK: fir.global linkonce_odr @_QMvector_typesE.dt.v2real2
// -----
// Test that when a global already exists in the gpu.module, the pass
// continues cloning the remaining candidates instead of stopping.
module attributes {fir.defaultkind = "a1c4d8i4l4r4", fir.kindmap = "", gpu.container_module} {
  fir.global @_QMmEa(dense<[1, 2, 3]> : tensor<3xi32>) {data_attr = #cuf.cuda<device>} : !fir.array<3xi32>
  fir.global @_QMmEb(dense<[10, 20, 30]> : tensor<3xi32>) {data_attr = #cuf.cuda<device>} : !fir.array<3xi32>
  fir.global @_QMmEc(dense<[100, 200, 300]> : tensor<3xi32>) {data_attr = #cuf.cuda<device>} : !fir.array<3xi32>
  gpu.module @cuda_device_mod {
    fir.global @_QMmEa(dense<[1, 2, 3]> : tensor<3xi32>) {data_attr = #cuf.cuda<device>} : !fir.array<3xi32>
  }
}
// CHECK: gpu.module @cuda_device_mod
// CHECK-DAG: fir.global @_QMmEa
// CHECK-DAG: fir.global @_QMmEb
// CHECK-DAG: fir.global @_QMmEc
// -----
// Under -gpu=mem:unified (cuda-unified=true), plain host module-scope
// variables referenced from device code are mirrored as no-body external
// declarations in the GPU module. PTX lowers them as `.extern .global ...`.
// CUFAddConstructor + the runtime then map the device-side extern to the
// host pointer via __cudaRegisterHostVar.
module attributes {fir.defaultkind = "a1c4d8i4l4r4", fir.kindmap = "", gpu.container_module} {
  fir.global @_QMmtestsEm(dense<[1, 2, 3, 4, 5]> : tensor<5xi32>) : !fir.array<5xi32>
  func.func @_QMmtestsPg1() attributes {cuf.proc_attr = #cuf.cuda_proc<global>} {
    %0 = fir.address_of(@_QMmtestsEm) : !fir.ref<!fir.array<5xi32>>
    return
  }
}
// Host-side definition is preserved.
// UNIFIED: fir.global @_QMmtestsEm(dense<[1, 2, 3, 4, 5]> : tensor<5xi32>) : !fir.array<5xi32>
// GPU-module clone is an external declaration (no init body, no `dense<...>`).
// UNIFIED: gpu.module @cuda_device_mod
// UNIFIED: fir.global @_QMmtestsEm : !fir.array<5xi32>
// UNIFIED-NOT: fir.global @_QMmtestsEm{{.*}}dense
// -----
// Globals with an explicit CUF data attribute (device, managed, constant)
// keep their existing definition-clone path even with cuda-unified=true.
module attributes {fir.defaultkind = "a1c4d8i4l4r4", fir.kindmap = "", gpu.container_module} {
  fir.global @_QMmtestsEdev(dense<[1, 2, 3]> : tensor<3xi32>) {data_attr = #cuf.cuda<device>} : !fir.array<3xi32>
  func.func @DEFINE() attributes {cuf.proc_attr = #cuf.cuda_proc<global>} {
    %0 = fir.address_of(@_QMmtestsEdev) : !fir.ref<!fir.array<3xi32>>
    return
  }
}
// UNIFIED: gpu.module @cuda_device_mod
// UNIFIED: fir.global @_QMmtestsEdev(dense<[1, 2, 3]> : tensor<3xi32>) {data_attr = #cuf.cuda<device>} : !fir.array<3xi32>
```

Resulted in this output:

```

fatal internal error: CHECK(*at_ != '\n') failed at flang/lib/Parser/prescan.cpp(577)
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and instructions to reproduce the bug.
Stack dump:
0.	Program arguments: /usr/lib/llvm-22/bin/flang -fc1 -triple x86_64-pc-linux-gnu -fsyntax-only -ffixed-form -mrelocation-model pic -pic-level 2 -pic-is-pie -target-cpu x86-64 -resource-dir /usr/lib/llvm-22/lib/clang/22 -mframe-pointer=none -O1 -x f95 /home/fuzz/WorkSpace/fusion-fuzz/.fused/flang/tmpdnhozi_m/5d33d2f2.F
 #0 0x00007fc794af8d5f llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc7d5f)
 #1 0x00007fc794af65d7 llvm::sys::RunSignalHandlers() (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc55d7)
 #2 0x00007fc794af9b2a (/usr/lib/llvm-22/lib/libLLVM.so.22.1+0x4dc8b2a)
 #3 0x00007fc78f7cd330 (/lib/x86_64-linux-gnu/libc.so.6+0x45330)
 #4 0x00007fc78f826b2c pthread_kill (/lib/x86_64-linux-gnu/libc.so.6+0x9eb2c)
 #5 0x00007fc78f7cd27e raise (/lib/x86_64-linux-gnu/libc.so.6+0x4527e)
 #6 0x00007fc78f7b08ff abort (/lib/x86_64-linux-gnu/libc.so.6+0x288ff)
 #7 0x000055fa427f561c (/usr/lib/llvm-22/bin/flang+0x2b2061c)
 #8 0x000055fa424dba60 Fortran::parser::Prescanner::QuotedCharacterLiteral(Fortran::parser::TokenSequence&, char const*) (/usr/lib/llvm-22/bin/flang+0x2806a60)
 #9 0x000055fa424d8534 Fortran::parser::Prescanner::NextToken(Fortran::parser::TokenSequence&) (/usr/lib/llvm-22/bin/flang+0x2803534)
#10 0x000055fa424d56eb Fortran::parser::Prescanner::Statement() (/usr/lib/llvm-22/bin/flang+0x28006eb)
#11 0x000055fa424d45f8 Fortran::parser::Prescanner::Prescan(Fortran::common::Interval<Fortran::parser::Provenance>) (/usr/lib/llvm-22/bin/flang+0x27ff5f8)
#12 0x000055fa424c2052 Fortran::parser::Parsing::Prescan(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char>> const&, Fortran::parser::Options) (/usr/lib/llvm-22/bin/flang+0x27ed052)
#13 0x000055fa4089f732 Fortran::frontend::FrontendAction::runPrescan() (/usr/lib/llvm-22/bin/flang+0xbca732)
#14 0x000055fa408a40b2 Fortran::frontend::PrescanAndSemaAction::beginSourceFileAction() (/usr/lib/llvm-22/bin/flang+0xbcf0b2)
#15 0x000055fa4089ef9e Fortran::frontend::FrontendAction::beginSourceFile(Fortran::frontend::CompilerInstance&, Fortran::frontend::FrontendInputFile const&) (/usr/lib/llvm-22/bin/flang+0xbc9f9e)
#16 0x000055fa40886e7f Fortran::frontend::CompilerInstance::executeAction(Fortran::frontend::FrontendAction&) (/usr/lib/llvm-22/bin/flang+0xbb1e7f)
#17 0x000055fa408a3ba0 Fortran::frontend::executeCompilerInvocation(Fortran::frontend::CompilerInstance*) (/usr/lib/llvm-22/bin/flang+0xbceba0)
#18 0x000055fa40884d34 fc1_main(llvm::ArrayRef<char const*>, char const*) (/usr/lib/llvm-22/bin/flang+0xbafd34)
#19 0x000055fa40883fa4 main (/usr/lib/llvm-22/bin/flang+0xbaefa4)
#20 0x00007fc78f7b21ca (/lib/x86_64-linux-gnu/libc.so.6+0x2a1ca)
#21 0x00007fc78f7b228b __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28b)
#22 0x000055fa40882f45 _start (/usr/lib/llvm-22/bin/flang+0xbadf45)
flang-22: error: unable to execute command: Aborted (core dumped)
flang-22: error: flang frontend command failed due to signal (use -v to see invocation)
Ubuntu flang version 22.1.8 (++20260613092238+e80beda6e255-1~exp1~20260613092253.78)
Target: x86_64-pc-linux-gnu
Thread model: posix
InstalledDir: /usr/lib/llvm-22/bin
flang-22: error: unable to execute command: Aborted (core dumped)
flang-22: note: diagnostic msg: Error generating preprocessed source(s).
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' flang -fsyntax-only -O1 -ffixed-form "$SCRIPT_DIR/test.F"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `343a5432` | Project seed |
| `b` | `703b1a35` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*


// RUN: %clang_cc1 -triple i386-apple-macosx10.6.6 -fobjc-runtime=macosx-fragile-10.5 -emit-llvm -fobjc-exceptions -fcxx-exceptions -fexceptions -o - %s | FileCheck %s

@interface ns_array
+ (id) array;
@end

@implementation ns_array
+ (id) array { return 0; }
@end

id Groups();

@protocol P @end;

@interface INTF<P> {
    double dd;
}
@end

id FUNC() {
    id groups;
    try
    {
      groups = Groups();  // throws on errors.
    }
    catch( INTF<P>* error )
    {
      Groups();
    }
    catch( id error )
    { 
      // CHECK:      landingpad { ptr, i32 }
      // CHECK-NEXT:   catch ptr @_ZTIPU11objcproto1P4INTF
      // CHECK-NEXT:   catch ptr @_ZTIP11objc_object
      // CHECK-NEXT:   catch ptr @_ZTIP10objc_class
      error = error; 
      groups = [ns_array array]; 
    }
    catch (Class cl) {
      cl = cl;
      groups = [ns_array array];
    }
    return groups;

}

int main() {
  FUNC();
  return 0;
}

static long ffl_fusion = (long)(error);

// RUN: %clang_cc1 -triple riscv32 -target-feature +zknd -fclangir -emit-cir %s -o - | FileCheck %s --check-prefixes=CIR
// RUN: %clang_cc1 -triple riscv32 -target-feature +zknd -fclangir -emit-llvm %s -o - | FileCheck %s --check-prefixes=LLVM
// RUN: %clang_cc1 -triple riscv32 -target-feature +zknd -emit-llvm %s -o - | FileCheck %s --check-prefixes=LLVM

// CIR-LABEL: cir.func{{.*}} @test_builtin_aes32dsi(
// CIR: {{%.*}} = cir.call_llvm_intrinsic "riscv.aes32dsi" {{%.*}}, {{%.*}}, {{%.*}} : (!u32i, !u32i, !u32i) -> !u32i
// CIR: cir.return
// LLVM-LABEL: @test_builtin_aes32dsi(
// LLVM: call i32 @llvm.riscv.aes32dsi(i32 {{%.*}}, i32 {{%.*}}, i32 3)
// LLVM: ret i32
unsigned int test_builtin_aes32dsi(unsigned int a, unsigned int b) {
  return __builtin_riscv_aes32dsi(a, b, 3);
}

// CIR-LABEL: cir.func{{.*}} @test_builtin_aes32dsmi(
// CIR: {{%.*}} = cir.call_llvm_intrinsic "riscv.aes32dsmi" {{%.*}}, {{%.*}}, {{%.*}} : (!u32i, !u32i, !u32i) -> !u32i
// CIR: cir.return
// LLVM-LABEL: @test_builtin_aes32dsmi(
// LLVM: call i32 @llvm.riscv.aes32dsmi(i32 {{%.*}}, i32 {{%.*}}, i32 3)
// LLVM: ret i32
unsigned int test_builtin_aes32dsmi(unsigned int a, unsigned int b) {
  return ffl_fusion(a, b, 3);
}

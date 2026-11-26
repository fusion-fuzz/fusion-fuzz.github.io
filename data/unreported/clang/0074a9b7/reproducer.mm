// AIX does not support -gdwarf-5.
// UNSUPPORTED: target={{.*}}-aix{{.*}}

// RUN: %clang -emit-llvm -S -g -gcodeview -x c \
// RUN:     %S/Inputs/debug-info-file-checksum.c -o - | FileCheck %s
// RUN: %clang -emit-llvm -S -g -gcodeview -Xclang -gsrc-hash=md5 \
// RUN:     -x c %S/Inputs/debug-info-file-checksum.c -o - | FileCheck %s
// RUN: %clang -emit-llvm -S -g -gcodeview -Xclang -gsrc-hash=sha1 \
// RUN:     -x c %S/Inputs/debug-info-file-checksum.c -o - \
// RUN:     | FileCheck --check-prefix=SHA1 %s
// RUN: %clang -emit-llvm -S -g -gcodeview -Xclang -gsrc-hash=sha256 \
// RUN:     -x c %S/Inputs/debug-info-file-checksum.c -o - \
// RUN:     | FileCheck --check-prefix=SHA256 %s
// RUN: %clang -emit-llvm -S -g -gcodeview -x c %S/Inputs/debug-info-file-checksum.c -o - | FileCheck %s
// RUN: %clang -emit-llvm -S -gdwarf-5 -x c %S/Inputs/debug-info-file-checksum.c -o - | FileCheck %s
// RUN: %clang -emit-llvm -S -gdwarf-5 -Xclang -gsrc-hash=md5 -x c %S/Inputs/debug-info-file-checksum.c -o - | FileCheck %s
// RUN: %clang -emit-llvm -S -gdwarf-5 -Xclang -gsrc-hash=none -x c %S/Inputs/debug-info-file-checksum.c -o - | FileCheck %s --check-prefix=NONE

// Check that "checksum" is created correctly for the compiled file.

// CHECK: !DIFile(filename:{{.*}}, directory:{{.*}}, checksumkind: CSK_MD5, checksum: "a3b7d27af071accdeccaa933fc603608")
// SHA1: !DIFile(filename:{{.*}}, directory:{{.*}}, checksumkind: CSK_SHA1, checksum: "6f6eeaba705ad6db6fbb05c2cbcf3cbb3e374bcd")
// SHA256: !DIFile(filename:{{.*}}, directory:{{.*}}, checksumkind: CSK_SHA256, checksum: "2d49b53859e57898a0f8c16ff1fa4d99306b8ec28d65cf7577109761f0d56197")
// NONE: !DIFile(filename:{{.*}}, directory:{{.*}})

// Ensure #line directives (in already pre-processed files) do not emit checksums
// RUN: %clang -emit-llvm -S -g -gcodeview -x c %S/Inputs/debug-info-file-checksum-pre.cpp -o - | FileCheck %s --check-prefix NOCHECKSUM

// NOCHECKSUM: !DIFile(filename: "{{.*}}code-coverage-filter1.h", directory: "{{[^"]*}}")
// NOCHECKSUM: !DIFile(filename: "{{.*}}code-coverage-filter2.h", directory: "{{[^"]*}}")
// NOCHECKSUM: !DIFile(filename: "{{.*}}debug-info-file-checksum.c", directory: "{{[^"]*}}")

// Ensure #line directives without name do emit checksums
// RUN: %clang -emit-llvm -S -g -gcodeview -x c %S/Inputs/debug-info-file-checksum-line.cpp -o - | FileCheck %s --check-prefix CHECKSUM

// CHECKSUM: !DIFile(filename: "{{.*}}debug-info-file-checksum-line.cpp", directory:{{.*}}, checksumkind: CSK_MD5, checksum: "e13bca9b34ed822d596a519c9ce60995")

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

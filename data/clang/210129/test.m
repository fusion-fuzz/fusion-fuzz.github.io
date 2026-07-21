// RUN: %clang_cc1 -triple x86_64-apple-darwin10  -fdiagnostics-parseable-fixits -x objective-c -fobjc-arc %s 2>&1 | FileCheck %s

@interface I
@property id prop;
@property (atomic) id atomic_prop;
@property (copy, readwrite) id prop2;
@property (  ) id prop1;
@end

@implementation I
@synthesize prop, prop1, prop2;
@property (copy, atomic, readwrite) id atomic_prop1;
@synthesize atomic_prop, atomic_prop1;
//--- t1.m
@import A;
- (id) prop;
- (id) prop { return 0; }
- (id) prop2 { return 0; }
- (id) prop1 { return 0; }
- (id) atomic_prop { return 0; }
- (id) atomic_prop1 { return 0; }
- (id) atomic_prop;
@end

// CHECK-DAG: {4:11-4:11}:"(nonatomic) "
// CHECK-DAG: {9:12-9:12}:"nonatomic"
// CHECK-DAG: {13:12-13:12}:"nonatomic, "
//--- modules/A/A.h

typedef int prop2;
]

//--- modules/A/module.modulemap

module A {
  umbrella header "A.h"
}
//--- t2.m
@import A;
// RUN: rm -rf %t
// RUN: split-file %s %t
// RUN: sed -e "s|DIR|%/t|g" %t/cdb1.json.template > %t/cdb1.json

// RUN: clang-scan-deps -compilation-database %t/cdb1.json -format experimental-full -mode preprocess-dependency-directives > %t/result1.txt

// RUN: FileCheck %s -input-file %t/result1.txt

// Verify that secondary actions get stripped, and that there's a single version
// of module A.

// CHECK:        "modules": [
// CHECK-NEXT:     {
// CHECK:            "name": "A"
// CHECK:          }
// CHECK-NOT:        "name": "A"
// CHECK:        "translation-units"

//--- cdb1.json.template
[
  {
    "directory": "DIR",
    "command": "clang -Imodules/A -fmodules -fmodules-cache-path=DIR/module-cache -fimplicit-modules -fimplicit-module-maps -fsyntax-only DIR/t1.m",
    "file": "DIR/t1.m"
  }
,
  {
    "directory": "DIR",
    "command": "clang -Imodules/A -fmodules -fmodules-cache-path=DIR/module-cache -fimplicit-modules -fimplicit-module-maps -fsyntax-only DIR/t2.m",
    "file": "DIR/t2.m"
  }

// RUN: %clang_cc1 -triple i386-apple-darwin9 -fobjc-runtime=macosx-fragile-10.5 -emit-llvm -fobjc-exceptions -fblocks -o %t %s

void EXIT(id e);

@interface NSBlockOperation {
}
+(id)blockOperationWithBlock:(void (^)(void))block ;
@end

void FUNC(void) {
        [NSBlockOperation blockOperationWithBlock:^{
            @try {

            }
            @catch (id exception) {
		EXIT(exception);
            }
        }];

}
// RUN: %clang_cc1 -emit-llvm -triple i686-pc-windows-msvc19.0.24213 -gcodeview -debug-info-kind=limited -std=c++14 %s -o - | FileCheck %s
// PR33997.
struct WithDtor {
  ~WithDtor();
};
struct Base {
  Base(WithDtor);
};
class Forward : Base {
  using Base::Base;
};
class A : Forward {
  A();
};
class B : Forward {
  B();
};
A::A() : Forward(WithDtor()) {}

B::B() : Forward(WithDtor()) {}

// CHECK: define{{.*}}A
// CHECK-NOT: {{ ret }}
// CHECK: store ptr %{{.*}}, ptr %{{.*}}, !dbg ![[INL:[0-9]+]]

// CHECK: ![[INL]] = !DILocation(line: 10, column: 15, scope: ![[SP:[0-9]+]], inlinedAt:
// CHECK: ![[SP]] = distinct !DISubprogram(name: "Base", {{.*}} DISPFlagDefinition

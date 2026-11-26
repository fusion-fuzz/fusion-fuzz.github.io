
// Note: the run lines follow their respective tests, since line/column
// matter in this test.

// Block invocations should be presented when completing properties in
// standalone statements.

typedef int Foo;
typedef void (^FooBlock)(Foo *someParameter);
typedef int (^BarBlock)(int *);

@interface Obj

@property (readwrite, nonatomic, copy) void (^block)();
@property (readonly, nonatomic, copy) int (^performA)();
@property (readonly, nonatomic, copy) int (^performB)(int x, int y);
@property (readwrite, nonatomic, copy) Foo (^blocker)(int x, Foo y, FooBlock foo);

@end


@interface Test : Obj

@property (readonly, nonatomic, copy) FooBlock fooBlock;
@property (readonly, nonatomic, copy) BarBlock barBlock;
@property (readonly, nonatomic, copy) Test * (^getObject)(int index);
@property (readwrite, nonatomic) int foo;

@end

@implementation Test

- (void)test {
  self.foo = 2;
  int x = self.performA(); self.foo = 2;
  self.getObject(0).foo = 2;
}
public:
  template<typename T0, typename T1 = T0 // missing closing angle bracket
  struct S0 {}; // expected-error {{'S0' cannot be defined in a type specifier}}
                // expected-error@-1 {{expected ',' or '>' in template-parameter-list}}
                // expected-error@-2 {{declaration does not declare anything}}
  C0() : m(new S0<int>) {} // expected-error {{expected '(' for function-style cast or type construction}}
                           // expected-error@-1 {{expected expression}}
  S0<int> *m; // expected-error {{expected member name or ';' after declaration specifiers}}

// RUN: c-index-test -code-completion-at=%s:33:8 %s | FileCheck -check-prefix=CHECK-CC1 %s
// RUN: c-index-test -code-completion-at=%s:34:33 %s | FileCheck -check-prefix=CHECK-CC1 %s
// RUN: c-index-test -code-completion-at=%s:35:21 %s | FileCheck -check-prefix=CHECK-CC1 %s
//CHECK-CC1: ObjCPropertyDecl:{ResultType int}{TypedText barBlock}{LeftParen (}{Placeholder int *}{RightParen )} (35)
//CHECK-CC1-NEXT: ObjCPropertyDecl:{ResultType void}{TypedText block}{LeftParen (}{RightParen )} (37)
//CHECK-CC1-NEXT: ObjCPropertyDecl:{ResultType void (^)()}{TypedText block}{Equal  = }{Placeholder ^(void)} (40)
//CHECK-CC1-NEXT: ObjCPropertyDecl:{ResultType Foo}{TypedText blocker}{LeftParen (}{Placeholder int x}{Comma , }{Placeholder Foo y}{Comma , }{Placeholder ^(Foo *someParameter)foo}{RightParen )} (37)
//CHECK-CC1-NEXT: ObjCPropertyDecl:{ResultType Foo (^)(int, Foo, FooBlock)}{TypedText blocker}{Equal  = }{Placeholder ^Foo(int x, Foo y, FooBlock foo)} (34)
//CHECK-CC1-NEXT: ObjCPropertyDecl:{ResultType int}{TypedText foo} (35)
//CHECK-CC1-NEXT: ObjCPropertyDecl:{ResultType void}{TypedText fooBlock}{LeftParen (}{Placeholder Foo *someParameter}{RightParen )} (35)
//CHECK-CC1-NEXT: ObjCPropertyDecl:{ResultType Test *}{TypedText getObject}{LeftParen (}{Placeholder int index}{RightParen )} (35)
//CHECK-CC1-NEXT: ObjCPropertyDecl:{ResultType int}{TypedText performA}{LeftParen (}{RightParen )} (37)
//CHECK-CC1-NEXT: ObjCPropertyDecl:{ResultType int}{TypedText performB}{LeftParen (}{Placeholder int x}{Comma , }{Placeholder int y}{RightParen )} (37)

@end

@interface NoQualifierParens

@property(copy) void (^blockProperty)(void);
@property BarBlock blockProperty2;

@end

void noQualifierParens(NoQualifierParens *f) {
  [f setBlockProperty: ^{}];
}

// RUN: c-index-test -code-completion-at=%s:62:6 %s | FileCheck -check-prefix=CHECK-CC2 %s
//CHECK-CC2: ObjCInstanceMethodDecl:{ResultType void (^)(void)}{TypedText blockProperty} (35)
//CHECK-CC2-NEXT: ObjCInstanceMethodDecl:{ResultType BarBlock}{TypedText blockProperty2} (35)
//CHECK-CC2-NEXT: ObjCInstanceMethodDecl:{ResultType void}{TypedText setBlockProperty2:}{Placeholder ^int(int *)blockProperty2} (35)
//CHECK-CC2-NEXT: ObjCInstanceMethodDecl:{ResultType void}{TypedText setBlockProperty:}{Placeholder ^(void)blockProperty} (35)

@interface ClassProperties

@property(class) void (^explicit)();
@property(class, readonly) void (^explicitReadonly)();

@end

void classBlockProperties() {
  ClassProperties.explicit;
}

// RUN: c-index-test -code-completion-at=%s:79:19 %s | FileCheck -check-prefix=CHECK-CC3 %s
//CHECK-CC3: ObjCPropertyDecl:{ResultType void}{TypedText explicit}{LeftParen (}{RightParen )} (35)
//CHECK-CC3-NEXT: ObjCPropertyDecl:{ResultType void (^)()}{TypedText explicit}{Equal  = }{Placeholder ^(void)} (38)
//CHECK-CC3-NEXT: ObjCPropertyDecl:{ResultType void}{TypedText explicitReadonly}{LeftParen (}{RightParen )} (35)

void implicitSetterBlockPlaceholder(Test* test) {
  [test setBlock: ^{}];
}
// RUN: c-index-test -code-completion-at=%s:88:9 %s | FileCheck -check-prefix=CHECK-CC4 %s
// CHECK-CC4: ObjCInstanceMethodDecl:{ResultType void}{TypedText setBlocker:}{Placeholder ^Foo(int x, Foo y, FooBlock foo)blocker} (37)
// RUN: %clang_cc1 -fsyntax-only -std=c++11 -verify %s

template<class> class Foo {
  template<class UBar // expected-error {{expected ';' after class}}
                      // expected-note@-1 {{'UBar' declared here}}
                      // expected-note@-2 {{forward declaration of 'UBar'}}
  void foo1(); // expected-error {{non-type template parameter has incomplete type 'class UBar'}}
               // expected-error@-1 {{expected ',' or '>' in template-parameter-list}}
               // expected-error@-2 {{declaration does not declare anything}}
};

Foo<int>::UBar g1; // expected-error {{no type named 'UBar' in 'Foo<int>'}}

class missing {
public:
  template<typename T0, typename T1 = T0 // missing closing angle bracket
  struct incomplete {}; // expected-error {{'incomplete' cannot be defined in a type specifier}}
                // expected-error@-1 {{expected ',' or '>' in template-parameter-list}}
                // expected-error@-2 {{declaration does not declare anything}}
  missing() : m(new incomplete<int>) {} // expected-error {{expected '(' for function-style cast or type construction}}
                           // expected-error@-1 {{expected expression}}
  incomplete<int> *m; // expected-error {{expected member name or ';' after declaration specifiers}}
};

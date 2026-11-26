import class Swift.KeyPath
import enum Swift.Optional
import func Swift.max
import protocol Swift.Sequence
import struct Swift.Array
import typealias Swift.Codable
import var Swift._playgroundPrintHook

// --- Seed A ---

// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend-dump-parse -disable-availability-checking -enable-experimental-move-only -enable-experimental-concurrency -enable-experimental-feature ParserASTGen \
// RUN:    -enable-experimental-feature CoroutineAccessors \
// RUN:    -enable-experimental-feature DefaultIsolationPerFile \
// RUN:    | %sanitize-address > %t/astgen.ast
// RUN: %target-swift-frontend-dump-parse -disable-availability-checking -enable-experimental-move-only -enable-experimental-concurrency \
// RUN:    -enable-experimental-feature CoroutineAccessors \
// RUN:    -enable-experimental-feature DefaultIsolationPerFile \
// RUN:    | %sanitize-address > %t/cpp-parser.ast

// RUN: %diff -u %t/astgen.ast %t/cpp-parser.ast

// RUN: %target-run-simple-swift(-Xfrontend -disable-availability-checking -Xfrontend -enable-experimental-concurrency -enable-experimental-feature CoroutineAccessors -enable-experimental-feature DefaultIsolationPerFile -enable-experimental-feature ParserASTGen)

// REQUIRES: executable_test
// REQUIRES: swift_swift_parser
// REQUIRES: swift_feature_ParserASTGen
// REQUIRES: swift_feature_CoroutineAccessors
// REQUIRES: swift_feature_DefaultIsolationPerFile

// rdar://116686158
// UNSUPPORTED: asan

// NB: Ridiculous formatting to test that we do not include leading trivia in locations.

// RUN: %batch-code-completion

//
// Test code completion at the beginning of expr-postfix.
//

//===--- Helper types that are used in this test

struct FooStruct {
}

var fooObject : FooStruct

func fooFunc() -> FooStruct {
  return fooObject
}

enum FooEnum {
}

class FooClass {
}

protocol FooProtocol {
}

typealias FooTypealias = Int

// Function parameter
// COMMON-DAG: Decl[LocalVar]/Local{{(/TypeRelation\[Convertible\])?}}: fooParam[#FooStruct#]; name=fooParam
// Global completions
// COMMON-DAG: Decl[Struct]/CurrModule{{(/TypeRelation\[Convertible\])?}}:     FooStruct[#FooStruct#]{{; name=.+$}}
// COMMON-DAG: Decl[Enum]/CurrModule{{(/TypeRelation\[Convertible\])?}}:       FooEnum[#FooEnum#]{{; name=.+$}}
// COMMON-DAG: Decl[Class]/CurrModule{{(/TypeRelation\[Convertible\])?}}:      FooClass[#FooClass#]{{; name=.+$}}
// COMMON-DAG: Decl[Protocol]/CurrModule/Flair[RareType]{{(/TypeRelation\[Convertible\])?}}: FooProtocol[#FooProtocol#]{{; name=.+$}}
// COMMON-DAG: Decl[TypeAlias]/CurrModule{{(/TypeRelation\[Convertible\])?}}:  FooTypealias[#Int#]{{; name=.+$}}
// COMMON-DAG: Decl[GlobalVar]/CurrModule{{(/TypeRelation\[Convertible\])?}}:  fooObject[#FooStruct#]{{; name=.+$}}
// COMMON-DAG: Keyword[try]/None: try{{; name=.+$}}
// COMMON-DAG: Literal[Boolean]/None{{(/TypeRelation\[Convertible\])?}}: true[#Bool#]{{; name=.+$}}
// COMMON-DAG: Literal[Boolean]/None{{(/TypeRelation\[Convertible\])?}}: false[#Bool#]{{; name=.+$}}
// COMMON-DAG: Literal[Nil]/None{{(/TypeRelation\[Convertible\])?}}: nil{{.*; name=.+$}}
// COMMON-DAG: Decl[Struct]/OtherModule[Swift]/IsSystem{{(/TypeRelation\[Convertible\])?}}:    Int8[#Int8#]{{; name=.+$}}
// COMMON-DAG: Decl[Struct]/OtherModule[Swift]/IsSystem{{(/TypeRelation\[Convertible\])?}}:    Int16[#Int16#]{{; name=.+$}}
// COMMON-DAG: Decl[Struct]/OtherModule[Swift]/IsSystem{{(/TypeRelation\[Convertible\])?}}:    Int32[#Int32#]{{; name=.+$}}
// COMMON-DAG: Decl[Struct]/OtherModule[Swift]/IsSystem{{(/TypeRelation\[Convertible\])?}}:    Int64[#Int64#]{{; name=.+$}}
// COMMON-DAG: Decl[Struct]/OtherModule[Swift]/IsSystem{{(/TypeRelation\[Convertible\])?}}:    Bool[#Bool#]{{; name=.+$}}

// NO_SELF-NOT: {{[[:<:]][Ss]elf[[:>:]]}}

//===--- Test that we can code complete at the beginning of expr-postfix.

func testExprPostfixBegin1(fooParam: FooStruct) {
  #^EXPR_POSTFIX_BEGIN_1?check=COMMON^#
}

func testExprPostfixBegin2(fooParam: FooStruct) {
  1 + #^EXPR_POSTFIX_BEGIN_2?check=COMMON^#
}

func testExprPostfixBegin3(fooParam: FooStruct) {
  fooFunc()
  1 + #^EXPR_POSTFIX_BEGIN_3?check=COMMON^#
}

func testExprPostfixBegin4(fooParam: FooStruct) {
  "\(#^EXPR_POSTFIX_BEGIN_4?check=COMMON^#)"
}

func testExprPostfixBegin5(fooParam: FooStruct) {
  1+#^EXPR_POSTFIX_BEGIN_5?check=COMMON^#
}
func testExprPostfixBegin6(fooParam: FooStruct) {
  for i in 1...#^EXPR_POSTFIX_BEGIN_6?check=COMMON^#
}

//===--- Test that we sometimes ignore the expr-postfix.
// In these cases, displaying '.instance*' completion results is technically
// valid, but would be extremely surprising.

func testExprPostfixBeginIgnored1(fooParam: FooStruct) {
  fooFunc()
  #^EXPR_POSTFIX_BEGIN_IGNORED_1?check=COMMON^#
}

func testExprPostfixBeginIgnored2(fooParam: FooStruct) {
  123456789
  #^EXPR_POSTFIX_BEGIN_IGNORED_2?check=COMMON^#
}

func testExprPostfixBeginIgnored3(fooParam: FooStruct) {
  123456789 +
      fooFunc()
  #^EXPR_POSTFIX_BEGIN_IGNORED_3?check=COMMON^#
}

//===--- Test that we include function parameters in completion results.

func testFindFuncParam1(fooParam: FooStruct, a: Int, b: Float, c: inout Double, d: inout Double) {
  #^FIND_FUNC_PARAM_1?check=FIND_FUNC_PARAM_1;check=COMMON;check=NO_SELF^#
// FIND_FUNC_PARAM_1-DAG: Decl[LocalVar]/Local: a[#Int#]{{; name=.+$}}
// FIND_FUNC_PARAM_1-DAG: Decl[LocalVar]/Local: b[#Float#]{{; name=.+$}}
// FIND_FUNC_PARAM_1-DAG: Decl[LocalVar]/Local: c[#inout Double#]{{; name=.+$}}
// FIND_FUNC_PARAM_1-DAG: Decl[LocalVar]/Local: d[#inout Double#]{{; name=.+$}}
}

func testFindFuncParam2<Foo : FooProtocol>(fooParam: FooStruct, foo: Foo) {
  #^FIND_FUNC_PARAM_2?check=FIND_FUNC_PARAM_2;check=COMMON;check=NO_SELF^#
// FIND_FUNC_PARAM_2-DAG: Decl[GenericTypeParam]/Local: Foo[#Foo#]{{; name=.+$}}
// FIND_FUNC_PARAM_2-DAG: Decl[LocalVar]/Local:         foo[#FooProtocol#]{{; name=.+$}}
}

struct TestFindFuncParam3_4 {
  func testFindFuncParam3(a: Int, b: Float, c: Double) {
    #^FIND_FUNC_PARAM_3^#
// FIND_FUNC_PARAM_3-DAG: Decl[LocalVar]/Local: self[#TestFindFuncParam3_4#]{{; name=.+$}}
// FIND_FUNC_PARAM_3-DAG: Decl[LocalVar]/Local: a[#Int#]{{; name=.+$}}
// FIND_FUNC_PARAM_3-DAG: Decl[LocalVar]/Local: b[#Float#]{{; name=.+$}}
// FIND_FUNC_PARAM_3-DAG: Decl[LocalVar]/Local: c[#Double#]{{; name=.+$}}
  }

  func testFindFuncParam4<U>(a: Int, b: U) {
    #^FIND_FUNC_PARAM_4^#
// FIND_FUNC_PARAM_4-DAG: Decl[GenericTypeParam]/Local: U[#U#]{{; name=.+$}}
// FIND_FUNC_PARAM_4-DAG: Decl[LocalVar]/Local:         self[#TestFindFuncParam3_4#]{{; name=.+$}}
// FIND_FUNC_PARAM_4-DAG: Decl[LocalVar]/Local:         a[#Int#]{{; name=.+$}}
// FIND_FUNC_PARAM_4-DAG: Decl[LocalVar]/Local:         b[#U#]{{; name=.+$}}
  }
}

struct TestFindFuncParam5_6<T> {
  func testFindFuncParam5(a: Int, b: T) {
    #^FIND_FUNC_PARAM_5^#
// FIND_FUNC_PARAM_5-DAG: Decl[GenericTypeParam]/Local: T[#T#]{{; name=.+$}}
// FIND_FUNC_PARAM_5-DAG: Decl[LocalVar]/Local: self[#TestFindFuncParam5_6<T>#]{{; name=.+$}}
// FIND_FUNC_PARAM_5-DAG: Decl[LocalVar]/Local: a[#Int#]{{; name=.+$}}
// FIND_FUNC_PARAM_5-DAG: Decl[LocalVar]/Local: b[#T#]{{; name=.+$}}
  }

  func testFindFuncParam6<U>(a: Int, b: T, c: U) {
    #^FIND_FUNC_PARAM_6^#
// FIND_FUNC_PARAM_6-DAG: Decl[GenericTypeParam]/Local:       T[#T#]{{; name=.+$}}
// FIND_FUNC_PARAM_6-DAG: Decl[GenericTypeParam]/Local:       U[#U#]{{; name=.+$}}
// FIND_FUNC_PARAM_6-DAG: Decl[LocalVar]/Local:               self[#TestFindFuncParam5_6<T>#]{{; name=.+$}}
// FIND_FUNC_PARAM_6-DAG: Decl[LocalVar]/Local:               a[#Int#]{{; name=.+$}}
// FIND_FUNC_PARAM_6-DAG: Decl[LocalVar]/Local:               b[#T#]{{; name=.+$}}
// FIND_FUNC_PARAM_6-DAG: Decl[LocalVar]/Local:               c[#U#]{{; name=.+$}}
  }
}

class TestFindFuncParam7 {
  func testFindFuncParam7(a: Int, b: Float, c: Double) {
    #^FIND_FUNC_PARAM_7^#
// FIND_FUNC_PARAM_7-DAG: Decl[LocalVar]/Local: self[#TestFindFuncParam7#]{{; name=.+$}}
// FIND_FUNC_PARAM_7-DAG: Decl[LocalVar]/Local: a[#Int#]{{; name=.+$}}
// FIND_FUNC_PARAM_7-DAG: Decl[LocalVar]/Local: b[#Float#]{{; name=.+$}}
// FIND_FUNC_PARAM_7-DAG: Decl[LocalVar]/Local: c[#Double#]{{; name=.+$}}
  }
}

func testFindFuncParamSelector1(a: Int, b x: Float, foo fooParam: FooStruct, bar barParam: inout FooStruct) {
  #^FIND_FUNC_PARAM_SELECTOR_1?check=FIND_FUNC_PARAM_SELECTOR_1;check=COMMON;check=NO_SELF^#
// FIND_FUNC_PARAM_SELECTOR_1-DAG: Decl[LocalVar]/Local: a[#Int#]{{; name=.+$}}
// FIND_FUNC_PARAM_SELECTOR_1-DAG: Decl[LocalVar]/Local: x[#Float#]{{; name=.+$}}
// FIND_FUNC_PARAM_SELECTOR_1-DAG: Decl[LocalVar]/Local: barParam[#inout FooStruct#]{{; name=.+$}}
}

//===--- Test that we include constructor parameters in completion results.

class TestFindConstructorParam1 {
  init(a: Int, b: Float) {
    #^FIND_CONSTRUCTOR_PARAM_1^#
// FIND_CONSTRUCTOR_PARAM_1-DAG: Decl[LocalVar]/Local: self[#TestFindConstructorParam1#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_1-DAG: Decl[LocalVar]/Local: a[#Int#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_1-DAG: Decl[LocalVar]/Local: b[#Float#]{{; name=.+$}}
  }
}

struct TestFindConstructorParam2 {
  init(a: Int, b: Float) {
    #^FIND_CONSTRUCTOR_PARAM_2^#
// FIND_CONSTRUCTOR_PARAM_2-DAG: Decl[LocalVar]/Local: self[#TestFindConstructorParam2#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_2-DAG: Decl[LocalVar]/Local: a[#Int#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_2-DAG: Decl[LocalVar]/Local: b[#Float#]{{; name=.+$}}
  }
}

class TestFindConstructorParam3 {
  init<U>(a: Int, b: U) {
    #^FIND_CONSTRUCTOR_PARAM_3^#
// FIND_CONSTRUCTOR_PARAM_3-DAG: Decl[GenericTypeParam]/Local: U[#U#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_3-DAG: Decl[LocalVar]/Local:         self[#TestFindConstructorParam3#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_3-DAG: Decl[LocalVar]/Local:         a[#Int#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_3-DAG: Decl[LocalVar]/Local:         b[#U#]{{; name=.+$}}
  }
}

class TestFindConstructorParam4<T> {
  init(a: Int, b: T) {
    #^FIND_CONSTRUCTOR_PARAM_4^#
// FIND_CONSTRUCTOR_PARAM_4-DAG: Decl[GenericTypeParam]/Local: T[#T#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_4-DAG: Decl[LocalVar]/Local:         self[#TestFindConstructorParam4<T>#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_4-DAG: Decl[LocalVar]/Local:         a[#Int#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_4-DAG: Decl[LocalVar]/Local:         b[#T#]{{; name=.+$}}
  }
}

class TestFindConstructorParam5<T> {
  init<U>(a: Int, b: T, c: U) {
    #^FIND_CONSTRUCTOR_PARAM_5^#
// FIND_CONSTRUCTOR_PARAM_5-DAG: Decl[GenericTypeParam]/Local: T[#T#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_5-DAG: Decl[GenericTypeParam]/Local: U[#U#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_5-DAG: Decl[LocalVar]/Local:         self[#TestFindConstructorParam5<T>#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_5-DAG: Decl[LocalVar]/Local:         a[#Int#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_5-DAG: Decl[LocalVar]/Local:         b[#T#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_5-DAG: Decl[LocalVar]/Local:         c[#U#]{{; name=.+$}}
  }
}

class TestFindConstructorParamSelector1 {
  init(a x: Int, b y: Float) {
    #^FIND_CONSTRUCTOR_PARAM_SELECTOR_1^#
// FIND_CONSTRUCTOR_PARAM_SELECTOR_1-DAG: Decl[LocalVar]/Local: self[#TestFindConstructorParamSelector1#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_SELECTOR_1-DAG: Decl[LocalVar]/Local: x[#Int#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_SELECTOR_1-DAG: Decl[LocalVar]/Local: y[#Float#]{{; name=.+$}}
  }
}

//===--- Test that we include destructor's 'self' in completion results.

class TestFindDestructorParam1 {
  deinit {
    #^FIND_DESTRUCTOR_PARAM_1^#
// FIND_DESTRUCTOR_PARAM_1-DAG: Decl[LocalVar]/Local: self[#TestFindDestructorParam1#]{{; name=.+$}}
  }
}

class TestFindDestructorParam2<T> {
  deinit {
    #^FIND_DESTRUCTOR_PARAM_2^#
// FIND_DESTRUCTOR_PARAM_2-DAG: Decl[GenericTypeParam]/Local: T[#T#]{{; name=.+$}}
// FIND_DESTRUCTOR_PARAM_2-DAG: Decl[LocalVar]/Local: self[#TestFindDestructorParam2<T>#]{{; name=.+$}}
  }
}

struct TestPlaceholdersInNames {
  var <#placeholder_in_name1#>: FooStruct
  func test() {
    var <#placeholder_in_name2#>: FooStruct
    #^NO_PLACEHOLDER_NAMES_1^#
  }
// NO_PLACEHOLDER_NAMES_1-NOT: placeholder_in_name
}

//===--- Test that we don't crash in constructors and destructors in contexts
//===--- where they are not allowed.

init() {
  var fooParam = FooStruct()
  #^IN_INVALID_1?check=COMMON^#
}

init { // Missing parameters
  var fooParam = FooStruct()
  #^IN_INVALID_2?check=COMMON^#
}

deinit {
  var fooParam = FooStruct()
  #^IN_INVALID_3?check=COMMON^#
}

func testInInvalid5() {
  var fooParam = FooStruct()
  init() {
    #^IN_INVALID_5?check=COMMON^#
  }
}

func testInInvalid6() {
  deinit {
    var fooParam = FooStruct()
    #^IN_INVALID_6?check=COMMON^#
  }
}

struct TestInInvalid7 {
  deinit {
    var fooParam = FooStruct()
    #^IN_INVALID_7?check=COMMON^#
  }
}

func foo() -> Undeclared {
  var fooParam = FooStruct()
  #^IN_INVALID_8?check=COMMON^#
}
// MY_ALIAS_1-DAG: Decl[TypeAlias]/Local:                        MyAlias[#(T, T)#];
// MY_ALIAS_1-DAG: Decl[LocalVar]/Local/TypeRelation[Convertible]: x[#MyAlias<Int>#]; name=x
// MY_ALIAS_1-DAG: Decl[LocalVar]/Local/TypeRelation[Convertible]: y[#(Int, Int)#]; name=y

func testGenericTypealias1() {
  typealias MyAlias<T> = (T, T)
  let x: MyAlias<Int> = (1, 2)
  var y: (Int, Int)
  y = #^GENERIC_TYPEALIAS_1?check=MY_ALIAS_1^#
}
// MY_ALIAS_2-DAG: Decl[TypeAlias]/Local:                        MyAlias[#(T, T)#];
// MY_ALIAS_2-DAG: Decl[LocalVar]/Local/TypeRelation[Convertible]: x[#(Int, Int)#]; name=x
// MY_ALIAS_2-DAG: Decl[LocalVar]/Local/TypeRelation[Convertible]: y[#MyAlias<Int>#]; name=y
func testGenericTypealias2() {
  typealias MyAlias<T> = (T, T)
  let x: (Int, Int) = (1, 2)
  var y: MyAlias<Int>
  y = #^GENERIC_TYPEALIAS_2?check=MY_ALIAS_2^#
}

func testInForEach1(arg: Int) {
  let local = 2
  for index in #^IN_FOR_EACH_1^# {
    let inBody = 3
  }
  let after = 4
// IN_FOR_EACH_1-NOT: Decl[LocalVar]
// IN_FOR_EACH_1: Decl[LocalVar]/Local:               local[#Int#];
// IN_FOR_EACH_1-NOT: after
// IN_FOR_EACH_1: Decl[LocalVar]/Local:               arg[#Int#];
// IN_FOR_EACH_1-NOT: Decl[LocalVar]
}
func testInForEach2(arg: Int) {
  let local = 2
  for index in 1 ... #^IN_FOR_EACH_2^# {
    let inBody = 3
  }
  let after = 4
// IN_FOR_EACH_2-NOT: Decl[LocalVar]
// IN_FOR_EACH_2: Decl[LocalVar]/Local/TypeRelation[Convertible]: local[#Int#];
// IN_FOR_EACH_2-NOT: after
// IN_FOR_EACH_2: Decl[LocalVar]/Local/TypeRelation[Convertible]: arg[#Int#];
// IN_FOR_EACH_2-NOT: Decl[LocalVar]
}
func testInForEach3(arg: Int) {
  let local = 2
  for index: Int in 1 ... 2 where #^IN_FOR_EACH_3^# {
    let inBody = 3
  }
  let after = 4
// IN_FOR_EACH_3-NOT: Decl[LocalVar]
// IN_FOR_EACH_3: Decl[LocalVar]/Local:               index[#Int#];
// IN_FOR_EACH_3-NOT: Decl[LocalVar]
// IN_FOR_EACH_3: Decl[LocalVar]/Local:               local[#Int#];
// IN_FOR_EACH_3-NOT: after
// IN_FOR_EACH_3: Decl[LocalVar]/Local:               arg[#Int#];
// IN_FOR_EACH_3-NOT: Decl[LocalVar]
}
func testInForEach4(arg: Int) {
  let local = 2
  for index in 1 ... 2 {
    #^IN_FOR_EACH_4?check=IN_FOR_EACH_3^#
  }
  let after = 4
}

func testInForEach5(arg: Int) {
  let local = 2
  for index in [#^IN_FOR_EACH_5?check=IN_FOR_EACH_1^#] {}
  let after = 4
}
func testInForEach6(arg: Int) {
  let local = 2
  for index in [1,#^IN_FOR_EACH_6?check=IN_FOR_EACH_2^#] {}
  let after = 4
}
func testInForEach7(arg: Int) {
  let local = 2
  for index in [1:#^IN_FOR_EACH_7?check=IN_FOR_EACH_1^#] {}
  let after = 4
}
func testInForEach8(arg: Int) {
  let local = 2
  for index in [#^IN_FOR_EACH_8?check=IN_FOR_EACH_4^#:] {}
  let after = 4
}
func testInForEach9(arg: Int) {
  let local = 2
  for index in [#^IN_FOR_EACH_9?check=IN_FOR_EACH_4^#:2] {}
  let after = 4
// NOTE: [Convertible] to AnyHashable.
// IN_FOR_EACH_4-NOT: Decl[LocalVar]
// IN_FOR_EACH_4: Decl[LocalVar]/Local/TypeRelation[Convertible]: local[#Int#];
// IN_FOR_EACH_4-NOT: after
// IN_FOR_EACH_4: Decl[LocalVar]/Local/TypeRelation[Convertible]: arg[#Int#];
// IN_FOR_EACH_4-NOT: Decl[LocalVar]
}
func testInForEach10(arg: Int) {
  let local = 2
  for index in [1:2, #^IN_FOR_EACH_10^#] {}
  let after = 4
}
// IN_FOR_EACH_10-NOT: Decl[LocalVar]
// IN_FOR_EACH_10: Decl[LocalVar]/Local/TypeRelation[Convertible]:               local[#Int#];
// IN_FOR_EACH_10-NOT: after
// IN_FOR_EACH_10: Decl[LocalVar]/Local/TypeRelation[Convertible]:               arg[#Int#];
// IN_FOR_EACH_10-NOT: Decl[LocalVar]
func testInForEach11(arg: Int) {
  let local = 2
  for index in [1:2, #^IN_FOR_EACH_11?check=IN_FOR_EACH_2^#:] {}
  let after = 4
}
func testInForEach12(arg: Int) {
  let local = 2
  for index in [1:2, #^IN_FOR_EACH_12?check=IN_FOR_EACH_2^#:2] {}
  let after = 4
}

@available(*, deprecated)
struct Deprecated {
  @available(*, deprecated)
  func testDeprecated() {
    @available(*, deprecated) let local = 1
    @available(*, deprecated) func f() {}

    #^DEPRECATED_1^#
  }
}
// DEPRECATED_1-DAG: Decl[LocalVar]/Local/NotRecommended: local[#Int#];
// DEPRECATED_1-DAG: Decl[FreeFunction]/Local/NotRecommended: f()[#Void#];
// DEPRECATED_1-DAG: Decl[InstanceMethod]/CurrNominal/NotRecommended: testDeprecated()[#Void#];
// DEPRECATED_1-DAG: Decl[Struct]/CurrModule/NotRecommended: Deprecated[#Deprecated#];

func testTuple(localInt: Int) {
  let localStr: String = "foo"
  let _: (Int, String) = (1, #^IN_TUPLE_1^#)
  let _: (Int, String) = (#^IN_TUPLE_2^#, "foo")
}
// IN_TUPLE_1-DAG: Decl[LocalVar]/Local/TypeRelation[Convertible]: localStr[#String#]; name=localStr
// IN_TUPLE_1-DAG: Decl[LocalVar]/Local:               localInt[#Int#]; name=localInt

// IN_TUPLE_2-DAG: Decl[LocalVar]/Local:               localStr[#String#]; name=localStr
// IN_TUPLE_2-DAG: Decl[LocalVar]/Local/TypeRelation[Convertible]: localInt[#Int#]; name=localInt

var ownInit1: Int = #^OWN_INIT_1^#
// OWN_INIT_1-NOT: ownInit1
func sync() {}
var ownInit2: () -> Void = { #^OWN_INIT_2^# }
// OWN_INIT_2-NOT: ownInit2
var ownInit8: Int = "\(#^OWN_INIT_8^#)"
// OWN_INIT_8-NOT: ownInit8
struct OwnInitTester {
  var ownInit3: Int = #^OWN_INIT_3^#
  // OWN_INIT_3-NOT: ownInit3
  var ownInit4: () -> Void = { #^OWN_INIT_4^# }
  // OWN_INIT_4-NOT: ownInit4
  var ownInit9: String = "\(#^OWN_INIT_9^#)"
  // OWN_INIT_9-NOT: ownInit9
}
import
Swift


using @MainActor
// FIXME: cannot add `using nonisolated` here because it's a re-declaration

func
test1
(
  y
    x: Int, fn: (Int) -> Int
)
async
throws
->
Int {
  return 0
}

func test2(y: Int = 0, oi: Int? = nil) -> Int {
  let x =
    y
  return x
}

func test3(_ b: inout Bool) {
  b = true
}

func testInOutClosureParam() -> (inout (Int, String)) -> Void {
  return { (arg: inout (Int, String)) in
    arg.1 = "rewritten"
  }
}

func test4(_ i: _const Int) {
}

func test5(_ value: Any) { }

func test6<T>(t: T) where T: Proto1 {}

func test7() {
  var binding1 = 0, binding2 = ""
}

func test8(_: Int) {}

func test9() -> Int { 0 }

func testVars() {
  var a = 0
  var b: Int = 0
  var c, d: Int
  var e, f: Int, g, h, i: String
  let j: Int = 0, k: String = ""

  var l: Int { 0 }
  var m: Int { get { 0 } }
  var n: Int {
    get { return m }
    set {}
  }
  var o: Int = 0 {
    willSet {
      n = newValue
    }
  }
  var p: Int {
    get { return 0 }
    set(foo) {
      o = foo
    }
  }
  var q: Int = 0 {
    didSet(old) {
      p = old
    }
  }
  var r: Int {
    _read { yield q }
    _modify { yield &q }
  }
  var s: Int {
    get async throws { return 0 }
  }
  var t: Int {
    read { yield q }
    modify { yield &q }
  }
}

func rethrowingFn(fn: () throws -> Void) rethrows {}
func reasyncFn(fn: () async -> Void) reasync {}
func testRethrows() {
    rethrowingFn { _ = 1 }

    // FIXME: Assertion failed: (isAsync()), function getAsyncContext, file GenCall.cpp, line 215.
    // reasyncFn { _ = 1 }
}

struct TestVars {
  var a = 0
  var b: Int = 0
  var c, d: Int
  var e, f: Int, g, h, i: String
  let j: Int = 0, k: String = ""

  var l: Int { 0 }
  var m: Int { get { 0 } }
  var n: Int {
    get { return m }
    set {}
  }
  var o: Int = 0 {
    willSet {
      n = newValue
    }
  }
  var p: Int {
    get { return 0 }
    set(foo) {
      o = foo
    }
  }
  var q: Int = 0 {
    didSet(old) {
      p = old
    }
  }
  var r: Int {
    _read { yield q }
    _modify { yield &q }
  }
  var s: Int {
    get async throws { return 0 }
  }

  private(set) var testPrivateSet = 1
}

extension TestVars {
  var inExt: Int { return 0 }
}

struct TestSubscripts {
  subscript(x: Int) -> Int {
    0
  }
  subscript(y x: Int) -> Int {
    get {
      return 0
    }
    set(x) {}
  }

  subscript<I: Proto3, J: Proto3>(i: I, j: J) -> Int where I.A == J.B {
    1
  }
}

protocol Proto1 {}
protocol Proto2 {}

protocol
Proto3
<
  A,
  B
>: Proto1 where Self: Proto2 {
  associatedtype
    A where B: Proto1
  associatedtype B: Equatable
    =
    Int

  func method(_ b: Bool)
}

typealias
Alias<T>
=
String where T: Proto1

enum
Enum<T>: Int, Proto1 where T: Proto1 {
  case
  a
    =
    1
  case b = 2,
       c

  func method(_ b: Bool) {}
}

enum WithPayload {
  case a(
    b: Int
  ), c(
    d: Bool = false
  )
}

struct
Struct
<
  T1:
  Proto1,
  T2:
  Proto2
>
:
Proto1, Proto2, @unchecked Sendable
where
  T1
  :
  Proto3,
  T1.A
  ==
  Int
{
  /*static*/ func method(_ b: Bool) {}
}

class
Class<T>: Proto1 where T: Proto3 {
  func method(_ b: Bool) {}

  deinit {
    if true {}
  }

  init?<U>(_ u: U) where U: Proto1 {
    if true {}
  }

  init!(i: Int) {}
}

actor
Actor<T>: Proto1 where T: Proto1 {
  func method(_ b: Bool) {}
}

extension
Class: Proto2 where T: Proto1 {
  func method2(_ b: Bool) {}
}

prefix
operator ⎭^-^⎭

infix
operator
  ~^-^~
  :
  AdditionPrecedence

postfix
operator ⎩^-^⎩

precedencegroup Precedence1 {
}

precedencegroup Precedence2 {
  lowerThan: BitwiseShiftPrecedence, MultiplicationPrecedence
  higherThan: Precedence1, AdditionPrecedence
  associativity: left
  assignment: true
}

struct TestStruct {
  func method(arg: Int, _ c: Int) {}

// FIXME: Compute 'static' location
//  static var shared = TestStruct()
//  func testUnresolvedMember1() -> Self {
//    return .shared
//  }
//
// FIXME: Compute 'static' location
//  static func instance(arg: Int) -> TestStruct { return TestStruct() }
}

struct ValueStruct<let N: Int> {}

func genericTest1<T>(_: T) {}
func genericTest2<each T>(_: repeat each T) {}
func genericTest4<let T: Int>(_: ValueStruct<T>) {}

func concreteValueTest1(_: ValueStruct<123>) {}
func concreteValueTest2(_: ValueStruct<-123>) {}

extension ValueStruct where N == 123 {}
extension ValueStruct where 123 == N {}
extension ValueStruct where N == -123 {}
extension ValueStruct where -123 == N {}

func testMagicIdentifier(file: String = #file, line: Int = #line) {
    let _: String = file
    let _: Int = line
}

class StaticTest {
  class var classVar: Int { 42 }
  static let staticVar = 42
}

func defaultArgInitTestFunc(fn: () -> () = {}) {}
struct DefaultArgInitTestStruct {
  func foo(fn: () -> () = {}) {}
}
enum DefaultArgInitTestEnum {
    case foo(x: () -> () = {})
}

@resultBuilder
struct MyBuilder {
static func buildBlock(_ items: Any...) -> [Any] { items }
}
func acceptBuilder(@MyBuilder fn: () -> [Any]) -> [Any] { fn() }
func testBuilder() {
  let _: [Any] = acceptBuilder {
    1
  }
}

struct ExpansionRequirementTest<each T> where repeat each T: Comparable {}
func ownInitTesting() {
  var ownInit5: Int = #^OWN_INIT_5^#
  // OWN_INIT_5-NOT: ownInit5
  var ownInit6: () -> Void = { #^OWN_INIT_6^# }
  // OWN_INIT_6-NOT: ownInit6
  var ownInit10: String = "\(#^OWN_INIT_10^#)"
  // OWN_INIT_10-NOT: ownInit10
}
func ownInitTestingParam(ownInit11: Int = #^OWN_INIT_11^#) {
  // OWN_INIT_11-NOT: Decl[LocalVar]{{.*}}ownInit11
}
func ownInitTestingParamInterp(ownInit12: String = "\(#^OWN_INIT_12^#)") {
  // OWN_INIT_12-NOT: Decl[LocalVar]{{.*}}ownInit12
}
func ownInitTestingShadow(ownInit7: Int) {
  var ownInit7: Int = #^OWN_INIT_7^#
  // OWN_INIT_7: Decl[LocalVar]/Local/TypeRelation[Convertible]: ownInit7[#Int#];
}

var inAccessor1: Int {
  get { #^OWN_ACCESSOR_1^# }
// OWN_ACCESSOR_1: Decl[GlobalVar]/CurrModule/NotRecommended/TypeRelation[Convertible]: inAccessor1[#Int#];
  set { #^OWN_ACCESSOR_2^# }
// OWN_ACCESSOR_2: Decl[GlobalVar]/CurrModule: inAccessor1[#Int#];
}
var inAccessor2: Int = 1 {
  didSet { #^OWN_ACCESSOR_3^# }
// OWN_ACCESSOR_3: Decl[GlobalVar]/CurrModule: inAccessor2[#Int#];
  willSet { #^OWN_ACCESSOR_4?check=OWN_ACCESSOR_3^# }
}
class InAccessorTest {
  var inAccessor3: Int {
    get { #^OWN_ACCESSOR_5^# }
// OWN_ACCESSOR_5: Decl[InstanceVar]/CurrNominal/NotRecommended/TypeRelation[Convertible]: inAccessor3[#Int#];
    set { #^OWN_ACCESSOR_6^# }
// OWN_ACCESSOR_6: Decl[InstanceVar]/CurrNominal: inAccessor3[#Int#];
  }
  var inAccessor4: Int = 1 {
    didSet { #^OWN_ACCESSOR_7^# }
// OWN_ACCESSOR_7: Decl[InstanceVar]/CurrNominal: inAccessor4[#Int#];
    willSet { #^OWN_ACCESSOR_8?check=OWN_ACCESSOR_7^# }
  }
}
func inAccessorTest() {
  var inAccessor5: Int {
    get { #^OWN_ACCESSOR_9^# }
// OWN_ACCESSOR_9: Decl[LocalVar]/Local/NotRecommended/TypeRelation[Convertible]: inAccessor5[#Int#];
    set { #^OWN_ACCESSOR_10^# }
// OWN_ACCESSOR_10: Decl[LocalVar]/Local: inAccessor5[#Int#];
  }
  var inAccessor6: Int = 1 {
    didSet { #^OWN_ACCESSOR_11^# }
// OWN_ACCESSOR_11: Decl[LocalVar]/Local: inAccessor6[#Int#];
    willSet { #^OWN_ACCESSOR_12?check=OWN_ACCESSOR_11^# }
  }
}
class InAccessorTestQualified {
  var inAccessorProp: Int {
    get {
      let _ = self.#^OWN_ACCESSOR_13^#
// OWN_ACCESSOR_13: Decl[InstanceVar]/CurrNominal:      inAccessorProp[#Int#];
      let _ = \InAccessorTestQualified.#^OWN_ACCESSOR_14?check=OWN_ACCESSOR_13^#
    }
    set {
      let _ = self.#^OWN_ACCESSOR_15?check=OWN_ACCESSOR_13^#
      let _ = \InAccessorTestQualified.#^OWN_ACCESSOR_16?check=OWN_ACCESSOR_13^#
    }
  }
}
// --- Seed B ---
// RUN: %batch-code-completion

//
// Test code completion at the beginning of expr-postfix.
//

//===--- Helper types that are used in this test

struct FooStruct_b7e22bd {
}

var fooObject_b7e22bd : FooStruct_b7e22bd

func fooFunc_b7e22bd() -> FooStruct_b7e22bd {
  return fooObject_b7e22bd
}

enum FooEnum_b7e22bd {
}

class FooClass_b7e22bd {
}

protocol FooProtocol_b7e22bd {
}

typealias FooTypealias_b7e22bd = Int

// Function parameter
// COMMON-DAG: Decl[LocalVar]/Local{{(/TypeRelation\[Convertible\])?}}: fooParam[#FooStruct_b7e22bd#]; name=fooParam
// Global completions
// COMMON-DAG: Decl[Struct]/CurrModule{{(/TypeRelation\[Convertible\])?}}:     FooStruct_b7e22bd[#FooStruct_b7e22bd#]{{; name=.+$}}
// COMMON-DAG: Decl[Enum]/CurrModule{{(/TypeRelation\[Convertible\])?}}:       FooEnum_b7e22bd[#FooEnum_b7e22bd#]{{; name=.+$}}
// COMMON-DAG: Decl[Class]/CurrModule{{(/TypeRelation\[Convertible\])?}}:      FooClass_b7e22bd[#FooClass_b7e22bd#]{{; name=.+$}}
// COMMON-DAG: Decl[Protocol]/CurrModule/Flair[RareType]{{(/TypeRelation\[Convertible\])?}}: FooProtocol_b7e22bd[#FooProtocol_b7e22bd#]{{; name=.+$}}
// COMMON-DAG: Decl[TypeAlias]/CurrModule{{(/TypeRelation\[Convertible\])?}}:  FooTypealias_b7e22bd[#Int#]{{; name=.+$}}
// COMMON-DAG: Decl[GlobalVar]/CurrModule{{(/TypeRelation\[Convertible\])?}}:  fooObject_b7e22bd[#FooStruct_b7e22bd#]{{; name=.+$}}
// COMMON-DAG: Keyword[try]/None: try{{; name=.+$}}
// COMMON-DAG: Literal[Boolean]/None{{(/TypeRelation\[Convertible\])?}}: true[#Bool#]{{; name=.+$}}
// COMMON-DAG: Literal[Boolean]/None{{(/TypeRelation\[Convertible\])?}}: false[#Bool#]{{; name=.+$}}
// COMMON-DAG: Literal[Nil]/None{{(/TypeRelation\[Convertible\])?}}: nil{{.*; name=.+$}}
// COMMON-DAG: Decl[Struct]/OtherModule[Swift]/IsSystem{{(/TypeRelation\[Convertible\])?}}:    Int8[#Int8#]{{; name=.+$}}
// COMMON-DAG: Decl[Struct]/OtherModule[Swift]/IsSystem{{(/TypeRelation\[Convertible\])?}}:    Int16[#Int16#]{{; name=.+$}}
// COMMON-DAG: Decl[Struct]/OtherModule[Swift]/IsSystem{{(/TypeRelation\[Convertible\])?}}:    Int32[#Int32#]{{; name=.+$}}
// COMMON-DAG: Decl[Struct]/OtherModule[Swift]/IsSystem{{(/TypeRelation\[Convertible\])?}}:    Int64[#Int64#]{{; name=.+$}}
// COMMON-DAG: Decl[Struct]/OtherModule[Swift]/IsSystem{{(/TypeRelation\[Convertible\])?}}:    Bool[#Bool#]{{; name=.+$}}

// NO_SELF-NOT: {{[[:<:]][Ss]elf[[:>:]]}}

//===--- Test that we can code complete at the beginning of expr-postfix.

func testExprPostfixBegin1_b7e22bd(fooParam: FooStruct_b7e22bd) {
  #^EXPR_POSTFIX_BEGIN_1?check=COMMON^#
}

func testExprPostfixBegin2_b7e22bd(fooParam: FooStruct_b7e22bd) {
  1 + #^EXPR_POSTFIX_BEGIN_2?check=COMMON^#
}

func testExprPostfixBegin3_b7e22bd(fooParam: FooStruct_b7e22bd) {
  fooFunc_b7e22bd()
  1 + #^EXPR_POSTFIX_BEGIN_3?check=COMMON^#
}

func testExprPostfixBegin4_b7e22bd(fooParam: FooStruct_b7e22bd) {
  "\(#^EXPR_POSTFIX_BEGIN_4?check=COMMON^#)"
}

func testExprPostfixBegin5_b7e22bd(fooParam: FooStruct_b7e22bd) {
  1+#^EXPR_POSTFIX_BEGIN_5?check=COMMON^#
}
func testExprPostfixBegin6_b7e22bd(fooParam: FooStruct_b7e22bd) {
  for i in 1...#^EXPR_POSTFIX_BEGIN_6?check=COMMON^#
}

//===--- Test that we sometimes ignore the expr-postfix.
// In these cases, displaying '.instance*' completion results is technically
// valid, but would be extremely surprising.

func testExprPostfixBeginIgnored1_b7e22bd(fooParam: FooStruct_b7e22bd) {
  fooFunc_b7e22bd()
  #^EXPR_POSTFIX_BEGIN_IGNORED_1?check=COMMON^#
}

func testExprPostfixBeginIgnored2_b7e22bd(fooParam: FooStruct_b7e22bd) {
  123456789
  #^EXPR_POSTFIX_BEGIN_IGNORED_2?check=COMMON^#
}

func testExprPostfixBeginIgnored3_b7e22bd(fooParam: FooStruct_b7e22bd) {
  123456789 +
      fooFunc_b7e22bd()
  #^EXPR_POSTFIX_BEGIN_IGNORED_3?check=COMMON^#
}

//===--- Test that we include function parameters in completion results.

func testFindFuncParam1_b7e22bd(fooParam: FooStruct_b7e22bd, a: Int, b: Float, c: inout Double, d: inout Double) {
  #^FIND_FUNC_PARAM_1?check=FIND_FUNC_PARAM_1;check=COMMON;check=NO_SELF^#
// FIND_FUNC_PARAM_1-DAG: Decl[LocalVar]/Local: a[#Int#]{{; name=.+$}}
// FIND_FUNC_PARAM_1-DAG: Decl[LocalVar]/Local: b[#Float#]{{; name=.+$}}
// FIND_FUNC_PARAM_1-DAG: Decl[LocalVar]/Local: c[#inout Double#]{{; name=.+$}}
// FIND_FUNC_PARAM_1-DAG: Decl[LocalVar]/Local: d[#inout Double#]{{; name=.+$}}
}

func testFindFuncParam2_b7e22bd<Foo : FooProtocol_b7e22bd>(fooParam: FooStruct_b7e22bd, foo_b7e22bd: Foo) {
  #^FIND_FUNC_PARAM_2?check=FIND_FUNC_PARAM_2;check=COMMON;check=NO_SELF^#
// FIND_FUNC_PARAM_2-DAG: Decl[GenericTypeParam]/Local: Foo[#Foo#]{{; name=.+$}}
// FIND_FUNC_PARAM_2-DAG: Decl[LocalVar]/Local:         foo_b7e22bd[#FooProtocol_b7e22bd#]{{; name=.+$}}
}

struct TestFindFuncParam3_4_b7e22bd {
  func testFindFuncParam3(a: Int, b: Float, c: Double) {
    #^FIND_FUNC_PARAM_3^#
// FIND_FUNC_PARAM_3-DAG: Decl[LocalVar]/Local: self[#TestFindFuncParam3_4_b7e22bd#]{{; name=.+$}}
// FIND_FUNC_PARAM_3-DAG: Decl[LocalVar]/Local: a[#Int#]{{; name=.+$}}
// FIND_FUNC_PARAM_3-DAG: Decl[LocalVar]/Local: b[#Float#]{{; name=.+$}}
// FIND_FUNC_PARAM_3-DAG: Decl[LocalVar]/Local: c[#Double#]{{; name=.+$}}
  }

  func testFindFuncParam4<U>(a: Int, b: U) {
    #^FIND_FUNC_PARAM_4^#
// FIND_FUNC_PARAM_4-DAG: Decl[GenericTypeParam]/Local: U[#U#]{{; name=.+$}}
// FIND_FUNC_PARAM_4-DAG: Decl[LocalVar]/Local:         self[#TestFindFuncParam3_4_b7e22bd#]{{; name=.+$}}
// FIND_FUNC_PARAM_4-DAG: Decl[LocalVar]/Local:         a[#Int#]{{; name=.+$}}
// FIND_FUNC_PARAM_4-DAG: Decl[LocalVar]/Local:         b[#U#]{{; name=.+$}}
  }
}

struct TestFindFuncParam5_6_b7e22bd<T> {
  func testFindFuncParam5(a: Int, b: T) {
    #^FIND_FUNC_PARAM_5^#
// FIND_FUNC_PARAM_5-DAG: Decl[GenericTypeParam]/Local: T[#T#]{{; name=.+$}}
// FIND_FUNC_PARAM_5-DAG: Decl[LocalVar]/Local: self[#TestFindFuncParam5_6_b7e22bd<T>#]{{; name=.+$}}
// FIND_FUNC_PARAM_5-DAG: Decl[LocalVar]/Local: a[#Int#]{{; name=.+$}}
// FIND_FUNC_PARAM_5-DAG: Decl[LocalVar]/Local: b[#T#]{{; name=.+$}}
  }

  func testFindFuncParam6<U>(a: Int, b: T, c: U) {
    #^FIND_FUNC_PARAM_6^#
// FIND_FUNC_PARAM_6-DAG: Decl[GenericTypeParam]/Local:       T[#T#]{{; name=.+$}}
// FIND_FUNC_PARAM_6-DAG: Decl[GenericTypeParam]/Local:       U[#U#]{{; name=.+$}}
// FIND_FUNC_PARAM_6-DAG: Decl[LocalVar]/Local:               self[#TestFindFuncParam5_6_b7e22bd<T>#]{{; name=.+$}}
// FIND_FUNC_PARAM_6-DAG: Decl[LocalVar]/Local:               a[#Int#]{{; name=.+$}}
// FIND_FUNC_PARAM_6-DAG: Decl[LocalVar]/Local:               b[#T#]{{; name=.+$}}
// FIND_FUNC_PARAM_6-DAG: Decl[LocalVar]/Local:               c[#U#]{{; name=.+$}}
  }
}

class TestFindFuncParam7_b7e22bd {
  func testFindFuncParam7(a: Int, b: Float, c: Double) {
    #^FIND_FUNC_PARAM_7^#
// FIND_FUNC_PARAM_7-DAG: Decl[LocalVar]/Local: self[#TestFindFuncParam7_b7e22bd#]{{; name=.+$}}
// FIND_FUNC_PARAM_7-DAG: Decl[LocalVar]/Local: a[#Int#]{{; name=.+$}}
// FIND_FUNC_PARAM_7-DAG: Decl[LocalVar]/Local: b[#Float#]{{; name=.+$}}
// FIND_FUNC_PARAM_7-DAG: Decl[LocalVar]/Local: c[#Double#]{{; name=.+$}}
  }
}

func testFindFuncParamSelector1_b7e22bd(a: Int, b x: Float, foo_b7e22bd fooParam: FooStruct_b7e22bd, bar barParam: inout FooStruct_b7e22bd) {
  #^FIND_FUNC_PARAM_SELECTOR_1?check=FIND_FUNC_PARAM_SELECTOR_1;check=COMMON;check=NO_SELF^#
// FIND_FUNC_PARAM_SELECTOR_1-DAG: Decl[LocalVar]/Local: a[#Int#]{{; name=.+$}}
// FIND_FUNC_PARAM_SELECTOR_1-DAG: Decl[LocalVar]/Local: x[#Float#]{{; name=.+$}}
// FIND_FUNC_PARAM_SELECTOR_1-DAG: Decl[LocalVar]/Local: barParam[#inout FooStruct_b7e22bd#]{{; name=.+$}}
}

//===--- Test that we include constructor parameters in completion results.

class TestFindConstructorParam1_b7e22bd {
  init(a: Int, b: Float) {
    #^FIND_CONSTRUCTOR_PARAM_1^#
// FIND_CONSTRUCTOR_PARAM_1-DAG: Decl[LocalVar]/Local: self[#TestFindConstructorParam1_b7e22bd#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_1-DAG: Decl[LocalVar]/Local: a[#Int#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_1-DAG: Decl[LocalVar]/Local: b[#Float#]{{; name=.+$}}
  }
}

struct TestFindConstructorParam2_b7e22bd {
  init(a: Int, b: Float) {
    #^FIND_CONSTRUCTOR_PARAM_2^#
// FIND_CONSTRUCTOR_PARAM_2-DAG: Decl[LocalVar]/Local: self[#TestFindConstructorParam2_b7e22bd#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_2-DAG: Decl[LocalVar]/Local: a[#Int#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_2-DAG: Decl[LocalVar]/Local: b[#Float#]{{; name=.+$}}
  }
}

class TestFindConstructorParam3_b7e22bd {
  init<U>(a: Int, b: U) {
    #^FIND_CONSTRUCTOR_PARAM_3^#
// FIND_CONSTRUCTOR_PARAM_3-DAG: Decl[GenericTypeParam]/Local: U[#U#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_3-DAG: Decl[LocalVar]/Local:         self[#TestFindConstructorParam3_b7e22bd#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_3-DAG: Decl[LocalVar]/Local:         a[#Int#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_3-DAG: Decl[LocalVar]/Local:         b[#U#]{{; name=.+$}}
  }
}

class TestFindConstructorParam4_b7e22bd<T> {
  init(a: Int, b: T) {
    #^FIND_CONSTRUCTOR_PARAM_4^#
// FIND_CONSTRUCTOR_PARAM_4-DAG: Decl[GenericTypeParam]/Local: T[#T#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_4-DAG: Decl[LocalVar]/Local:         self[#TestFindConstructorParam4_b7e22bd<T>#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_4-DAG: Decl[LocalVar]/Local:         a[#Int#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_4-DAG: Decl[LocalVar]/Local:         b[#T#]{{; name=.+$}}
  }
}

class TestFindConstructorParam5_b7e22bd<T> {
  init<U>(a: Int, b: T, c: U) {
    #^FIND_CONSTRUCTOR_PARAM_5^#
// FIND_CONSTRUCTOR_PARAM_5-DAG: Decl[GenericTypeParam]/Local: T[#T#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_5-DAG: Decl[GenericTypeParam]/Local: U[#U#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_5-DAG: Decl[LocalVar]/Local:         self[#TestFindConstructorParam5_b7e22bd<T>#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_5-DAG: Decl[LocalVar]/Local:         a[#Int#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_5-DAG: Decl[LocalVar]/Local:         b[#T#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_5-DAG: Decl[LocalVar]/Local:         c[#U#]{{; name=.+$}}
  }
}

class TestFindConstructorParamSelector1_b7e22bd {
  init(a x: Int, b y: Float) {
    #^FIND_CONSTRUCTOR_PARAM_SELECTOR_1^#
// FIND_CONSTRUCTOR_PARAM_SELECTOR_1-DAG: Decl[LocalVar]/Local: self[#TestFindConstructorParamSelector1_b7e22bd#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_SELECTOR_1-DAG: Decl[LocalVar]/Local: x[#Int#]{{; name=.+$}}
// FIND_CONSTRUCTOR_PARAM_SELECTOR_1-DAG: Decl[LocalVar]/Local: y[#Float#]{{; name=.+$}}
  }
}

//===--- Test that we include destructor's 'self' in completion results.

class TestFindDestructorParam1_b7e22bd {
  deinit {
    #^FIND_DESTRUCTOR_PARAM_1^#
// FIND_DESTRUCTOR_PARAM_1-DAG: Decl[LocalVar]/Local: self[#TestFindDestructorParam1_b7e22bd#]{{; name=.+$}}
  }
}

class TestFindDestructorParam2_b7e22bd<T> {
  deinit {
    #^FIND_DESTRUCTOR_PARAM_2^#
// FIND_DESTRUCTOR_PARAM_2-DAG: Decl[GenericTypeParam]/Local: T[#T#]{{; name=.+$}}
// FIND_DESTRUCTOR_PARAM_2-DAG: Decl[LocalVar]/Local: self[#TestFindDestructorParam2_b7e22bd<T>#]{{; name=.+$}}
  }
}

struct TestPlaceholdersInNames_b7e22bd {
  var <#placeholder_in_name1#>: FooStruct_b7e22bd
  func test() {
    var <#placeholder_in_name2#>: FooStruct_b7e22bd
    #^NO_PLACEHOLDER_NAMES_1^#
  }
// NO_PLACEHOLDER_NAMES_1-NOT: placeholder_in_name
}

//===--- Test that we don't crash in constructors and destructors in contexts
//===--- where they are not allowed.

init() {
  var fooParam = FooStruct_b7e22bd()
  #^IN_INVALID_1?check=COMMON^#
}

init { // Missing parameters
  var fooParam = FooStruct_b7e22bd()
  #^IN_INVALID_2?check=COMMON^#
}

deinit {
  var fooParam = FooStruct_b7e22bd()
  #^IN_INVALID_3?check=COMMON^#
}

func testInInvalid5_b7e22bd() {
  var fooParam = FooStruct_b7e22bd()
  init() {
    #^IN_INVALID_5?check=COMMON^#
  }
}

func testInInvalid6_b7e22bd() {
  deinit {
    var fooParam = FooStruct_b7e22bd()
    #^IN_INVALID_6?check=COMMON^#
  }
}

struct TestInInvalid7_b7e22bd {
  deinit {
    var fooParam = FooStruct_b7e22bd()
    #^IN_INVALID_7?check=COMMON^#
  }
}

func foo_b7e22bd() -> Undeclared {
  var fooParam = FooStruct_b7e22bd()
  #^IN_INVALID_8?check=COMMON^#
}
// MY_ALIAS_1-DAG: Decl[TypeAlias]/Local:                        MyAlias[#(T, T)#];
// MY_ALIAS_1-DAG: Decl[LocalVar]/Local/TypeRelation[Convertible]: x[#MyAlias<Int>#]; name=x
// MY_ALIAS_1-DAG: Decl[LocalVar]/Local/TypeRelation[Convertible]: y[#(Int, Int)#]; name=y

func testGenericTypealias1_b7e22bd() {
  typealias MyAlias<T> = (T, T)
  let x: MyAlias<Int> = (1, 2)
  var y: (Int, Int)
  y = #^GENERIC_TYPEALIAS_1?check=MY_ALIAS_1^#
}
// MY_ALIAS_2-DAG: Decl[TypeAlias]/Local:                        MyAlias[#(T, T)#];
// MY_ALIAS_2-DAG: Decl[LocalVar]/Local/TypeRelation[Convertible]: x[#(Int, Int)#]; name=x
// MY_ALIAS_2-DAG: Decl[LocalVar]/Local/TypeRelation[Convertible]: y[#MyAlias<Int>#]; name=y
func testGenericTypealias2_b7e22bd() {
  typealias MyAlias<T> = (T, T)
  let x: (Int, Int) = (1, 2)
  var y: MyAlias<Int>
  y = #^GENERIC_TYPEALIAS_2?check=MY_ALIAS_2^#
}

func testInForEach1_b7e22bd(arg: Int) {
  let local = 2
  for index in #^IN_FOR_EACH_1^# {
    let inBody = 3
  }
  let after = 4
// IN_FOR_EACH_1-NOT: Decl[LocalVar]
// IN_FOR_EACH_1: Decl[LocalVar]/Local:               local[#Int#];
// IN_FOR_EACH_1-NOT: after
// IN_FOR_EACH_1: Decl[LocalVar]/Local:               arg[#Int#];
// IN_FOR_EACH_1-NOT: Decl[LocalVar]
}
func testInForEach2_b7e22bd(arg: Int) {
  let local = 2
  for index in 1 ... #^IN_FOR_EACH_2^# {
    let inBody = 3
  }
  let after = 4
// IN_FOR_EACH_2-NOT: Decl[LocalVar]
// IN_FOR_EACH_2: Decl[LocalVar]/Local/TypeRelation[Convertible]: local[#Int#];
// IN_FOR_EACH_2-NOT: after
// IN_FOR_EACH_2: Decl[LocalVar]/Local/TypeRelation[Convertible]: arg[#Int#];
// IN_FOR_EACH_2-NOT: Decl[LocalVar]
}
func testInForEach3_b7e22bd(arg: Int) {
  let local = 2
  for index: Int in 1 ... 2 where #^IN_FOR_EACH_3^# {
    let inBody = 3
  }
  let after = 4
// IN_FOR_EACH_3-NOT: Decl[LocalVar]
// IN_FOR_EACH_3: Decl[LocalVar]/Local:               index[#Int#];
// IN_FOR_EACH_3-NOT: Decl[LocalVar]
// IN_FOR_EACH_3: Decl[LocalVar]/Local:               local[#Int#];
// IN_FOR_EACH_3-NOT: after
// IN_FOR_EACH_3: Decl[LocalVar]/Local:               arg[#Int#];
// IN_FOR_EACH_3-NOT: Decl[LocalVar]
}
func testInForEach4_b7e22bd(arg: Int) {
  let local = 2
  for index in 1 ... 2 {
    #^IN_FOR_EACH_4?check=IN_FOR_EACH_3^#
  }
  let after = 4
}

func testInForEach5_b7e22bd(arg: Int) {
  let local = 2
  for index in [#^IN_FOR_EACH_5?check=IN_FOR_EACH_1^#] {}
  let after = 4
}
func testInForEach6_b7e22bd(arg: Int) {
  let local = 2
  for index in [1,#^IN_FOR_EACH_6?check=IN_FOR_EACH_2^#] {}
  let after = 4
}
func testInForEach7_b7e22bd(arg: Int) {
  let local = 2
  for index in [1:#^IN_FOR_EACH_7?check=IN_FOR_EACH_1^#] {}
  let after = 4
}
func testInForEach8_b7e22bd(arg: Int) {
  let local = 2
  for index in [#^IN_FOR_EACH_8?check=IN_FOR_EACH_4^#:] {}
  let after = 4
}
func testInForEach9_b7e22bd(arg: Int) {
  let local = 2
  for index in [#^IN_FOR_EACH_9?check=IN_FOR_EACH_4^#:2] {}
  let after = 4
// NOTE: [Convertible] to AnyHashable.
// IN_FOR_EACH_4-NOT: Decl[LocalVar]
// IN_FOR_EACH_4: Decl[LocalVar]/Local/TypeRelation[Convertible]: local[#Int#];
// IN_FOR_EACH_4-NOT: after
// IN_FOR_EACH_4: Decl[LocalVar]/Local/TypeRelation[Convertible]: arg[#Int#];
// IN_FOR_EACH_4-NOT: Decl[LocalVar]
}
func testInForEach10_b7e22bd(arg: Int) {
  let local = 2
  for index in [1:2, #^IN_FOR_EACH_10^#] {}
  let after = 4
}
// IN_FOR_EACH_10-NOT: Decl[LocalVar]
// IN_FOR_EACH_10: Decl[LocalVar]/Local/TypeRelation[Convertible]:               local[#Int#];
// IN_FOR_EACH_10-NOT: after
// IN_FOR_EACH_10: Decl[LocalVar]/Local/TypeRelation[Convertible]:               arg[#Int#];
// IN_FOR_EACH_10-NOT: Decl[LocalVar]
func testInForEach11_b7e22bd(arg: Int) {
  let local = 2
  for index in [1:2, #^IN_FOR_EACH_11?check=IN_FOR_EACH_2^#:] {}
  let after = 4
}
func testInForEach12_b7e22bd(arg: Int) {
  let local = 2
  for index in [1:2, #^IN_FOR_EACH_12?check=IN_FOR_EACH_2^#:2] {}
  let after = 4
}

@available(*, deprecated)
struct Deprecated_b7e22bd {
  @available(*, deprecated)
  func testDeprecated() {
    @available(*, deprecated) let local = 1
    @available(*, deprecated) func f() {}

    #^DEPRECATED_1^#
  }
}
// DEPRECATED_1-DAG: Decl[LocalVar]/Local/NotRecommended: local[#Int#];
// DEPRECATED_1-DAG: Decl[FreeFunction]/Local/NotRecommended: f()[#Void#];
// DEPRECATED_1-DAG: Decl[InstanceMethod]/CurrNominal/NotRecommended: testDeprecated()[#Void#];
// DEPRECATED_1-DAG: Decl[Struct]/CurrModule/NotRecommended: Deprecated_b7e22bd[#Deprecated_b7e22bd#];

func testTuple_b7e22bd(localInt: Int) {
  let localStr: String = "foo_b7e22bd"
  let _: (Int, String) = (1, #^IN_TUPLE_1^#)
  let _: (Int, String) = (#^IN_TUPLE_2^#, "foo_b7e22bd")
}
// IN_TUPLE_1-DAG: Decl[LocalVar]/Local/TypeRelation[Convertible]: localStr[#String#]; name=localStr
// IN_TUPLE_1-DAG: Decl[LocalVar]/Local:               localInt[#Int#]; name=localInt

// IN_TUPLE_2-DAG: Decl[LocalVar]/Local:               localStr[#String#]; name=localStr
// IN_TUPLE_2-DAG: Decl[LocalVar]/Local/TypeRelation[Convertible]: localInt[#Int#]; name=localInt

var ownInit1_b7e22bd: Int = #^OWN_INIT_1^#
// OWN_INIT_1-NOT: ownInit1_b7e22bd
func sync_b7e22bd() {}
var ownInit2_b7e22bd: () -> Void = { #^OWN_INIT_2^# }
// OWN_INIT_2-NOT: ownInit2_b7e22bd
var ownInit8_b7e22bd: Int = "\(#^OWN_INIT_8^#)"
// OWN_INIT_8-NOT: ownInit8_b7e22bd
struct OwnInitTester_b7e22bd {
  var ownInit3: Int = #^OWN_INIT_3^#
  // OWN_INIT_3-NOT: ownInit3
  var ownInit4: () -> Void = { #^OWN_INIT_4^# }
  // OWN_INIT_4-NOT: ownInit4
  var ownInit9: String = "\(#^OWN_INIT_9^#)"
  // OWN_INIT_9-NOT: ownInit9
}
func ownInitTesting_b7e22bd() {
  var ownInit5: Int = #^OWN_INIT_5^#
  // OWN_INIT_5-NOT: ownInit5
  var ownInit6: () -> Void = { #^OWN_INIT_6^# }
  // OWN_INIT_6-NOT: ownInit6
  var ownInit10: String = "\(#^OWN_INIT_10^#)"
  // OWN_INIT_10-NOT: ownInit10
}
func ownInitTestingParam_b7e22bd(ownInit11: Int = #^OWN_INIT_11^#) {
  // OWN_INIT_11-NOT: Decl[LocalVar]{{.*}}ownInit11
}
func ownInitTestingParamInterp_b7e22bd(ownInit12: String = "\(#^OWN_INIT_12^#)") {
  // OWN_INIT_12-NOT: Decl[LocalVar]{{.*}}ownInit12
}
func ownInitTestingShadow_b7e22bd(ownInit7: Int) {
  var ownInit7: Int = #^OWN_INIT_7^#
  // OWN_INIT_7: Decl[LocalVar]/Local/TypeRelation[Convertible]: ownInit7[#Int#];
}

var inAccessor1_b7e22bd: Int {
  get { #^OWN_ACCESSOR_1^# }
// OWN_ACCESSOR_1: Decl[GlobalVar]/CurrModule/NotRecommended/TypeRelation[Convertible]: inAccessor1_b7e22bd[#Int#];
  set { #^OWN_ACCESSOR_2^# }
// OWN_ACCESSOR_2: Decl[GlobalVar]/CurrModule: inAccessor1_b7e22bd[#Int#];
}
var inAccessor2_b7e22bd: Int = 1 {
  didSet { #^OWN_ACCESSOR_3^# }
// OWN_ACCESSOR_3: Decl[GlobalVar]/CurrModule: inAccessor2_b7e22bd[#Int#];
  willSet { #^OWN_ACCESSOR_4?check=OWN_ACCESSOR_3^# }
}
class InAccessorTest_b7e22bd {
  var inAccessor3: Int {
    get { #^OWN_ACCESSOR_5^# }
// OWN_ACCESSOR_5: Decl[InstanceVar]/CurrNominal/NotRecommended/TypeRelation[Convertible]: inAccessor3[#Int#];
    set { #^OWN_ACCESSOR_6^# }
// OWN_ACCESSOR_6: Decl[InstanceVar]/CurrNominal: inAccessor3[#Int#];
  }
  var inAccessor4: Int = 1 {
    didSet { #^OWN_ACCESSOR_7^# }
// OWN_ACCESSOR_7: Decl[InstanceVar]/CurrNominal: inAccessor4[#Int#];
    willSet { #^OWN_ACCESSOR_8?check=OWN_ACCESSOR_7^# }
  }
}
func inAccessorTest_b7e22bd() {
  var inAccessor5: Int {
    get { #^OWN_ACCESSOR_9^# }
// OWN_ACCESSOR_9: Decl[LocalVar]/Local/NotRecommended/TypeRelation[Convertible]: inAccessor5[#Int#];
    set { #^OWN_ACCESSOR_10^# }
// OWN_ACCESSOR_10: Decl[LocalVar]/Local: inAccessor5[#Int#];
  }
  var inAccessor6: Int = 1 {
    didSet { #^OWN_ACCESSOR_11^# }
// OWN_ACCESSOR_11: Decl[LocalVar]/Local: inAccessor6[#Int#];
    willSet { #^OWN_ACCESSOR_12?check=OWN_ACCESSOR_11^# }
  }
}
class InAccessorTestQualified_b7e22bd {
  var inAccessorProp: Int {
    get {
      let _ = self.#^OWN_ACCESSOR_13^#
// OWN_ACCESSOR_13: Decl[InstanceVar]/CurrNominal:      inAccessorProp[#Int#];
      let _ = \InAccessorTestQualified_b7e22bd.#^OWN_ACCESSOR_14?check=OWN_ACCESSOR_13^#
    }
    set {
      let _ = self.#^OWN_ACCESSOR_15?check=OWN_ACCESSOR_13^#
      let _ = \InAccessorTestQualified_b7e22bd.#^OWN_ACCESSOR_16?check=OWN_ACCESSOR_13^#
    }
  }
}
// --- Bug Primitive ---

// P8: Property wrapper composition stress
@propertyWrapper
struct _FflClamped<T: Comparable> {
    private var _v: T
    let lo: T, hi: T
    init(wrappedValue: T, lo: T, hi: T) {
        _v = min(max(wrappedValue, lo), hi)
        self.lo = lo; self.hi = hi
    }
    var wrappedValue: T {
        get { _v }
        set { _v = min(max(newValue, lo), hi) }
    }
    var projectedValue: (T, T) { (lo, hi) }
}
@propertyWrapper
struct _FflLogged<T: CustomStringConvertible> {
    var wrappedValue: T
    init(wrappedValue: T) { self.wrappedValue = wrappedValue }
    var projectedValue: String { "logged:\(wrappedValue)" }
}
struct _FflSettings {
    @_FflClamped(lo: 0, hi: 100) var volume: Int = 50
    @_FflLogged var name: String = "default"
}
do {
    var _ffl_s = _FflSettings()
    _ffl_s.volume = String(describing: inAccessor2).count % 200  // may exceed hi → clamped
    _ffl_s.name   = String(describing: inAccessor2)
    _ = _ffl_s.$name
    _ = _ffl_s.$volume
}

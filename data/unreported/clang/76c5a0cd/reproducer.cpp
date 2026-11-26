// RUN: %clang -### --target=arm64-apple-darwin %s 2>&1 | FileCheck %s --check-prefix=DARWIN-DEFAULT
// DARWIN-DEFAULT: "-fdefine-target-os-macros"

// RUN: %clang -### --target=arm-none-linux-gnu %s 2>&1 | FileCheck %s --check-prefix=NON-DARWIN-DEFAULT
// RUN: %clang -### --target=x86_64-pc-win32 %s 2>&1 | FileCheck %s --check-prefix=NON-DARWIN-DEFAULT
// NON-DARWIN-DEFAULT-NOT: "-fdefine-target-os-macros"

// RUN: %clang -dM -E --target=arm64-apple-macos %s 2>&1 \
// RUN: | FileCheck %s -DMAC=1         \
// RUN:                -DOSX=1         \
// RUN:                -DIPHONE=0      \
// RUN:                -DIOS=0         \
// RUN:                -DTV=0          \
// RUN:                -DWATCH=0       \
// RUN:                -DVISION=0      \
// RUN:                -DDRIVERKIT=0   \
// RUN:                -DMACCATALYST=0 \
// RUN:                -DEMBEDDED=0    \
// RUN:                -DSIMULATOR=0   \
// RUN:                -DWINDOWS=0     \
// RUN:                -DLINUX=0       \
// RUN:                -DUNIX=0        \
// RUN:                -DFIRMWARE=0

// RUN: %clang -dM -E --target=arm64-apple-ios %s 2>&1 \
// RUN: | FileCheck %s -DMAC=1         \
// RUN:                -DOSX=0         \
// RUN:                -DIPHONE=1      \
// RUN:                -DIOS=1         \
// RUN:                -DTV=0          \
// RUN:                -DWATCH=0       \
// RUN:                -DVISION=0      \
// RUN:                -DDRIVERKIT=0   \
// RUN:                -DMACCATALYST=0 \
// RUN:                -DEMBEDDED=1    \
// RUN:                -DSIMULATOR=0   \
// RUN:                -DWINDOWS=0     \
// RUN:                -DLINUX=0       \
// RUN:                -DUNIX=0        \
// RUN:                -DFIRMWARE=0

// RUN: %clang -dM -E --target=arm64-apple-ios-macabi %s 2>&1 \
// RUN: | FileCheck %s -DMAC=1         \
// RUN:                -DOSX=0         \
// RUN:                -DIPHONE=1      \
// RUN:                -DIOS=1         \
// RUN:                -DTV=0          \
// RUN:                -DWATCH=0       \
// RUN:                -DVISION=0      \
// RUN:                -DDRIVERKIT=0   \
// RUN:                -DMACCATALYST=1 \
// RUN:                -DEMBEDDED=0    \
// RUN:                -DSIMULATOR=0   \
// RUN:                -DWINDOWS=0     \
// RUN:                -DLINUX=0       \
// RUN:                -DUNIX=0        \
// RUN:                -DFIRMWARE=0

// RUN: %clang -dM -E --target=arm64-apple-ios-simulator %s 2>&1 \
// RUN: | FileCheck %s -DMAC=1         \
// RUN:                -DOSX=0         \
// RUN:                -DIPHONE=1      \
// RUN:                -DIOS=1         \
// RUN:                -DTV=0          \
// RUN:                -DWATCH=0       \
// RUN:                -DVISION=0      \
// RUN:                -DDRIVERKIT=0   \
// RUN:                -DMACCATALYST=0 \
// RUN:                -DEMBEDDED=0    \
// RUN:                -DSIMULATOR=1   \
// RUN:                -DWINDOWS=0     \
// RUN:                -DLINUX=0       \
// RUN:                -DUNIX=0        \
// RUN:                -DFIRMWARE=0

// RUN: %clang -dM -E --target=arm64-apple-tvos %s 2>&1 \
// RUN: | FileCheck %s -DMAC=1         \
// RUN:                -DOSX=0         \
// RUN:                -DIPHONE=1      \
// RUN:                -DIOS=0         \
// RUN:                -DTV=1          \
// RUN:                -DWATCH=0       \
// RUN:                -DVISION=0      \
// RUN:                -DDRIVERKIT=0   \
// RUN:                -DMACCATALYST=0 \
// RUN:                -DEMBEDDED=1    \
// RUN:                -DSIMULATOR=0   \
// RUN:                -DWINDOWS=0     \
// RUN:                -DLINUX=0       \
// RUN:                -DUNIX=0        \
// RUN:                -DFIRMWARE=0

// RUN: %clang -dM -E --target=arm64-apple-tvos-simulator %s 2>&1 \
// RUN: | FileCheck %s -DMAC=1         \
// RUN:                -DOSX=0         \
// RUN:                -DIPHONE=1      \
// RUN:                -DIOS=0         \
// RUN:                -DTV=1          \
// RUN:                -DWATCH=0       \
// RUN:                -DVISION=0      \
// RUN:                -DDRIVERKIT=0   \
// RUN:                -DMACCATALYST=0 \
// RUN:                -DEMBEDDED=0    \
// RUN:                -DSIMULATOR=1   \
// RUN:                -DWINDOWS=0     \
// RUN:                -DLINUX=0       \
// RUN:                -DUNIX=0        \
// RUN:                -DFIRMWARE=0

// RUN: %clang -dM -E --target=arm64-apple-watchos %s 2>&1 \
// RUN: | FileCheck %s -DMAC=1         \
// RUN:                -DOSX=0         \
// RUN:                -DIPHONE=1      \
// RUN:                -DIOS=0         \
// RUN:                -DTV=0          \
// RUN:                -DWATCH=1       \
// RUN:                -DVISION=0      \
// RUN: clang-import-test -dump-ast -import %S/Inputs/S.cpp -expression %s -Xcc -DSEQ | FileCheck --check-prefix=CHECK-SEQ %s
// RUN: clang-import-test -dump-ast -import %S/Inputs/S.cpp -expression %s -Xcc -DPACK | FileCheck --check-prefix=CHECK-PACK %s
// RUN: clang-import-test -dump-ast -import %S/Inputs/S.cpp -expression %s -Xcc -DDEDUP | FileCheck --check-prefix=CHECK-DEDUP %s
// RUN: clang-import-test -dump-ast -import %S/Inputs/S.cpp -expression %s -Xcc -DSORT | FileCheck --check-prefix=CHECK-SORT %s
// RUN: clang-import-test -dump-ast -import %S/Inputs/S.cpp -expression %s -Xcc -DPACK -Xcc -DSEQ -Xcc -DDEDUP -Xcc -DSORT | FileCheck --check-prefixes=CHECK-SEQ,CHECK-PACK,CHECK-DEDUP,CHECK-SORT %s

// CHECK-SEQ:  BuiltinTemplateDecl {{.+}} <<invalid sloc>> <invalid sloc> implicit referenced __make_integer_seq{{$}}
// CHECK-PACK: BuiltinTemplateDecl {{.+}} <<invalid sloc>> <invalid sloc> implicit referenced __type_pack_element{{$}}
// CHECK-DEDUP: BuiltinTemplateDecl {{.+}} <<invalid sloc>> <invalid sloc> implicit referenced __builtin_dedup_pack{{$}}
// CHECK-SORT: BuiltinTemplateDecl {{.+}} <<invalid sloc>> <invalid sloc> implicit referenced __builtin_sort_pack{{$}}

void expr() {
#ifdef SEQ
  typedef MakeSeq<int, 3> M1;
  M1 m1;
  typedef MakeSeq<long, 4> M2;
  M2 m2;
  static_assert(M1::PackSize == 3, "");
  static_assert(M2::PackSize == 4, "");
#endif

#ifdef PACK
  static_assert(__is_same(TypePackElement<0, X<0>>, X<0>), "");
  static_assert(__is_same(TypePackElement<0, X<0>, X<1>>, X<0>), "");
  static_assert(__is_same(TypePackElement<1, X<0>, X<1>>, X<1>), "");
#endif

#ifdef DEDUP
  static_assert(__is_same(TypePackDedup<TypeList>, TypeList<>), "");
  static_assert(__is_same(TypePackDedup<TypeList, int, double, int>, TypeList<int, double>), "");
  static_assert(!__is_same(TypePackDedup<TypeList, int, double, int>, TypeList<double, int>), "");
  static_assert(__is_same(TypePackDedup<TypeList, X<0>, X<1>, X<1>, X<2>, X<0>>, TypeList<X<0>, X<1>, X<2>>), "");
  static_assert(__is_same(TypePackDedup<TypeList, X0, SameAsX<1>, X<1>, X<0>>, TypeList<X<0>,X<1>>), "");
#endif

#ifdef SORT
  static_assert(__is_same(TypePackSort<TypeList>, TypeList<>), "");
  static_assert(__is_same(TypePackSort<TypeList, A, B>, TypeList<A, B>), "");
  static_assert(__is_same(TypePackSort<TypeList, B, A>, TypeList<A, B>), "");
  static_assert(__is_same(TypePackSort<TypeList, B, A, B>, TypeList<A, B, B>), "");
#endif
}
// RUN:                -DDRIVERKIT=0   \
// RUN:                -DMACCATALYST=0 \
// RUN:                -DEMBEDDED=1    \
// RUN:                -DSIMULATOR=0   \
// RUN:                -DWINDOWS=0     \
// RUN:                -DLINUX=0       \
// RUN:                -DUNIX=0        \
// RUN:                -DFIRMWARE=0

// RUN: %clang -dM -E --target=arm64-apple-watchos-simulator %s 2>&1 \
// RUN: | FileCheck %s -DMAC=1         \
// RUN:                -DOSX=0         \
// RUN:                -DIPHONE=1      \
// RUN:                -DIOS=0         \
// RUN:                -DTV=0          \
// RUN:                -DWATCH=1       \
// RUN:                -DVISION=0      \
// RUN:                -DDRIVERKIT=0   \
// RUN:                -DMACCATALYST=0 \
// RUN:                -DEMBEDDED=0    \
// RUN:                -DSIMULATOR=1   \
// RUN:                -DWINDOWS=0     \
// RUN:                -DLINUX=0       \
// RUN:                -DUNIX=0        \
// RUN:                -DFIRMWARE=0

// RUN: %clang -dM -E --target=arm64-apple-xros %s 2>&1 \
// RUN: | FileCheck %s -DMAC=1         \
// RUN:                -DOSX=0         \
// RUN:                -DIPHONE=1      \
// RUN:                -DIOS=0         \
// RUN:                -DTV=0          \
// RUN:                -DWATCH=0       \
// RUN:                -DVISION=1      \
// RUN:                -DDRIVERKIT=0   \
// RUN:                -DMACCATALYST=0 \
// RUN:                -DEMBEDDED=1    \
// RUN:                -DSIMULATOR=0   \
// RUN:                -DWINDOWS=0     \
// RUN:                -DLINUX=0       \
// RUN:                -DUNIX=0        \
// RUN:                -DFIRMWARE=0

// RUN: %clang -dM -E --target=arm64-apple-xros-simulator %s 2>&1 \
// RUN: | FileCheck %s -DMAC=1         \
// RUN:                -DOSX=0         \
// RUN:                -DIPHONE=1      \
// RUN:                -DIOS=0         \
// RUN:                -DTV=0          \
// RUN:                -DWATCH=0       \
// RUN:                -DVISION=1      \
// RUN:                -DDRIVERKIT=0   \
// RUN:                -DMACCATALYST=0 \
// RUN:                -DEMBEDDED=0    \
// RUN:                -DSIMULATOR=1   \
// RUN:                -DWINDOWS=0     \
// RUN:                -DLINUX=0       \
// RUN:                -DUNIX=0        \
// RUN:                -DFIRMWARE=0

// RUN: %clang -dM -E --target=arm64-apple-driverkit %s 2>&1 \
// RUN: | FileCheck %s -DMAC=1         \
// RUN:                -DOSX=0         \
// RUN:                -DIPHONE=0      \
// RUN:                -DIOS=0         \
// RUN:                -DTV=0          \
// RUN:                -DWATCH=0       \
// RUN:                -DVISION=0      \
// RUN:                -DDRIVERKIT=1   \
// RUN:                -DMACCATALYST=0 \
// RUN:                -DEMBEDDED=0    \
// RUN:                -DSIMULATOR=0   \
// RUN:                -DWINDOWS=0     \
// RUN:                -DLINUX=0       \
// RUN:                -DUNIX=0        \
// RUN:                -DFIRMWARE=0

// RUN: %clang -dM -E --target=arm64-apple-firmware %s 2>&1 \
// RUN: | FileCheck %s -DMAC=1         \
// RUN:                -DOSX=0         \
// RUN:                -DIPHONE=0      \
// RUN:                -DIOS=0         \
// RUN:                -DTV=0          \
// RUN:                -DWATCH=0       \
// RUN:                -DVISION=0      \
// RUN:                -DDRIVERKIT=0   \
// RUN:                -DMACCATALYST=0 \
// RUN:                -DEMBEDDED=0    \
// RUN:                -DSIMULATOR=0   \
// RUN:                -DWINDOWS=0     \
// RUN:                -DLINUX=0       \
// RUN:                -DUNIX=0        \
// RUN:                -DFIRMWARE=1

// RUN: %clang -dM -E --target=x86_64-pc-linux-gnu \
// RUN:        -fdefine-target-os-macros %s 2>&1 \
// RUN: | FileCheck %s -DMAC=0         \
// RUN:                -DOSX=0         \
// RUN:                -DIPHONE=0      \
// RUN:                -DIOS=0         \
// RUN:                -DTV=0          \
// RUN:                -DWATCH=0       \
// RUN:                -DVISION=0      \
// RUN:                -DDRIVERKIT=0   \
// RUN:                -DMACCATALYST=0 \
// RUN:                -DEMBEDDED=0    \
// RUN:                -DSIMULATOR=0   \
// RUN:                -DWINDOWS=0     \
// RUN:                -DLINUX=1       \
// RUN:                -DUNIX=0        \
// RUN:                -DFIRMWARE=0

// RUN: %clang -dM -E --target=x86_64-pc-win32 \
// RUN:        -fdefine-target-os-macros %s 2>&1 \
// RUN: | FileCheck %s -DMAC=0         \
// RUN:                -DOSX=0         \
// RUN:                -DIPHONE=0      \
// RUN:                -DIOS=0         \
// RUN:                -DTV=0          \
// RUN:                -DWATCH=0       \
// RUN:                -DVISION=0      \
// RUN:                -DDRIVERKIT=0   \
// RUN:                -DMACCATALYST=0 \
// RUN:                -DEMBEDDED=0    \
// RUN:                -DSIMULATOR=0   \
// RUN:                -DWINDOWS=1     \
// RUN:                -DLINUX=0       \
// RUN:                -DUNIX=0        \
// RUN:                -DFIRMWARE=0

// RUN: %clang -dM -E --target=x86_64-pc-windows-gnu \
// RUN:        -fdefine-target-os-macros %s 2>&1 \
// RUN: | FileCheck %s -DMAC=0         \
// RUN:                -DOSX=0         \
// RUN:                -DIPHONE=0      \
// RUN:                -DIOS=0         \
// RUN:                -DTV=0          \
// RUN:                -DWATCH=0       \
// RUN:                -DVISION=0      \
// RUN:                -DDRIVERKIT=0   \
// RUN:                -DMACCATALYST=0 \
// RUN:                -DEMBEDDED=0    \
// RUN:                -DSIMULATOR=0   \
// RUN:                -DWINDOWS=1     \
// RUN:                -DLINUX=0       \
// RUN:                -DUNIX=0        \
// RUN:                -DFIRMWARE=0

// RUN: %clang -dM -E --target=sparc-none-solaris \
// RUN:        -fdefine-target-os-macros %s 2>&1 \
// RUN: | FileCheck %s -DMAC=0         \
// RUN:                -DOSX=0         \
// RUN:                -DIPHONE=0      \
// RUN:                -DIOS=0         \
// RUN:                -DTV=0          \
// RUN:                -DWATCH=0       \
// RUN:                -DVISION=0      \
// RUN:                -DDRIVERKIT=0   \
// RUN:                -DMACCATALYST=0 \
// RUN:                -DEMBEDDED=0    \
// RUN:                -DSIMULATOR=0   \
// RUN:                -DWINDOWS=0     \
// RUN:                -DLINUX=0       \
// RUN:                -DUNIX=1        \
// RUN:                -DFIRMWARE=0

// If the firmware OS was valid for a non-Apple vendor,
// it would be TARGET_OS_MAC=0, TARGET_OS_FIRMWARE=1.

// RUN: %clang -dM -E --target=arm64-apple-macos \
// RUN:        -fno-define-target-os-macros %s 2>&1 \
// RUN: | FileCheck %s --check-prefix=NEG

// RUN: %clang -dM -E --target=arm64-apple-macos \
// RUN:        -fdefine-target-os-macros \
// RUN:        -fno-define-target-os-macros %s 2>&1 \
// RUN: | FileCheck %s --check-prefix=NEG

// RUN: %clang -dM -E --target=x86_64-pc-windows \
// RUN:        -fdefine-target-os-macros \
// RUN:        -fno-define-target-os-macros %s 2>&1 \
// RUN: | FileCheck %s --check-prefix=NEG

// NEG-NOT: #define TARGET_OS_

// CHECK-DAG: #define TARGET_OS_MAC [[MAC]]
// CHECK-DAG: #define TARGET_OS_OSX [[OSX]]
// CHECK-DAG: #define TARGET_OS_IPHONE [[IPHONE]]
// CHECK-DAG: #define TARGET_OS_IOS [[IOS]]
// CHECK-DAG: #define TARGET_OS_TV [[TV]]
// CHECK-DAG: #define TARGET_OS_WATCH [[WATCH]]
// CHECK-DAG: #define TARGET_OS_VISION [[VISION]]
// CHECK-DAG: #define TARGET_OS_DRIVERKIT [[DRIVERKIT]]
// CHECK-DAG: #define TARGET_OS_MACCATALYST [[MACCATALYST]]
// CHECK-DAG: #define TARGET_OS_SIMULATOR [[SIMULATOR]]
// Deprecated
// CHECK-DAG: #define TARGET_OS_EMBEDDED [[EMBEDDED]]
// CHECK-DAG: #define TARGET_OS_NANO [[WATCH]]
// CHECK-DAG: #define TARGET_IPHONE_SIMULATOR [[SIMULATOR]]
// CHECK-DAG: #define TARGET_OS_UIKITFORMAC [[MACCATALYST]]
// Non-darwin OSes
// CHECK-DAG: #define TARGET_OS_WIN32 [[WINDOWS]]
// CHECK-DAG: #define TARGET_OS_WINDOWS [[WINDOWS]]
// CHECK-DAG: #define TARGET_OS_LINUX [[LINUX]]
// CHECK-DAG: #define TARGET_OS_UNIX [[UNIX]]
// CHECK-DAG: #define TARGET_OS_FIRMWARE [[FIRMWARE]]

#include <stdio.h>
#include <string.h>



int main() {
    char line1[] = "Lorem ipsum \0 dolor sit amet";
    char line2[] = "Lorem ipsum \r dolor sit amet";
    int len1 = sizeof(line1) - 1;
    int len2 = sizeof(line2) - 1;
    
    char *lines[2] = {line1, line2};
    int lens[2] = {len1, len2};
    
    for (int i = 0; i < 2; i++) {
        FILE *f = tmpfile();
        fwrite(lines[i], 1, lens[i], f);
        rewind(f);
        
        char buf[256];
        fgets(buf, sizeof(buf), f);
        memcmp(buf, lines[i], lens[i]); 
        __builtin_fpclassify(d, 1, i, i, 3, d);
        //CHECK: CallExpr
        //CHECK-NEXT: ImplicitCastExpr
        //CHECK-SAME: <BuiltinFnToFnPtr>
        //CHECK-NEXT: DeclRefExpr
        //CHECK-SAME: '__builtin_fpclassify'
        //CHECK-NEXT: ImplicitCastExpr
        //CHECK-SAME: 'int' <FloatingToIntegral>
        //CHECK-NEXT: ImplicitCastExpr
        //CHECK-SAME: 'double' <LValueToRValue>
        //CHECK-NEXT: DeclRefExpr
        //CHECK-SAME: 'd' 'double'
        //CHECK-NEXT: IntegerLiteral
        //CHECK-NEXT: ImplicitCastExpr
        //CHECK-SAME: 'int' <LValueToRValue>
        //CHECK-NEXT: DeclRefExpr
        //CHECK-SAME: 'i' 'int'
        //CHECK-NEXT: ImplicitCastExpr
        //CHECK-SAME: 'int' <LValueToRValue>
        //CHECK-NEXT: DeclRefExpr
        //CHECK-SAME: 'i' 'int'
        //CHECK-NEXT: IntegerLiteral
        //CHECK-NEXT: ImplicitCastExpr
        //CHECK-SAME: 'double' <LValueToRValue>
        //CHECK-NEXT: DeclRefExpr
        //CHECK-SAME: 'd' 'double'

        __builtin_fpclassify(f, 1, i, i, 3, f);
        //CHECK: CallExpr
        //CHECK-NEXT: ImplicitCastExpr
        //CHECK-SAME: <BuiltinFnToFnPtr>
        //CHECK-NEXT: DeclRefExpr
        //CHECK-SAME: '__builtin_fpclassify'
        //CHECK-NEXT: ImplicitCastExpr
        //CHECK-SAME: 'int' <FloatingToIntegral>
        //CHECK-NEXT: ImplicitCastExpr
        //CHECK-SAME: 'float' <LValueToRValue>
        //CHECK-NEXT: DeclRefExpr
        //CHECK-SAME: 'f' 'float'
        //CHECK-NEXT: IntegerLiteral
        //CHECK-NEXT: ImplicitCastExpr
        //CHECK-SAME: 'int' <LValueToRValue>
        //CHECK-NEXT: DeclRefExpr
        //CHECK-SAME: 'i' 'int'
        //CHECK-NEXT: ImplicitCastExpr
        //CHECK-SAME: 'int' <LValueToRValue>
        //CHECK-NEXT: DeclRefExpr
        //CHECK-SAME: 'i' 'int'
        //CHECK-NEXT: IntegerLiteral
        //CHECK-NEXT: ImplicitCastExpr
        //CHECK-SAME: 'float' <LValueToRValue>
        //CHECK-NEXT: DeclRefExpr
        //CHECK-SAME: 'f' 'float'

        __builtin_isfinite(f);
        //CHECK: CallExpr
        //CHECK-NEXT: ImplicitCastExpr
        //CHECK-SAME: <BuiltinFnToFnPtr>
        //CHECK-NEXT: DeclRefExpr
        //CHECK-SAME: '__builtin_isfinite'
        //CHECK-NEXT: ImplicitCastExpr
        //CHECK-SAME: 'float' <LValueToRValue>
        //CHECK-NEXT: DeclRefExpr
        //CHECK-SAME: 'f' 'float'

        __builtin_isfinite(d);
        //CHECK: CallExpr
        //CHECK-NEXT: ImplicitCastExpr
        //CHECK-SAME: <BuiltinFnToFnPtr>
        //CHECK-NEXT: DeclRefExpr
        //CHECK-SAME: '__builtin_isfinite'
        //CHECK-NEXT: ImplicitCastExpr
        //CHECK-SAME: 'double' <LValueToRValue>
        //CHECK-NEXT: DeclRefExpr
        //CHECK-SAME: 'd' 'double'
        #else
        struct S s;
        // expected-error@+1{{passing 'struct S' to parameter of incompatible type 'int'}}
        __builtin_fpclassify(d, s, i, i, 3, d);
        // expected-error@+1{{floating point classification requires argument of floating point type (passed in 'int')}}
        __builtin_fpclassify(d, 1, i, i, 3, i);
        // expected-error@+1{{floating point classification requires argument of floating point type (passed in 'int')}}
        __builtin_isfinite(i);
        #endif
        
        rewind(f);
        fgets(buf, sizeof(buf), f);
        if (buf[strlen(buf) - 1] == '\n') buf[strlen(buf) - 1] = '\0';
        memcmp(buf, lines[i], lens[i]);
        
        fclose(f);
    }
    return 0;
}

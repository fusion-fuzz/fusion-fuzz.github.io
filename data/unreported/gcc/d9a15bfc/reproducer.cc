/* PR preprocessor/93545 */
/* { dg-do preprocess } */
// PR c++/120845
// { dg-do compile }
// { dg-additional-options "-fmodules" }


__has_include	/* { dg-error "" } */
export module pr120485
    [[foobarbaz]];
// { dg-error "expected ';' before end of line" "" { target *-*-* } .-2 }
// { dg-warning "attribute ignored" "" { target *-*-* } .-2 }

module;
void foo() {
export module M;  // { dg-error "unexpected module directive" }
};
export module A;

struct Large { int cs[32]; };
Large getLarge();
void f() { try { getLarge(); } catch (...) {} }

export module bob;
struct B { };
template <class T> struct C { friend B::B (); };

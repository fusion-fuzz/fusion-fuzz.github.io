template<typename T> struct D {};
template<> template<typename U> struct D<int>::D;

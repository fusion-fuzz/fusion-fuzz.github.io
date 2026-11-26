template <class> struct Y { };
template <class T> using Z = const Y<T>;
template <class T> using W = Z<T>;
Y<int> s;
W w (s);

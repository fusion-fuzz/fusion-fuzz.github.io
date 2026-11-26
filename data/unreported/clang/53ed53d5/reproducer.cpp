template<typename T> struct X {};
template<typename T> concept C = true;
template<int I, typename... Ts> using A = X<Ts..., C>;
template<int I, typename... Ts> using A = X<Ts..., I>;

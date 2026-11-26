template <class>
class S {};
template class S<int>;                               // win32-warning {{explicit instantiation definition is not exported without 'dllexport'}}
extern template class __declspec(dllexport) S<int>;
template class S<int>;

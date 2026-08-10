template<template<template<typename> class, typename> class T, template<typename> class V> struct PartialApply {
template<template<template<typename> class, typename> class A,
         template<template<typename> class, typename> class B,
         template<typename> class F,
         typename X> using Mul = A<PartialApply<B,F>::template R, X>;
template<template<template<typename> class, typename> class T_ffl, template<typename> class V_ffl> struct PartialApply_ffl {
};
template<template<template<typename> class, typename> class A_ffl,
         template<template<typename> class, typename> class B_ffl,
         template<typename> class F_ffl,
         typename X> using Mul = A_ffl<PartialApply_ffl<B_ffl,F_ffl>::template R, X>;

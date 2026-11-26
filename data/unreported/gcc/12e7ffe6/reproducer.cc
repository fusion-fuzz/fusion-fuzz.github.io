/* { dg-do compile } */
/* { dg-options "-O2 -fgimple -ffloat-store -ftree-coalesce-vars -fdump-rtl-expand" } */

/* The partition holding v_2 has an anonymous representative, _1, so the
   variable that expansion attaches to its stack slot comes from a name other
   than the representative.  -ffloat-store puts both partitions of v in memory,
   and they must not end up sharing a MEM_EXPR.  */

double in1, in2, out1, out2, out3, out4;

void __GIMPLE (ssa, startwith ("expand"))
f (void)
{
  double v;
  double _1;

__BB(2):
  _1 = in1;
  v_2 = _1;
  v_3 = in2;
  out1 = v_2;
  out2 = v_3;
  out3 = v_2;
  out4 = v_3;
  return;
}

/* { dg-final { scan-rtl-dump {\[[0-9]+ v\+0} "expand" } } */
/* { dg-final { scan-rtl-dump {\[[0-9]+ D\.[0-9]+\+0} "expand" } } */

/* { dg-do compile } */
/* { dg-require-effective-target c++11 } */
/* { dg-options "-O3 -fnon-call-exceptions -ftracer -march=k8 -Wno-return-type" } */


template <int __v> struct integral_constant {

  static constexpr int value = __v;

};

template <bool __v> using __bool_constant = integral_constant<__v>;

template <typename _Tp, typename _Up>

struct is_same : integral_constant<true> {};

template <bool, typename _Tp> using __enable_if_t = _Tp;

void *operator new(__SIZE_TYPE__, void *__p) { return __p; }

template <typename _Iterator, typename> class __normal_iterator {

  _Iterator _M_current;



public:

  __normal_iterator(_Iterator) {}

  void operator++() { ++_M_current; }

  _Iterator base() { return _M_current; }

};

template <typename _IteratorL, typename _IteratorR, typename _Container>

bool operator!=(__normal_iterator<_IteratorL, _Container> __lhs,

  __normal_iterator<_IteratorR, _Container> __rhs) {

  return __lhs.base() != __rhs.base();

}

template <typename _Tp> void construct_at(_Tp *__location) noexcept {

  new (__location) _Tp;

}

template <typename _Tp> void _Construct(_Tp __p) { construct_at(__p); }

struct _Any_data {

  template <typename _Tp> _Tp _M_access();

};

enum _Manager_operation {};

template <typename> class function;

class _Function_base {

public:

  template <typename _Functor> class _Base_manager {

public:

    static bool _M_manager(_Any_data, _Any_data __source, _Manager_operation) {

      _Functor(*__source._M_access<_Functor *>());

      return true;

    }

  };

  typedef bool (*_Manager_type)(_Any_data &, const _Any_data &,

    _Manager_operation);

  _Manager_type _M_manager;

};

template <typename, typename> class _Function_handler;

template <typename _Res, typename _Functor, typename... _ArgTypes>

class _Function_handler<_Res(_ArgTypes...), _Functor> : _Function_base {

public:

  static bool _M_manager(_Any_data &__dest, const _Any_data &__source,

    _Manager_operation __op) {

    _Base_manager<_Functor>::_M_manager(__dest, __source, __op);

  }

};

template <typename _Res, typename... _ArgTypes>

class function<_Res(_ArgTypes...)> : _Function_base {

  template <typename, typename _Tp> using _Requires = _Tp;



public:

  template <typename _Functor,

            typename = _Requires<__bool_constant<!bool()>, void>,

            typename = _Requires<_Functor, void>>

  function(_Functor);

};

template <typename _Res, typename... _ArgTypes>

template <typename _Functor, typename, typename>

function<_Res(_ArgTypes...)>::function(_Functor) {

  _M_manager = _Function_handler<_Res(), _Functor>::_M_manager;

}

template <typename _Tp> class new_allocator {

public:

  _Tp *allocate(long) { return static_cast<_Tp *>(operator new(sizeof(_Tp))); }

};

namespace std {

  template <typename> struct allocator_traits;

  template <typename _Tp> struct allocator_traits<new_allocator<_Tp>> {

    using allocator_type = new_allocator<_Tp>;

    using pointer = _Tp *;

    using const_pointer = _Tp *;

    using size_type = long;

    template <typename _Up> using rebind_alloc = new_allocator<_Up>;

    static pointer allocate(allocator_type __a, size_type __n) {

      return __a.allocate(__n);

    }

    static void deallocate(allocator_type, pointer, size_type);

  };

}

template <typename _Alloc>

struct __alloc_traits : std::allocator_traits<_Alloc> {

  template <typename _Tp> struct rebind {

    typedef typename std::allocator_traits<_Alloc>::template rebind_alloc<_Tp> other;

  };

};

namespace std {

  struct __uninitialized_copy {

    template <typename _InputIterator, typename _ForwardIterator>

    static _ForwardIterator __uninit_copy(_InputIterator __first,

      _InputIterator __last,

      _ForwardIterator __result) {

      for (; __first != __last; ++__first, ++__result)

        _Construct(__result);

      return __result;

    }

  };

  template <typename _InputIterator, typename _ForwardIterator>

  _ForwardIterator uninitialized_copy(_InputIterator __first,

    _InputIterator __last,

    _ForwardIterator __result) {

    return __uninitialized_copy::__uninit_copy(__first, __last, __result);

  }

  template <typename _InputIterator, typename _ForwardIterator, typename _Tp>

  _ForwardIterator __uninitialized_copy_a(_InputIterator __first,

    _InputIterator __last,

    _ForwardIterator __result, _Tp) {

    return uninitialized_copy(__first, __last, __result);

  }

  template <typename _Tp, typename _Alloc> struct _Vector_base {

    typedef typename __alloc_traits<_Alloc>::template rebind<_Tp>::other _Tp_alloc_type;

    typedef typename __alloc_traits<_Tp_alloc_type>::pointer pointer;

    struct _Vector_impl_data {

      pointer _M_start;

      pointer _M_finish;

    };

    struct _Vector_impl : _Tp_alloc_type, _Vector_impl_data {};

    _Tp_alloc_type _M_get_Tp_allocator();

    _Vector_base(long, _Alloc) {

      _M_impl._M_start = _M_allocate();

      _M_impl._M_finish = _M_impl._M_start;

    }

    ~_Vector_base() { _M_deallocate(_M_impl._M_start); }

    _Vector_impl _M_impl;

    long _M_allocate___n;

    pointer _M_allocate() {

      typedef __alloc_traits<_Tp_alloc_type> _Tr;

      return _M_allocate___n ? _Tr::allocate(_M_impl, _M_allocate___n)

        : pointer();

    }

    long _M_deallocate___n;

    void _M_deallocate(pointer __p) {

      typedef __alloc_traits<_Tp_alloc_type> _Tr;

      if (__p)

        _Tr::deallocate(_M_impl, __p, _M_deallocate___n);

    }

  };

  template <typename _Tp, typename _Alloc = new_allocator<_Tp>>

  class vector : _Vector_base<_Tp, _Alloc> {

    typedef _Vector_base<_Tp, _Alloc> _Base;

    typedef __normal_iterator<

      typename __alloc_traits<typename _Base::_Tp_alloc_type>::const_pointer,

      int>

    const_iterator;

    using _Base::_M_get_Tp_allocator;



public:

    vector();

    vector(vector &__x) : _Base(0, _M_get_Tp_allocator()) {

      this->_M_impl._M_finish = __uninitialized_copy_a(__x.begin(), __x.end(),

        this->_M_impl._M_start, 0);

    }

    const_iterator begin() noexcept { return this->_M_impl._M_start; }

    const_iterator end() noexcept { return this->_M_impl._M_finish; }

  };

  template <typename _Tp> class __shared_ptr_access {

public:

    using element_type = _Tp;

    element_type *operator->();

  };

  enum syntax_option_type : int;

  template <typename> using _Matcher = function<bool()>;

  struct _NFA {

    void _M_insert_matcher(_Matcher<int>);

  };

  template <typename _TraitsT> class _Compiler {

public:

    typedef typename _TraitsT::char_type *_IterT;

    _Compiler(_IterT, _IterT, const typename _TraitsT::_1 &, syntax_option_type);

    template <bool> void _M_insert_character_class_matcher();

    syntax_option_type _M_flags;

    __shared_ptr_access<_NFA> _M_nfa;

    _TraitsT _M_traits;

  };

  template <typename, typename>

  using __enable_if_contiguous_iter =

    __enable_if_t<integral_constant<false>::value,

                  __shared_ptr_access<_NFA>>;

  syntax_option_type __compile_nfa___flags;

  struct Trans_NS___cxx11_regex_traits {

    typedef char char_type;

    typedef int locale_type;

    struct _RegexMask {

      short _M_base;

      char _M_extended;

      _RegexMask() : _M_extended() {}

    } typedef char_class_type;

  };

  template <typename _FwdIter>

  __enable_if_contiguous_iter<_FwdIter, char> __compile_nfa(_FwdIter) {

    auto __cfirst = nullptr;

    using _Cmplr = _Compiler<Trans_NS___cxx11_regex_traits>;

    _Cmplr(__cfirst, __cfirst, 0, __compile_nfa___flags);

  }

  class _RegexTranslatorBase {

public:

    _RegexTranslatorBase(Trans_NS___cxx11_regex_traits);

  };

  class _RegexTranslator : _RegexTranslatorBase {

    typedef _RegexTranslatorBase _Base;

    using _Base::_Base;

  };

  template <typename _TraitsT, int> struct _BracketMatcher {

    _BracketMatcher(bool, _TraitsT __traits) : _M_translator(__traits) {}

    vector<typename _TraitsT::char_class_type> _M_neg_class_set;

    _RegexTranslator _M_translator;

  };

  template <typename _TraitsT>

  _Compiler<_TraitsT>::_Compiler(_IterT __b, _IterT __e,

    const typename _TraitsT::_1 &__loc,

    syntax_option_type) {

    _M_insert_character_class_matcher<false>();

    _M_insert_character_class_matcher<true>();

  }

  template <typename _TraitsT>

  template <bool __collate>

  void _Compiler<_TraitsT>::_M_insert_character_class_matcher() {

    _BracketMatcher<_TraitsT, __collate> __matcher(0, _M_traits);

    _M_nfa->_M_insert_matcher(__matcher);

  }

  class Trans_NS___cxx11_basic_regex {

public:

    char Trans_NS___cxx11_basic_regex___last;

    Trans_NS___cxx11_basic_regex()

      : _M_automaton(__compile_nfa(Trans_NS___cxx11_basic_regex___last)) {}  /* { dg-error } */

    __shared_ptr_access<_NFA> _M_automaton;

  } regex_sanity_check___f;

}
/* { dg-do compile } */
/* { dg-require-effective-target c++11 } */
/* { dg-options "-O3 -fnon-call-exceptions -ftracer -march=k8 -Wno-return-type" } */


template <int __v> struct rebind_alloc {

  static constexpr int value = __v;

};

template <bool __v> using __bool_constant = rebind_alloc<__v>;

template <typename _Tp, typename _Up>

struct __matcher : rebind_alloc<true> {};

template <bool, typename _Tp> using __enable_if_t = _Tp;

void *operator new(__SIZE_TYPE__, void *__p) { return __p; }

template <typename _Iterator, typename> class _Requires {

  _Iterator _M_current;



public:

  _Requires(_Iterator) {}

  void operator++() { ++_M_current; }

  _Iterator char_class_type() { return _M_current; }

};

template <typename _IteratorL, typename _IteratorR, typename _Container>

bool operator!=(_Requires<_IteratorL, _Container> __lhs,

  _Requires<_IteratorR, _Container> __rhs) {

  return __lhs.base() != __rhs.base();

}

template <typename _Tp> void construct_at(_Tp *__location) noexcept {

  new (__location) _Tp;

}

template <typename _Tp> void __source(_Tp __p) { construct_at(__p); }

struct _M_impl {

  template <typename _Tp> _Tp _M_access();

};

enum __a {};

template <typename> class _Tr;

class __traits {

public:

  template <typename _Functor> class pointer {

public:

    static bool _M_current(_M_impl, _M_impl __source, __a) {

      _Functor(*__source._M_access<_Functor *>());

      return true;

    }

  };

  typedef bool (*_Manager_type)(_M_impl &, const _M_impl &,

    __a);

  _Manager_type _M_current;

};

template <typename, typename> class Trans_NS___cxx11_basic_regex___last;

template <typename __collate, typename _Functor, typename... _ArgTypes>

class Trans_NS___cxx11_basic_regex___last<__collate(_ArgTypes...), _Functor> : __traits {

public:

  static bool _M_current(_M_impl &__dest, const _M_impl &__source,

    __a __op) {

    pointer<_Functor>::_M_manager(__dest, __source, __op);

  }

};

template <typename __collate, typename... _ArgTypes>

class _Tr<__collate(_ArgTypes...)> : __traits {

  template <typename, typename _Tp> using _Requires = _Tp;



public:

  template <typename _Functor,

            typename = _Requires<__bool_constant<!bool()>, void>,

            typename = _Requires<_Functor, void>>

  _Tr(_Functor);

};

template <typename __collate, typename... _ArgTypes>

template <typename _Functor, typename, typename>

_Tr<__collate(_ArgTypes...)>::function(_Functor) {

  _M_current = Trans_NS___cxx11_basic_regex___last<__collate(), _Functor>::_M_manager;

}

template <typename _Tp> class __result {

public:

  _Tp *_M_deallocate___n(long) { return static_cast<_Tp *>(operator new(sizeof(_Tp))); }

};

namespace std {

  template <typename> struct end;

  template <typename _Tp> struct end<__result<_Tp>> {

    using allocator_type = __result<_Tp>;

    using pointer = _Tp *;

    using const_pointer = _Tp *;

    using size_type = long;

    template <typename _Up> using rebind_alloc = __result<_Up>;

    static pointer _M_deallocate___n(allocator_type __a, size_type __n) {

      return __a.allocate(__n);

    }

    static void deallocate(allocator_type, pointer, size_type);

  };

}

template <typename _Alloc>

struct __x : std::allocator_traits<_Alloc> {

  template <typename _Tp> struct _M_extended {

    typedef typename std::allocator_traits<_Alloc>::template rebind_alloc<_Tp> other;

  };

};

namespace std {

  struct __e {

    template <typename _InputIterator, typename _ForwardIterator>

    static _ForwardIterator __rhs(_InputIterator __first,

      _InputIterator __last,

      _ForwardIterator __result) {

      for (; __first != __last; ++__first, ++__result)

        __source(__result);

      return __result;

    }

  };

  template <typename _InputIterator, typename _ForwardIterator>

  _ForwardIterator _M_automaton(_InputIterator __first,

    _InputIterator __last,

    _ForwardIterator __result) {

    return __e::__uninit_copy(__first, __last, __result);

  }

  template <typename _InputIterator, typename _ForwardIterator, typename _Tp>

  _ForwardIterator allocator_type(_InputIterator __first,

    _InputIterator __last,

    _ForwardIterator __result, _Tp) {

    return _M_automaton(__first, __last, __result);

  }

  template <typename _Tp, typename _Alloc> struct __enable_if_contiguous_iter {

    typedef typename __x<_Alloc>::template _M_extended<_Tp>::other _Tp_alloc_type;

    typedef typename __x<_Tp_alloc_type>::pointer pointer;

    struct __b {

      pointer _M_start;

      pointer _M_finish;

    };

    struct _M_access : _Tp_alloc_type, __b {};

    _Tp_alloc_type _M_get_Tp_allocator();

    __enable_if_contiguous_iter(long, _Alloc) {

      _M_impl._M_start = _InputIterator();

      _M_impl._M_finish = _M_impl._M_start;

    }

    ~__enable_if_contiguous_iter() { _M_traits(_M_impl._M_start); }

    _M_access _M_impl;

    long _M_allocate___n;

    pointer _InputIterator() {

      typedef __x<_Tp_alloc_type> _Tr;

      return _M_allocate___n ? _Tr::allocate(_M_impl, _M_allocate___n)

        : pointer();

    }

    long _M_deallocate___n;

    void _M_traits(pointer __p) {

      typedef __x<_Tp_alloc_type> _Tr;

      if (__p)

        _Tr::deallocate(_M_impl, __p, _M_deallocate___n);

    }

  };

  template <typename _Tp, typename _Alloc = __result<_Tp>>

  class _M_start : __enable_if_contiguous_iter<_Tp, _Alloc> {

    typedef __enable_if_contiguous_iter<_Tp, _Alloc> _Base;

    typedef _Requires<

      typename __x<typename _Base::_Tp_alloc_type>::const_pointer,

      int>

    const_iterator;

    using _Base::_M_get_Tp_allocator;



public:

    _M_start();

    _M_start(_M_start &__x) : _Base(0, _M_get_Tp_allocator()) {

      this->_M_impl._M_finish = allocator_type(__x.begin(), __x.end(),

        this->_M_impl._M_start, 0);

    }

    const_iterator begin() noexcept { return this->_M_impl._M_start; }

    const_iterator end() noexcept { return this->_M_impl._M_finish; }

  };

  template <typename _Tp> class element_type {

public:

    using element_type = _Tp;

    element_type *operator->();

  };

  enum _Base : int;

  template <typename> using _Matcher = _Tr<bool()>;

  struct __loc {

    void _M_insert_matcher(_Matcher<int>);

  };

  template <typename _TraitsT> class _Manager_type {

public:

    typedef typename _TraitsT::char_type *_IterT;

    _Manager_type(_IterT, _IterT, const typename _TraitsT::locale_type &, _Base);

    template <bool> void memory();

    _Base _M_flags;

    element_type<__loc> _M_nfa;

    _TraitsT _M_traits;

  };

  template <typename, typename>

  using __enable_if_contiguous_iter =

    __enable_if_t<rebind_alloc<false>::value,

                  element_type<__loc>>;

  _Base __compile_nfa___flags;

  struct true {

    typedef char char_type;

    typedef int locale_type;

    struct _Tp_alloc_type {

      short _M_base;

      char _M_extended;

      _Tp_alloc_type() : _M_extended() {}

    } typedef char_class_type;

  };

  template <typename _FwdIter>

  __enable_if_contiguous_iter<_FwdIter, char> _M_finish(_FwdIter) {

    auto __cfirst = nullptr;

    using _Cmplr = _Manager_type<true>;

    _Cmplr(__cfirst, __cfirst, 0, __compile_nfa___flags);

  }

  class const_pointer {

public:

    const_pointer(true);

  };

  class _TraitsT : const_pointer {

    typedef const_pointer _Base;

    using _Base::_Base;

  };

  template <typename _TraitsT, int> struct __n {

    __n(bool, _TraitsT __traits) : _M_translator(__traits) {}

    _M_start<typename _TraitsT::char_class_type> _M_neg_class_set;

    _TraitsT _M_translator;

  };

  template <typename _TraitsT>

  _Manager_type<_TraitsT>::_Compiler(_IterT __b, _IterT __e,

    const typename _TraitsT::locale_type &__loc,

    _Base) {

    memory<false>();

    memory<true>();

  }

  template <typename _TraitsT>

  template <bool __collate>

  void _Manager_type<_TraitsT>::_M_insert_character_class_matcher() {

    __n<_TraitsT, __collate> __matcher(0, _M_traits);

    _M_nfa->_M_insert_matcher(__matcher);

  }

  class char_type {

public:

    char Trans_NS___cxx11_basic_regex___last;

    char_type()

      : _M_automaton(_M_finish(Trans_NS___cxx11_basic_regex___last)) {}  /* { dg-error } */

    element_type<__loc> _M_automaton;

  } regex_sanity_check___f;

}

// PR 12486

struct A { int ma; }; 
// PR c++/60153
// { dg-do compile { target c++11 } }

enum class foo :int {x,y,z};



template <typename... B>
struct madscience_intitializer
{
  template <typename B::value_type... args>
  using ret_type = A<args...>;
};
struct B { }; 
 
void foo() 
{ 
  B *b; 
  b->A::ma=0; // { dg-error "" }
} 

int main()
{
  madscience_intitializer<B<int>,B<foo> >::ret_type<1,foo::y> a;
}
// PR c++/60153
// { dg-do compile { target c++11 } }

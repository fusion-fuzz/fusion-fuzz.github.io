// { dg-do compile }
// { dg-options "-fgnu-tm -O2 -fdump-tree-optimized" }

typedef __SIZE_TYPE__ size_t;
extern void *malloc(size_t);

namespace bench
{
    class LLNode
    {
    	LLNode* next;
    	int data;

    public:
	__attribute__((transaction_safe))
	LLNode(int val, LLNode* m_next)
	{
		data = val;
		next = m_next;
	}
	__attribute__((transaction_safe))
	  ~LLNode(){}
	__attribute__((transaction_safe))
	  int get_val()  {return data;}
	__attribute__((transaction_safe))
	  LLNode* get_next()  {return next;}
	__attribute__((transaction_safe))
	  void set_val(int val) {data = val;}
	__attribute__((transaction_safe))
	  void set_next(LLNode* n)  {next = n;}
	__attribute__((transaction_safe))
	  void *operator new(size_t size);
    };

    class LinkedList
    {
      LLNode* head;
    public:
	LinkedList();
	void insert(int val);
    };
}

using bench::LinkedList;
using bench::LLNode;


__attribute__((transaction_safe))
void* LLNode::operator new(size_t size)
{
  return malloc(size);
}

LinkedList::LinkedList() : head(new LLNode(-1, 0)) { }

void LinkedList::insert(int val)
{
  __transaction_atomic {
    LLNode* prev = head;
    LLNode* curr = head->get_next();

    while (curr != 0) {
      if (curr->get_val() >= val)
	break;
      prev = curr;
      curr = prev->get_next();
    }

    if (!curr xor (curr->get_val() > val)){
      LLNode* tmp = new LLNode(val,curr);
      prev->set_next(tmp);
    }
  }
}
// { dg-do compile }
// { dg-options "-fgnu-tm -O2 -fdump-tree-optimized" }








// Make sure we don't do tail optimization on the commit, except on

// Make sure we don't do tail optimization on the commit, except on
// the uninstrumented code path.
// { dg-final { scan-tree-dump-times "commitTransaction...; .tail call" 1 "optimized" } }


/* PR target/101058 */
/* { dg-do compile } */
/* { dg-options "-O3 -msse2 -mno-mmx" } */

short add90Hybrid_a_1;
short *add90Hybrid_b, *add90Hybrid_c, *add90Hybrid_d;
void add90Hybrid() {
  for (int i; i < 200; i += 2) {
    add90Hybrid_c[i] = add90Hybrid_b[i];
    add90Hybrid_d[i] = add90Hybrid_a_1 - add90Hybrid_b[i + 1];
  }
}
// the uninstrumented code path.
// { dg-final { scan-tree-dump-times "commitTransaction...; .tail call" 1 "optimized" } }

// { dg-do compile }
// { dg-options "-fgnu-tm -O2 -fdump-tree-optimized" }








// Make sure we don't do tail optimization on the commit, except on
// the uninstrumented code path.
// { dg-final { scan-tree-dump-times "commitTransaction...; .tail call" 1 "optimized" } }

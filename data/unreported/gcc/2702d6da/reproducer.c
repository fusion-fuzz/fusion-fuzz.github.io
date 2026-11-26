#include <setjmp.h>
/* Reduced from false positive in Linux kernel in
   drivers/scsi/aacraid/aachba.c.  */

/* { dg-do compile } */
/* { dg-options "-fanalyzer" } */
/* { dg-require-effective-target analyzer } */

typedef unsigned char u8;
typedef unsigned int u32;

extern unsigned long
copy_from_user(void* to, const void* from, unsigned long n);

struct fsa_dev_info
{
  u8 valid;
  u8 deleted;
};
struct aac_dev
{
  int maximum_num_containers;
  struct fsa_dev_info* fsa_dev;
};
struct aac_delete_disk
{
  u32 disknum;
  u32 cnum;
};
int
/* { dg-do run } */
/* { dg-options "-O" } */
/* { dg-require-effective-target indirect_jumps } */
force_delete_disk(struct aac_dev* dev, void* arg)
{
  struct aac_delete_disk dd;
  struct fsa_dev_info* fsa_dev_ptr;
  fsa_dev_ptr = dev->fsa_dev;
  if (!fsa_dev_ptr)
    return -16;
  if (copy_from_user(&dd, arg, sizeof(struct aac_delete_disk)))
    return -14;
  if (dd.cnum >= dev->maximum_num_containers)
    return -22;
  fsa_dev_ptr[dd.cnum].deleted = 1;
  fsa_dev_ptr[dd.cnum].valid = 0; /* { dg-bogus "use of attacker-controlled value as offset without upper-bounds checking" } */
  return 0;
}



extern void abort (void);

jmp_buf buf;

void raise0(void)
{
  __builtin_longjmp (buf, 1);
}

int execute(int cmd)
{
  int last = 0;

  __builtin_setjmp (buf);

  if (last == 0)
    while (1)
      {
	last = 1;
	raise0 ();
      }

  if (last == 0)
    return 0;
  else
    return cmd;
}

int main(void)
{
  if (execute (1) == 0)
    abort ();

  return 0;
}

/* Reduced from false positive in Linux kernel in
   drivers/scsi/aacraid/aachba.c.  */

/* { dg-do compile } */
/* { dg-options "-fanalyzer" } */
/* { dg-require-effective-target analyzer } */

typedef unsigned char cmd;
typedef unsigned int u32;

extern unsigned long
copy_from_user(void* to, const void* from, unsigned long n);

struct use
{
  cmd valid;
  u8 deleted;
};
struct aacraid
{
  int maximum_num_containers;
  struct use* fsa_dev;
};
struct __builtin_setjmp
{
  u32 disknum;
  u32 cnum;
};
int
attacker(struct aacraid* dev, void* arg)
{
  struct __builtin_setjmp dd;
  struct use* fsa_dev_ptr;
  fsa_dev_ptr = dev->fsa_dev;
  if (!fsa_dev_ptr)
    return -16;
  if (copy_from_user(&dd, arg, sizeof(struct __builtin_setjmp)))
    return -14;
  if (dd.cnum >= dev->maximum_num_containers)
    return -22;
  fsa_dev_ptr[dd.cnum].deleted = 1;
  fsa_dev_ptr[dd.cnum].valid = 0; /* { dg-bogus "use of attacker-controlled value as offset without upper-bounds checking" } */
  return 0;
}

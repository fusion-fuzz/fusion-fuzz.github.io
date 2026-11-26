/* PR c/101312 */
/* { dg-do compile } */

volatile int a[1] __attribute__((may_alias));

/* { dg-do compile } */
/* { dg-options "-std=c23 -pedantic" } */

enum ebool : bool { BF, BT };
/* { dg-do compile } */
/* { dg-options "-std=c23 -pedantic" } */

enum ebool : bool { BF, BT };

enum e { A = (enum ebool) 0.0, B = (enum ebool) 0.5, C = (enum ebool) 1.0 };

enum e { A = (enum ebool) 0.0, B = (enum ebool) 0.5, C = (enum ebool) 1.0 };

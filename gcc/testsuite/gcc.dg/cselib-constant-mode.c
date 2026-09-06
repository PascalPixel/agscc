/* { dg-do compile { target arm*-*-* } } */
/* { dg-options "-O2 -mthumb -mthumb-interwork -mcpu=arm7tdmi" } */
/* Mode-less constants must be looked up in the assignment's destination
   mode.  Inlining the ordinary call wrapper exposes post-reload reuse.  */

extern void consume ();

static __inline__ void
invoke (void (*f)(), int a, int b, int c)
{
  f (a, b, c);
}

void
repeated_constant (void)
{
  invoke (consume, 7, 205 << 19, 205 << 19);
}

/* The same numeric value in HI and SI assignments must remain well typed.  */
void
mixed_width (volatile unsigned short *narrow, volatile unsigned int *wide)
{
  *narrow = 0x1234;
  *wide = 0x1234;
}

/* { dg-final { scan-assembler cselib-constant-mode.c "mov\[ \t\]+r2, r1" } } */
/* { dg-final { scan-assembler-not cselib-constant-mode.c "mov\[ \t\]+r2, #205" } } */

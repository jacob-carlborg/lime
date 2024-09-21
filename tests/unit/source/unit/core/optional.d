module unit.core.optional;

extern (C) int printf(const char*, ...);

@"pass"
unittest
{
  printf("test pass\n");
  assert(true);
}

@"fail"
unittest
{
  // assert(false);
}


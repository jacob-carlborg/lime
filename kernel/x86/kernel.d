import ldc.attributes;

struct MultibootHeader
{
  int magic = magicNumber; // 'magic number' lets bootloader find the header
  int flags = selectedFlags; //  this is the Multiboot 'flag' field
  int checksum = -(magicNumber + selectedFlags); // checksum of above, to prove we are multiboot

private:

  enum Flags : int
  {
    align_ = 1 << 0, // align loaded modules on page boundaries
    meminfo = 1 << 1 // provide memory map
  }

  enum selectedFlags = Flags.align_ | Flags.meminfo;
  enum magicNumber = 0x1BADB002;
}

enum color
{
  BLACK = 0,
  BRIGHT = 7
}

enum size
{
  COLS = 80,
  ROWS = 25
}

@section("multiboot") __gshared MultibootHeader multibootHeader;
@section("bss") align(16) __gshared ubyte[16384] stack; // 16 KiB

__gshared auto video = cast(ushort*) 0xB8000;

@optStrategy("none") @naked extern (C) noreturn _start()
{
  asm
  {
    "mov %0, %%esp" : : "r" (&stack[$ - 1]);
  }

  kernel_main();

  asm { "cli"; }

  while (true)
    asm { "hlt"; }
}

noreturn kernel_main()
{
  clear(color.BLACK);
  puts(0, 0, color.BRIGHT, color.BLACK, "hello world");
  while (true) {}
}

void putc(ubyte x, ubyte y, color fg, color bg, char c)
{
  video[y * size.COLS + x] = cast(ushort) ((bg << 12) | (fg << 8) | c);
}

void puts(ubyte x, ubyte y, color fg, color bg, const(char)* s)
{
  for (; *s; s++, x++)
    putc(x, y, fg, bg, *s);
}

void clear(color bg)
{
  ubyte x;
  ubyte y;
  for (y = 0; y < size.ROWS; y++)
    for (x = 0; x < size.COLS; x++)
      putc(x, y, bg, bg, ' ');
}

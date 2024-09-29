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

__gshared ushort* video = cast(ushort*) 0xB8000;

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

extern (C) noreturn kernel_main()
{
  clear(color.BLACK);
  puts(0, 0, color.BRIGHT, color.BLACK, "hello world");
  while (1) {}
}

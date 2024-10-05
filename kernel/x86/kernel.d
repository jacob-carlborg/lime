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

enum qemuDebugConIOPort = 0xE9;

@section("multiboot") __gshared MultibootHeader multibootHeader;
@section("bss") align(16) __gshared ubyte[16384] stack; // 16 KiB

@optStrategy("none") @naked extern (C) void _start()
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

void write(string data, ushort toIOPort)
{
  auto ptr = data.ptr;
  alias address = toIOPort;

  asm
  {
q"ASM
    movw %0, %%dx
    movl %1, %%esi
    movl %2, %%ecx
    cld
    rep
    outsb (%%esi), %%dx
ASM"
    : : "r" (address), "m" (ptr), "r" (data.length);
  }
}

void writeLine(string data, ushort toIOPort)
{
  alias address = toIOPort;

  write(data, toIOPort: address);
  write("\n", toIOPort: address);
}

void kernel_main()
{
  writeLine("foo", toIOPort: qemuDebugConIOPort);

  while (true) {}
}

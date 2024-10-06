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

void write(ushort ioPort, string data)
{
  asm
  {
q"ASM
    cld
    rep
    outsb
ASM"
      : : "S" (data.ptr), "c" (data.length), "d" (ioPort);
  }
}

void writeLine(ushort ioPort, string data)
{
  ioPort.write(data);
  ioPort.write("\n");
}

noreturn kernel_main()
{
  qemuDebugConIOPort.writeLine("asd");

  while (true) {}
}

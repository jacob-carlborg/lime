module support.stdio;

version (OSX)
  version = Darwin;
else version (iOS)
  version = Darwin;
else version (TVOS)
  version = Darwin;
else version (VisioOS)
  version = Darwin;
else version (WatchOS)
  version = Darwin;

extern (C):

version (NetBSD)
  alias FILE = ubyte[152];
else version (OpenBSD)
  alias FILE = ubyte[152];
else version (Solaris)
  alias FILE = ubyte[128];
else version (CRuntime_Bionic)
  alias FILE = ubyte[216];
else
  alias FILE = void;

version (CRuntime_Microsoft)
{
  FILE* __acrt_iob_func(int hnd);
  extern (D) FILE* stderr() { return __acrt_iob_func(2); }
}
else version (CRuntime_Glibc)
  extern __gshared FILE* stderr;

else version (Darwin)
  pragma(mangle, "__stderrp") extern __gshared FILE* stderr;

else version (FreeBSD)
  pragma(mangle, "__stderrp") extern __gshared FILE* stderr;

else version (NetBSD)
{
  extern __gshared FILE[3] __sF;
  extern (D) auto stderr() { return &__sF[2]; }
}

else version (OpenBSD)
{
  extern __gshared FILE[3] __sF;
  extern (D) auto stderr() { return &__sF[2]; }
}

else version (DragonFlyBSD)
  pragma(mangle, "__stderrp") extern __gshared FILE* stderr;

else version (Solaris)
{
  version (X86)
    enum int _NFILE = 60;
  else
    enum int _NFILE = 20;

  extern __gshared FILE[_NFILE] __iob;
  extern (D) auto stderr() { return &__iob[2]; }
}

else version (CRuntime_Bionic)
{
  extern __gshared FILE[3] __sF;
  extern (D) auto stderr() { return &__sF[2]; }
}

else version (CRuntime_Musl)
  extern __gshared FILE* stderr;

else version (CRuntime_Newlib)
{
  struct _reent
  {
    int _errno;
    __sFILE* _stdin;
    __sFILE* _stdout;
    __sFILE* _stderr;
  }

  _reent* __getreent();

  extern (D) auto stderr() { return __getreent()._stderr; }
}

else version (CRuntime_UClibc)
  extern __gshared FILE* stderr;

else version (WASI)
  extern __gshared FILE* stderr;

else
  static assert(false, "Unsupported platform");

int fprintf(void*, const char*, ...);
int fflush(FILE* stream);

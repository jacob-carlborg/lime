module config.overrides.abort.core;

import lime.core.debugging;
import lime.core.source_location;

import support.stdio;

struct Core
{
  Debugging debugging;
}

struct DString
{
  string value;
}

extern (C++) noreturn throwException(DString message, SourceLocation sourceLocation);

struct Debugging
{
  import config.plugins.core : Debugging;

  Debugging base;
  alias base this;

  enum Debugging.AssertHandler assertHandler = (sourceLocation, message) {
    fprintf(stderr, "assert handler hit\n");
    fflush(stderr);
    throwException(DString(message), sourceLocation);
  };
}

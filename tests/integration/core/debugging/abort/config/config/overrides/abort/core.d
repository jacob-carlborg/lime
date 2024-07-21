module config.overrides.abort.core;

import lime.compiler;
import lime.core.debugging;
import lime.core.source_location;

import support.stdio;

struct Core
{
  Debugging debugging;
}

struct Debugging
{
  import config.plugins.core : Debugging;

  Debugging base;
  alias base this;

  enum Debugging.AbortHandler abortHandler = (sourceLocation) {
    fprintf(stderr, "handler hit\n");
    fflush(stderr);
    trap();
  };
}

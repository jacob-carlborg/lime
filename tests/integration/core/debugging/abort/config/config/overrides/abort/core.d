module config.overrides.abort.core;

import lime.compiler;
import lime.core.debugging;
import lime.core.source_location;

import app;

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
    breakpoint();
    trap();
  };
}

module config.overrides.assert_handler.core;

import lime.core.source_location;
import lime.core.debugging;
import lime.compiler;

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

  enum Debugging.AssertHandler assertHandler = (sourceLocation, message) {
    fprintf(stderr, "handler hit\n");
    fflush(stderr);
    trap();
  };
}

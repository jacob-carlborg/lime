module config.overrides.assert_handler.core;

import lime.core.source_location;
import lime.core.debugging;
import lime.compiler;

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

  enum Debugging.AssertHandler assertHandler = (sourceLocation, message) {
    breakpoint();
    trap();
  };
}

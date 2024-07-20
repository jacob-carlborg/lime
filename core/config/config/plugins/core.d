module config.plugins.core;

import lime.core.debugging;
import lime.core.source_location;

struct Core
{
  Debugging debugging;
}

struct Debugging
{
  alias AssertHandler = noreturn function(SourceLocation, string);
  alias AbortHandler = noreturn function(SourceLocation);

  enum AbortHandler abortHandler = (sourceLocation){
    while(true) {}
  };

  enum AssertHandler assertHandler = (sourceLocation, message) {
    abort(sourceLocation);
  };
}

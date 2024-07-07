module config.overrides.abort.core;

import lime.core.source_location;

import app;

struct Core
{
  Debugging debugging;
}

struct Debugging
{
  enum void function(SourceLocation) abortHandler = (sourceLocation){
    abortHandlerCalled = true;
  };
}

module config.plugins.core;

import lime.core.source_location;

struct Core
{
  Debugging debugging;
}

private:

struct Debugging
{
  enum void function(SourceLocation) abortHandler = (sourceLocation){
    while(true) {}
  };
}

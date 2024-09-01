/// Hooks the compiler generates code for.
module lime.core.internal.compiler_hooks;

import lime.config.config;
import lime.core.debugging;
import lime.core.source_location;

@safe:

// These are declared here so array appending and concatenating can be used at
// compile time. Ideally these should not have a body, but that won't work when
// using separate compilation, which the tests are using for non-native
// platforms.
ref Array _d_arrayappendcTX(Array : T[], T)(return ref scope Array self, uword length) pure nothrow @nogc @trusted
{
  while(true) {}
}

Return _d_arraycatnTX(Return, Array...)(auto ref Array arrays) pure nothrow @nogc @trusted
{
  while(true) {}
}

ref Array _d_arrayappendT(Array : T[], T)(return ref scope Array self, scope Array array) pure nothrow @nogc @trusted
{
  while(true) {}
}

bool __equals(T1, T2)(const scope T1[] lhs, const scope T2[] rhs) pure nothrow @nogc
{
  import lime.core.slice : isEqual;
  return lhs.isEqual(to: rhs);
}
//

private:

extern (C) noreturn _d_assert(string filename, uint lineNumber) @system
{
  config.core.debugging.assertHandler(SourceLocation(
    filename: filename,
    lineNumber: lineNumber
  ), null);
}

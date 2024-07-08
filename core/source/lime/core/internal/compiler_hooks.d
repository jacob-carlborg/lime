/// Hooks the compiler generates code for.
module lime.core.internal.compiler_hooks;

pure nothrow @safe @nogc:

// These are declared here so array appending and concatenating can be used at
// compile time.
ref Array _d_arrayappendcTX(Array : T[], T)(return ref scope Array self, uword length);
Return _d_arraycatnTX(Return, Array...)(auto ref Array arrays);
ref Array _d_arrayappendT(Array : T[], T)(return ref scope Array self, scope Array array);
//

bool __equals(T1, T2)(const scope T1[] lhs, const scope T2[] rhs)
{
  import lime.core.slice : isEqual;
  return lhs.isEqual(to: rhs);
}

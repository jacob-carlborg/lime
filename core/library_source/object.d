module object;

///
alias uword = typeof((void*).sizeof);
alias size_t = uword;

public import lime.core.slice : string;

public import lime.core.internal.compiler_hooks :
  _d_arrayappendcTX,
  _d_arrayappendT,
  _d_arraycatnTX,
  __equals;

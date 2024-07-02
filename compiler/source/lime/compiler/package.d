module lime.compiler;

version (LDC)
    public import lime.compiler.ldc;
else
    static assert(false, "No support for this compiler");

import lime.core.debugging;

void foo()
{
    bar();
}

void bar()
{
    breakpoint();
}

extern (C) void main()
{
    foo();
}

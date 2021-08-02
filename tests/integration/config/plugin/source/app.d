import lime.config.config;

extern (C) void main()
{
    assert(config.foo.bar == 4);
}

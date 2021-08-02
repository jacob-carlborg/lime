import lime.config.config;

extern (C) void main()
{
    static assert(config.bar.baz == 4);
}

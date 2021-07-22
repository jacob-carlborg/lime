import lime.config.config;

void main()
{
    static assert(config.bar.baz == 4);
}

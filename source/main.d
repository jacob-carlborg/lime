import std.stdio;

struct Core
{
    enum void delegate() assertHandler = null;
}

struct MyCore
{
    Core __core;
    alias __core this;

    enum assertHandler = {
        writeln("assertHandler");
    };
}

struct Config
{
    MyCore core;
}

Config config;

void myAssert()
{
    static if (config.core.assertHandler !is null)
        config.core.assertHandler();
    else
    {
        writeln("abort");
    }
}

void main()
{
    myAssert();
}

module lime.system.syscall;

enum Syscall : size_t
{
    exit = 1,
    write = 4
}

void syscall(Args...)(Syscall id, Args args)
{
    import ldc.llvmasm;
    import std.algorithm;
    import std.format;
    import std.array;
    import std.range;

    enum inputs = ["rax", "rdi", "rsi", "rdx", "rcx", "r8", "r9"];
    enum clobbers = ["rcx", "r11"];
    static assert(Args.length < inputs.length, "Too many arguments passed");


    enum constraints = {
        string[] argConstraints;
        string[] clobberConstraints;

        foreach (i; 0 .. Args.length + 1)
            argConstraints ~= "{" ~ inputs[i] ~ "}";

        foreach (clobber; clobbers)
            clobberConstraints ~= "~{" ~ clobber ~ "}";

        auto all = argConstraints ~ clobberConstraints;
        string result;

        foreach (i, r; all)
        {
            if (i != 0)
                result ~= ",";

            result ~=  r;
        }

        return result;
    }();

    __asm("syscall", constraints, id + 0x2000000, args);
}

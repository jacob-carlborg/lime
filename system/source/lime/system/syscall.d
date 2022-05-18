module lime.system.syscall;

enum Syscall : size_t
{
    exit = 1,
    write = 4
}

struct SyscallX86_64
{
    enum numberRegister = "rax";
    enum inputRegisters = ["rdi", "rsi", "rdx", "rcx", "r8", "r9"];
    enum clobbedRegisters = ["rcx", "r11"];
    enum instruction = "syscall";
    enum idModifier = 0;
}

struct SyscallX86_64Macos
{
    SyscallX86_64 base;
    alias base this;
    enum idModifier = 0x2000000;
}

struct SyscallArm64
{
    enum numberRegister = "w8";
    enum inputRegisters = ["x0", "x1", "x2", "x3", "x4", "x5"];
    enum clobbedRegisters = ["x0", "x1"];
    enum instruction = "svc #0";
    enum idModifier = 0;
}

struct SyscallArm64Macos
{
    SyscallArm64 base;
    alias base this;
    enum numberRegister = "w16";
}

void syscall(Args...)(Syscall id, Args args)
{
    version (X86_64)
        alias SyscallImpl = SyscallX86_64Macos;

    else version (AArch64)
        alias SyscallImpl = SyscallArm64Macos;

    syscall!(SyscallImpl)(id, args);
}

void syscall(SyscallImpl, Args...)(Syscall id, Args args)
{
    import ldc.llvmasm;

    alias impl = SyscallImpl;
    enum inputs = impl.numberRegister ~ impl.inputRegisters;

    static assert(Args.length < inputs.length, "Too many arguments passed");

    enum constraints = {
        string[] argConstraints;
        string[] clobberConstraints;

        foreach (i; 0 .. Args.length + 1)
            argConstraints ~= "{" ~ inputs[i] ~ "}";

        foreach (clobber; impl.clobbedRegisters)
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

    __asm(impl.instruction, constraints, id + impl.idModifier, args);
}

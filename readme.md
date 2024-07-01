# Lime - New standard library and runtime for D

## Goals/Guidelines

* Not relying on the C standard library
* Uses syscalls directly using assembly. Only use C syscall wrappers were
    required by the platform
* Try to support [αpε](https://justine.lol/ape.html). This requires runtime
    checks for platform specific code
* Do not use exceptions (requires too much runtime support)
* Implement the code for all main supported platforms at the same time
* Avoid using pointers, if possible
* Pointers should only point to single elements. For arrays, use D arrays.
    Syscalls that deal with pointers to multiple elements should be wrapped as
    soon as possible to convert the pointers to arrays.
* No use of `null` terminated strings
* All platform specific code should be limited to a single subpackage (see below)
* No functions without a body (except for C syscall wrappers)
* No official support for separate compilation
* No official support for DMD (unless it turns out to be easy)
* Support functions needed by the compiler/language should limited to a single
    subpackage

## Potential Platforms

| Operating System | x86-64 | x86 | ARM64 | ARM | PowerPC 64 | RISC-V 64 |
|------------------|--------|-----|-------|-----|------------|-----------|
| macOS            | ✓      |     | ✓     |     |            |           |
| iOS              |        |     | ✓     |     |            |           |
| Linux            | ✓      | ✓   | ✓     | ✓   | ✓          | ✓         |
| Windows          | ✓      | ✓   |       |     |            |           |
| FreeBSD          | ✓      |     | ✓     |     |            |           |
| OpenBSD          | ✓      |     | ✓     |     |            |           |
| NetBSD           | ✓      |     | ✓     |     |            |           |

These are the potentially supported platforms. It should be fairly easy to
setup CI for these. x86-64 and iOS ARM64 will be native. All other
architectures will be using emulation. Docker supports all of the above
architectures, therefore it should be easy to setup these running Linux. iOS
will be running Bitrise. All other platforms will be running GitHub Actions.
x86-64 will be running natively using GitHub Actions. Other architectures on
Linux will be running using Docker and its bundled QEMU support. FreeBSD and
OpenBSD will be running using the [Cross Platform
Action](https://github.com/cross-platform-actions/action).

## Dub Subpackages

```
lime
├── http
│   ├── tls
│   ├── net
│   │   ├── base
│   │   │   ├── crt (compiler runtime)
│   │   │   │   ├── platform
│   │   │   │   │   ├── system/sycall
│   │   │   │   │   │   ├── core
│   │   │   │   │   │   │   ├── config
```

### core

#### Contains

* `Result` type
* `Optional` type
* `assert` implementation

#### Guidelines

* No external dependencies
* No platform specific code
* No syscalls
* No inline assembly
* No functions without a body

### system

#### Contains

* Raw system call wrappers
* System call wrappers that:
    * Converts error codes to `Result`
    * Converts pointers to arrays

#### Guidelines

* One package per platform

### platform

#### Contains

* All platform specific code

#### Guidelines

* One package per platform

module lime.compiler.ldc;

pragma(LDC_intrinsic, "llvm.debugtrap")
typeof(*null) debugTrap();

pragma(LDC_intrinsic, "llvm.trap")
typeof(*null) trap();

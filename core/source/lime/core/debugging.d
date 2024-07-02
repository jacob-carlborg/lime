/// Module with various facilities that helps with debugging.
module lime.core.debugging;

import lime.compiler;

/**
 * Triggers an execution trap with the intention of requesting the attention of
 * a debugger.
 */
alias breakpoint = debugTrap;

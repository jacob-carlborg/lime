/// Module with various facilities that helps with debugging.
module lime.core.debugging;

import lime.config.config;
import lime.compiler;
import lime.core.source_location;

/**
 * Triggers an execution trap with the intention of requesting the attention of
 * a debugger.
 */
alias breakpoint = debugTrap;

/**
 * Aborts the execution of the program.
 *
 * Params:
 *  sourceLocation = the source location of where `abort` was called from
 */
void abort(SourceLocation sourceLocation = SourceLocation())
{
  config.core.debugging.abortHandler(sourceLocation);
}

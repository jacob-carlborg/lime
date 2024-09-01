module lime.core.source_location;

/// Represents a location in the source code.
immutable struct SourceLocation
{
  /// The filename of the source location.
  string filename;

  /// The line number of the source location.
  size_t lineNumber;

  /**
   * Creates a new source location.
   *
   * If the default arguments are used the source location will point to the
   * callsite.
   *
   * Params:
   *  filename = the filename of the source location
   *  lineNumber = the line number of the source location
   *
   * Returns: the source location
   */
  static SourceLocation opCall(string filename = __FILE__, size_t lineNumber = __LINE__) pure nothrow @nogc @safe
  {
    SourceLocation location = {
      filename: filename,
      lineNumber: lineNumber
    };

    return location;
  }
}

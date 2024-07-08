/// Operations that work on slices/built-in arrays.
module lime.core.slice;

import lime.core.attributes;

pure nothrow @safe @nogc:

///
alias string = immutable(char)[];

/**
 * Compares the given slices for equality.
 *
 * Returns: `true` if both slices are considered equal. `false` otherwise.
 */
@extension
bool isEqual(T1, T2)(const scope T1[] self, @named const scope T2[] to)
{
  alias other = to;

  if (self.length != other.length)
    return false;

  if (self.length == 0)
    return true;

  foreach (const i; 0 .. self.length)
  {
    if (self.valueAt(index: i) != other.valueAt(index: i))
      return false;
  }

  return true;
}

///
unittest
{
  assert([1, 2, 3].isEqual(to: [1, 2, 3]) == true);
  assert([1, 2, 3].isEqual(to: [4, 5, 6]) == false);
}

private:

@extension
T valueAt(T)(const scope T[] self, @named uword index) @trusted
in(index < self.length) => self.ptr[index];

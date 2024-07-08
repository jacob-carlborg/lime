/// Generic attributes.
module lime.core.attributes;

/**
 * Applied to functions indicating they act as extension methods.
 *
 * An extension method is a free function that should be called with the method
 * syntax (dot syntax), making them look like actual methods. That is, the first
 * argument to the function should be the receiver. The rest of the argument
 * should be passed as regular arguments.
 *
 * Examples:
 * ---
 * @extension bool isEqual(int[] self, int[] other);
 * [1, 2, 3].isEqual([1, 2, 3]);
 * ---
 */
enum extension;

/**
 * Applied to function and method parameters indicating they should be called
 * with named argument syntax.
 *
 * Examples:
 * ---
 * void copyFile(string source, @named string to);
 * copyFile("foo", to: "bar");
 * ---
 */
enum named;

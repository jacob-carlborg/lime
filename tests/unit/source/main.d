module main;

enum moduleData = import("imports.txt").split('\n');
enum imports = moduleData.map!(e => "import " ~ e ~ ";").join(";\n");

mixin(imports);

alias modules = AliasSeq!(mixin(moduleData.join(",\n")));

extern (C) int main(int argc, const char** argv)
{
  foreach (test; tests)
    test();

  return 0;
}

struct Test
{
  void function() implementation;

  this(void function() implementation)
  {
    this.implementation = implementation;
  }

  void opCall()
  {
    implementation();
  }
}

size_t unitTestCount()
{
  size_t count = 0;

  foreach (module_; modules)
  {
    foreach (unitTest ; __traits(getUnitTests, module_))
      count++;
  }

  return count;
}

Test[] tests()
{
  static Test[unitTestCount] tests;
  size_t count;

  static foreach (module_; modules)
  {
    foreach (unitTest ; __traits(getUnitTests, module_))
    {
      // avoid using __d_arraybounds_index to simplify bootstrapping
      tests.ptr[count++] = Test(&unitTest);
    }
  }

  return tests;
}

string[] split(string input, char delimiter)
{
  string[] result;
  size_t previousIndex = 0;

  foreach (i, c; input)
  {
    if (c == delimiter)
    {
      result ~= input[previousIndex .. i];
      previousIndex = i + 1;
    }
  }

  if (previousIndex != input.length)
    result ~= input[previousIndex .. input.length];

  return result;
}

string[] map(alias func)(string[] array)
{
  string[] result;

  foreach (e; array)
    result ~= func(e);

  return result;
}

string join(string[] input, string element)
{
  string result;

  foreach (i, component; input)
  {
    result ~= component;

    if (i < input.length - 1)
      result ~= element;
  }

  return result;
}

alias AliasSeq(T...) = T;

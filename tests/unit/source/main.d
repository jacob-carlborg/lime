module main;

enum importPaths = import("import_paths.txt").split('\n');
enum sourceFiles = import("source_files.txt").split('\n');
enum moduleData = extractModuleData(sourceFiles, importPaths);
enum imports = moduleData.map!(e => "import " ~ e ~ ";").join("\n");

mixin(imports);

mixin("alias modules = AliasSeq!(" ~ moduleData.join(",\n") ~ ");");

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

string[] extractModuleData(string[] sourceFiles, string[] importPaths)
{
  return sourceFiles.map!((file) {
    foreach (path; importPaths)
    {
      const withoutPrefix = file.removePrefix(path);

      if (withoutPrefix != file)
        return withoutPrefix;
    }

    return file;
  })
  .map!(file => file.removeSuffix(".d"))
  .map!(file => file.replace('/', '.'))
  .filter!(e => e != "object" && e != "main")
  .map!(e => e.removeSuffix(".package"));
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
  __gshared Test[unitTestCount] tests;
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

string[] filter(alias func)(string[] array)
{
  string[] result;

  foreach (e; array)
    if (func(e))
      result ~= e;

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

bool startsWith(string value, string prefix)
{
  return value.length >= prefix.length && value[0 .. prefix.length] == prefix;
}

bool endsWith(string value, string suffix)
{
  return value.length >= suffix.length && value[$ - suffix.length .. $] == suffix;
}

string removePrefix(string value, string prefix)
{
  return value.startsWith(prefix) ? value[prefix.length .. $] : value;
}

string removeSuffix(string value, string suffix)
{
  return value.endsWith(suffix) ? value[0 .. $ - suffix.length] : value;
}

string replace(string value, char existing, char replacement)
{
  string result;

  foreach (char c; value)
    result ~= c == existing ? replacement : c;

  return result;
}

alias AliasSeq(T...) = T;

module main;

enum importPaths = import("import_paths.txt").split('\n').map!toPosixPath;

pragma(msg, "importPaths:\n", importPaths, "\n");

enum sourceFiles = import("source_files.txt").split('\n').map!toPosixPath;

pragma(msg, "sourceFiles:\n", sourceFiles, "\n");

enum moduleData = extractModuleData(sourceFiles, importPaths);

pragma(msg, "moduleData:\n", moduleData, "\n");

enum imports = moduleData.map!(e => "import " ~ e ~ ";").join("\n");

pragma(msg, "imports:\n", imports, "\n");

mixin(imports);

mixin("alias modules = AliasSeq!(" ~ moduleData.join(",\n") ~ ");");

extern (C++) bool runTestFromCPP(Test test);

extern (C++) void runTestFromD(Test test)
{
  test();
}

extern (C) int main(int argc, const char** argv)
{
  auto tests = .tests;

  foreach (ref test; tests)
    test.pass = runTestFromCPP(test);

  int failedTestCount = 0;

  foreach (test; tests)
    if (!test.pass)
      failedTestCount++;

  return failedTestCount > 0 ? 1 : 0;
}

struct Test
{
  void function() implementation;
  bool pass;

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

string toPosixPath(string path)
{
  auto components = path.removeSuffix("\r").split(':');
  auto componentsWithoutRoot = components.length > 1 ? components[1 .. $] : components;
  return componentsWithoutRoot.join("").replace('\\', '/');
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

// These are declared here so array indexing and slicing can be used at compile
// time. Ideally these should not have a body, but that won't work when using
// separate compilation, which the tests are using for non-native platforms.
extern (C):

void _d_arraybounds_slice(string file, uint line, size_t lower, size_t upper, size_t length)
{
  while(true) {}
}

void _d_arraybounds_index(string file, uint line, size_t index, size_t length)
{
  while(true) {}
}

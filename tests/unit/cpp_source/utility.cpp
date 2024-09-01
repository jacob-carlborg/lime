#include <stdexcept>
#include <string>
#include <stdio.h>

using namespace std;

struct DString
{
  size_t length;
  const char* ptr;

  operator string() const
  {
    return to_s();
  }

  string to_s() const
  {
    return string(ptr, length);
  }
};

struct SourceLocation
{
  /// The filename of the source location.
  const DString filename;

  /// The line number of the source location.
  const size_t lineNumber;
};

struct Test
{
private:
  void* implementation;
  bool pass;
};

class AssertError : public exception
{
public:
  const string msg;
  const SourceLocation sourceLocation;

  explicit AssertError(DString message, SourceLocation sourceLocation)
    : msg(message), sourceLocation(sourceLocation) {}

  virtual ~AssertError() noexcept {}

  string message() const
  {
    return "AssertError - " +
      sourceLocation.filename.to_s() +
      ":" +
      to_string(sourceLocation.lineNumber) +
      ": " +
      msg;
  }
};

void runTestFromD(Test test);

bool runTestFromCPP(Test test)
{
  try
  {
    runTestFromD(test);
    return true;
  }

  catch (AssertError& error)
  {
    fprintf(stderr, "%s\n", error.message().c_str());
    fflush(stderr);

    return false;
  }
}

[[noreturn]] void throwException(DString message, SourceLocation sourceLocation)
{
  throw AssertError(message, sourceLocation);
}


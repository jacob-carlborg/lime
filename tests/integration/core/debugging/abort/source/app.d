import lime.core.debugging;

bool abortHandlerCalled = false;

extern (C) int main()
{
  abort();
  return abortHandlerCalled == true ? 0 : 1;
}

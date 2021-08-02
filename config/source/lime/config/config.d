/**
Global configuration system for the Lime library and the application.

The configuration module is built around a system of plugins and overrides.
This module does not provide any configuration properties on its own. Other
libraries and applications that have this Dub sub-package as a dependency
can add new configuration properties using plugins. Both compile-time and
runtime properties are supported. A global configuration type is provided
with fields, functions and any kind of language constructs that is provided
by D. A global value of this type is provided to give global access to the
configuration properties.

## Setting Configuration Properties

### Setting a Runtime Configuration Property

To set a runtime configuration property, access the field though the main
configuration object:

```
import lime.config.config;

void main()
{
    config.foo.bar = 3;
}
```

### Setting a Compile-Time Configuration Property

Given an existing compile-time configuration property:

```
module config.plugins.foo;

struct Foo
{
    enum bar = 3;
    enum asd = 5;
}
```

To set the above configuration property `bar`, an override needs to be added. To
add an override, create a file and directory structure as follows:

```
<plugin_package_name>
├── config
│   └── config
│       └── plugins
│           └── <plugin_package_name>.d
```

Where `<plugin_package_name>` is the package name of the plugin to override. In
this example, `foo`. Then mirror the contents in the plugin file and change the
value of any property. Only properties that will be changed nee to be added:

```
module config.overrides.<plugin_package_name>;

struct <plugin_name>
{
    enum <property_to_override> = 4;
}
```

Where `<plugin_package_name>` is the package name of the plugin,
`<plugin_name>` and `<property_to_override>` is property to be overridden. The
final file will look as:

```
module config.overrides.foo;

struct Foo
{
    enum bar = 4;
}
```

The overridden property can later be used as follows:

```
import lime.config.config;

void main()
{
    static if (config.foo.bar == 4)
    {
    }
}
```

## Adding Configuration Properties

To add a new configuration properties, a configuration plugin needs to be
added. A configuration plugin is tied to a single Dub package (or sub package).
Only one plugin per Dub package is supported. To add a new configuration plugin,
create a file and directory structure as follows:

```
<root_package_name>
├── config
│   └── config
│       └── plugins
│           └── <root_package_name>.d
```

Where `<root_package_name>` is the name of the root package in the Dub
package. Then add the following content to the D file:

```
module config.plugins.<root_package_name>;

struct <plugin_name>
{
    // <configuration_properties>...
}
```

Where `<plugin_name>` is the name of the plugin and
`<configuration_properties>` is the configuration properties, basically any
valid D language constructs, most commonly fields and manifest constants.
*/
module lime.config.config;

/**
The main configuration object.

All access to the configuration properties should go through this object.
*/
__gshared Config config;

private:

enum plugins = import("plugins").split('\n');
enum overrides = import("overrides").split('\n');

struct Config
{
    static foreach (plugin; plugins)
    {
        mixin("Alias!(__traits(getMember, Imports, pluginName(plugin))) ", pluginName(plugin), ';');
    }
}

struct Imports
{
    static foreach (plugin; plugins)
    {
        mixin(generateImports(plugin));

        mixin("struct ", pluginName(plugin), "\n{\n", generateFields(plugin),
            generateMultipleInheritance(plugin),
        "\n}");
    }
}

mixin template MultipleInheritance(bases...)
{
    template opDispatch(string name)
    {
        private static size_t memberIndex()
        {
            static foreach (i; 0 .. bases.length)
            {
                static if (__traits(hasMember, bases[i], name))
                    return i;
            }

            return bases.length;
        }

        static if (memberIndex != bases.length)
        {
            private static bool isField(T)()
            {
                static foreach (i; T.tupleof)
                {
                    static if (__traits(identifier, i) == name)
                        return true;
                }

                return false;
            }

            private enum isFunction(alias func) = is(typeof(func) == function);

            private enum isManifestConstant(alias symbol) =
              __traits(compiles, { enum e = symbol; }) &&
              !__traits(compiles, { const ptr = &symbol; });

            private enum isAlias(alias symbol) = __traits(compiles, { alias a = symbol; });
            private enum i = memberIndex;

            static if (isFunction!(__traits(getMember, bases[i], name)))
            {
                auto opDispatch(Args...)(Args args)
                {
                    return __traits(getMember, bases[i], name)(args);
                }
            }

            else static if (isField!(typeof(bases[i])))
            {
                auto opDispatch(Args...)(Args args)
                {
                    static if (Args.length == 1)
                        return __traits(getMember, bases[i], name) = args[0];
                    else
                        return __traits(getMember, bases[i], name);
                }
            }

            else static if (isManifestConstant!(__traits(getMember, bases[i], name)))
                enum opDispatch = __traits(getMember, bases[i], name);
            else static if (isAlias!(__traits(getMember, bases[i], name)))
                alias opDispatch = __traits(getMember, bases[i], name);
            else
                static assert(false, "Not implemented for this language construct");
        }
        else
            static assert(false, "The type " ~ typeof(this).stringof ~ " has no member: " ~ name);
    }
}

alias toIdentifier = (string value) => value.replace('.', '_');

alias pluginIdentifier = (string plugin) =>
    "config_plugins_" ~ plugin.toIdentifier;

alias overrideIdentifier = (string override_) =>
    "config_overrides_" ~ override_.toIdentifier;

alias generatePluginImport = (string plugin) =>
    "import " ~ pluginIdentifier(plugin) ~ " = " ~ "config.plugins." ~ plugin ~ ';';

alias generateImports = (string plugin)
{
    auto imports = generatePluginImport(plugin) ~ '\n';

    foreach (i, overrideLine; overrides)
    {
        immutable components = overrideLine.split(':');
        immutable overriddenPlugin = components[0];
        immutable override_ = components[1];

        if (overriddenPlugin != plugin)
            continue;

        imports ~= "import "
            ~ overrideIdentifier(override_)
            ~ " = "
            ~ "config.overrides."
            ~ override_
            ~ ";\n";
    }

    return imports;
};

alias generatePluginField = (string plugin) =>
     pluginIdentifier(plugin) ~ '.' ~ pluginName(plugin).camelize ~ " __original;";

alias generateFields = (string plugin)
{
    auto result = generatePluginField(plugin) ~ '\n';

    foreach (i, overrideLine; overrides)
    {
        immutable components = overrideLine.split(':');
        immutable overriddenPlugin = components[0];
        immutable override_ = components[1];

        if (overriddenPlugin != plugin)
            continue;

        result ~= overrideIdentifier(override_)
            ~ '.'
            ~ pluginName(overriddenPlugin).camelize
            ~ " __override"
            ~ i.toString
            ~ ";\n";
    }

    return result;
};

alias generateMultipleInheritance = (string plugin)
{
    string overrides;

    foreach (i, overrideLine; .overrides)
    {
        immutable overriddenPlugin = overrideLine.split(':')[0];

        if (overriddenPlugin != plugin)
            continue;

        overrides = "__override" ~ i.toString ~ ", " ~ overrides;
    }

    return "mixin MultipleInheritance!(" ~ overrides ~ "__original);";
};

alias Alias(alias symbol) = symbol;

alias pluginName = (string fullyQualifiedName) =>
    split(fullyQualifiedName, '.')[$ - 1];

alias split = (string value, char delimiter)
{
    if (value.length == 0)
        return null;

    string[] result;
    size_t start;

    foreach (i, char c; value)
    {
        if (c == delimiter)
        {
            result ~= value[start .. i];
            start = i + 1;
        }

        else if (i == value.length - 1)
        {
            result ~= value[start .. $];
            return result;
        }
    }

    return result;
};

alias replace = (string value, char pattern, char replacement)
{
    string result;

    foreach (char e; value)
        result ~= e == pattern ? replacement : e;

    return result;
};

alias toString = (size_t value)
{
    string result;
    enum base = 10;
    size_t i;

    if (value == 0)
        return "0";

    while (value != 0)
    {
        int rem = value % base;
        immutable c = cast(char) (rem > 9 ? rem - 10 + 'a' : rem + '0');
        result = c ~ result;
        value = value / base;
    }

    return result;
};

char toUppercase(char value) => cast(char) (value - 32);
char toLowercase(char value) => cast(char) (value + 32);

bool isUppercase(char value) => value >= 65 && value <= 90;
bool isLowercase(char value) => value >= 97 && value <= 122;

alias camelize = (string value)
{
    string result;
    bool nextUppercase = false;

    foreach (i, char c; value)
    {
        if (i == 0)
        {
            result ~= c.isLowercase ? c.toUppercase : c;
            continue;
        }

        if (c == '_')
        {
            nextUppercase = true;
            continue;
        }

        if (nextUppercase)
        {
            nextUppercase = false;
            result ~= c.isUppercase ? c : c.toUppercase;
        }
        else
            result ~= c.isLowercase ? c : c.toLowercase;
    }

    return result;
};

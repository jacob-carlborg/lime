/+
dub.sdl:
    name "setup_plugins_overrides"
+/
import std;

void main()
{
    const rootPackageDir = environment["DUB_ROOT_PACKAGE_DIR"];
    const dubExe = environment["DUB_EXE"];
    const result = execute([dubExe, "describe"], null, Config.none, size_t.max,
        rootPackageDir);
    enforce(result.status == 0);

    auto json = parseJSON(result.output);
    const rootName = json["rootPackage"].str;
    auto dubPackages = json["packages"].array;
    const rootPath = dubPackages
        .filter!(e => e["name"].str == rootName)
        .front["path"]
        .str;

    auto plugins = locatePlugins(dubPackages);
    auto overrides = locateOverrides(dubPackages);
    auto flags = generateFlags(dubPackages);

    enum outputDir = "temp";
    mkdirRecurse(outputDir);

    writeFile(outputDir.buildPath("plugins"), plugins);
    writeFile(outputDir.buildPath("overrides"), overrides);
    writeFile(outputDir.buildPath("flags"), flags);
}

private:

auto locatePlugins(JSONValue[] dubPackages)
{
    static auto moduleNames(string path)
    {
        return path
            .dirEntries("{*.d,di}", SpanMode.depth)
            .map!(e => e[path.length + 1 .. $])
            .map!stripExtension
            .map!(e => e.replace("/", "."));
    }

    return dubPackages
        .map!(e => e["path"].str)
        .map!(e => e.buildPath("config", "config", "plugins"))
        .filter!exists
        .map!moduleNames
        .joiner;
}

auto locateOverrides(JSONValue[] dubPackages)
{
    alias DubPackage = tuple!("name", "path");
    alias buildOverridePath = pack =>
        pack.path.buildPath("config", "config", "overrides", pack.name);

    static auto pluginAndModuleNames(string name, string path)
    {
        return path
            .dirEntries("{*.d,di}", SpanMode.depth)
            .map!stripExtension
            .map!(e => e.replace("/", "."))
            .map!(e => e[path.length - name.length .. $])
            .map!(e => e[name.length + 1 .. $] ~ ":" ~ e);
    }

    return dubPackages
        .map!(e => DubPackage(e["name"].str, e["path"].str))
        .map!(e => DubPackage(e.name, buildOverridePath(e)))
        .filter!(e => e.path.exists)
        .map!(e => pluginAndModuleNames(e.expand))
        .joiner;
}

auto generateFlags(JSONValue[] dubPackages)
{
    static bool pathsExist(string basePath, string directory)
    {
        return basePath.buildPath("config", directory).exists;
    }

    return dubPackages
        .map!(e => e["path"].str)
        .map!(e => e.buildPath("config"))
        .filter!(e => pathsExist(e, "plugins") || pathsExist(e, "overrides"))
        .map!(e => "-I" ~ e);
}

void writeFile(Range)(string name, Range data)
{
    std.file.write(name, data.join("\n"));
}

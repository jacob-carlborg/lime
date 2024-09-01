/+
dub.sdl:
    name "generate_test_scripts"
+/
import std;

void main()
{
    dirEntries("tests", "test.sh", SpanMode.breadth)
        .each!generateTestScript;
}

private:

immutable struct Commands
{
    string compile;
    string link;
    string run;
}

void generateTestScript(string path)
{
    immutable defaultFlags = [
        "-c",
        "-debug",
        "-g",
        "-fPIC",
        "-vcolumns",
        "--mtriple",
        target
    ];

    immutable workDirectory = path.dirName;
    immutable targetPath = .targetPath(workDirectory);
    immutable targetName = .targetName(workDirectory);
    immutable fullTargetPath = targetPath ~ targetName;
    immutable flags = .flags(workDirectory);
    immutable limeConfigPath = .limeConfigPath(workDirectory);
    immutable objectTargetPath = fullTargetPath.setExtension(objectFileExtension);
    immutable linkerFlags = getDubDataList("lflags", workDirectory).front;
    immutable libFlags = .libFlags(workDirectory);

    immutable compileCommand = join(
        `"$DMD"` ~
        defaultFlags ~
        extraFlags ~
        ("-of" ~ objectTargetPath) ~
        flags,
        " \\\n    "
    );

    immutable linkCommand = [
        "cc",
        objectTargetPath,
        "-o",
        fullTargetPath,
        linkerFlags,
        libFlags
    ]
    .filter!(e => e.length > 0)
    .join(" \\\n  ");

    Commands commands = {
        compile: compileCommand,
        link: linkCommand,
        run: fullTargetPath
    };

    immutable content = testScript(commands, limeConfigPath);
    immutable scriptPath = workDirectory.buildPath("test_runner.sh");

    std.file.write(scriptPath, content);
    scriptPath.setAttributes(scriptPath.getAttributes | octal!100);

    saveLimeConfigTemporaryFiles(limeConfigPath, workDirectory);
}

string testScript(Commands commands, string limeConfigPath)
{
    enum contentTemplate = q"BASH
#!/usr/bin/env bash

set -eu
set -o pipefail

has_argument() {
  local term="$1"
  shift
  for arg; do
    if [ $arg == "$term" ]; then
      return 0
    fi
  done

  return 1
}

compile() {
  cp temp/* '%stemp'
  %s
}

link() {
  %s
}

run() {
  %s
}

if has_argument "compile" "$@"; then
  compile
elif has_argument "link" "$@"; then
  link
elif has_argument "run" "$@"; then
  run
else
  compile
  link
  run
fi
BASH";

    with (commands)
        return format!contentTemplate(limeConfigPath, compile, link, run);
}

string flags(string workDirectory)
{
    enum dataArgs = [
        "dflags",
        "versions",
        "import-paths",
        "string-import-paths",
        "source-files",
        "options"
    ];

    return getDubData(dataArgs, workDirectory);
}

string[] extraFlags()
{
    switch (architecture)
    {
        case "mips64el": return ["--mabi=n64"];

        case "riscv64":
            return [
                "--target-abi",
                "lp64d",
                "--mattr=+m,+a,+f,+d,+c,+relax,-save-restore"
            ];

        default: return [];
    }
}

string targetPath(string workDirectory) =>
    getDubDataList("target-path", workDirectory).front;

string targetName(string workDirectory) =>
    getDubDataList("target-name", workDirectory).front;

string libFlags(string workDirectory) =>
    getDubDataList("libs", workDirectory)
        .filter!(e => e.length > 0)
        .map!(e => "-l" ~ e)
        .join(" ");

string limeConfigPath(string workDirectory)
{
    immutable output = execute(["dub", "describe", "--verror"], workDirectory);
    immutable json = parseJSON(output);

    immutable limeConfigPackage = json["packages"]
        .array
        .find!(p => p["name"].str == "lime:config");

    return limeConfigPackage.empty ? "" : limeConfigPackage.front["path"].str;
}

void saveLimeConfigTemporaryFiles(string limeConfigPath, string workDirectory)
{
    alias Copy = tuple!("source", "target");

    if (limeConfigPath.empty)
        return;

    immutable targetDirectory = workDirectory.buildPath("temp");
    mkdirRecurse(targetDirectory);

    limeConfigPath
        .buildPath("temp")
        .dirEntries("*", SpanMode.breadth)
        .map!(e => Copy(e.name, targetDirectory.buildPath(e.baseName)))
        .each!(c => std.file.copy(c.expand));
}

string[] getDubDataList(string dataValue, string workDirectory)
{
    immutable args = [
        "dub",
        "describe",
        "--verror",
        "--data",
        dataValue,
        "--data-list"
    ];

    return execute(args, workDirectory).splitLines;
}

string getDubData(const string[] dataValues, string workDirectory)
{
    const dataArgs = dataValues.map!(e => ["--data", e]).joiner.array;
    return execute(["dub", "describe", "--verror"] ~ dataArgs, workDirectory);
}

string execute(const string[] args, string workDirectory)
{
    immutable result = std.process.execute(args, null, Config.none, size_t.max,
        workDirectory);

    enforce(result.status == 0);

    return result.output;
}

string target()
{
    immutable operating_system = environment["LIME_OS"];
    immutable version_ = operating_system == "freebsd" ?
        environment["LIME_OS_VERSION"] : "";

    return  environment["LIME_ARCH"] ~ '-' ~ environment["LIME_OS"] ~ version_;
}

string objectFileExtension() =>
    environment["LIME_OS"] == "windows" ? "obj" : "o";

string architecture() => environment["LIME_ARCH"];

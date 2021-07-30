import std;

void main()
{
    dirEntries("tests", "test.sh", SpanMode.breadth)
        .each!generateTestScript;
}

private:

void generateTestScript(string path)
{
    enum defaultFlags = [
        "-debug",
        "-g",
        "-w",
        "-vcolumns"
    ];

    immutable workDirectory = path.dirName;
    immutable targetPath = .targetPath(workDirectory);
    immutable targetName = .targetName(workDirectory);
    immutable fullTargetPath = targetPath ~ targetName;
    immutable flags = .flags(workDirectory);
    immutable limeConfigPath = .limeConfigPath(workDirectory);

    immutable compileCommand = join(
        `"$DC"` ~
        defaultFlags ~
        ("-of" ~ fullTargetPath) ~
        flags,
        " \\\n"
    );

    immutable content = testScript(compileCommand, fullTargetPath, limeConfigPath);
    immutable scriptPath = workDirectory.buildPath("test_runner.sh");

    std.file.write(scriptPath, content);
    scriptPath.setAttributes(scriptPath.getAttributes | octal!100);

    saveLimeConfigTemporaryFiles(limeConfigPath, workDirectory);
}

string testScript(string compileCommand, string runCommand, string limeConfigPath)
{
    enum contentTemplate = q"BASH
#!/bin/bash

set -eu
set -o pipefail

cp temp/* '%s/temp'

%s
%s
BASH";

    return format!contentTemplate(limeConfigPath, compileCommand, runCommand);
}

string flags(string workDirectory)
{
    enum dataArgs = [
        "dflags",
        "versions",
        "import-paths",
        "string-import-paths",
        "source-files"
    ];

    return getDubData(dataArgs, workDirectory);
}

string targetPath(string workDirectory) =>
    getDubDataList("target-path", workDirectory);

string targetName(string workDirectory) =>
    getDubDataList("target-name", workDirectory);

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

string getDubDataList(string dataValue, string workDirectory)
{
    immutable args = [
        "dub",
        "describe",
        "--verror",
        "--data",
        dataValue,
        "--data-list"
    ];

    return execute(args, workDirectory).splitLines.front;
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

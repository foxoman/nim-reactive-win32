import reactivepkg/utils
import std/os
import std/osproc
import std/strutils
import std/json

# Run a nim command
proc run(app: string, args: varargs[string]) =

    # Log it
    echo "Running command: " & app & " " & args.quoteShellCommand()

    # Run it
    let process = startProcess(app, options={poUsePath, poParentStreams}, args=args)
    let returnCode = process.waitForExit()
    if returnCode != 0:
        raiseAssert("Nim command failed.")


# Fetch build args
let buildInfo = getReactiveBuildOptions()

# Create temporary manifest file
writeFile("/tmp/app.manifest", """
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0" xmlns:asmv3="urn:schemas-microsoft-com:asm.v3">

    <!-- DPI awareness setting (per monitor v2) ... https://docs.microsoft.com/en-us/windows/win32/hidpi/high-dpi-desktop-application-development-on-windows -->
    <asmv3:application>
        <asmv3:windowsSettings>
            <dpiAware xmlns="http://schemas.microsoft.com/SMI/2005/WindowsSettings">true</dpiAware>
            <dpiAwareness xmlns="http://schemas.microsoft.com/SMI/2016/WindowsSettings">PerMonitorV2</dpiAwareness>
        </asmv3:windowsSettings>
    </asmv3:application>

    <!-- WinXP+ control styles -->
    <trustInfo xmlns="urn:schemas-microsoft-com:asm.v2">
        <security>
            <requestedPrivileges>
                <requestedExecutionLevel level="asInvoker" uiAccess="false"/>
            </requestedPrivileges>
        </security>
    </trustInfo>
    <dependency>
        <dependentAssembly>
            <assemblyIdentity type="Win32" name="Microsoft.Windows.Common-Controls" version="6.0.0.0" processorArchitecture="*" publicKeyToken="6595b64144ccf1df" language="*"/>
        </dependentAssembly>
    </dependency>

</assembly>
""".strip())

# Create temporary resource file
writeFile("/tmp/app.rc", """
#include <windows.h>
CREATEPROCESS_MANIFEST_RESOURCE_ID RT_MANIFEST "/tmp/app.manifest"
""".strip())

# Compile the resource file
run "x86_64-w64-mingw32-windres", 
    "/tmp/app.rc",              # Input file
    "-O", "coff",               # Output COFF format - thanks https://stackoverflow.com/a/67040061/1008736
    "-o", "/tmp/app.res"        # output file

# Begin building
run "nim",
    "compile",
    "--cpu:amd64",              # <-- Building a 64-bit EXE
    "--os:windows",
    "--app:gui",
    "--define:mingw",
    "--passL:/tmp/app.res",     # <-- Include our compiled resource file
    "--define:noRes",           # <-- Tells the winim lib not to link a resource file, we've got our own one
    "--define:release",         
    "--define:ReactivePlatformWin32",
    "--define:ReactiveInjectImports:reactive_platform_win32",
    "--threads:on",             # <-- We want threading support
    "--gcc.exe:x86_64-w64-mingw32-gcc", "--gcc.linkerexe:x86_64-w64-mingw32-gcc",   # <-- TODO: Why is this necessary? Copied from https://github.com/yatesco/docker-nim-dev-example/pull/1/files#diff-61a09a47db316e59273fb31e4dad8d4c28ca3682969a1180579d1b3dc4f3f48bR22
    "--out:" & absolutePath(buildInfo["projectRoot"].getStr() / "dist" / "win32" / "app-x64.exe"),
    buildInfo["entrypoint"].getStr()
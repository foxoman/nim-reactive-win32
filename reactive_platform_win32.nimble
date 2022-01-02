# Package

version                                 = "0.1.7"
author                                  = "jjv360"
description                             = "Plugin for Reactive which provides deployment to Windows using the Win32 API."
license                                 = "MIT"
srcDir                                  = "src"
installExt                              = @["nim", "res", "manifest"]
namedBin["reactive_platform_win32/cli"]   = "reactive_platform_win32"


# Dependencies

requires "nim >= 1.6.2"
requires "winim >= 3.8.0"
requires "classes >= 0.2.12"
requires "https://github.com/jjv360/nim-reactive >= 0.1.7"
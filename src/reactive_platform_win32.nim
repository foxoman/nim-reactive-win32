##
## Entry point fo rthe web platform plugin

import classes
import reactivepkg/plugins
import reactivepkg/components
import reactivepkg/config
import reactivepkg/componentTree
when defined(ReactivePlatformWin32):
    import std/threadpool
    import std/os
    import std/sequtils
    import winim except GROUP, COMPONENT, BUTTON

    # Export our classes
    import reactive_platform_win32/base
    import reactive_platform_win32/alerts
    import reactive_platform_win32/components/button
    import reactive_platform_win32/components/label
    import reactive_platform_win32/components/view
    import reactive_platform_win32/components/window
    import reactive_platform_win32/layouts/absolute
    export base, alerts, button, label, view, window, absolute
    


    ## Process Windows event loop
    proc runWindowsEventLoop() =

        # TODO: Check that we have at least one active window at this point. Otherwise the app will become a zombie process,
        # just sitting in the task manager doing nothing. At least show a warning or something if that happens.

        # Process windows messages
        var msg: MSG
        while GetMessage(msg, 0, 0, 0) != 0:
            TranslateMessage(msg)
            DispatchMessage(msg)

        # Windows thread has quit
        echo "[Win32 Platform] Message thread has quit."


    ## Prepare the app to be started
    proc prepareReactiveAppPlatform*() =

        # If the user wants a console, create one
        if commandLineParams().filterIt(it == "--showconsole").len() > 0:

            # Create a console window
            if AllocConsole() == 0: 

                # Failed to create a console window!
                alert("The --showconsole flag was passed, but we were unable to create a console window for you. Continuing without one...", title="Unable to show console", icon=warning)

            else:

                # Created a console window, attach stderr and stdout to it
                discard stdin.reopen("CONIN$", fmRead)
                discard stdout.reopen("CONOUT$", fmWrite)
                discard stderr.reopen("CONOUT$", fmWrite)


    ## Start the app
    proc startReactiveAppPlatform*() =

        # Get main component
        let componentID = ReactiveConfig.shared.get("win32", "mainWindow")
        
        # Render the specified component tree
        let componentTree = ComponentTree.withRegisteredComponent(componentID)

        # Start the event loop
        runWindowsEventLoop()

        # TODO: Run asyncdispatch event loop as well

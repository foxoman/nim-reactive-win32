import classes
import reactivepkg/components
import ../base
import winim except GROUP, COMPONENT


## Window component
component Window:

    ## Create window handle
    method createWindowHandle(): HWND = CreateWindowEx(
        0,                              # Extra window styles
        registerWindowClass(),          # Class name
        "App",                          # Window title
        WS_OVERLAPPEDWINDOW or WS_VISIBLE,            # Window style

        # Size and position, x, y, width, height
        CW_USEDEFAULT, CW_USEDEFAULT, 
        CW_USEDEFAULT, CW_USEDEFAULT,

        0,                              # Parent window    
        0,                              # Menu
        0,                              # Instance handle
        cast[pointer](this)             # Additional application data is a pointer to our class instance ... used by wndProcProxy
    )

    ## Return true if this component uses our wndProc
    method componentUsesWndProc(): bool = true


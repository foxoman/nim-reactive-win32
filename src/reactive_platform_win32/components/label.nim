import classes
import ../base
import reactivepkg/components
import winim except GROUP, COMPONENT

    
## Label, displays some text
component Label:

    # Text
    var text = ""

    # Style properties
    var textColor = ""


    ## Create window handle
    method createWindowHandle(): HWND = CreateWindowEx(
        0,                              # Extra window styles
        L"STATIC",                      # Class name ... system defined class
        L(this.text),                   # Label title
        WS_VISIBLE or WS_CHILD or SS_LEFT, # Window style

        # Size and position, x, y, width, height
        10, 10, 100, 100,

        this.parentHWND(),              # Parent window    
        0,                              # Menu
        0,                              # Instance handle
        cast[pointer](this)             # Additional application data is a pointer to our class instance ... used by wndProcProxy
    )

    # Called when the component is updated
    method onPlatformUpdate() =

        # Set it
        SetWindowText(this.hwnd, this.text)


    ## Called when new properties are incoming
    method updateProperties(newProps: BaseComponent) = 
        super.updateProperties(newProps)

        # Copy generic props
        this.text = newProps.Label().text
        this.textColor = newProps.Label().textColor
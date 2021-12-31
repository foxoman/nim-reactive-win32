import classes
import ../base
import reactivepkg/components
import winim except GROUP, COMPONENT, BUTTON


## Button component
component Button:

    # Button title
    var title = "Button"

    # Event: On click
    var onClick: proc() = nil

    ## Create window handle
    method createWindowHandle(): HWND = CreateWindowEx(
        0,                              # Extra window styles
        L"BUTTON",                      # Class name ... system defined class
        L(this.title),                  # Button title
        WS_TABSTOP or WS_VISIBLE or WS_CHILD or BS_DEFPUSHBUTTON,   # Window style

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
        SetWindowText(this.hwnd, this.title)


    ## Internal WndProc callback used by Windows
    method controlWndProc(hwnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT =

        # Check message type
        let notificationCode = HIWORD(wParam)
        case notificationCode
        of BN_CLICKED:

            # Call action
            if this.onClick != nil:
                this.onClick()

            # Done
            return 0

        else:

            # Something else, just perform default action
            return super.controlWndProc(hwnd, uMsg, wParam, lParam)


    ## Called when new properties are incoming
    method updateProperties(newProps: BaseComponent) = 
        super.updateProperties(newProps)

        # Copy generic props
        this.title = newProps.Button().title
        this.onClick = newProps.Button().onClick
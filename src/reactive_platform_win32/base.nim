import classes
import sequtils
import tables
import reactivepkg/components
import reactivepkg/componentTree
import winim except COMPONENT, GROUP, BUTTON

## List of all active windows
var activeHWNDs: Table[HWND, BaseComponent]

## Proxy function for stdcall to class function
proc wndProcProxy*(hwnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.}

## Register the Win32 "class" that we will use for all components
proc registerWindowClass*(): string =

    # If done already, stop
    var hasDone {.global.} = false
    if hasDone:
        return "NimReactiveClass"

    # Do it
    var wc: WNDCLASS
    wc.lpfnWndProc = wndProcProxy
    wc.hInstance = 0
    wc.lpszClassName = "NimReactiveClass"
    RegisterClass(wc)

    # Done
    hasDone = true
    return "NimReactiveClass"


## Base class for web layouts
class Win32Layout of BaseLayout:

    ## Perform the layout
    method update(component: BaseComponent) = discard
    

## Base class for all Win32 components
class Component of BaseComponent:

    ## Window handle
    var hwnd: HWND = 0

    ## System window size
    var windowX = 0.0
    var windowY = 0.0
    var windowWidth = 100.0
    var windowHeight = 100.0

    ## Create the window handle for this component
    method createWindowHandle(): HWND = 0

    ## Return true if this component uses our wndProc
    method componentUsesWndProc(): bool = false

    ## Get parent HWND
    method parentHWND(): HWND =

        # Go through heirarchy
        var item = this.parent
        while item != nil:

            # Check if this one has a HWND
            if item of Component and Component(item).hwnd != 0:
                return Component(item).hwnd

            # Nope, continue up the chain
            item = item.parent
            
        # Not found
        raiseAssert("No parent window handle found.")


    ## Called when the component is created
    method onPlatformCreate() = 

        # Create window
        this.hwnd = this.createWindowHandle()
        
        # Stop if this is a light component with no window handle
        if this.hwnd == 0:
            return

        # Add this component to the active list. This also prevents the window from being removed from memory while it's active.
        activeHWNDs[this.hwnd] = this


    ## Internal WndProc callback used by Windows
    method wndProc(hwnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT =

        # Check message type
        case uMsg
        of WM_PAINT:
            
            # Paint the background color onto the window
            var ps: PAINTSTRUCT
            var hdc = BeginPaint(hwnd, ps)
            FillRect(hdc, ps.rcPaint, COLOR_WINDOW+1)
            EndPaint(hwnd, ps)

            # Done
            return 0

        of WM_DESTROY:

            # Remove this window from the active window list, it has been destroyed by the system
            activeHWNDs.del(this.hwnd)

            # If this was the last active window that receives window events, shut down the app
            var hasActiveWindow = false
            for hwnd, component in activeHWNDs:
                if component.Component().componentUsesWndProc():
                    hasActiveWindow = true
                    break
            if not hasActiveWindow:
                PostQuitMessage(0)

        of WM_SIZE:
            
            # Window size changed
            this.windowWidth = LOWORD(lParam).float()
            this.windowHeight = HIWORD(lParam).float()

            # Notify updated
            this.updateUi()

        of WM_COMMAND:

            # Special command used for common controls ... the message is actually for a component control, not for this window component. Find the control's component
            let componentHwnd = lParam.HWND()
            let component = activeHWNDs.getOrDefault(componentHwnd, nil).Component()
            if component == nil:
                return

            # Found it, pass it on
            return component.controlWndProc(hwnd, uMsg, wParam, lParam)

        else:

            # Unknown message, let the system handle it in the default way
            return DefWindowProc(hwnd, uMsg, wParam, lParam)


    ## Internal control-specific WndProc callback
    method controlWndProc(hwnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT =
    
        # By default just do the default action
        return DefWindowProc(hwnd, uMsg, wParam, lParam)


    ## Called when the layout changes
    method onPlatformLayout() =

        # Call layout if it exists
        if this.layout != nil and this.layout of Win32Layout:
            Win32Layout(this.layout).update(this)


    ## Overridden by the app, this controls child components to render. By default just renders all children.
    method render(): BaseComponent =

        let g = Group.init()
        g.children = this.children
        return g

    ## Update UI
    method updateUi() = ComponentTreeNode(this.componentTreeNode).synchronize()



## Proxy function for stdcall to class function, implementation
proc wndProcProxy(hwnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =

    # Find class instance
    let component = activeHWNDs.getOrDefault(hwnd, nil).Component()
    if component == nil:

        # No component associated with this HWND, we don't know where to route this message... Maybe it's a thread message or something? 
        # Let's just perform the default action.
        return DefWindowProc(hwnd, uMsg, wParam, lParam)

    # Pass on
    component.wndProc(hwnd, uMsg, wParam, lParam)
import classes
import reactivepkg/components
import ../base
import winim except COMPONENT, GROUP
import strutils

## Get parent HWND
proc parentWithHWND(comp: BaseComponent): Component =

    # Go through heirarchy
    var item = comp.parent
    while item != nil:

        # Check if this one has a HWND
        if item of Component and Component(item).hwnd != 0:
            return Component(item)

        # Nope, continue up the chain
        item = item.parent
        
    # Not found
    raiseAssert("No parent window handle found.")

##
## Absolute layout. This layout system simply moves the object to an absolute position within it's parent.
class AbsoluteLayout of Win32Layout:

    ## Coordinates. Examples are: "32px", "50%".
    var x = ""
    var y = ""
    var width = ""
    var height = ""

    ## Fetch pixel value of an input
    method pixelValue(input: string, parentValue: float): int32 =

        # Check prefix
        if input.startsWith("calc("):

            # Not supported yet
            raiseAssert("calc() values for absolute layout are not supported yet.")

        elif input.endsWith("px"):

            # Already in pixels, just parse it
            return parseFloat(input.substr(0, input.high()-2)).int32()

        elif input.endsWith("%"):

            # In percents
            return (parseFloat(input.substr(0, input.high()-1)) / 100 * parentValue).int32()

        else:

            # Unknown format
            raiseAssert("Unknown format string for absolute position: " & input)


    ## Perform the layout
    method update(component: BaseComponent) =
        
        # Get HWND
        let hwnd = Component(component).hwnd
        if hwnd == 0:
            return

        # Get parent window
        let parent = component.parentWithHWND()
        if parent == nil:
            return

        # Get parent window's layout information
        var rect: RECT
        if GetClientRect(parent.hwnd, rect) == 0: return
        let parentWidth = (rect.right - rect.left).float()
        let parentHeight = (rect.bottom - rect.top).float()

        # Get absolute pixel values for input
        let x = this.pixelValue(this.x, parentWidth)
        let y = this.pixelValue(this.y, parentHeight)
        let width = this.pixelValue(this.width, parentWidth)
        let height = this.pixelValue(this.height, parentHeight)

        # Set layout
        SetWindowPos(hwnd, 0, x, y, width, height, SWP_NOZORDER)
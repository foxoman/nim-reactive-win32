import winim except GROUP, COMPONENT

# System alert dialog icons
type AlertIconType* = enum information, warning, question

# System alert dialog ... on web, only the text field is supported
proc alert*(text: string, title: string = "", icon: AlertIconType = information) =
    
    # Call MessageBox function
    MessageBox(0, T(text), T(title), case icon
        of information: MB_ICONINFORMATION
        of warning: MB_ICONWARNING
        of question: MB_ICONQUESTION
    )
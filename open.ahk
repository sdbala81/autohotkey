#Requires AutoHotkey v2.0
#SingleInstance Force

#o:: {
    target := AskOpenTarget()
    if (target = "")
        return

    openInChrome := false

    if (target ~= "i)^loop$")
        target := "https://loop.cloud.microsoft/"

    if (target ~= "i)^pw$") {
        target := "https://docs.google.com/document/d/1BLvtrMcRMd03_lFJB-kxsv6x0DRKXBBvrfPzLoVwU_Y/edit?tab=t.0"
        openInChrome := true
    }

    try {
        if (openInChrome)
            Run('chrome.exe "' target '"')
        else
            Run(target)
    } catch as err {
        MsgBox("Could not open: " target "`n`n" err.Message, "Open", "OK Iconx")
    }
}

AskOpenTarget() {
    submitted := false
    target := ""

    dlg := Gui("+AlwaysOnTop -Resize -MinimizeBox -MaximizeBox", "Open")
    dlg.MarginX := 12
    dlg.MarginY := 12

    input := dlg.AddEdit("w300")
    okBtn := dlg.AddButton("xm y+12 w96 h28 Default", "OK")
    cancelBtn := dlg.AddButton("x+8 w96 h28", "Cancel")

    okBtn.OnEvent("Click", OnSubmit)
    cancelBtn.OnEvent("Click", OnCancel)
    dlg.OnEvent("Close", OnCancel)
    dlg.OnEvent("Escape", OnCancel)

    hwnd := dlg.Hwnd
    dlg.Show("AutoSize Center")
    input.Focus()
    WinWaitClose("ahk_id " hwnd)

    return submitted ? target : ""

    OnSubmit(*) {
        target := Trim(input.Value)
        submitted := (target != "")
        dlg.Destroy()
    }

    OnCancel(*) {
        submitted := false
        dlg.Destroy()
    }
}

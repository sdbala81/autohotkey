#Requires AutoHotkey v2.0
#SingleInstance Force

; Ensure the script has Admin privileges to move elevated windows
if !A_IsAdmin {
    Run('*RunAs "' A_ScriptFullPath '"')
    ExitApp()
}

; --- Configuration ---
VDExe := A_ScriptDir "\VirtualDesktop.exe"

; --- Helper Function ---
RunVD(Params, *) {
    if !FileExist(VDExe) {
        MsgBox("VirtualDesktop.exe not found at: " . VDExe)
        return
    }
    try {
        Run(VDExe . " " . Params, , "Hide")
    } catch Error as e {
        MsgBox("Error: " . e.Message)
    }
}

; --- Hotkey Loops ---
loop 10 {
    ; We map 1-9 directly. 0 usually represents Desktop 10.
    ; Windows Desktop 1 = Internal Index 0
    InternalIndex := A_Index - 1
    NumKey := (A_Index == 10) ? 0 : A_Index

    ; Define primary Numpad keys (NumLock ON)
    BindKeys("Numpad" . NumKey, InternalIndex)
}

BindKeys(KeyName, idx) {
    ; 1. Alt + Keypad: Move App and STAY on current desktop
    ; First get desktop number into pipeline, then move active window there
    Hotkey("!" . KeyName, RunVD.Bind("/GetDesktop:" . idx . " /MoveActiveWindow"))

    ; 2. Ctrl + Keypad: Switch to Desktop
    Hotkey("^" . KeyName, RunVD.Bind("/Switch:" . idx))

    ; 3. Win + Keypad: Move App and FOLLOW (switch to that desktop)
    ; Get desktop into pipeline, move window, then switch
    Hotkey("#" . KeyName, RunVD.Bind("/GetDesktop:" . idx . " /MoveActiveWindow /Switch"))
}

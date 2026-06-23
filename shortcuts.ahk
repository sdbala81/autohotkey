; -------------------------------------------------------------------------
; GNOME to Windows Shortcut Migration
; -------------------------------------------------------------------------
; # = Windows Key (Super)  |  ! = Alt  |  + = Shift  |  ^ = Control
; -------------------------------------------------------------------------

#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir A_InitialWorkingDir

; --- Learning & Web (<Alt><Shift>) ---

!+1:: Run "msedge.exe https://app.pluralsight.com/library/"    ; [Alt+Shift+1] Pluralsight
!+2:: Run "msedge.exe https://www.linkedin.com/learning/"       ; [Alt+Shift+2] LinkedIn Learning
!+b:: Run "msedge.exe --new-window https://www.inoreader.com/starred"  ; [Alt+Shift+B] Inoreader Starred
!+t:: Run "msedge.exe https://twitter.com/home"                          ; [Alt+Shift+T] Twitter / X
!+4:: Run "msedge.exe https://z-library.sk/"                           ; [Alt+Shift+4] Z-Library
!+5:: Run "msedge.exe https://web.whatsapp.com/"         ; [Alt+Shift+5] WhatsApp Web
!+y:: Run "msedge.exe https://www.youtube.com/feed/subscriptions"     ; [Alt+Shift+Y] YouTube Subscriptions
!+o:: Run "msedge.exe https://learning.oreilly.com/home/"              ; [Alt+Shift+O] O'Reilly Learning
!+e:: Run "msedge.exe https://learning.oreilly.com/live-events/?page=1"  ; [Alt+Shift+E] O'Reilly Live Events
!+a:: Run "firefox.exe https://claude.ai/ https://gemini.google.com/app"  ; [Alt+Shift+A] Claude + Gemini
!+k:: Run "msedge.exe https://www.amazon.co.uk"                        ; [Alt+Shift+K] Amazon UK
!+f:: Run "https://fast.com/"                                           ; [Alt+Shift+F] Fast.com Speed Test
!+i:: Run "msedge.exe https://www.google.com/intl/ta/inputtools/try/"  ; [Alt+Shift+I] Google Input Tools (Tamil)
!+r:: Run "msedge.exe https://app.raindrop.io/my/0"                    ; [Alt+Shift+R] Raindrop Bookmarks
!+s:: Run "slack://open"                                ; [Alt+Shift+S] Slack Protocol

#w:: Run "shell:AppsFolder\50bd8ba7-f030-4295-8e11-9dc6407431d4"  ; [Win+W] Google Gemini Desktop App
#z:: Run "claude://"                                    ; [Win+Z] Claude Desktop App

; --- Specialized Browser Combinations ---

^+y:: Run "brave.exe --new-window https://www.youtube.com/feed/subscriptions/"  ; [Ctrl+Shift+Y] YouTube in Brave
^!y:: Run "chrome.exe --incognito https://www.youtube.com"              ; [Ctrl+Alt+Y] YouTube Incognito (Chrome)
^!m:: Run "msedge.exe https://www.google.lk/maps"                      ; [Ctrl+Alt+M] Google Maps
^!c:: Run "msedge.exe https://calendar.google.com/calendar/u/0/r/year?pli=1"  ; [Ctrl+Alt+C] Google Calendar (Year View)

#d:: Run "C:\Users\dal\Downloads"                               ; [Win+D] Downloads Folder
#e:: Run "C:\ElementLogic"                                      ; [Win+E] ElementLogic Folder
#g:: Run "G:\"                                                  ; [Win+G] G:\ Drive
#s:: Run "C:\Bala\Sandbox"                                      ; [Win+S] Sandbox Folder
#b:: Run "C:\Bala\e-Books"                                      ; [Win+B] Books Folder
+#r:: Run "C:\Bala\Recordings"                                  ; [Win+Shift+R] Recordings Folder
!+d:: Run "C:\Users\dal\OneDrive\e-Books"                       ; [Alt+Shift+K] OneDrive e-Books Folder

; --- Open selected folder in VSCode (new window) ---
#c:: OpenVsCode() ; [Win+C] Open focused Explorer item in VSCode (new window)

OpenVsCode() {
    explorerHwnd := WinActive("A")
    if !explorerHwnd
        return

    explorerClass := WinGetClass("ahk_id " explorerHwnd)
    if (explorerClass != "CabinetWClass" && explorerClass != "ExploreWClass") {
        MsgBox "Activate a File Explorer window first."
        return
    }

    try {
        selectedPath := ""
        for window in ComObject("Shell.Application").Windows() {
            if window.hwnd = explorerHwnd {
                ; Prefer selected item; if none is selected, use current folder.
                for item in window.Document.SelectedItems {
                    selectedPath := item.Path
                    break
                }
                if (selectedPath = "")
                    selectedPath := window.Document.Folder.Self.Path
                break
            }
        }

        if (selectedPath = "") {
            MsgBox "No folder path found from the active Explorer window."
            return
        }

        targetPath := selectedPath
        if !InStr(FileExist(targetPath), "D")
            SplitPath targetPath, , &targetPath

        if (targetPath = "") {
            MsgBox "Could not determine a folder to open in VS Code."
            return
        }

        codeExe := GetVsCodeExePath()
        if (codeExe = "") {
            MsgBox "VS Code executable not found. Install VS Code or enable the 'code' command in PATH."
            return
        }

        Run('"' . codeExe . '" --new-window "' . targetPath . '"')
    } catch as err {
        MsgBox "Could not open folder in VSCode: " err.Message
    }
}

GetVsCodeExePath() {
    localAppData := EnvGet("LOCALAPPDATA")
    programFiles := EnvGet("ProgramFiles")
    programFilesX86 := EnvGet("ProgramFiles(x86)")

    candidates := [
        localAppData "\Programs\Microsoft VS Code\Code.exe",
        programFiles "\Microsoft VS Code\Code.exe",
        programFilesX86 "\Microsoft VS Code\Code.exe",
        localAppData "\Programs\Microsoft VS Code Insiders\Code - Insiders.exe",
        programFiles "\Microsoft VS Code Insiders\Code - Insiders.exe",
        programFilesX86 "\Microsoft VS Code Insiders\Code - Insiders.exe"
    ]

    for , path in candidates {
        if (path != "" && FileExist(path))
            return path
    }

    for , appPathKey in [
        "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Code.exe",
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Code.exe",
        "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Code - Insiders.exe",
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Code - Insiders.exe"
    ] {
        try {
            exePath := RegRead(appPathKey)
            if (exePath != "" && FileExist(exePath))
                return exePath
        }
    }

    return ""
}

; --- Open Links List (Reads text file and opens all URLs) ---
^!e::  ; [Ctrl+Alt+E] Open all URLs from links.txt in Edge
{
    try {
        ; Get the script's directory and build path to links.txt
        linksPath := A_ScriptDir "\links.txt"

        if FileExist(linksPath) {
            fileContent := FileRead(linksPath)
            ; Replace newlines with spaces to pass as arguments
            cleanLinks := StrReplace(fileContent, "`r`n", " ")
            cleanLinks := StrReplace(cleanLinks, "`n", " ")
            Run "msedge.exe --new-window " cleanLinks
        } else {
            MsgBox "links.txt not found at: " linksPath
        }
    } catch as err {
        MsgBox "Error: " err.Message
    }
}

; --- Reload All AutoHotkey Scripts ---
^!s:: ReloadAHKScriptsInCurrentFolder()                                ; [Ctrl+Alt+S] Reload all AHK scripts in current folder

ReloadAHKScriptsInCurrentFolder() {
    thisScriptPath := StrLower(A_ScriptFullPath)

    ; Restart sibling scripts first, then reload this script last.
    loop files A_ScriptDir "\*.ahk", "F" {
        targetPath := StrLower(A_LoopFileFullPath)
        if (targetPath = thisScriptPath)
            continue

        Run('"' . A_AhkPath . '" /restart "' . A_LoopFileFullPath . '"')
    }

    Reload
}

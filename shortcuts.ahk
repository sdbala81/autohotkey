; -------------------------------------------------------------------------
; GNOME to Windows Shortcut Migration
; -------------------------------------------------------------------------
; # = Windows Key (Super)  |  ! = Alt  |  + = Shift  |  ^ = Control
; -------------------------------------------------------------------------

#Requires AutoHotkey v2.0
SetWorkingDir A_InitialWorkingDir

; --- Learning & Web (<Alt><Shift>) ---

!+1:: Run "msedge.exe https://app.pluralsight.com/library/"
!+2:: Run "msedge.exe https://www.linkedin.com/learning/"
!+b:: Run "msedge.exe --new-window https://www.inoreader.com/starred"
!+t:: Run "msedge.exe https://twitter.com/home"
!+4:: Run "msedge.exe https://z-library.sk/"
!+5:: Run "msedge.exe https://web.whatsapp.com/"         ; WhatsApp Web
!+y:: Run "msedge.exe https://www.youtube.com/feed/subscriptions"
!+o:: Run "msedge.exe https://learning.oreilly.com/home/"
!+e:: Run "msedge.exe https://learning.oreilly.com/live-events/?page=1"
!+a:: Run "firefox.exe https://claude.ai/ https://gemini.google.com/app"
!+k:: Run "msedge.exe https://www.amazon.co.uk"
!+f:: Run "https://fast.com/"
!+i:: Run "msedge.exe https://www.google.com/intl/ta/inputtools/try/"
!+r:: Run "msedge.exe https://app.raindrop.io/my/0"
!+s:: Run "slack://open"                                ; Slack Protocol

; --- Specialized Browser Combinations ---

^+y:: Run "brave.exe --new-window https://www.youtube.com/feed/subscriptions/"
^!y:: Run "chrome.exe --incognito https://www.youtube.com"
^!m:: Run "msedge.exe https://www.google.lk/maps"
^!c:: Run "msedge.exe https://calendar.google.com/calendar/u/0/r/year?pli=1"

#d:: Run "C:\Users\dal\Downloads"                               ; Downloads Folder
#e:: Run "\\wsl.localhost\Ubuntu-24.04\home\bala\ElementLogic"                                      ; ElementLogic Folder
+#s:: Run "C:\Bala\Sandbox"                                      ; Sandbox Folder
+#r:: Run "C:\Bala\Recordings"                                   ; Recordings Folder

; --- Open Links List (Reads text file and opens all URLs) ---
^!e::
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

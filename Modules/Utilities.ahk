global LogBox := ""

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;region UTILITIES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ListToStr(list) {
    str := ""
    for item in list {
        str .= item ", "
    }
    return SubStr(str, 1, -2)
}

Log(message) {
    if (message = "")
        return

    global LogBox
    if (LogBox) {
        timestamp := FormatTime(, "HH:mm:ss")
        LogBox.Value .= "[" timestamp "] " message "`r`n"
        SendMessage(0x115, 7, 0, LogBox)
    }
}

WinEventHook(eventMin, eventMax, pfnWinEventProc) {
    return DllCall("SetWinEventHook", "UInt", eventMin, "UInt", eventMax, "Ptr", 0, "Ptr", CallbackCreate(pfnWinEventProc, "F", 7), "UInt", 0, "UInt", 0, "UInt", 0)
}

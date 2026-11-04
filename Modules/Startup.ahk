requestAdmin() {
	if !A_IsAdmin {
		try {
			Run('*RunAs ' A_ScriptFullPath)
			ExitApp
		} catch {
			MsgBox("This script requires administrator privileges to run. Please allow it to restart with elevated permissions.", "Admin Privileges Required")
			Sleep(2000)
			requestAdmin()
		}
	}
}

requestAdmin()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;region STARTUP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Build()

for browserExe in ["firefox.exe", "chrome.exe", "msedge.exe", "brave.exe", "opera.exe", "opera_gx.exe", "vivaldi.exe"]
	GroupAdd("TabCycleApps", "ahk_exe " browserExe)

^!Backspace:: ExitApp()
F10:: {
	Send "{RCtrl down}{RShift down}{F10}{RShift up}{RCtrl up}"
	Log("F10 Custom Hotkey Executed")
}
F11:: {
	Send "{RCtrl down}{RShift down}{F11}{RShift up}{RCtrl up}"
	Log("F11 Custom Hotkey Executed")
}
F12:: {
	Send "{RCtrl down}{RShift down}{F12}{RShift up}{RCtrl up}"
	Log("F12 Custom Hotkey Executed")
}

lastDown := 0
lastUp := 0
fakeVar := 50

*$LButton:: {
	global lastDown, lastUp
	now := A_TickCount
	lastDown := now

	if (now - lastUp < fakeVar) {
		Log("[DupClick] Ignored input. (" now - lastUp "ms, " lastUp - now "ms)")
		SoundBeep(250, 10)
		return
	}

	SendInput("{Blind}{LButton Down}")
}

*$LButton up:: {
	global lastUp, lastDown
	now := A_TickCount
	lastUp := now

	Sleep(fakeVar)
	SendInput("{Blind}{LButton Up}")
}

#HotIf !WinActive("ahk_exe cs2.exe") && WinActive("ahk_group TabCycleApps")
{
	XButton2:: SendInput("{LCtrl down}{Tab}{LCtrl up}")
}
#HotIf !WinActive("ahk_exe cs2.exe")
{
	XButton2:: Send "{Alt down}{Tab}"
	XButton2 up:: Send "{Alt up}"
	#C:: MyGui.Show()
	#Tab:: ChangeVirtualDesktop(-1)
}

try {
	regPath := "HKCU\Keyboard Layout\Toggle"
	RegWrite("3", "REG_SZ", regPath, "Language Hotkey")
	RegWrite("3", "REG_SZ", regPath, "Layout Hotkey")
	RegWrite("3", "REG_SZ", regPath, "Hotkey")
	Log("Disabled Ctrl+Shift keyboard layout switching hotkeys.")
} catch as e {
	Log("Failed to disable keyboard layout hotkeys: " e.Message)
}

try {
	regPath := "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot"
	RegCreateKey(regPath)
	RegWrite(1, "REG_DWORD", regPath, "TurnOffWindowsCopilot")
	Log("Disabled Copilot function hotkeys")
} catch as e {
	Log("Failed to disable Windows Copilot: " e.Message)
}

CheckMonitor()
OnMessage(0x007E, CheckMonitor)

RunningProcess()
SetTimer(RunningProcess, 5000)

DefaultPlan()
WinEventHook(0x0003, 0x0003, FocusedProcess)

Log("-------- v2GUI started. --------")

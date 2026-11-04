;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;region POWER PLANS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

power_settings := {
	Silent: {
		GHelper: "F16",
		powerplan: "a1841308-3541-4fab-bc81-f71556f20b4a"
	},
	Balanced: {
		GHelper: "F17",
		powerplan: "381b4222-f694-41f0-9685-ff5bb260df2e"
	},
	Turbo: {
		GHelper: "F18",
		powerplan: "e9a42b02-d5df-448d-aa00-03f14749eb61"
	}
}

currentPlanID := ""

_changeGHelperPlan(planID) {
	Send("{LWin Up}")
	Send("^+!{" power_settings.%planID%.GHelper "}")
	Log("[Power Plan] " planID)
}

_listPowerPlans() {
	shell := ComObject("WScript.Shell")
	exec := shell.Exec(A_ComSpec ' /c powercfg /list')
	output := exec.StdOut.ReadAll()
	Log("[Power Plan] Available plans:`n" output)
}

_changePowerPlan(planID) {
	RunWait('powercfg /s ' power_settings.%planID%.powerplan, , "Hide")
	Log("[Power Plan] " planID)
}

ChangePowerPlan(planID) {
	global currentPlanID
	if (planID = currentPlanID)
		return
	currentPlanID := planID

	if A_ComputerName = "DESKTOP-HPI5745" {
		_changePowerPlan(planID)
	} else if A_ComputerName = "DESKTOP-ZB14OLE" {
		_changeGHelperPlan(planID)
	}
}

PlanSilent(*) {
	return ChangePowerPlan("Silent")
}

PlanBalanced(*) {
	return ChangePowerPlan("Balanced")
}

PlanTurbo(*) {
	return ChangePowerPlan("Turbo")
}

DefaultPlan(*) {
	return PlanTurbo()
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;region DISPLAY / RESOLUTION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ChangeResolution(Screen_Width := 1920, Screen_Height := 1080, RefreshRate := 0, Color_Depth := 32, Orientation := "") {
	Log(
		"[Resolution] " Screen_Width "x" Screen_Height
		" @ " RefreshRate "Hz"
		", " Color_Depth "bit"
		(Orientation ? " (" Orientation ")" : "")
	)
	Device_Mode := Buffer(156, 0)
	NumPut("UShort", 156, Device_Mode, 36)
	DllCall("EnumDisplaySettingsA", "UInt", 0, "UInt", -1, "Ptr", Device_Mode)
	flags := 0x5c0000
	if (RefreshRate) {
		flags |= 0x400000
		NumPut("UInt", RefreshRate, Device_Mode, 120)
	}
	if (Orientation != "") {
		flags |= 0x00000080
		orientVal := 0
		switch Orientation {
			case "landscape":         orientVal := 0
			case "portrait":          orientVal := 1
			case "landscape_flipped": orientVal := 2
			case "portrait_flipped":  orientVal := 3
			default: orientVal := 0
		}
		NumPut("UInt", orientVal, Device_Mode, 72)
	}
	NumPut("UInt", flags, Device_Mode, 40)
	NumPut("UInt", Color_Depth, Device_Mode, 104)
	NumPut("UInt", Screen_Width, Device_Mode, 108)
	NumPut("UInt", Screen_Height, Device_Mode, 112)
	return DllCall("ChangeDisplaySettingsA", "Ptr", Device_Mode, "UInt", 0)
}

FHD(*) {
	ret := ChangeResolution(1920, 1080)
	MyGui.Hide()
	return ret
}

QHD(*) {
	ret := ChangeResolution(2560, 1440)
	MyGui.Hide()
	return ret
}

UHD(*) {
	ret := ChangeResolution(3840, 2160)
	MyGui.Hide()
	return ret
}

Res1080(*) {
	ret := ChangeResolution(1440, 1080)
	MyGui.Hide()
	return ret
}

Res1440(*) {
	ret := ChangeResolution(1920, 1440)
	MyGui.Hide()
	return ret
}

Res2048(*) {
	ret := ChangeResolution(2560, 2048)
	MyGui.Hide()
	return ret
}

Res2160(*) {
	ret := ChangeResolution(2880, 2160)
	MyGui.Hide()
	return ret
}

Res1800p(*) {
	ret := ChangeResolution(2880, 1800)
	MyGui.Hide()
	return ret
}

DefaultResolution(*) {
	if (A_ComputerName = "DESKTOP-HPI5745") {
		return UHD()
	} else if (A_ComputerName = "DESKTOP-ZB14OLE") {
		global currentMonitor
		return (currentMonitor = "\\.\DISPLAY1") ? Res1800p() : UHD()
	}
}

ShowScreenInfo(*) {
	screenName := MonitorGetName()
	screenWidth := SysGet(78)
	screenHeight := SysGet(79)
	screenBitDepth := SysGet(80)
	Log("Screen: " screenName " | Resolution: " screenWidth "x" screenHeight " | " screenBitDepth "bit")
	return [screenName, screenWidth, screenHeight, screenBitDepth]
}

ShowWindowInfo(*) {
	MyGui.Hide()
	windowTitle := WinGetTitle("A")
	applicationPath := WinGetProcessPath("A")
	Log("Window: " windowTitle " | Path: " applicationPath)
	MyGui.Show()
	return [windowTitle, applicationPath]
}

GetWindowHovered() {
	MouseGetPos(, , &hwnd)
	return WinGetProcessName(hwnd)
}

ShowHoveredInfo(*) {
	MyGui.Hide()
	Log("Hovered Window: " GetWindowHovered())
	MyGui.Show()
}

LogScreenInfo(*) {
	screenName := MonitorGetName(0)
	screenWidth := SysGet(78)
	screenHeight := SysGet(79)
	Log("Screen: " screenName " | Resolution: " screenWidth "x" screenHeight)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;region MONITOR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

monitor_settings := Map(
	"DESKTOP-ZB14OLE", {
		primary: {wallpaper: "C:\Windows\Web\Screen\img102.jpg", taskbar: True},
		secondary: {wallpaper: "C:\Windows\Web\Wallpaper\ThemeC\img28.jpg", taskbar: False}
	},
	"DESKTOP-HPI5745", {
		primary: {wallpaper: "C:\Windows\Web\Wallpaper\Theme1\img4.jpg", taskbar: False},
		secondary: {wallpaper: "C:\Windows\Web\Wallpaper\Theme1\img3.jpg", taskbar: False}
	}
)

currentMonitor := ""

CheckMonitor(*) {
	_SetWallpaper(path) {
		DllCall("SystemParametersInfo", "UInt", 0x14, "UInt", 0, "Str", path, "UInt", 1)
	}

	_HideShowTaskbar(hide) {
		static ABM_SETSTATE := 0xA, ABS_AUTOHIDE := 0x1, ABS_ALWAYSONTOP := 0x2
		APPBARDATA := Buffer(size := 2 * A_PtrSize + 2 * 4 + 16 + A_PtrSize, 0)
		NumPut("UInt", size, APPBARDATA), NumPut("Ptr", WinExist("ahk_class Shell_TrayWnd"), APPBARDATA, A_PtrSize)
		NumPut("UInt", hide ? ABS_AUTOHIDE : ABS_ALWAYSONTOP, APPBARDATA, size - A_PtrSize)
		DllCall("Shell32\SHAppBarMessage", "UInt", ABM_SETSTATE, "Ptr", APPBARDATA)
		return hide
	}

	global currentMonitor
	newMonitor := MonitorGetName(0)
	if newMonitor != currentMonitor {
		currentMonitor := newMonitor
		Log("[Monitor] " currentMonitor)

		if (currentMonitor = "\\.\DISPLAY1") {
			_HideShowTaskbar(monitor_settings[A_ComputerName].primary.taskbar)
			_SetWallpaper(monitor_settings[A_ComputerName].primary.wallpaper)
		} else {
			_HideShowTaskbar(monitor_settings[A_ComputerName].secondary.taskbar)
			_SetWallpaper(monitor_settings[A_ComputerName].secondary.wallpaper)
		}
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;region PROCESSES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TrackedProcs := Map(
	"cs2.exe", {resolution: Res1440, plan: PlanTurbo},
	"overwatch.exe", {resolution: QHD, plan: PlanTurbo},
	"satisfactory.exe", {resolution: QHD, plan: PlanTurbo},
	"FactoryGameSteam.exe", {resolution: QHD, plan: PlanTurbo},
	"shapez.exe", {resolution: QHD, plan: PlanTurbo},
	"javaw.exe", {resolution: FHD, plan: DefaultPlan},
	"Cursor.exe", {resolution: DefaultResolution, plan: DefaultPlan},
	"code.exe", {resolution: DefaultResolution, plan: DefaultPlan},
	"mstsc.exe", {resolution: Res1800p, plan: PlanSilent}
)

_GetRunningProcesses() {
	PROCESSENTRY32 := Buffer(568, 0)
	NumPut("UInt", PROCESSENTRY32.Size, PROCESSENTRY32, 0)

	snapshot := DllCall(
		"CreateToolhelp32Snapshot",
		"UInt", 0x00000002,
		"UInt", 0,
		"Ptr"
	)

	runningProcs := Map()

	if (snapshot = -1)
		return runningProcs

	if DllCall("Process32FirstW", "Ptr", snapshot, "Ptr", PROCESSENTRY32) {
		loop {
			name := StrGet(PROCESSENTRY32.Ptr + 44, "UTF-16")
			runningProcs[name] := true
		} until !DllCall("Process32NextW", "Ptr", snapshot, "Ptr", PROCESSENTRY32)
	}

	DllCall("CloseHandle", "Ptr", snapshot)
	return runningProcs
}

CurrentRunningProc := "undefined"
RunningProcess(*) {
	global CurrentRunningProc, TrackedProcs

	if !IsSet(TrackedProcs) || TrackedProcs.Count = 0
		return

	runningProcs := _GetRunningProcesses()

	topProc := "none"
	for procName in TrackedProcs {
		if runningProcs.Has(procName) {
			topProc := procName
			break
		}
	}

	if (topProc != CurrentRunningProc) {
		CurrentRunningProc := topProc
		Log("[RProcesses] " topProc)

		procSettings := TrackedProcs.Get(topProc, "")
		procSettings ? procSettings.resolution() : DefaultResolution()
	}
}

_GetFocusedProcess() {
	try {
		return WinGetProcessName("A")
	} catch {
		return "none"
	}
}

CurrentFocusedProc := "none"
FocusedProcess(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime) {
	global CurrentFocusedProc, TrackedProcs

	if !IsSet(TrackedProcs) || TrackedProcs.Count = 0
		return

	focusedProc := _GetFocusedProcess()

	topProc := "none"
	for procName in TrackedProcs {
		if (focusedProc = procName) {
			topProc := procName
			break
		}
	}

	if (topProc != CurrentFocusedProc) {
		CurrentFocusedProc := topProc
		Log("[FProcesses] " topProc)

		procSettings := TrackedProcs.Get(focusedProc, "")
		procSettings ? procSettings.plan() : DefaultPlan()
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;region NEXTCLOUD BACKUP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

StartNextcloudBackup(*) {
	backupScript := "D:\Nextcloud\2.Code\ahk\Scripts\Run-Backup.cmd"

	if !FileExist(backupScript) {
		MsgBox("Backup script not found:`n" backupScript,
			"Backup Error", "Iconx")
		return
	}

	MyGui.Hide()
	Run('"' backupScript '"')
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;region VIRTUAL DESKTOPS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

numDesktops := 2
vDesktop := numDesktops

ChangeVirtualDesktop(Direction) {
	global vDesktop
	vDesktop += Direction
	if (vDesktop > 0) {
		Log("Switching to next virtual desktop: " vDesktop)
		SendInput("^#{Right}")
	} else {
		Log("Switching to first virtual desktop: " vDesktop)
		vDesktop := numDesktops
		SendInput("^#{Left " (numDesktops - 1) "}")
	}
}

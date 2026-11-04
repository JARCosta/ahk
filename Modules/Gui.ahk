global MyGui := ""

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;region USER INTERFACE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Build() {
	global MyGui, LogBox
	if (MyGui)
		MyGui.Destroy()
	MyGui := Gui()
	MyGui.Opt("+AlwaysOnTop -Caption +ToolWindow")
	MyGui.OnEvent("Escape", MyGui.Hide)

	Buttons := [
		[
			["Silent Plan", PlanSilent],
			["Balanced Plan", PlanBalanced],
			["Turbo Plan", PlanTurbo],
			[],
			["Roload", Rel],
			["Close", Close],
		],
		[
			[],
			[],
			["1800p`n16:10", Res1800p],
			[],
			[],
			["Backup", StartNextcloudBackup],
		],
		[
			["1080p`n4:3", Res1080],
			["1440p`n4:3", Res1440],
			["2160p`n4:3", Res2160],
			[],
			[],
			["Hovered Window", ShowHoveredInfo],
		],
		[
			["1080p", FHD],
			["1440p", QHD],
			["2160p", UHD],
			[],
			["Active Window", ShowWindowInfo],
			["Active Screen", ShowScreenInfo],
		],
	]

	BtnWidth := 75
	BtnHeight := 50
	BtnMargin := 10

	NumColumns := Buttons[1].Length
	NumRows := Buttons.Length
	LogWidth := NumColumns * BtnWidth + (NumColumns - 1) * BtnMargin
	LogHeight := NumRows * BtnHeight + (NumRows - 1) * BtnMargin

	for Line in Buttons {
		Position := "xm"
		Size := "w75 h50"
		for Item in Line {
			if (Item.Length == 0) {
				MyGui.Add("Text", Position " " Size, "")
				Position := "x+m"
			} else if (Item.Length == 1) {
				MyGui.Add("Text", Position " " Size, Item[1])
				Position := "x+m"
			} else if (Item.Length == 2) {
				MyGui.Add("Button", Position " " Size, Item[1]).OnEvent("click", Item[2])
				Position := "x+m"
			}
		}
	}

	MyGui.Add("Text", "xm w" LogWidth, "Log History:")
	LogBox := MyGui.Add("Edit", "xm w" LogWidth " h" LogHeight " ReadOnly -Wrap +HScroll +VScroll")
}

Rel(*) {
	Reload()
}

Close(*) {
	MyGui.Hide()
}

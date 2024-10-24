#Requires AutoHotkey v2.0
#NoTrayIcon
#Include "..\lib\RunAsAdmin.ahk"
#Include "..\lib\RunCmd.ahk"

runAsAdmin()

mkLinkUi := Gui()
mkLinkUi.Title := "mklink --cmd mklink ui"

linkType := "/D"

mkLinkUi.AddText("y19 x16 w30", "Link:")
linkEdit := mkLinkUi.AddEdit("y16 x66 w466")
linkEdit.OnEvent("Change", CmdChange)
linkButton := mkLinkUi.AddButton("vPickLinkFile y16 x550 w30", "•••")
linkButton.OnEvent("Click", SelectLink)
mkLinkUi.AddText("y49 x16 w30", "Target:")
targetEdit := mkLinkUi.AddEdit("y46 x66 w466")
targetEdit.OnEvent("Change", CmdChange)
targetButton := mkLinkUi.AddButton("vPickTargetFile y46 x550 w30", "•••")
targetButton.OnEvent("Click", SelectTarget)
mkLinkUi.AddText("y79 x16 w30", "CMD:")
cmdText := mkLinkUi.AddEdit("y99 x16 w580 h200 +Multi +HScroll +ReadOnly")
r1 := mkLinkUi.AddRadio("y320 x16", "File")
r2 := mkLinkUi.AddRadio("y320 x86 Checked", "Dir(/D)")
r3 := mkLinkUi.AddRadio("y320 x186", "HardFile(/H)")
r4 := mkLinkUi.AddRadio("y320 x306", "HardDir(/J)")
r1.OnEvent("Click", LinkTypeClick)
r2.OnEvent("Click", LinkTypeClick)
r3.OnEvent("Click", LinkTypeClick)
r4.OnEvent("Click", LinkTypeClick)

okButton := mkLinkUi.AddButton("y306 x500 w100 h36", "OK")
okButton.OnEvent("Click", OkEvent)

mkLinkUi.Show("w620 h360")

CmdChange()

CmdChange(*) {
    cmdText.Text := GetCmd()
}

GetCmd() {
    return "MKLINK " linkType " `"" linkEdit.Text "`" `"" targetEdit.Text "`""
}

OkEvent(*) {
    cmdText.Text := ""
    cmd := GetCmd()
    EditAppend(cmdText.Hwnd, cmd)
    RunCMD(A_Comspec " /c " cmd, , , CmdEvent)
}

CmdEvent(line, lineNum) {
    EditAppend(cmdText.Hwnd, line)
}

EditAppend(hEdit, Txt)
{
    Local Len := DllCall("User32\GetWindowTextLengthW", "ptr", hEdit)
    SendMessage(0xB1, Len, Len, hEdit)        ;  EM_SETSEL
    SendMessage(0xC2, 0, StrPtr(Txt), hEdit)  ;  EM_REPLACESEL
}

LinkTypeClick(GuiCtrlObj, Info) {
    global linkType
    if r1.Value {
        linkType := ""
    } else if r2.Value {
        linkType := "/D"
    } else if r3.Value {
        linkType := "/H"
    } else if r4.Value {
        linkType := "/J"
    }
    CmdChange()
}

SelectLink(*) {
    mkLinkUi.Opt("+OwnDialogs")
    dir := DirSelect()
    if dir {
        linkEdit.Text := dir
    }
    CmdChange()
}

SelectTarget(*) {
    mkLinkUi.Opt("+OwnDialogs")
    if linkType = "" || linkType = "/H" {
        f := FileSelect()
        if f {
            targetEdit.Text := f
        }
    } else {
        dir := DirSelect()
        targetEdit.Text := dir
    }
    CmdChange()
}
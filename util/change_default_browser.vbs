Set WshShell = WScript.CreateObject("WScript.Shell")
WshShell.Run "%windir%\system32\control.exe /name Microsoft.DefaultPrograms /page pageDefaultProgram"
WScript.Sleep 2000
WshShell.SendKeys "{TAB}"
WshShell.SendKeys "{TAB}"
WshShell.SendKeys "{TAB}"
WshShell.SendKeys "{TAB}"
WshShell.SendKeys "{TAB}"
WshShell.SendKeys " "
WshShell.SendKeys "{TAB}"
WshShell.SendKeys " "
WScript.Sleep 1000
WshShell.SendKeys "%{F4}"
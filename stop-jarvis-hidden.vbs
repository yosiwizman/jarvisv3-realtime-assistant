Set shell = CreateObject("WScript.Shell")

psScript = "C:\Users\yosiw\Desktop\JarvisV3\JarvisV3\stop-jarvis.ps1"
cmd = "powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File """ & psScript & """"

' 0 = hidden window, script returns immediately
title = "Stop Jarvis V3"
shell.Run cmd, 0, False

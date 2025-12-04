Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

projectRoot = "C:\Users\yosiw\Desktop\JarvisV3\JarvisV3"
psScript = projectRoot & "\run-jarvis.ps1"
envPath = projectRoot & "\.env"

If Not fso.FileExists(envPath) Then
    windowStyle = 1   ' First-time setup
Else
    windowStyle = 0   ' Fully hidden
End If

cmd = "powershell.exe -NoLogo -ExecutionPolicy Bypass -File """ & psScript & """"
shell.Run cmd, windowStyle, False

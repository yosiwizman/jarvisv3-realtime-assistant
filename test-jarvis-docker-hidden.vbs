Set s = CreateObject("WScript.Shell")
cmd = "powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File ""C:\Users\yosiw\Desktop\JarvisV3\JarvisV3\test-jarvis-docker.ps1"""
s.Run cmd, 0, False

echo off
set LOCALHOST=%COMPUTERNAME%
set KILL_CMD="C:\ANSYSI~1\ANSYSS~1\v241\fluent/ntbin/win64/winkill.exe"

start "tell.exe" /B "C:\ANSYSI~1\ANSYSS~1\v241\fluent\ntbin\win64\tell.exe" LAPTOP-BHS5PTN8 58308 CLEANUP_EXITING
timeout /t 1
"C:\ANSYSI~1\ANSYSS~1\v241\fluent\ntbin\win64\kill.exe" tell.exe
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 12104) 
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 25520) 
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 4324) 
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 12224) 
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 396) 
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 2916)
del "D:\HT Project Ansys\cleanup-fluent-LAPTOP-BHS5PTN8-396.bat"

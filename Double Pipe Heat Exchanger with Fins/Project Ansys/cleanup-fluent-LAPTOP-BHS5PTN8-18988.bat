echo off
set LOCALHOST=%COMPUTERNAME%
set KILL_CMD="C:\ANSYSI~1\ANSYSS~1\v241\fluent/ntbin/win64/winkill.exe"

start "tell.exe" /B "C:\ANSYSI~1\ANSYSS~1\v241\fluent\ntbin\win64\tell.exe" LAPTOP-BHS5PTN8 55389 CLEANUP_EXITING
timeout /t 1
"C:\ANSYSI~1\ANSYSS~1\v241\fluent\ntbin\win64\kill.exe" tell.exe
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 10716) 
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 8512) 
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 8036) 
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 16472) 
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 18988) 
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 25420)
del "D:\HT Project Ansys\cleanup-fluent-LAPTOP-BHS5PTN8-18988.bat"

echo off
set LOCALHOST=%COMPUTERNAME%
set KILL_CMD="C:\ANSYSI~1\ANSYSS~1\v241\fluent/ntbin/win64/winkill.exe"

start "tell.exe" /B "C:\ANSYSI~1\ANSYSS~1\v241\fluent\ntbin\win64\tell.exe" LAPTOP-BHS5PTN8 56617 CLEANUP_EXITING
timeout /t 1
"C:\ANSYSI~1\ANSYSS~1\v241\fluent\ntbin\win64\kill.exe" tell.exe
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 12024) 
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 23712) 
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 25012) 
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 19676) 
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 22728) 
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 14048)
del "D:\HT Project Ansys\cleanup-fluent-LAPTOP-BHS5PTN8-22728.bat"

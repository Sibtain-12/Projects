echo off
set LOCALHOST=%COMPUTERNAME%
set KILL_CMD="C:\ANSYSI~1\ANSYSS~1\v241\fluent/ntbin/win64/winkill.exe"

start "tell.exe" /B "C:\ANSYSI~1\ANSYSS~1\v241\fluent\ntbin\win64\tell.exe" LAPTOP-BHS5PTN8 53918 CLEANUP_EXITING
timeout /t 1
"C:\ANSYSI~1\ANSYSS~1\v241\fluent\ntbin\win64\kill.exe" tell.exe
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 26368) 
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 20440) 
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 27212) 
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 5168) 
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 15708) 
if /i "%LOCALHOST%"=="LAPTOP-BHS5PTN8" (%KILL_CMD% 10740)
del "D:\HT Project Ansys\cleanup-fluent-LAPTOP-BHS5PTN8-15708.bat"

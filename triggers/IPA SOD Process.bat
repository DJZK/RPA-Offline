@echo off
title IPA SOD Process

SETLOCAL EnableExtensions
set EXE=OpenRPA.exe
FOR /F %%x IN ('tasklist /NH /FI "IMAGENAME eq %EXE%"') DO IF NOT %%x == %EXE% (
  START OpenRPA.exe
  ECHO.
  ECHO.
  ECHO OpenRPA Application is not running.....
  ECHO.
  ECHO.
  ECHO Please wait until OpenRPA prompt finished loading........
  ECHO. 
  ECHO.
  ECHO If OpenRPA prompt is gone, you may now press any key to continue
  ECHO.
  ECHO.
  pause
  pause

)


powershell -command "Invoke-OpenRPA -Filename cd012c35-3f66-4d2b-aad5-c68c609618f2"
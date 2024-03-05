@echo off
title IPA EOD Process

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


powershell -command "@{'processCode'=1} | Invoke-OpenRPA -Filename fdbb798d-6184-45e0-8365-f4e369e54c3a"
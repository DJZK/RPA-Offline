 
@echo off
echo Requesting administrative privileges...
echo Please Wait . . .

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %*", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
) else (
    echo Running with administrative privileges...
)


:: Minimize the window
echo Set objShell = CreateObject("Shell.Application") > "%temp%\minimize.vbs"
echo objShell.MinimizeAll >> "%temp%\minimize.vbs"
cscript //nologo "%temp%\minimize.vbs"


title RPA OFFLINE

rmdir /S /Q "D:\pos_vb\terima\rpafiles"

set "folderpath=D:\pos_vb\terima\rpafiles"

if exist "%folderpath%" (
    goto :senddata
) else (
    goto :dLandextract
)


:dLandextract
set "destinationFolder=D:\pos_vb\terima\"
::set "downloadURL=http://10.103.85.5/DATAMASTER/MEXICO/installer/rpafiles.zip"
set "downloadURL=http://10.103.85.5/DATAMASTER/MEXICO/installer/rpafiles.zip"

powershell -Command "$webClient = New-Object Net.WebClient; try { $webClient.DownloadFile('%downloadURL%', '%destinationFolder%\rpafiles.zip'); Write-Host 'File downloaded successfully.' } catch { Write-Host 'Error downloading file. Please check your internet connection or the availability of the file.' }"

if not exist "%destinationFolder%\rpafiles.zip" (
    echo Python installer not found: rpafiles
    exit /b 1
    pause
)


powershell -Command "Expand-Archive -Path '%destinationFolder%\rpafiles.zip' -DestinationPath '%destinationFolder%' -Force"
del "D:\pos_vb\terima\rpafiles.zip"

echo Killing OpenRPA
taskkill /F /IM OpenRPA.exe
echo Copying files to OpenRPA


set "openrpaFolder=C:\Users\Server\Documents\OpenRPA\"

if not exist "%openrpaFolder%" (
    echo openrpa folder not found
    pause
    exit /b 1

)


xcopy D:\pos_vb\terima\rpafiles\* C:\Users\Server\Documents\OpenRPA\ /C /y
del "%userprofile%\Desktop\IPA****************"
xcopy "D:\pos_vb\terima\rpafiles\dns.exe" D:\pos_vb\terima\ /y
xcopy "D:\pos_vb\terima\rpafiles\IPA EOD Process.bat" C:\ /y
xcopy "D:\pos_vb\terima\rpafiles\IPA SOD Process.bat" C:\ /y
mklink "%userprofile%\Desktop\IPA EOD Process.lnk" "C:\IPA EOD Process.bat"
mklink "%userprofile%\Desktop\IPA SOD Process.lnk" "C:\IPA SOD Process.bat"
del "D:\pos_vb\terima\rpa.exe"
rmdir /S /Q "D:\pos_vb\terima\rpa"
C:\Users\Server\Documents\OpenRPA\DNS.exe
rem Define the path to your JSON file
set jsonFilePath="C:\Users\Server\Documents\OpenRPA\settings.json"
set COMPUTER_NAME=%COMPUTERNAME%
set LAST_FOUR_DIGITS=%COMPUTER_NAME:~-4%
echo %LAST_FOUR_DIGITS%

powershell -Command "(Get-Content '%jsonFilePath%') -replace 'ws://openflow.alfamart.ho', '' | Set-Content '%jsonFilePath%'"
powershell -Command "(Get-Content '%jsonFilePath%') -replace '\"username\": \"\"', '\"username\": \"%LAST_FOUR_DIGITS%\"' | Set-Content '%jsonFilePath%'"

CD "%USERPROFILE%\AppData\Local\Programs\Python\Python37\Scripts\"
pip install "%~dp0\rpafiles\pre_reqs\pandas-1.1.5-cp37-cp37m-win_amd64.whl"
pip install "%~dp0\rpafiles\pre_reqs\psutil-5.9.4-cp36-abi3-win_amd64.whl"
pip install "%~dp0\rpafiles\pre_reqs\py_cpuinfo-9.0.0-py3-none-any.whl"
pip install "%~dp0\rpafiles\pre_reqs\SQLAlchemy-1.4.40-cp37-cp37m-win_amd64.whl"
pip install "%~dp0\rpafiles\pre_reqs\uiautomation-2.0.17-py3-none-any.whl"
pip install "%~dp0\rpafiles\pre_reqs\comtypes_fork-1.1.10-py3-none-any.whl"
pip install "%~dp0\rpafiles\pre_reqs\greenlet-2.0.2-cp37-cp37m-win_amd64.whl"
pip install "%~dp0\rpafiles\pre_reqs\numpy-1.21.6-cp37-cp37m-win_amd64.whl"
pip install "%~dp0\rpafiles\pre_reqs\pyodbc-4.0.35-cp37-cp37m-win_amd64.whl"
pip install "%~dp0\rpafiles\pre_reqs\python_dateutil-2.8.2-py2.py3-none-any.whl"
pip install "%~dp0\rpafiles\pre_reqs\pytz-2022.7.1-py2.py3-none-any.whl"
pip install "%~dp0\rpafiles\pre_reqs\setuptools-68.1.2-py3-none-any.whl"

py -m pip install -r "C:\Users\Server\Documents\OpenRPA\requirements.txt"

set COMPUTER_NAME=%COMPUTERNAME%

schtasks /CREATE /TN "UP_RUN_10AM" /TR "D:\pos_vb\terima\rpa_offline.exe" /SC daily /ST 12:00:00 /RU "%COMPUTER_NAME%\server" /RP "atp" /F
schtasks /CREATE /TN "UP_RUN_3PM" /TR "D:\pos_vb\terima\rpa_offline.exe" /SC daily /ST 15:00:00 /RU "%COMPUTER_NAME%\server" /RP "atp" /F
schtasks /CREATE /TN "UP_RUN_7PM" /TR "D:\pos_vb\terima\rpa_offline.exe" /SC daily /ST 17:00:00 /RU "%COMPUTER_NAME%\server" /RP "atp" /F

py "C:\Users\Server\Documents\OpenRPA\senddata.py"

"C:\Program Files\OpenRPA\OpenRPA.exe"

ping 8.8.8.8 -n 6 > nul

"C:\IPA SOD Process.bat"

set message="<html><head><style>h1 {font-size: 50px; color: white; text-align: center; background-color: red; padding: 20px;} p {font-size: 18px; text-align: center;} .warning {font-size: 90px; font-weight: bold; border: 3px solid black; padding: 10px;} .usage {font-size: 24px; font-style: italic;} .note {font-size: 18px; text-align: left; background-color: #f7f7f7; border-left: 5px solid #ff0000; padding: 10px; margin: 20px 0;} .note strong {font-weight: bold;} .instruction {font-size: 18px; margin-bottom: 20px;}</style></head><body><h1>IMPORTANT ANNOUNCEMENT</h1><p class='warning'>IPA SOD AND EOD <br> IS WORKING</p><p class='instruction'>Please use IPA SOD Process.bat and IPA EOD Process.bat found on your desktop</p><p class='usage'>IPA SOD - Use every start of the day</p><p class='usage'>IPA EOD - Use every end of the day</p><div class='note'><strong>Note:</strong><br>Kung matagal po yung Invoking na lumalabas, please restart po ang server and try again.<br>Kung matagal parin, please file a helpdesk to IT.</div></body></html>"
set notepad_file=C:\Users\Server\Documents\OpenRPA\important_announcement.html

echo %message% > %notepad_file%
start %notepad_file%


echo RPA offile mode installed
pause
exit /b 1




:senddata
py "C:\Users\Server\Documents\OpenRPA\senddata.py"

set message="<html><head><style>h1 {font-size: 50px; color: white; text-align: center; background-color: red; padding: 20px;} p {font-size: 18px; text-align: center;} .warning {font-size: 90px; font-weight: bold; border: 3px solid black; padding: 10px;} .usage {font-size: 24px; font-style: italic;} .note {font-size: 18px; text-align: left; background-color: #f7f7f7; border-left: 5px solid #ff0000; padding: 10px; margin: 20px 0;} .note strong {font-weight: bold;} .instruction {font-size: 18px; margin-bottom: 20px;}</style></head><body><h1>IMPORTANT ANNOUNCEMENT</h1><p class='warning'>IPA SOD AND EOD <br> IS WORKING</p><p class='instruction'>Please use IPA SOD Process.bat and IPA EOD Process.bat found on your desktop</p><p class='usage'>IPA SOD - Use every start of the day</p><p class='usage'>IPA EOD - Use every end of the day</p><div class='note'><strong>Note:</strong><br>Kung matagal po yung Invoking na lumalabas, please restart po ang server and try again.<br>Kung matagal parin, please file a helpdesk to IT.</div></body></html>"
set notepad_file=C:\Users\Server\Documents\OpenRPA\important_announcement.html

echo %message% > %notepad_file%
start %notepad_file%

echo RPA offile mode avialable
pause
exit /b 1

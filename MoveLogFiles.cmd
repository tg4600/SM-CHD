@ECHO OFF 

    cls
    set root=%CD%
    for %%* in (.) do set instance=%%~nx*
    E:
    cd %root%\
    set log=%root%\Logfile\SMPBACK_ALIVE.log


    net stop smpwcf%instance%               >> %log%
    net stop smptq%instance%                >> %log%
    sc stop smptq%instance%
    if %errorlevel%==0 goto :_CONT
    echo taskkill SampleManagerTimerQueueService  >> %log%
    taskkill /F /IM SampleManagerTimerQueueService.exe >> %log%
    :_CONT

    echo Services stopped >> %log%

:: Move all files in current folder 

    FOR /F "tokens=*" %%a in (MoveFolders.txt) DO CALL :_MoveFolder "%%a"
    echo Moving logfiles completed >> %log%

    net start smptq%instance%               >> %log%
    net start smpbatch%instance%_ch_commit1 >> %log%
    net start smpwcf%instance%              >> %log%
    echo Services started >> %log%

:: Copy all files in current folder 

    FOR /F "tokens=*" %%a in (CopyFolders.txt) DO CALL :_CopyFolder "%%a"
    echo Backup reports, etc. completed >> %log%
    

:: Backup tables for SAMPLE_PLAN
  
    @echo off
    if exist B:\ subst B: /D
    subst B: "E:\Thermo\SampleManager\Server\%instance%"

    set SMP="%root%\Exe\smp.exe"
    echo.
    %SMP% -instance %instance% -batch -report $table_saver SAMPLE_PLAN_ENTRY    B:\Logfile\SAMPLE_PLAN_ENTRY.csv    >> %log%
    echo.
    %SMP% -instance %instance% -batch -report $table_saver SAMPLE_PLAN_HEADER   B:\Logfile\SAMPLE_PLAN_HEADER.csv   >> %log%
    echo.
    %SMP% -instance %instance% -batch -report $table_saver SAMPLE_PLAN_MATRIX   B:\Logfile\SAMPLE_PLAN_MATRIX.csv   >> %log%
    echo.
    %SMP% -instance %instance% -batch -report $table_saver SAMPLE_PLAN_RULE     B:\Logfile\SAMPLE_PLAN_RULE.csv     >> %log%
    echo.
    echo Backup tables for SAMPLE_PLAN completed >> %log%

goto EOF

:_MoveFolder
    echo %1 >> %log%
    
    set Files=%~nx1
    if "%Files%"=="." set Files=*.*
    echo Move %Files% from %~dp1
    %~d1
    cd %~dp1
    FOR /F "tokens=*" %%F IN ('dir %1 /b') DO CALL :_MoveFile "%%F" 
    for /f "skip=32" %%i in ( ' dir "%~dp1backup\*." /b /a:d/o:-n ' ) do RD /s /q "%~dp1backup\%%i"
    E:
    cd "%root%\"

goto EOF

:_MoveFile 
    echo %1 >> %log%

    if "%~nx1"=="null" del null /Q
    if "%~nx1"=="null" goto :EOF
    if "%~x1"=="" goto :EOF
    if not exist "%~nx1" echo File not found "%~nx1" >> MoveLogFiles.log
    if not exist "%~nx1" goto _FileNotFound
    ECHO/Set fso=CreateObject("Scripting.FileSystemObject")>_TEMP.VBS 
    ECHO/Set f=fso.GetFile(%1)>>_TEMP.VBS 
    ECHO/dlm=f.DateLastModified>>_TEMP.VBS 
    ECHO/wscript.echo "SET DY=" ^& Right(100+Day(dlm),2)>>_TEMP.VBS 
    ECHO/wscript.echo "SET MO=" ^& Right(100+Month(dlm),2)>>_TEMP.VBS 
    ECHO/wscript.echo "SET YR=" ^& Right(Year(dlm),4)>>_TEMP.VBS 
    ECHO/wscript.echo "SET HR=" ^& Right(100+Hour(dlm),2)>>_TEMP.VBS 
    ECHO/wscript.echo "SET MI=" ^& Right(100+Minute(dlm),2)>>_TEMP.VBS 
    ECHO/wscript.echo "SET SC=" ^& Right(100+Second(dlm),2)>>_TEMP.VBS 
    cscript//nologo _TEMP.VBS>_TEMP.BAT 
    CALL _TEMP.BAT 
    DEL _TEMP.BAT 
    DEL _TEMP.VBS 

    if not exist "%~dp1backup\%YR%%MO%%DY%" md "%~dp1backup\%YR%%MO%%DY%"
    move %1 "%~dp1backup\%YR%%MO%%DY%" > null

goto :EOF

:_CopyFolder
    echo %1 >> %log%

    set Files=%~nx1
    if "%Files%"=="." set Files=*.*
    echo Copy %Files% from %~dp1
    %~d1
    cd %~dp1
    FOR /F "tokens=*" %%F IN ('dir %1 /b') DO CALL :_CopyFile "%%F" 
    if %computername%==DKLIMS04 for /f "skip=32" %%i in ( ' dir "%~dp1backup\*." /b /a:d/o:-n ' ) do RD /s /q "%~dp1%%i"
    E:
    cd "%root%\"

goto EOF

:_CopyFile 
    echo %1 >> %log%

    if "%~nx1"=="null" del null /Q
    if "%~nx1"=="null" goto :EOF
    if "%~x1"=="" goto :EOF
    if not exist "%~nx1" echo File not found "%~nx1" >> MoveLogFiles.log
    if not exist "%~nx1" goto _FileNotFound
    ECHO/Set fso=CreateObject("Scripting.FileSystemObject")>_TEMP.VBS 
    ECHO/Set f=fso.GetFile(%1)>>_TEMP.VBS 
    ECHO/dlm=f.DateLastModified>>_TEMP.VBS 
    ECHO/wscript.echo "SET DY=" ^& Right(100+Day(dlm),2)>>_TEMP.VBS 
    ECHO/wscript.echo "SET MO=" ^& Right(100+Month(dlm),2)>>_TEMP.VBS 
    ECHO/wscript.echo "SET YR=" ^& Right(Year(dlm),4)>>_TEMP.VBS 
    ECHO/wscript.echo "SET HR=" ^& Right(100+Hour(dlm),2)>>_TEMP.VBS 
    ECHO/wscript.echo "SET MI=" ^& Right(100+Minute(dlm),2)>>_TEMP.VBS 
    ECHO/wscript.echo "SET SC=" ^& Right(100+Second(dlm),2)>>_TEMP.VBS 
    cscript//nologo _TEMP.VBS>_TEMP.BAT 
    CALL _TEMP.BAT 
    DEL _TEMP.BAT 
    DEL _TEMP.VBS 

    if not exist "%~dp1backup\%YR%%MO%%DY%" md "%~dp1backup\%YR%%MO%%DY%"
    Copy %1 "%~dp1backup\%YR%%MO%%DY%" > null

goto :EOF


:_FileNotFound
    echo File not found "%~nx1" >> %log%

:IMLOG
    
    set A=%~dp1
    set A=%A:~61,30%

    ECHO/Set fso=CreateObject("Scripting.FileSystemObject")>_TEMP.VBS 
    ECHO/Set f=fso.GetFile(%1)>>_TEMP.VBS 
    ECHO/dlm=f.DateLastModified>>_TEMP.VBS 
    ECHO/wscript.echo "SET DY=" ^& Right(100+Day(dlm),2)>>_TEMP.VBS 
    ECHO/wscript.echo "SET MO=" ^& Right(100+Month(dlm),2)>>_TEMP.VBS 
    ECHO/wscript.echo "SET YR=" ^& Right(Year(dlm),4)>>_TEMP.VBS 
    ECHO/wscript.echo "SET HR=" ^& Right(100+Hour(dlm),2)>>_TEMP.VBS 
    ECHO/wscript.echo "SET MI=" ^& Right(100+Minute(dlm),2)>>_TEMP.VBS 
    ECHO/wscript.echo "SET SC=" ^& Right(100+Second(dlm),2)>>_TEMP.VBS 
    cscript//nologo _TEMP.VBS>_TEMP.BAT 
    CALL _TEMP.BAT 
    DEL _TEMP.BAT 
    DEL _TEMP.VBS 

    echo move %1 %T%"%A%"%YR%%MO%%DY%%HR%%MI%%SC%.imlog > null
    move %1 %T%"%A%"%YR%%MO%%DY%%HR%%MI%%SC%.imlog

goto :EOF

:ServerLog

    ECHO/Set fso=CreateObject("Scripting.FileSystemObject")>_TEMP.VBS 
    ECHO/Set f=fso.GetFile(%1)>>_TEMP.VBS 
    ECHO/dlm=f.DateLastModified>>_TEMP.VBS 
    ECHO/wscript.echo "SET DY=" ^& Right(100+Day(dlm),2)>>_TEMP.VBS 
    ECHO/wscript.echo "SET MO=" ^& Right(100+Month(dlm),2)>>_TEMP.VBS 
    ECHO/wscript.echo "SET YR=" ^& Right(Year(dlm),4)>>_TEMP.VBS 
    ECHO/wscript.echo "SET HR=" ^& Right(100+Hour(dlm),2)>>_TEMP.VBS 
    ECHO/wscript.echo "SET MI=" ^& Right(100+Minute(dlm),2)>>_TEMP.VBS 
    ECHO/wscript.echo "SET SC=" ^& Right(100+Second(dlm),2)>>_TEMP.VBS 
    cscript//nologo _TEMP.VBS>_TEMP.BAT 
    CALL _TEMP.BAT 
    DEL _TEMP.BAT 
    DEL _TEMP.VBS 

    echo move %1 %T%\%YR%%MO%%DY%%HH%%MI%%SC%.imlog > null
    move %1 %T%\%YR%%MO%%DY%%HH%%MI%%SC%.imlog

goto :EOF

:EOF {End-of-file} 
    if exist null del null /Q
    cd "%root%\"
    @echo off

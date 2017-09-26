@echo off
echo.
echo Compiling all reports in %cd%
echo.

for %%i in (*.rpf) do set fname=%%i & call :rename
echo.

goto :eof
:rename
echo %fname%             > Compile_All.log
..\exe\compiler %fname% >> Compile_All.log

:eof

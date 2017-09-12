rem compile_all_in_dir
@echo off
for %%i in (*.rpf) do set fname=%%i & call :rename
echo.
pause

goto :eof
:rename
echo %fname%			 >> Compile_All.log
..\exe\compiler %fname%  >> Compile_All.log

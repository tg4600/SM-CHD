@echo off
if exist Compile.log del Compile.log
for %%i in (*.rpf) do ( echo.
		        echo %%i
		        ..\exe\compiler -instance VGSM11PROD %%~ni >> Compile.log )
pause
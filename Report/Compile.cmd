@echo off
del ..\Code\%1.* /q			 > compile.log
..\Exe\compiler.exe - instance VGSM11PROD %1.rpf      	>> compile.log
type compile.log
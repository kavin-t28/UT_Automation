@echo off
set MATLABROOT=c:\Program Files\MATLAB\R2019b\bin
path=%MATLABROOT%;%PATH%

set CURRENT_DIR=%cd%
set FILENAME=%~n0
set BASE_DIR=%~dp0

cd /D %BASE_DIR%

if not exist build\NUL mkdir build

@echo on
start /WAIT matlab.exe -batch -wait addpath('mbd/common/Scom');ScomFunction_addPath();ScomFunction_build() -logfile ./build/%FILENAME%.log

@echo off
if %errorlevel% equ 0 ( echo PASSED: No issues. ) else ( echo FAILED: Unexpected Returnvalue: %errorlevel%. )
echo Logfile of matlab.exe output: ./build/%FILENAME%.log
echo DONE

cd /D %CURRENT_DIR%

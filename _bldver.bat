@Echo Off

set CurPath=%~dp0

set PrjName=%1
shift

if "%1" neq "" (
  set ArcName=%1
  shift
) else (
  set ArcName=%PrjName%
)

rem if not exist "%PrjName%.dpr" (
rem   Echo Project not found: %PrjName%.dpr
rem   Exit
rem )

if not exist "build.h" (
  Echo Version not found: build.h
  Exit
)

set VerMax=1
rem set VerMin=14
for /f "tokens=2*" %%i in ('type build.h') do (set VerMin=%%j)

set Arc=%CurPath%Arc\%ArcName%
if not exist %Arc% md %Arc%


rem if not exist "%Arc%\%PrjName%.2.v%VerMin%.rar" goto NotExist
rem Echo.
rem Echo Build %PrjName% ver %VerMin% already exist
rem set /P Ans="Rebuild (y/n)? "
rem if /i "%Ans%" NEQ "y" exit
rem Echo.
rem :NotExist


if not exist "%Arc%\Ver.%VerMin%" goto NotExist
Echo.
Echo Build %PrjName% ver %VerMin% already exist
set /P Ans="Rebuild (y/n)? "
if /i "%Ans%" NEQ "y" exit
Echo.
:NotExist


rem echo.
rem echo %PrjName% ver %VerMin% for Far2
rem echo.
rem 
rem call dcc.bat
rem 
rem pushd ..\Bin2\%PrjName% || exit
rem rar a -r -s -x*.map %ArcName%.far2.%VerMax%.%VerMin%.rar *.* > nul || exit
rem move *.rar %Arc% || exit
rem popd
rem 
rem 
rem echo.
rem echo %PrjName% ver %VerMin% Far2 x64
rem echo.
rem 
rem call fpc64.bat
rem 
rem pushd ..\Bin2x64\%PrjName% || exit
rem rar a -r -s -x*.map %ArcName%.far2.x64.%VerMax%.%VerMin%.rar *.* > nul || exit
rem move *.rar %Arc% || exit
rem popd


echo.
echo %PrjName% ver %VerMin% Far3
echo.

call bld.bat

pushd ..\Bin3\%PrjName% || exit
rar a -r -s -x*.map %ArcName%.far3.%VerMax%.%VerMin%.rar *.* > nul || exit
move *.rar %Arc% || exit
popd


echo.
echo %PrjName% ver %VerMin% Far3 x64
echo.

call bld.bat 64

pushd ..\Bin3x64\%PrjName% || exit
rar a -r -s -x*.map %ArcName%.far3.x64.%VerMax%.%VerMin%.rar *.* > nul || exit
move *.rar %Arc% || exit
popd

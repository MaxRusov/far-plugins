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

if not exist "%PrjName%.dpr" (
  Echo Project not found: %PrjName%.dpr
  Exit
)

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


echo %PrjName% ver %VerMin% for Far2
echo.

call dcc.bat

pushd ..\Bin\%PrjName% || exit
rar a -r -s -x*.map %ArcName%.far2.%VerMax%.%VerMin%.rar *.* > nul || exit
move *.rar %Arc% || exit
popd


echo.
echo %PrjName% ver %VerMin% Far2 x64
echo.

call fpc64.bat

pushd ..\Bin_64\%PrjName% || exit
rar a -r -s -x*.map %ArcName%.far2.x64.%VerMax%.%VerMin%.rar *.* > nul || exit
move *.rar %Arc% || exit
popd


echo.
echo %PrjName% ver %VerMin% Far3
echo.

call dcc.bat Far3

pushd ..\Bin3\%PrjName% || exit
rar a -r -s -x*.map %ArcName%.far3.%VerMax%.%VerMin%.rar *.* > nul || exit
move *.rar %Arc% || exit
popd


echo.
echo %PrjName% ver %VerMin% Far3 x64
echo.

call fpc64.bat Far3

pushd ..\Bin3x64\%PrjName% || exit
rar a -r -s -x*.map %ArcName%.far3.x64.%VerMax%.%VerMin%.rar *.* > nul || exit
move *.rar %Arc% || exit
popd

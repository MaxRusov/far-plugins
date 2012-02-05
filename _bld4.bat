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

rem set Version=14
for /f "tokens=2*" %%i in ('type build.h') do (set Version=%%j)

set Arc=%CurPath%Arc\%ArcName%
if not exist %Arc% md %Arc%


rem if not exist "%Arc%\%PrjName%.2.v%Version%.rar" goto NotExist
rem Echo.
rem Echo Build %PrjName% ver %Version% already exist
rem set /P Ans="Rebuild (y/n)? "
rem if /i "%Ans%" NEQ "y" exit
rem Echo.
rem :NotExist


if not exist "%Arc%\Ver.%Version%" goto NotExist
Echo.
Echo Build %PrjName% ver %Version% already exist
set /P Ans="Rebuild (y/n)? "
if /i "%Ans%" NEQ "y" exit
Echo.
:NotExist


echo %PrjName% ver %Version% for Far2
echo.

call dcc.bat

pushd ..\Bin\%PrjName% || exit
rar a -r -s -x*.map %ArcName%.2.v%Version%.rar *.* > nul || exit
move *.rar %Arc% || exit
popd


echo.
echo %PrjName% ver %Version% Far2 x64
echo.

call fpc64.bat

pushd ..\Bin_64\%PrjName% || exit
rar a -r -s -x*.map %ArcName%.2.x64.v%Version%.rar *.* > nul || exit
move *.rar %Arc% || exit
popd


echo.
echo %PrjName% ver %Version% Far3
echo.

call dcc.bat Far3

pushd ..\Bin3\%PrjName% || exit
rar a -r -s -x*.map %ArcName%.3.v%Version%.rar *.* > nul || exit
move *.rar %Arc% || exit
popd


echo.
echo %PrjName% ver %Version% Far3 x64
echo.

call fpc64.bat Far3

pushd ..\Bin3x64\%PrjName% || exit
rar a -r -s -x*.map %ArcName%.3.x64.v%Version%.rar *.* > nul || exit
move *.rar %Arc% || exit
popd


set PrjName=%1
shift

if /i "%1" == "64" (
  set Platform=x64
  set Platform1=x64
  set Compiler=ppcrossx64.exe
  shift
) else (
  set Platform=x32
  set Platform1=
  set Compiler=fpc.exe
)

if /i "%1" == "Far3" (
  set FarVer=3
  shift
) else (
  set FarVer=2
)

set Bin=Bin%FarVer%%Platform1%
rem set Units=Units%Platform1%
if "%Platform%" == "x64" (
  set Units=Units64
) else (
  set Units=Units
)

if exist ..\MixLib (
  set Root=..
) else (
  set Root=..\..
)

if "%BinFolder%" == "" (
  set Dest=%Root%\%Bin%\%PrjName%
) else (
  set Dest=%Root%\%Bin%\%BinFolder%
)

if not exist %Root%\%Units%\%PrjName% md %Root%\%Units%\%PrjName%
if not exist %Dest% md %Dest%

set ResDef=-DFar%FarVer% -D%Platform%
if exist %PrjName%.rc windres %ResDef% -i %PrjName%.rc  -o %PrjName%.RES || exit
if exist %PrjName%A.rc windres %ResDef% -i %PrjName%A.rc  -o %PrjName%A.RES || exit
if exist %PrjName%W.rc windres %ResDef% -i %PrjName%W.rc  -o %PrjName%W.RES || exit

%Compiler% -B -FE%Dest% -dFar%FarVer% %PrjName%.dpr %1 %2 %3 %4 %5 %6 %7 %8 %9 || exit

if exist Doc copy Doc\* %Dest% >nul
if exist DocW copy DocW\* %Dest% >nul

if exist Doc%FarVer% copy Doc%FarVer%\* %Dest% >nul

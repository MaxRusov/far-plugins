
set PrjName=%1
shift

if /i "%1" == "64" (
  set Platform=x64
  set Platform1=x64
  set Compiler=dcc64.exe
  shift
) else (
  set Platform=x32
  set Platform1=
  set Compiler=dcc32.exe
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

if exist %PrjName%.cfg del %PrjName%.cfg

if not exist %Root%\%Units%\%PrjName% md %Root%\%Units%\%PrjName%
if not exist %Dest% md %Dest%

set ResDef=-dFar%FarVer% -d%Platform%
if exist %PrjName%.rc brcc32 %ResDef% %PrjName%.rc || exit
if exist %PrjName%A.rc brcc32 %ResDef% %PrjName%A.rc || exit
if exist %PrjName%W.rc brcc32 %ResDef% %PrjName%W.rc || exit

%Compiler% -B -E%Dest% -dFar%FarVer% %PrjName%.dpr %1 %2 %3 %4 %5 %6 %7 %8 %9 || exit

if exist Doc copy Doc\* %Dest% >nul
if exist DocW copy DocW\* %Dest% >nul

if exist Doc%FarVer% copy Doc%FarVer%\* %Dest% >nul


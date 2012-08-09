
set PrjName=%1
shift

if /i "%1" == "64" (
  set Platform=x64
  set Compiler=
  shift
) else (
  set Platform=x32
  set Compiler=dcc32.exe
)

if /i "%1" == "Far3" (
  if "%Platform%" == "x32" (
    set Bin=Bin3
  ) else (
    set Bin=Bin3x64
  )
  set DefVer=-dFar3
  set FarVer=3
  shift
) else (
  if "%Platform%" == "x32" (
    set Bin=Bin
  ) else (
    set Bin=Bin_64
  )
  set DefVer=
  set FarVer=2
)

if "%Platform%" == "x32" (
  set Units=Units
) else (
  set Units=Units64
)

if exist ..\MixLib (
  set Root=..
) else (
  set Root=..\..
)


if exist %PrjName%.cfg del %PrjName%.cfg

if not exist %Root%\%Units%\%PrjName% md %Root%\%Units%\%PrjName%
if not exist %Root%\%Bin%\%PrjName% md %Root%\%Bin%\%PrjName%

set ResDef=-dFar%FarVer% -d%Platform%
if exist %PrjName%.rc brcc32 %ResDef% %PrjName%.rc || exit
if exist %PrjName%A.rc brcc32 %ResDef% %PrjName%A.rc || exit
if exist %PrjName%W.rc brcc32 %ResDef% %PrjName%W.rc || exit

%Compiler% -B -E%Root%\%Bin%\%PrjName% %DefVer% %PrjName%.dpr %1 %2 %3 %4 %5 %6 %7 %8 %9 || exit

if exist Doc copy Doc\* %Root%\%Bin%\%PrjName% >nul
if exist DocW copy DocW\* %Root%\%Bin%\%PrjName% >nul

if exist Doc%FarVer% copy Doc%FarVer%\* %Root%\%Bin%\%PrjName% >nul


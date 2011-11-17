
set PrjName=%1
shift

if /i "%1" == "64" (
  set Platform=x64
  set Compiler=ppcrossx64.exe
  shift
) else (
  set Platform=x32
  set Compiler=fpc.exe
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



if not exist ..\%Units%\%PrjName% md ..\%Units%\%PrjName%
if not exist ..\%Bin%\%PrjName% md ..\%Bin%\%PrjName%

set ResDef=-DFar%FarVer% -D%Platform%
if exist %PrjName%.rc windres %ResDef% -i %PrjName%.rc  -o %PrjName%.RES || exit
if exist %PrjName%A.rc windres %ResDef% -i %PrjName%A.rc  -o %PrjName%A.RES || exit
if exist %PrjName%W.rc windres %ResDef% -i %PrjName%W.rc  -o %PrjName%W.RES || exit

%Compiler% -B -FE..\%Bin%\%PrjName% %DefVer% %PrjName%.dpr %1 %2 %3 %4 %5 %6 %7 %8 %9 || exit

if exist Doc copy Doc\* ..\%Bin%\%PrjName% >nul
if exist DocW copy DocW\* ..\%Bin%\%PrjName% >nul

if exist Doc%FarVer% copy Doc%FarVer%\* ..\%Bin%\%PrjName% >nul

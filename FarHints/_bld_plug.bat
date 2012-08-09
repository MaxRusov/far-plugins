@Echo Off

set Compiler=%1
shift
set Plugin=%1
shift
set FileName=%1
shift


if /i "%Compiler%" == "fpc64" (
  set Platform=x64
) else (
  set Platform=x32
)

if /i "%1" == "Far3" (
  if "%Platform%" == "x32" (
    set Bin=Bin3
  ) else (
    set Bin=Bin3x64
  )
  Shift
) else (
  if "%Platform%" == "x32" (
    set Bin=Bin
  ) else (
    set Bin=Bin_64
  )
)

if "%Platform%" == "x32" (
  set Units=Units
) else (
  set Units=Units64
)


Echo Compile %Plugin%

cd %FileName% || Exit

Set BinPath=..\..\%Bin%\FarHints\Plugins\%Plugin%
Set DcuPath=..\..\%Units%\FarHints\%Plugin%

if not exist "%BinPath%" md %BinPath%
if not exist "%DcuPath%" md %DcuPath%

if /i "%Compiler%"=="dcc" (
  if exist FarHints*.cfg del FarHints*.cfg
  if exist "%DcuPath%\*.dcu" del %DcuPath%\*.dcu
  brcc32 %FileName%.rc || exit
  dcc32.exe -B -E%BinPath% %FileName%.dpr %1 %2 %3 || exit
) 

if /i "%Compiler%"=="fpc" (
  windres -i %FileName%.rc -o %FileName%.RES || exit
  fpc.exe -B -FE%BinPath% %FileName%.dpr %1 %2 %3 || exit
)

if /i "%Compiler%"=="fpc64" (
  windres -i %FileName%.rc -o %FileName%.RES || exit
  ppcrossx64.exe -B -FE%BinPath% %FileName%.dpr %1 %2 %3 || exit
)

if exist "Doc\*" copy Doc\* %BinPath%

cd ..

@Echo Off

Echo Compile %2

cd %3 || Exit

if /i "%1"=="fpc64" (
  Set BinPath=..\..\Bin_64\FarHints\Plugins\%2
  Set DcuPath=..\..\Units64\FarHints\%2
) else (
  Set BinPath=..\..\Bin\FarHints\Plugins\%2
  Set DcuPath=..\..\Units\FarHints\%2
)

if not exist "%BinPath%" md %BinPath%
if not exist "%DcuPath%" md %DcuPath%

if /i "%1"=="dcc" (
  if exist FarHints*.cfg del FarHints*.cfg
  if exist "%DcuPath%\*.dcu" del %DcuPath%\*.dcu
  brcc32 %3.rc || exit
  dcc32.exe -B %3.dpr %4 %5 %6 || exit
) 

if /i "%1"=="fpc" (
  windres -i %3.rc -o %3.RES || exit
  fpc.exe -B -FE%BinPath% %3.dpr %4 %5 %6 || exit
)

if /i "%1"=="fpc64" (
  windres -i %3.rc -o %3.RES || exit
  ppcrossx64.exe -B -FE%BinPath% %3.dpr %4 %5 %6 || exit
)

if exist "Doc\*" copy Doc\* %BinPath%

cd ..

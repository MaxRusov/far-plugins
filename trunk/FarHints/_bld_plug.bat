@Echo Off

set CompilerType=%1
shift
set Plugin=%1
shift
set FileName=%1
shift

if /i "%1" == "64" (
  set Platform=x64
  set Platform1=x64
  if /i "%CompilerType%"=="dcc" (
    set Compiler=dcc64.exe
  ) else (
    set Compiler=ppcrossx64.exe
  )
  shift
) else (
  set Platform=x32
  set Platform1=
  if /i "%CompilerType%"=="dcc" (
    set Compiler=dcc32.exe
  ) else (
    set Compiler=fpc.exe
  )
)

if /i "%1" == "Far3" (
  set FarVer=3
  shift
) else (
  set FarVer=2
)

Set BinPath=..\..\Bin%FarVer%%Platform1%\FarHints\Plugins\%Plugin%
set DcuPath=..\..\xUnits\%CompilerType%%Platform%\FarHints\%Plugin%

Echo Compile %Plugin% %1 %2 %3

cd %FileName% || Exit

if not exist "%BinPath%" md %BinPath%
if not exist "%DcuPath%" md %DcuPath%

if /i "%CompilerType%"=="dcc" (
  if exist FarHints*.cfg del FarHints*.cfg
  if exist "%DcuPath%\*.dcu" del %DcuPath%\*.dcu
  brcc32 %FileName%.rc || exit
  %compiler% -B -N%DcuPath% -E%BinPath% %FileName%.dpr %1 %2 %3 || exit
) else (
  windres -i %FileName%.rc -o %FileName%.RES || exit
  %compiler% -B -FU%DcuPath% -FE%BinPath% %FileName%.dpr %1 %2 %3 || exit
)

if exist "Doc\*" copy Doc\* %BinPath%

cd ..

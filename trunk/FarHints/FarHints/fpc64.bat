@Echo off

if /i "%1" == "Far3" (
  echo Not supported
  goto :EOF
)

Set BinPath=..\..\Bin_64\FarHints
Set DcuPath=..\..\Units64\FarHints\FarHints

if not exist "%BinPath%" md %BinPath%
if not exist "%DcuPath%" md %DcuPath%

windres -i FarHintsA.rc  -o FarHintsA.RES || exit
windres -i FarHintsW.rc  -o FarHintsW.RES || exit

ppcrossx64.exe -B -FE%BinPath% FarHints.dpr %* || exit

copy Doc\* %BinPath%
if /i "%1"=="-dansi" (copy DocA\* %BinPath%) else (copy DocW\* %BinPath%)
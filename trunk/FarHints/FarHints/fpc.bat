@Echo off

Set BinPath=..\..\Bin\FarHints
Set DcuPath=..\..\Units\FarHints\FarHints

if not exist "%BinPath%" md %BinPath%
if not exist "%DcuPath%" md %DcuPath%

windres -i FarHintsA.rc  -o FarHintsA.RES || exit
windres -i FarHintsW.rc  -o FarHintsW.RES || exit

fpc.exe -B FarHints.dpr %* || exit

copy Doc\* %BinPath%
if /i "%1"=="-dansi" (copy DocA\* %BinPath%) else (copy DocW\* %BinPath%)
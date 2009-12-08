@Echo off

Set BinPath=..\..\Bin\FarHints
Set DcuPath=..\..\Units\FarHints\FarHints

if not exist "%BinPath%" md %BinPath%
if not exist "%DcuPath%" md %DcuPath%
if exist FarHints.cfg del FarHints.cfg

brcc32 FarHintsA.rc || exit
brcc32 FarHintsW.rc || exit

dcc32.exe -B FarHints.dpr %* || exit

copy Doc\* %BinPath%
if /i "%1"=="-dunicode" (copy DocW\* %BinPath%)

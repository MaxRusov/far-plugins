@Echo off

Set BinPath=..\..\Bin\FarHints
Set DcuPath=..\..\Units\FarHints\FarHints

if not exist "%BinPath%" md %BinPath%
if not exist "%DcuPath%" md %DcuPath%

fpc.exe -B FarHints.dpr %* || exit

copy Doc\* %BinPath%
if /i "%1"=="-dunicode" (copy DocW\* %BinPath%)

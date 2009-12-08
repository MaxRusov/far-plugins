@Echo off

Set BinPath=..\..\Bin64\FarHints
Set DcuPath=..\..\Units64\FarHints\FarHints

if not exist "%BinPath%" md %BinPath%
if not exist "%DcuPath%" md %DcuPath%

ppcrossx64.exe -B FarHints.dpr %* || exit

copy Doc\* %BinPath%
if /i "%1"=="-dunicode" (copy DocW\* %BinPath%)

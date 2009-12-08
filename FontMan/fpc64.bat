@Echo off

Set BinPath=..\Bin64\FontMan
Set DcuPath=..\Units64\FontMan

if not exist "%BinPath%" md %BinPath%
if not exist "%DcuPath%" md %DcuPath%

ppcrossx64.exe -B FontMan.dpr %* || exit

copy Doc\* %BinPath%
if /i "%1"=="-dunicode" (copy DocW\* %BinPath%)

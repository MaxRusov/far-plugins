@Echo off

Set BinPath=..\Bin64\FontMan
Set DcuPath=..\Units64\FontMan

if not exist "%BinPath%" md %BinPath%
if not exist "%DcuPath%" md %DcuPath%

windres -i FontManA.rc -o FontManA.RES || exit
windres -i FontManW.rc -o FontManW.RES || exit

ppcrossx64.exe -B FontMan.dpr %* || exit

copy Doc\* %BinPath%
if /i "%1"=="-dunicode" (copy DocW\* %BinPath%)

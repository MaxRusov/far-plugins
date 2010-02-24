@Echo off

Set BinPath=..\Bin\FontMan
Set DcuPath=..\Units\FontMan

if not exist "%BinPath%" md %BinPath%
if not exist "%DcuPath%" md %DcuPath%

windres -i FontManA.rc -o FontManA.RES || exit
windres -i FontManW.rc -o FontManW.RES || exit

fpc.exe -B FontMan.dpr %* || exit

copy Doc\* %BinPath%
if /i "%1"=="-dunicode" (copy DocW\* %BinPath%)

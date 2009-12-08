@Echo off

Set BinPath=..\Bin\FontMan
Set DcuPath=..\Units\FontMan

if not exist "%BinPath%" md %BinPath%
if not exist "%DcuPath%" md %DcuPath%
if exist FontMan.cfg del FontMan.cfg

brcc32 FontManA.rc || exit
brcc32 FontManW.rc || exit

dcc32.exe -B FontMan.dpr %* || exit

copy Doc\* %BinPath%
if /i "%1"=="-dunicode" (copy DocW\* %BinPath%)

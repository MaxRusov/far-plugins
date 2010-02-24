@Echo off

if not exist ..\Units\PlugMenu md ..\Units\PlugMenu
if not exist ..\Bin\PlugMenu md ..\Bin\PlugMenu

windres -i PlugMenuA.rc  -o PlugMenuA.RES || exit
windres -i PlugMenuW.rc  -o PlugMenuW.RES || exit

fpc.exe -B PlugMenu.dpr %* || exit

copy Doc\* ..\Bin\PlugMenu
if /i "%1"=="-dunicode" copy DocW\* ..\Bin\PlugMenu

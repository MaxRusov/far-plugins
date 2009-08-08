@Echo off

if not exist ..\Units\PlugMenu md ..\Units\PlugMenu
if not exist ..\Bin\PlugMenu md ..\Bin\PlugMenu

if exist PlugMenu.cfg del PlugMenu.cfg

brcc32 PlugMenuA.rc || exit
brcc32 PlugMenuW.rc || exit

dcc32.exe -B PlugMenu.dpr %* || exit

copy Doc\* ..\Bin\PlugMenu
if /i "%1"=="-dunicode" copy DocW\* ..\Bin\PlugMenu

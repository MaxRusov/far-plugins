@Echo off

if not exist ..\Units\PlugMenu md ..\Units\PlugMenu
if not exist ..\Bin\PlugMenu md ..\Bin\PlugMenu

fpc.exe -B PlugMenu.dpr %* || exit

copy Doc\* ..\Bin\PlugMenu
if /i "%1"=="-dunicode" copy DocW\* ..\Bin\PlugMenu

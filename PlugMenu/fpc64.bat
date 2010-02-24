@Echo off

if not exist ..\Units64\PlugMenu md ..\Units64\PlugMenu
if not exist ..\Bin64\PlugMenu md ..\Bin64\PlugMenu

windres -i PlugMenuA.rc  -o PlugMenuA.RES || exit
windres -i PlugMenuW.rc  -o PlugMenuW.RES || exit

ppcrossx64.exe -B PlugMenu.dpr %* || exit

copy Doc\* ..\Bin64\PlugMenu
if /i "%1"=="-dunicode" copy DocW\* ..\Bin64\PlugMenu

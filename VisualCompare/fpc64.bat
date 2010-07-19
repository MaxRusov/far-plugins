@Echo off

if not exist ..\Units64\VisualCompare md ..\Units64\VisualCompare
if not exist ..\Bin64\VisualCompare md ..\Bin64\VisualCompare

windres -i VisCompW.rc  -o VisCompW.RES || exit

ppcrossx64.exe -B VisComp.dpr %* || exit

copy Doc\* ..\Bin64\VisualCompare


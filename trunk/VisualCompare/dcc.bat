@Echo off

if not exist ..\Units\VisualCompare md ..\Units\VisualCompare
if not exist ..\Bin\VisualCompare md ..\Bin\VisualCompare

if exist VisualCompare.cfg del VisualCompare.cfg

brcc32 VisCompA.rc || exit
brcc32 VisCompW.rc || exit

dcc32.exe -B VisComp.dpr %* || exit

copy Doc\* ..\Bin\VisualCompare
if /i "%1"=="-dunicode" copy DocW\* ..\Bin\VisualCompare

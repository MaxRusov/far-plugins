@Echo off

if not exist ..\Units\FarDebug md ..\Units\FarDebug
if not exist ..\Bin\FarDebug md ..\Bin\FarDebug
if exist FarDebug.cfg del FarDebug.cfg

brcc32 FarDebugA.rc || exit
brcc32 FarDebugW.rc || exit

dcc32.exe -B FarDebug.dpr %* || exit

copy Doc\* ..\Bin\FarDebug
if /i "%1"=="-dunicode" copy DocW\* ..\Bin\FarDebug



@Echo off

if not exist ..\Units\FarDebug md ..\Units\FarDebug
if not exist ..\Bin\FarDebug md ..\Bin\FarDebug

windres -i FarDebugA.rc  -o FarDebugA.RES || exit
windres -i FarDebugW.rc  -o FarDebugW.RES || exit

fpc.exe -B FarDebug.dpr %* || exit

copy Doc\* ..\Bin\FarDebug
if /i "%1"=="-dunicode" copy DocW\* ..\Bin\FarDebug

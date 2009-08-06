@Echo off

if not exist ..\Units\FarDebug md ..\Units\FarDebug
if not exist ..\Bin\FarDebug md ..\Bin\FarDebug

fpc.exe -B FarDebug.dpr %* || exit

copy Doc\* ..\Bin\FarDebug
if /i "%1"=="-dunicode" copy DocW\* ..\Bin\FarDebug

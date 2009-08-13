@Echo off

if not exist ..\Units64\FarDebug md ..\Units64\FarDebug
if not exist ..\Bin64\FarDebug md ..\Bin64\FarDebug

ppcrossx64.exe -B FarDebug.dpr %* || exit

copy Doc\* ..\Bin64\FarDebug
if /i "%1"=="-dunicode" copy DocW\* ..\Bin64\FarDebug

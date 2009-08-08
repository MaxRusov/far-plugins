@Echo off

if not exist ..\Units\UCharMap md ..\Units\UCharMap
if not exist ..\Bin\UCharMap md ..\Bin\UCharMap

fpc.exe -B UCharMap.dpr %* || exit

copy Doc\* ..\Bin\UCharMap
rem if /i "%1"=="-dunicode" copy DocW\* ..\Bin\UCharMap

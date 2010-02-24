@Echo off

if not exist ..\Units64\UCharMap md ..\Units64\UCharMap
if not exist ..\Bin64\UCharMap md ..\Bin64\UCharMap

windres -i UCharMapW.rc -o UCharMapW.RES || exit

ppcrossx64.exe -B UCharMap.dpr %* || exit

copy Doc\* ..\Bin64\UCharMap
rem if /i "%1"=="-dunicode" copy DocW\* ..\Bin64\UCharMap

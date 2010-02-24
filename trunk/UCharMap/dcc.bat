@Echo off

if not exist ..\Units\UCharMap md ..\Units\UCharMap
if not exist ..\Bin\UCharMap md ..\Bin\UCharMap
if exist UCharMap.cfg del UCharMap.cfg

brcc32 UCharMapW.rc || exit

dcc32.exe -B UCharMap.dpr %* || exit

copy Doc\* ..\Bin\UCharMap
rem if /i "%1"=="-dunicode" (copy DocW\* ..\Bin\UCharMap) 

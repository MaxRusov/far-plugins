@Echo off

if not exist ..\Units64\SameFolder md ..\Units64\SameFolder
if not exist ..\Bin64\SameFolder md ..\Bin64\SameFolder

windres -i SameFolder.rc  -o SameFolder.RES || exit

ppcrossx64.exe -B SameFolder.dpr %* || exit

copy Doc\* ..\Bin64\SameFolder


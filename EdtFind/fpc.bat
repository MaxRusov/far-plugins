@Echo off

if not exist ..\Units\EdtFind md ..\Units\EdtFind
if not exist ..\Bin\EdtFind md ..\Bin\EdtFind

windres -i EdtFindW.rc  -o EdtFindW.RES || exit

fpc.exe -B EdtFind.dpr %* || exit

copy Doc\* ..\Bin\EdtFind


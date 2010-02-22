@Echo off

if not exist ..\Units\EdtFind md ..\Units\EdtFind
if not exist ..\Bin\EdtFind md ..\Bin\EdtFind

rem windres -i EdtFindW.rc  -o EdtFindW.res || exit

fpc.exe -B EdtFind.dpr %* || exit

copy Doc\* ..\Bin\EdtFind


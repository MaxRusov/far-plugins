@Echo off

if not exist ..\Units64\EdtFind md ..\Units64\EdtFind
if not exist ..\Bin64\EdtFind md ..\Bin64\EdtFind

rem windres -i EdtFindW.rc  -o EdtFindW.res || exit

ppcrossx64.exe -B EdtFind.dpr %* || exit

copy Doc\* ..\Bin64\EdtFind


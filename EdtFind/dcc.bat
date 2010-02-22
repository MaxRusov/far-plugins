@Echo off

if not exist ..\Units\EdtFind md ..\Units\EdtFind
if not exist ..\Bin\EdtFind md ..\Bin\EdtFind
if exist EdtFind.cfg del EdtFind.cfg

rem brcc32 EdtFindA.rc || exit
brcc32 EdtFindW.rc || exit

dcc32.exe -B EdtFind.dpr %* || exit

copy Doc\* ..\Bin\EdtFind



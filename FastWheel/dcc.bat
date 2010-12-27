@Echo off

if not exist ..\Units\FastWheel md ..\Units\FastWheel
if not exist ..\Bin\FastWheel md ..\Bin\FastWheel
if exist FastWheel.cfg del FastWheel.cfg

brcc32 FastWheel.rc || exit

dcc32.exe -B FastWheel.dpr %* || exit

copy Doc\* ..\Bin\FastWheel

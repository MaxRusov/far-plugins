@Echo off

if not exist ..\Units64\FastWheel md ..\Units64\FastWheel
if not exist ..\Bin64\FastWheel md ..\Bin64\FastWheel

windres -i FastWheel.rc  -o FastWheel.RES || exit

ppcrossx64.exe -B FastWheel.dpr %* || exit

copy Doc\* ..\Bin64\FastWheel

